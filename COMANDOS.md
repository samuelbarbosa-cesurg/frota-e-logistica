# Comandos

## Com o rodar.sh

Permissão (uma vez):

```bash
chmod +x rodar.sh
```

| Comando | O que faz |
|---|---|
| `./rodar.sh up` | sobe o banco |
| `./rodar.sh 1` | roda `scripts/01_create.sql` (use 1 a 6) |
| `./rodar.sh tudo` | apaga o banco, sobe vazio e roda os scripts 01 a 06 |
| `./rodar.sh reset` | apaga tudo e sobe um banco vazio |
| `./rodar.sh psql` | abre o psql interativo |
| `./rodar.sh status` | mostra o estado do container |

## Comandos padrões

Subir o banco:

```bash
docker compose up -d
```

Recriar do zero:

```bash
docker compose down -v && docker compose up -d
```

Scripts:

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

psql interativo:

```bash
docker compose exec db psql -U frota -d frota_logistica
```
