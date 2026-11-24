CREATE TABLE cliente (
    id            SERIAL       PRIMARY KEY,
    nome          VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL,
    telefone      VARCHAR(15)  NOT NULL,
    logradouro    VARCHAR(50)  NOT NULL,
    cep           VARCHAR(9)   NOT NULL,
    bairro        VARCHAR(50)  NOT NULL,
    cidade        VARCHAR(50)  NOT NULL,
    estado_sigla  VARCHAR(2)   NOT NULL,
    pais          VARCHAR(50)  NOT NULL
);

CREATE TABLE veiculo (
    id             SERIAL      PRIMARY KEY,
    placa          VARCHAR(30) NOT NULL,
    modelo         VARCHAR(30) NOT NULL,
    capacidade     INTEGER     NOT NULL,
    quilometragem  INTEGER     NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'disponível',

    CONSTRAINT uq_veiculo_placa      UNIQUE (placa),
    CONSTRAINT chk_veiculo_capacidade CHECK (capacidade > 0),
    CONSTRAINT chk_veiculo_status     CHECK (status IN ('disponível', 'em viagem', 'em manutenção'))
);

CREATE TABLE motorista (
    id               SERIAL      PRIMARY KEY,
    nome             VARCHAR(50) NOT NULL,
    data_nascimento  DATE        NOT NULL,
    cnh_categoria    VARCHAR(10) NOT NULL,
    cnh_registro     VARCHAR(11) NOT NULL,
    cnh_validade     DATE        NOT NULL,

    CONSTRAINT uq_motorista_cnh_registro UNIQUE (cnh_registro),
    CONSTRAINT chk_motorista_categoria_cnh CHECK (cnh_categoria IN ('A', 'B', 'C', 'D', 'E'))
);

CREATE TABLE rota (
    id                 SERIAL        PRIMARY KEY,
    cidade_partida     VARCHAR(50)   NOT NULL,
    cidade_destino     VARCHAR(50)   NOT NULL,
    latitude_partida   NUMERIC(9, 6) NOT NULL,
    longitude_partida  NUMERIC(9, 6) NOT NULL,
    latitude_destino   NUMERIC(9, 6) NOT NULL,
    longitude_destino  NUMERIC(9, 6) NOT NULL
);

CREATE TABLE viagem (
    id            SERIAL    PRIMARY KEY,
    veiculo_id    INTEGER   NOT NULL,
    motorista_id  INTEGER   NOT NULL,
    rota_id       INTEGER   NOT NULL,
    data_saida    TIMESTAMP NOT NULL,
    data_entrega  TIMESTAMP,
    km_inicial    INTEGER   NOT NULL,
    km_final      INTEGER,

    CONSTRAINT fk_viagem_veiculo   FOREIGN KEY (veiculo_id)   REFERENCES veiculo (id)   ON DELETE RESTRICT,
    CONSTRAINT fk_viagem_motorista FOREIGN KEY (motorista_id) REFERENCES motorista (id) ON DELETE RESTRICT,
    CONSTRAINT fk_viagem_rota      FOREIGN KEY (rota_id)      REFERENCES rota (id)      ON DELETE RESTRICT,

    CONSTRAINT chk_viagem_km CHECK (km_final >= km_inicial),
    CONSTRAINT chk_viagem_datas CHECK (data_entrega IS NULL OR data_entrega >= data_saida)
);

CREATE TABLE entrega (
    id          SERIAL        PRIMARY KEY,
    viagem_id   INTEGER       NOT NULL,
    cliente_id  INTEGER       NOT NULL,
    peso_kg     NUMERIC(10,3) NOT NULL,
    prazo       DATE          NOT NULL,
    status      VARCHAR(30)   NOT NULL DEFAULT 'pendente',

    CONSTRAINT fk_entrega_viagem  FOREIGN KEY (viagem_id)  REFERENCES viagem (id)  ON DELETE RESTRICT,
    CONSTRAINT fk_entrega_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id) ON DELETE RESTRICT,

    CONSTRAINT chk_entrega_peso   CHECK (peso_kg > 0),
    CONSTRAINT chk_entrega_status CHECK (status IN ('pendente', 'em trânsito', 'entregue', 'devolvida'))
);

CREATE TABLE manutencao (
    id          SERIAL        PRIMARY KEY,
    veiculo_id  INTEGER       NOT NULL,
    km_veiculo  INTEGER       NOT NULL,
    data        DATE          NOT NULL,
    preco       NUMERIC(10,2) NOT NULL,
    detalhes    TEXT,

    CONSTRAINT fk_manutencao_veiculo FOREIGN KEY (veiculo_id) REFERENCES veiculo (id) ON DELETE RESTRICT,
    CONSTRAINT chk_manutencao_preco  CHECK (preco > 0)
);

CREATE TABLE abastecimento (
    id            SERIAL        PRIMARY KEY,
    veiculo_id    INTEGER       NOT NULL,
    motorista_id  INTEGER       NOT NULL,
    km_veiculo    INTEGER       NOT NULL,
    data          DATE          NOT NULL,
    litros        NUMERIC(8,2)  NOT NULL,
    preco         NUMERIC(10,2) NOT NULL,
    detalhes      TEXT,

    CONSTRAINT fk_abastecimento_veiculo   FOREIGN KEY (veiculo_id)   REFERENCES veiculo (id)   ON DELETE RESTRICT,
    CONSTRAINT fk_abastecimento_motorista FOREIGN KEY (motorista_id) REFERENCES motorista (id) ON DELETE RESTRICT,
    CONSTRAINT chk_abastecimento_litros CHECK (litros > 0),
    CONSTRAINT chk_abastecimento_preco  CHECK (preco > 0)
);
