-- Esquema fictício de uma concessionária (dados 100% inventados).
-- Testado em SQLite 3. Equivalências para SQL Server estão no README.

DROP TABLE IF EXISTS os_itens;
DROP TABLE IF EXISTS ordens_servico;
DROP TABLE IF EXISTS vendas;
DROP TABLE IF EXISTS veiculos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS vendedores;
DROP TABLE IF EXISTS filiais;

CREATE TABLE filiais (
    id_filial   INTEGER PRIMARY KEY,
    nome        TEXT NOT NULL,
    cidade      TEXT NOT NULL
);

CREATE TABLE vendedores (
    id_vendedor INTEGER PRIMARY KEY,
    nome        TEXT NOT NULL,
    id_filial   INTEGER NOT NULL REFERENCES filiais(id_filial)
);

CREATE TABLE clientes (
    id_cliente  INTEGER PRIMARY KEY,
    nome        TEXT NOT NULL,
    cidade      TEXT NOT NULL
);

CREATE TABLE veiculos (
    id_veiculo  INTEGER PRIMARY KEY,
    modelo      TEXT NOT NULL,
    categoria   TEXT NOT NULL CHECK (categoria IN ('novo','seminovo')),
    preco_tabela NUMERIC NOT NULL CHECK (preco_tabela > 0)
);

CREATE TABLE vendas (
    id_venda    INTEGER PRIMARY KEY,
    data_venda  TEXT NOT NULL,              -- formato AAAA-MM-DD
    id_cliente  INTEGER NOT NULL REFERENCES clientes(id_cliente),
    id_veiculo  INTEGER NOT NULL REFERENCES veiculos(id_veiculo),
    id_vendedor INTEGER NOT NULL REFERENCES vendedores(id_vendedor),
    valor_final NUMERIC NOT NULL CHECK (valor_final > 0),
    forma_pgto  TEXT NOT NULL CHECK (forma_pgto IN ('avista','financiado','consorcio'))
);

CREATE TABLE ordens_servico (
    id_os       INTEGER PRIMARY KEY,
    data_abertura TEXT NOT NULL,
    data_fechamento TEXT,                   -- NULL = em aberto
    id_cliente  INTEGER NOT NULL REFERENCES clientes(id_cliente),
    id_filial   INTEGER NOT NULL REFERENCES filiais(id_filial),
    tipo        TEXT NOT NULL CHECK (tipo IN ('revisao','mecanica','funilaria'))
);

CREATE TABLE os_itens (
    id_item     INTEGER PRIMARY KEY,
    id_os       INTEGER NOT NULL REFERENCES ordens_servico(id_os),
    descricao   TEXT NOT NULL,
    valor       NUMERIC NOT NULL CHECK (valor >= 0)
);

CREATE INDEX ix_vendas_data     ON vendas(data_venda);
CREATE INDEX ix_vendas_vendedor ON vendas(id_vendedor);
CREATE INDEX ix_os_filial       ON ordens_servico(id_filial);
