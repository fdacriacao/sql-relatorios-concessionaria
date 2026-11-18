-- Relatórios gerenciais (SQLite). Cada consulta responde a uma pergunta de negócio.

-- R1. Faturamento e ticket médio por mês
SELECT substr(data_venda, 1, 7)       AS ano_mes,
       COUNT(*)                       AS qtd_vendas,
       ROUND(SUM(valor_final), 2)     AS faturamento,
       ROUND(AVG(valor_final), 2)     AS ticket_medio
FROM vendas
GROUP BY substr(data_venda, 1, 7)
ORDER BY ano_mes;

-- R2. Ranking de vendedores, com posição dentro da própria filial
SELECT f.nome                          AS filial,
       vd.nome                         AS vendedor,
       COUNT(*)                        AS qtd_vendas,
       ROUND(SUM(v.valor_final), 2)    AS faturamento,
       RANK() OVER (PARTITION BY f.id_filial ORDER BY SUM(v.valor_final) DESC) AS posicao_na_filial
FROM vendas v
JOIN vendedores vd ON vd.id_vendedor = v.id_vendedor
JOIN filiais f     ON f.id_filial   = vd.id_filial
GROUP BY f.id_filial, f.nome, vd.id_vendedor, vd.nome
ORDER BY f.nome, posicao_na_filial;

-- R3. Mix de forma de pagamento (% do faturamento)
SELECT forma_pgto,
       COUNT(*)                                                    AS qtd,
       ROUND(SUM(valor_final), 2)                                  AS faturamento,
       ROUND(100.0 * SUM(valor_final) / (SELECT SUM(valor_final) FROM vendas), 1) AS pct_faturamento
FROM vendas
GROUP BY forma_pgto
ORDER BY faturamento DESC;

-- R4. Desconto médio concedido por modelo (preço de tabela x valor final)
SELECT ve.modelo,
       COUNT(*)                                                      AS qtd,
       ROUND(AVG(100.0 * (ve.preco_tabela - v.valor_final) / ve.preco_tabela), 2) AS desconto_medio_pct
FROM vendas v
JOIN veiculos ve ON ve.id_veiculo = v.id_veiculo
GROUP BY ve.id_veiculo, ve.modelo
ORDER BY desconto_medio_pct DESC;

-- R5. Crescimento mensal do faturamento (mês atual vs. anterior) com LAG
WITH mensal AS (
    SELECT substr(data_venda, 1, 7) AS ano_mes, SUM(valor_final) AS fat
    FROM vendas
    GROUP BY substr(data_venda, 1, 7)
)
SELECT ano_mes,
       ROUND(fat, 2) AS faturamento,
       ROUND(100.0 * (fat - LAG(fat) OVER (ORDER BY ano_mes)) / LAG(fat) OVER (ORDER BY ano_mes), 1) AS variacao_pct
FROM mensal
ORDER BY ano_mes;

-- R6. Pós-venda: receita por filial e tipo de serviço (somente OS fechadas)
SELECT f.nome AS filial,
       os.tipo,
       COUNT(DISTINCT os.id_os)   AS qtd_os,
       ROUND(SUM(i.valor), 2)     AS receita
FROM ordens_servico os
JOIN filiais f    ON f.id_filial = os.id_filial
JOIN os_itens i   ON i.id_os     = os.id_os
WHERE os.data_fechamento IS NOT NULL
GROUP BY f.nome, os.tipo
ORDER BY f.nome, receita DESC;

-- R7. OS em aberto há mais de 30 dias (data de referência fixa para ser reproduzível)
SELECT os.id_os, c.nome AS cliente, os.tipo, os.data_abertura,
       CAST(julianday('2025-12-31') - julianday(os.data_abertura) AS INTEGER) AS dias_em_aberto
FROM ordens_servico os
JOIN clientes c ON c.id_cliente = os.id_cliente
WHERE os.data_fechamento IS NULL
  AND julianday('2025-12-31') - julianday(os.data_abertura) > 30
ORDER BY dias_em_aberto DESC;

-- R8. Clientes que compraram e também usaram o pós-venda (relacionamento)
SELECT c.nome,
       COUNT(DISTINCT v.id_venda) AS compras,
       COUNT(DISTINCT os.id_os)   AS os_abertas
FROM clientes c
JOIN vendas v          ON v.id_cliente = c.id_cliente
LEFT JOIN ordens_servico os ON os.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
HAVING COUNT(DISTINCT os.id_os) > 0
ORDER BY os_abertas DESC, compras DESC
LIMIT 10;
