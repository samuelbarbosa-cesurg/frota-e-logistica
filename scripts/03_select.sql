-- FILTRO E ORDENAÇÃO
-- Quais motoristas estão com a CNH vencida? Mostrando o nome, categoria e a validade, do que venceu há mais tempo até o que venceu por último.
SELECT nome, cnh_categoria, cnh_registro, cnh_validade
FROM motorista
WHERE cnh_validade < CURRENT_DATE
ORDER BY cnh_validade;

-- Quais entregas ainda estão pendentes ou em trânsito? Mostrando as que têm o prazo mais perto primeiro.
SELECT id, viagem_id, cliente_id, peso_kg, prazo, status
FROM entrega
WHERE status IN ('pendente', 'em trânsito')
ORDER BY prazo, id;

-- Quais manutenções custaram mais de 5 mil reais? Mostrando das mmais caras pras menos caras.
SELECT id, veiculo_id, data, preco, detalhes
FROM manutencao
WHERE preco > 5000
ORDER BY preco DESC;

-- COM JOIN
-- Quais viagens o motorista Sérgio Luiz Cardoso fez? Mostrando o veículo que ele usou e a rota de cada viagem, da mais antiga para a mais recente.
SELECT vi.id AS viagem, vi.data_saida, vi.data_entrega, ve.placa, ve.modelo, ro.cidade_partida, ro.cidade_destino
FROM viagem vi
JOIN motorista mo ON mo.id = vi.motorista_id
JOIN veiculo ve ON ve.id = vi.veiculo_id
JOIN rota ro ON ro.id = vi.rota_id
WHERE mo.nome = 'Sérgio Luiz Cardoso'
ORDER BY vi.data_saida;

-- Quais entregas estão na viagem ID 34? Mostrando para qual cliente cada uma vai, peso, prazo e status.
SELECT e.id AS entrega, c.nome AS cliente, c.cidade, e.peso_kg, e.prazo, e.status
FROM entrega e
JOIN cliente c ON c.id = e.cliente_id
WHERE e.viagem_id = 34
ORDER BY e.id;

-- Quais manutenções foram feitas no veículo de placa "HPP0I01"? Mostrando a data, preço e detalhes de cada manutenção, da mais recente para a mais antiga.
SELECT ve.placa, ve.modelo, ma.data, ma.preco, ma.detalhes
FROM veiculo ve
JOIN manutencao ma ON ma.veiculo_id = ve.id
WHERE ve.placa = 'HPP0I01'
ORDER BY ma.data DESC;

-- Quais motoristas estão com viagens em andamento? Mostrando o nome do motorista, a placa do veículo e a cidade de destino da viagem.
SELECT mo.nome, ve.placa, ro.cidade_destino
FROM viagem vi
JOIN motorista mo ON mo.id = vi.motorista_id
JOIN veiculo ve ON ve.id = vi.veiculo_id
JOIN rota ro ON ro.id = vi.rota_id
WHERE vi.data_entrega IS NULL
ORDER BY vi.motorista_id