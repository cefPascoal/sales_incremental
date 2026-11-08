WITH source_lines AS (
  SELECT
    s.*,
    row_number() OVER (
      PARTITION BY
        nome_ficheiro, empresa, loja_id, loja_nome, cidade, data, hora,
        id_venda, linha, sku, produto, categoria, quantidade, preco_unit,
        desconto_pct, valor_desconto, total_linha, metodo_pagamento,
        vendedor, timestamp_envio
      ORDER BY data_ingestao
    ) AS identical_row_number
  FROM silver.vendas s
),
keyed_lines AS (
  SELECT
    source_lines.*,
    md5(jsonb_build_array(
      nome_ficheiro, empresa, loja_id, loja_nome, cidade, data, hora,
      id_venda, linha, sku, produto, categoria, quantidade, preco_unit,
      desconto_pct, valor_desconto, total_linha, metodo_pagamento,
      vendedor, timestamp_envio, identical_row_number
    )::text) AS source_record_key
  FROM source_lines
)
INSERT INTO gold.fact_vendas (
  source_record_key,
  data_key,
  loja_key,
  produto_key,
  vendedor_key,
  metodo_pagamento_key,
  id_venda,
  linha,
  quantidade,
  preco_unit,
  desconto_pct,
  valor_desconto,
  total_linha,
  timestamp_envio,
  nome_ficheiro
)
SELECT
  s.source_record_key,
  d.data_key,
  l.loja_key,
  p.produto_key,
  v.vendedor_key,
  m.metodo_pagamento_key,
  s.id_venda,
  s.linha,
  s.quantidade,
  s.preco_unit,
  s.desconto_pct,
  s.valor_desconto,
  s.total_linha,
  s.timestamp_envio,
  s.nome_ficheiro
FROM keyed_lines s
LEFT JOIN gold.dim_calendario d
  ON d.data = s.data
LEFT JOIN gold.dim_loja l
  ON l.empresa = btrim(s.empresa)
 AND l.loja_id = btrim(s.loja_id)
LEFT JOIN gold.dim_produto p
  ON p.empresa = btrim(s.empresa)
 AND p.sku = upper(btrim(s.sku))
LEFT JOIN gold.dim_vendedor v
  ON v.empresa = btrim(s.empresa)
 AND v.vendedor = btrim(s.vendedor)
LEFT JOIN gold.dim_metodo_pagamento m
  ON m.metodo_pagamento = upper(btrim(s.metodo_pagamento))
ON CONFLICT (source_record_key) DO UPDATE
SET data_key = EXCLUDED.data_key,
    loja_key = EXCLUDED.loja_key,
    produto_key = EXCLUDED.produto_key,
    vendedor_key = EXCLUDED.vendedor_key,
    metodo_pagamento_key = EXCLUDED.metodo_pagamento_key,
    id_venda = EXCLUDED.id_venda,
    linha = EXCLUDED.linha,
    quantidade = EXCLUDED.quantidade,
    preco_unit = EXCLUDED.preco_unit,
    desconto_pct = EXCLUDED.desconto_pct,
    valor_desconto = EXCLUDED.valor_desconto,
    total_linha = EXCLUDED.total_linha,
    timestamp_envio = EXCLUDED.timestamp_envio,
    nome_ficheiro = EXCLUDED.nome_ficheiro;
