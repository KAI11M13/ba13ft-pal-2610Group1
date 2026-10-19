-- 04_build_fact.sql
USE pal_dw;

CREATE TABLE IF NOT EXISTS fact_purchase_line (
  sales_line_key BIGINT NOT NULL,
  invoice_id VARCHAR(40) NOT NULL,
  date_key INT NOT NULL,
  store_key INT NOT NULL,
  product_key BIGINT NOT NULL,
  category_key INT NOT NULL,
  vendor_key INT NOT NULL,
  state_bottle_cost DECIMAL(10,2) NOT NULL DEFAULT 0,
  state_bottle_retail DECIMAL(10,2) NOT NULL DEFAULT 0,
  sales_bottles INT NOT NULL DEFAULT 0,
  sales_dollars DECIMAL(12,2) NOT NULL DEFAULT 0,
  sales_liters DECIMAL(12,2) NOT NULL DEFAULT 0,
  sales_gallons DECIMAL(12,4) NOT NULL DEFAULT 0,
  is_return TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (sales_line_key),
  KEY idx_fact_date (date_key),
  KEY idx_fact_store_category_date (store_key, category_key, date_key),
  KEY idx_fact_product (product_key),
  KEY idx_fact_vendor (vendor_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

TRUNCATE TABLE fact_purchase_line;

INSERT INTO fact_purchase_line (
  sales_line_key, invoice_id, date_key, store_key, product_key,
  category_key, vendor_key, state_bottle_cost, state_bottle_retail,
  sales_bottles, sales_dollars, sales_liters, sales_gallons, is_return
)
SELECT
  s.row_id AS sales_line_key,
  s.invoice_id,
  d.date_key,
  st.store_key,
  p.product_key,
  c.category_key,
  v.vendor_key,
  s.state_bottle_cost,
  s.state_bottle_retail,
  s.sales_bottles,
  s.sales_dollars,
  s.sales_liters,
  s.sales_gallons,
  s.is_return
FROM stg_iowa_liquor_sales s
JOIN dim_date d
  ON d.full_date = s.ordered_on
JOIN dim_store st
  ON st.store_no = TRIM(s.store_no)
JOIN dim_product p
  ON p.item_no = TRIM(s.item_no)
 AND p.im_desc = COALESCE(NULLIF(TRIM(s.im_desc), ''), 'UNKNOWN')
 AND p.pack = s.pack
 AND p.bottle_volume_ml = s.bottle_volume_ml
JOIN dim_category c
  ON c.category_code = COALESCE(NULLIF(TRIM(s.category_code), ''), 'UNKNOWN')
JOIN dim_vendor v
  ON v.vendor_number = TRIM(s.vendor_number);