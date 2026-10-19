-- 99_validation_summary.sql
-- One result set for a quick warehouse integrity check.
USE pal_dw;

SELECT
  check_name,
  actual_value,
  expected_value,
  CASE WHEN actual_value = expected_value THEN 'OK' ELSE 'CHECK' END AS status
FROM (
  SELECT 'staging_rows' AS check_name, COUNT(*) AS actual_value, 4305455 AS expected_value
  FROM stg_iowa_liquor_sales
  UNION ALL
  SELECT 'dim_date', COUNT(*), 529 FROM dim_date
  UNION ALL
  SELECT 'dim_store', COUNT(*), 2385 FROM dim_store
  UNION ALL
  SELECT 'dim_product', COUNT(*), 6251 FROM dim_product
  UNION ALL
  SELECT 'dim_category', COUNT(*), 45 FROM dim_category
  UNION ALL
  SELECT 'dim_vendor', COUNT(*), 251 FROM dim_vendor
  UNION ALL
  SELECT 'fact_rows', COUNT(*), 4305455 FROM fact_purchase_line
  UNION ALL
  SELECT 'mart_rows', COUNT(*), 1644490 FROM mart_store_category_week
  UNION ALL
  SELECT 'unmatched_store', COUNT(*), 0
  FROM stg_iowa_liquor_sales s
  LEFT JOIN dim_store st ON st.store_no = TRIM(s.store_no)
  WHERE st.store_key IS NULL
  UNION ALL
  SELECT 'unmatched_product', COUNT(*), 0
  FROM stg_iowa_liquor_sales s
  LEFT JOIN dim_product p
    ON p.item_no = TRIM(s.item_no)
   AND p.im_desc = COALESCE(NULLIF(TRIM(s.im_desc), ''), 'UNKNOWN')
   AND p.pack = s.pack
   AND p.bottle_volume_ml = s.bottle_volume_ml
  WHERE p.product_key IS NULL
  UNION ALL
  SELECT 'unmatched_vendor', COUNT(*), 0
  FROM stg_iowa_liquor_sales s
  LEFT JOIN dim_vendor v ON v.vendor_number = TRIM(s.vendor_number)
  WHERE v.vendor_key IS NULL
  UNION ALL
  SELECT 'unknown_category_lines', COUNT(*), 26
  FROM fact_purchase_line f
  JOIN dim_category c ON c.category_key = f.category_key
  WHERE c.category_code = 'UNKNOWN'
  UNION ALL
  SELECT 'fact_minus_staging',
         (SELECT COUNT(*) FROM fact_purchase_line) - (SELECT COUNT(*) FROM stg_iowa_liquor_sales),
         0
) checks;