CREATE SCHEMA IF NOT EXISTS silver;

CREATE TABLE IF NOT EXISTS silver.vendas (
  empresa VARCHAR(40),
  loja_id VARCHAR(40),
  loja_nome VARCHAR(120),
  cidade VARCHAR(120),
  data DATE,
  hora TIME,
  id_venda VARCHAR(80),
  linha INTEGER,
  sku VARCHAR(80),
  produto VARCHAR(255),
  categoria VARCHAR(120),
  quantidade INTEGER,
  preco_unit NUMERIC(12, 2),
  desconto_pct NUMERIC(5, 4),
  valor_desconto NUMERIC(12, 2),
  total_linha NUMERIC(12, 2),
  metodo_pagamento VARCHAR(80),
  vendedor VARCHAR(120),
  timestamp_envio TIMESTAMP WITHOUT TIME ZONE,
  nome_ficheiro TEXT,
  data_ingestao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver.vendas_rejeitadas (
  id_rejeicao BIGSERIAL PRIMARY KEY,
  nome_ficheiro TEXT,
  error_row TEXT,
  error_description TEXT,
  error_code TEXT,
  data_rejeicao TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE silver.vendas_rejeitadas
  ADD COLUMN IF NOT EXISTS nome_ficheiro TEXT,
  ADD COLUMN IF NOT EXISTS error_row TEXT,
  ADD COLUMN IF NOT EXISTS error_description TEXT,
  ADD COLUMN IF NOT EXISTS error_code TEXT,
  ADD COLUMN IF NOT EXISTS data_rejeicao TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;
