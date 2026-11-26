-- COMANDO:
INSERT INTO veiculo (placa, modelo, capacidade, quilometragem, status)
  VALUES ('RCZ1I99', 'Fiat Fiorino', 650, 40426, 'teste');
-- ERRO:
/*
psql:commands.sql:447: ERROR:  new row for relation "veiculo" violates check constraint "chk_veiculo_status"
DETAIL:  Failing row contains (31, RCZ1I99, Fiat Fiorino, 650, 40426, teste).
*/
-- EXPLICAÇÃO: Esse erro é causado porque a coluna "status" aceita somente os parâmetros 'disponível', 'em viagem' e 'em manutenção'
-- e ao tentar inserir um valor diferente desses o banco recusa por conta dessa regra.

-- COMANDO:
INSERT INTO abastecimento (veiculo_id, motorista_id, km_veiculo, data, litros, preco, detalhes)
  VALUES (15, 15, 241230, '2026-01-22', 0, 576.52, 'Abastecimento completo');
-- ERRO:
/*
psql:commands.sql:445: ERROR:  new row for relation "abastecimento" violates check constraint "chk_abastecimento_litros"
DETAIL:  Failing row contains (50, 15, 15, 241230, 2026-01-22, 0.00, 576.52, Abastecimento completo).
*/
-- EXPLICAÇÃO: Esse erro é causado porque estamos tentando inserir dado na tabela de abastecimento com o valor 0 para a coluna "litros",
-- mas essa coluna só permite inserir valores maiores que 0.


-- COMANDO:
INSERT INTO veiculo (placa, modelo, capacidade, quilometragem, status) VALUES
    ('RCZ1I99', 'Fiat Fiorino', 650, 40426, 'disponível');
-- ERRO:
/*
psql:commands.sql:445: ERROR:  duplicate key value violates unique constraint "uq_veiculo_placa"
DETAIL:  Key (placa)=(RCZ1I99) already exists.
*/
-- EXPLICAÇÃO: O banco recusou porque a coluna placa tem "UNIQUE", e ao tentar inserir um veículo com a mesma placa de um outro
-- veículo já cadastrado no banco causa esse erro.