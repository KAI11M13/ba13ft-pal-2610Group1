-- 05_build_mart.sql
USE pal_dw;

CREATE TABLE IF NOT EXISTS mart_store_category_week (
  week_start DATE NOT NULL,
  store_key INT NOT NULL,
  category_key INT NOT NULL,
  positive_bottles DECIMAL(16,2) NOT NULL DEFAULT 0,
  return_bottles DECIMAL(16,2) NOT NULL DEFAULT 0,
  net_bottles DECIMAL(16,2) NOT NULL DEFAULT 0,
  sales_dollars DECIMAL(16,2) NOT NULL DEFAULT 0,
  purchase_line_count INT NOT NULL DEFAULT 0,
  return_line_count INT NOT NULL DEFAULT 0,
  invoice_count INT NOT NULL DEFAULT 0,
  PRIMARY KEY (week_start, store_key, category_key),
  KEY idx_mart_store (store_key),
  KEY idx_mart_category (category_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

TRUNCATE TABLE mart_store_category_week;

INSERT INTO mart_store_category_week (
  week_start, store_key, category_key, positive_bottles, return_bottles,
  net_bottles, sales_dollars, purchase_line_count, return_line_count, invoice_count
)
SELECT
  d.week_start_date AS week_start,
  f.store_key,
  f.category_key,
  SUM(GREATEST(f.sales_bottles, 0)) AS positive_bottles,
  SUM(LEAST(f.sales_bottles, 0)) AS return_bottles,
  SUM(f.sales_bottles) AS net_bottles,
  SUM(f.sales_dollars) AS sales_dollars,
  COUNT(*) AS purchase_line_count,
  SUM(CASE WHEN f.is_return = 1 OR f.sales_bottles < 0 THEN 1 ELSE 0 END) AS return_line_count,
  COUNT(DISTINCT f.invoice_id) AS invoice_count
FROM fact_purchase_line f
JOIN dim_date d
  ON d.date_key = f.date_key
GROUP BY
  d.week_start_date,
  f.store_key,
  f.category_key;

CREATE OR REPLACE VIEW vw_mart_store_category_week AS
SELECT
  m.week_start,
  s.store_no,
  s.store_name,
  s.store_city,
  s.county_name,
  c.category_code,
  c.category_name,
  m.positive_bottles,
  m.return_bottles,
  m.net_bottles,
  m.sales_dollars,
  m.purchase_line_count,
  m.return_line_count,
  m.invoice_count
FROM mart_store_category_week m
JOIN dim_store s ON s.store_key = m.store_key
JOIN dim_category c ON c.category_key = m.category_key;

-- Note:
-- This mart contains observed store-category weeks only.
-- Zero-demand weeks should be generated after the modelling cohort is selected.