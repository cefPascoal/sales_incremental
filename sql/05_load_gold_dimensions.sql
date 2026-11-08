INSERT INTO gold.dim_loja (
  empresa, loja_id, loja_nome, cidade
)
SELECT DISTINCT ON (empresa, loja_id)
  btrim(empresa),
  btrim(loja_id),
  NULLIF(btrim(loja_nome), ''),
  NULLIF(btrim(cidade), '')
FROM silver.vendas
WHERE NULLIF(btrim(empresa), '') IS NOT NULL
  AND NULLIF(btrim(loja_id), '') IS NOT NULL
ORDER BY empresa, loja_id, timestamp_envio DESC NULLS LAST, data_ingestao DESC NULLS LAST
ON CONFLICT (empresa, loja_id) DO UPDATE
SET loja_nome = EXCLUDED.loja_nome,
    cidade = EXCLUDED.cidade;

INSERT INTO gold.dim_produto (
  empresa, sku, produto, categoria
)
SELECT DISTINCT ON (empresa, sku)
  btrim(empresa),
  upper(btrim(sku)),
  NULLIF(btrim(produto), ''),
  NULLIF(btrim(categoria), '')
FROM silver.vendas
WHERE NULLIF(btrim(empresa), '') IS NOT NULL
  AND NULLIF(btrim(sku), '') IS NOT NULL
ORDER BY empresa, sku, timestamp_envio DESC NULLS LAST, data_ingestao DESC NULLS LAST
ON CONFLICT (empresa, sku) DO UPDATE
SET produto = EXCLUDED.produto,
    categoria = EXCLUDED.categoria;

INSERT INTO gold.dim_vendedor (
  empresa, vendedor
)
SELECT DISTINCT
  btrim(empresa),
  btrim(vendedor)
FROM silver.vendas
WHERE NULLIF(btrim(empresa), '') IS NOT NULL
  AND NULLIF(btrim(vendedor), '') IS NOT NULL
ON CONFLICT (empresa, vendedor) DO NOTHING;

INSERT INTO gold.dim_metodo_pagamento (
  metodo_pagamento
)
SELECT DISTINCT
  upper(btrim(metodo_pagamento))
FROM silver.vendas
WHERE NULLIF(btrim(metodo_pagamento), '') IS NOT NULL
ON CONFLICT (metodo_pagamento) DO NOTHING;
