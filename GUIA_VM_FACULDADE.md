# Guia: configurar o Docker na VM da faculdade

Passo a passo para repetir, no computador da faculdade, o ambiente que foi montado em casa:
**VirtualBox -> VM Ubuntu Server -> Docker -> repositório -> banco PostgreSQL**.

> Tudo é feito **dentro da VM**, sem SSH.
> Tempo estimado: 30 a 40 minutos (a maior parte é a instalação do Ubuntu).

---

## 0. O que levar / conferir antes

- [ ] O VirtualBox está instalado no computador da faculdade? (Se não estiver, peça ao professor ou instale em virtualbox.org.)
- [ ] O ISO do Ubuntu Server: `ubuntu-26.04.1-live-server-amd64.iso` (~2,5 GB). **Leve em um pendrive**, para não depender da internet da faculdade.
- [ ] Internet liberada para `github.com` e para os repositórios do Ubuntu (teste antes no navegador).
- [ ] A URL HTTPS do repositório no GitHub (botão verde **Code**):
  `https://github.com/SEU_USUARIO/NOME_DO_REPO.git`
- [ ] Usuário e senha que você vai usar na VM (anote em um lugar seguro, **fora** do repositório).

### Atalho: levar a VM pronta
Em vez de refazer tudo, dá para exportar a VM de casa e importar na faculdade:
- Em casa: VirtualBox -> **Arquivo -> Exportar Appliance** (gera um `.ova`, alguns GB; leve em pendrive).
- Na faculdade: **Arquivo -> Importar Appliance** e escolha o `.ova`.
- Depois pule para o **passo 6** (clonar/atualizar o repositório).

---

## 1. Criar a VM no VirtualBox

Clique em **Novo** e preencha:

| Campo | Valor |
|---|---|
| VM Name | `frota-logistica` |
| VM Folder | pasta padrão |
| ISO Image | o ISO do Ubuntu Server |
| OS / Distribution / Version | Linux / Ubuntu / Ubuntu (64-bit) |
| Proceed with Unattended Installation | marcado (veja o aviso abaixo) |

Na tela de instalação automática:

| Campo | Valor |
|---|---|
| User Name | `cesurg` (ou outro) |
| Senha | a sua (anote) |
| Host Name | `frota-logistica` (**sem underline `_`**, senão o campo fica vermelho) |
| Install Guest Additions | marcado |

Hardware:

| Item | Valor |
|---|---|
| Base Memory | **4096 MB** (2048 MB funciona) |
| CPUs | **2** |
| Disco | **25 GB** (novo disco virtual) |
| Use EFI | **desmarcado** |

Clique em **Concluir**.

> **Aviso (instalação automática):** como o ISO é recente, o VirtualBox pode não conseguir instalar sozinho.
> Se a VM travar ou mostrar erro do instalador, **apague a VM e recrie desmarcando "Proceed with Unattended Installation"**.
> Aí instale pelo instalador de texto do Ubuntu (aceite os padrões, crie o usuário e a senha).

---

## 2. Rede da VM

Confira em **Configurações -> Rede -> Adaptador 1**: **Habilitado** e **NAT**.
Isso dá internet para a VM. Como tudo será feito dentro dela, **não precisa** de redirecionamento de portas.

> Opcional: se quiser acessar o banco por um cliente do Windows (DBeaver, pgAdmin), em
> **Avançado -> Redirecionamento de portas** crie `postgres | TCP | host 5432 | convidado 5432`.

---

## 3. Instalar o Ubuntu

1. Selecione a VM e clique em **Iniciar**.
2. Aguarde a instalação (10 a 20 minutos). A VM reinicia sozinha no final.
3. Quando aparecer `login:`, entre com o usuário e a senha definidos no passo 1.

---

## 4. Instalar o Docker (dentro da VM)

```bash
sudo apt update && sudo apt install -y docker.io docker-compose-v2
```

Permitir usar o Docker sem `sudo`:

```bash
sudo usermod -aG docker $USER
```

**Saia e entre de novo na sessão** (digite `exit` e faça login outra vez). Sem isso o grupo `docker` não vale.

Teste:

```bash
docker run hello-world
```

```bash
docker compose version
```

Se aparecer **"Hello from Docker!"**, o Docker está pronto.

### Se der erro
| Erro | O que fazer |
|---|---|
| `Unable to locate package` | rode `sudo apt update` de novo; se continuar, a internet da VM está bloqueada ou o pacote mudou de nome (peça ajuda e mande a mensagem exata) |
| `permission denied ... docker.sock` | faltou sair e entrar na sessão depois do `usermod` (ou rode `newgrp docker`) |
| `Temporary failure resolving` | VM sem internet: confira o passo 2 e teste `ping -c 2 github.com` |

---

## 5. Instalar o Git (se não tiver)

```bash
git --version
```

Se der "command not found":

```bash
sudo apt install -y git
```

---

## 6. Clonar o repositório

```bash
git clone https://github.com/SEU_USUARIO/NOME_DO_REPO.git
```

```bash
cd NOME_DO_REPO
```

(Se a pasta já existir, por exemplo depois de importar a VM, use `git pull` dentro dela.)

---

## 7. Subir o banco PostgreSQL

```bash
docker compose up -d
```

```bash
docker compose ps
```

O container `frota_db` deve aparecer como **healthy** (pode levar alguns segundos).

Dados de conexão (definidos no `docker-compose.yml`):

| Item | Valor |
|---|---|
| Banco | `frota_logistica` |
| Usuário | `frota` |
| Senha | `frota123` |
| Porta | `5432` |
| Versão | PostgreSQL 16 |

Confirmar a versão (para o README do trabalho):

```bash
docker compose exec db psql -U frota -d frota_logistica -c "SELECT version();"
```

---

## 8. Rodar os scripts na ordem

A pasta `scripts/` do projeto fica visível dentro do container em `/scripts`. Rode **um de cada vez**, na ordem:

```bash
docker compose exec db psql -U frota -d frota_logistica -v ON_ERROR_STOP=1 -f /scripts/01_create.sql
```

```bash
docker compose exec db psql -U frota -d frota_logistica -v ON_ERROR_STOP=1 -f /scripts/02_insert.sql
```

```bash
docker compose exec db psql -U frota -d frota_logistica -a -f /scripts/03_select.sql
```

```bash
docker compose exec db psql -U frota -d frota_logistica -a -f /scripts/04_update.sql
```

```bash
docker compose exec db psql -U frota -d frota_logistica -a -f /scripts/05_delete.sql
```

```bash
docker compose exec db psql -U frota -d frota_logistica -a -f /scripts/06_restricoes.sql
```

- O `-a` mostra cada comando junto com o resultado (bom para o relatório).
- **Só o `06_restricoes.sql` deve gerar erros** (é o esperado).
- Para abrir o banco de forma interativa: `docker compose exec db psql -U frota -d frota_logistica` (sair com `\q`).

---

## 9. Recomeçar do zero (banco vazio)

Os scripts precisam funcionar em banco vazio. Para apagar tudo e testar de novo:

```bash
docker compose down -v
```

```bash
docker compose up -d
```

Depois repita o passo 8. **Faça esse teste completo antes da apresentação.**

---

## Dicas e cuidados

- **Copiar e colar na VM:** com o Guest Additions, ative em *Dispositivos -> Área de Transferência Compartilhada -> Bidirecional*. No terminal do Linux, cole com `Ctrl+Shift+V`.
- **Atualizar os arquivos:** edite no Windows, faça `git push`, e na VM rode `git pull`.
- **Não digite sua senha do GitHub** no computador da faculdade. O clone por HTTPS de repositório público não pede senha.
- **Desligar a VM:** `sudo poweroff`, ou *Máquina -> Fechar -> Desligar* no VirtualBox. Os dados do banco ficam salvos no volume `pgdata`.
- **Porta 5432 ocupada:** se der erro de porta em uso, algum PostgreSQL já roda na máquina. Pare-o ou troque `"5432:5432"` por `"5433:5432"` no `docker-compose.yml`.
- **Plano B:** se não conseguir rodar Docker na faculdade, o enunciado aceita PostgreSQL instalado direto; nesse caso o README precisa explicar como criar o banco e executar os scripts.

## Checklist rápido do dia

- [ ] VM criada (ou importada) e ligando
- [ ] `docker run hello-world` funciona
- [ ] Repositório clonado (ou `git pull` feito)
- [ ] `docker compose up -d` e container `healthy`
- [ ] Scripts `01` a `06` rodaram na ordem; só o `06` deu erro
- [ ] Testado do zero com `docker compose down -v`
