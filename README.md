# SQL para relatórios gerenciais — caso de concessionária

Conjunto de consultas SQL que respondem a perguntas reais de gestão de uma concessionária de veículos: faturamento, desempenho de vendedores, mix de pagamento, descontos e pós-venda.

> **Dados 100% fictícios.** Gerados por script com semente fixa, para qualquer pessoa reproduzir os mesmos resultados. Nenhuma informação real de empresa ou cliente.

## Por que este projeto existe

Em cinco anos como Supervisor de TI em um grupo de concessionárias, a rotina incluiu administrar o ERP e entregar relatórios gerenciais sobre SQL Server. Este repositório recria esse tipo de entrega em um ambiente aberto e seguro, sem dados de nenhuma empresa.

## O que as consultas respondem

| # | Pergunta de negócio | Técnicas SQL |
|---|---------------------|--------------|
| R1 | Quanto faturamos por mês e qual o ticket médio? | `GROUP BY`, agregações |
| R2 | Quem são os melhores vendedores em cada filial? | `JOIN`, `RANK() OVER (PARTITION BY ...)` |
| R3 | Qual o peso de cada forma de pagamento no faturamento? | subconsulta escalar, percentual |
| R4 | Qual o desconto médio por modelo? | `JOIN`, cálculo de margem |
| R5 | O faturamento cresceu ou caiu em relação ao mês anterior? | `CTE`, `LAG()` |
| R6 | Quanto o pós-venda rende por filial e tipo de serviço? | `JOIN`, `COUNT(DISTINCT)`, filtro de OS fechadas |
| R7 | Quais ordens de serviço estão abertas há mais de 30 dias? | filtro por data, `IS NULL` |
| R8 | Quais clientes compram e também usam o pós-venda? | `LEFT JOIN`, `HAVING` |

## Como rodar

Requer apenas Python 3 (o SQLite já vem incluso).

```bash
python3 gerar_dados.py   # opcional: recria sql/02_dados.sql
python3 testar.py        # cria o banco em memória, carrega os dados e roda os 8 relatórios
```

Também é possível abrir os arquivos de `sql/` em qualquer cliente SQLite, na ordem `01_schema.sql` → `02_dados.sql` → `03_relatorios.sql`.

## Modelo de dados

`filiais` ← `vendedores` → `vendas` ← `clientes`, `veiculos` · `ordens_servico` → `os_itens`

Há restrições de integridade (`CHECK`, chaves estrangeiras) e índices nas colunas mais filtradas.

## Usando em SQL Server (T-SQL)

As consultas foram testadas em SQLite. Para SQL Server, os pontos que mudam são:

| SQLite | SQL Server |
|--------|------------|
| `substr(data_venda, 1, 7)` | `FORMAT(data_venda, 'yyyy-MM')` (com `data_venda` como `DATE`) |
| `julianday(a) - julianday(b)` | `DATEDIFF(DAY, b, a)` |
| `LIMIT 10` | `SELECT TOP 10 ...` |
| `TEXT` | `VARCHAR(n)` / `DATE` |
| `INTEGER PRIMARY KEY` | `INT IDENTITY(1,1) PRIMARY KEY` |

Funções de janela (`RANK`, `LAG`) e CTEs funcionam da mesma forma.

## Transparência

Projeto montado com apoio de IA (Claude) e revisado por mim. As consultas foram executadas e conferidas em SQLite; a versão em T-SQL é a tabela de equivalências acima, ainda não executada em SQL Server.

## Autor

Filippe Daruis · Itaperuna/RJ · [LinkedIn](https://www.linkedin.com/in/filippe-daruis-1b227294/)
