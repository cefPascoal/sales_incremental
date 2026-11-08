CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_calendario (
  data_key INTEGER PRIMARY KEY,
  data DATE NOT NULL UNIQUE,
  dia_mes SMALLINT NOT NULL,
  dia_semana_iso SMALLINT NOT NULL,
  nome_dia VARCHAR(16) NOT NULL,
  semana_iso SMALLINT NOT NULL,
  mes SMALLINT NOT NULL,
  nome_mes VARCHAR(16) NOT NULL,
  trimestre SMALLINT NOT NULL,
  ano SMALLINT NOT NULL,
  fim_de_semana BOOLEAN NOT NULL
);

WITH limites AS (
  SELECT
    COALESCE(
      date_trunc('year', MIN(data))::date,
      date_trunc('year', CURRENT_DATE)::date
    ) AS data_inicial,
    make_date(EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER + 2, 12, 31) AS data_final
  FROM silver.vendas
),
calendario AS (
  SELECT serie.data::date AS data
  FROM limites
  CROSS JOIN LATERAL generate_series(
    limites.data_inicial::timestamp,
    limites.data_final::timestamp,
    INTERVAL '1 day'
  ) AS serie(data)
)
INSERT INTO gold.dim_calendario (
  data_key,
  data,
  dia_mes,
  dia_semana_iso,
  nome_dia,
  semana_iso,
  mes,
  nome_mes,
  trimestre,
  ano,
  fim_de_semana
)
SELECT
  to_char(data, 'YYYYMMDD')::INTEGER,
  data,
  EXTRACT(DAY FROM data)::SMALLINT,
  EXTRACT(ISODOW FROM data)::SMALLINT,
  CASE EXTRACT(ISODOW FROM data)
    WHEN 1 THEN 'segunda-feira'
    WHEN 2 THEN 'terça-feira'
    WHEN 3 THEN 'quarta-feira'
    WHEN 4 THEN 'quinta-feira'
    WHEN 5 THEN 'sexta-feira'
    WHEN 6 THEN 'sábado'
    WHEN 7 THEN 'domingo'
  END,
  EXTRACT(WEEK FROM data)::SMALLINT,
  EXTRACT(MONTH FROM data)::SMALLINT,
  CASE EXTRACT(MONTH FROM data)
    WHEN 1 THEN 'janeiro'
    WHEN 2 THEN 'fevereiro'
    WHEN 3 THEN 'março'
    WHEN 4 THEN 'abril'
    WHEN 5 THEN 'maio'
    WHEN 6 THEN 'junho'
    WHEN 7 THEN 'julho'
    WHEN 8 THEN 'agosto'
    WHEN 9 THEN 'setembro'
    WHEN 10 THEN 'outubro'
    WHEN 11 THEN 'novembro'
    WHEN 12 THEN 'dezembro'
  END,
  EXTRACT(QUARTER FROM data)::SMALLINT,
  EXTRACT(YEAR FROM data)::SMALLINT,
  EXTRACT(ISODOW FROM data) IN (6, 7)
FROM calendario
ON CONFLICT (data_key) DO NOTHING;
