-- 99_validation.sql
USE pal_dw;

SELECT 'staging_rows' AS check_name, COUNT(*) AS value
FROM stg_iowa_liquor_sales;
SELECT 'staging_min_date' AS check_name, MIN(ordered_on) AS value
FROM stg_iowa_liquor_sales;
SELECT 'staging_max_date' AS check_name, MAX(ordered_on) AS value
FROM stg_iowa_liquor_sales;
SELECT 'staging_total_bottles' AS check_name, SUM(sales_bottles) AS value
FROM stg_iowa_liquor_sales;
SELECT 'staging_total_dollars' AS check_name, SUM(sales_dollars) AS value
FROM stg_iowa_liquor_sales;
SELECT 'staging_return_lines' AS check_name, SUM(CASE WHEN is_return = 1 THEN 1 ELSE 0 END) AS value
FROM stg_iowa_liquor_sales;

SELECT 'dim_date_rows' AS check_name, COUNT(*) AS value FROM dim_date
UNION ALL SELECT 'dim_store_rows', COUNT(*) FROM dim_store
UNION ALL SELECT 'dim_product_rows', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_category_rows', COUNT(*) FROM dim_category
UNION ALL SELECT 'dim_vendor_rows', COUNT(*) FROM dim_vendor
UNION ALL SELECT 'fact_rows', COUNT(*) FROM fact_purchase_line
UNION ALL SELECT 'mart_rows', COUNT(*) FROM mart_store_category_week;

SELECT 'unmatched_store' AS check_name, COUNT(*) AS value
FROM stg_iowa_liquor_sales s
LEFT JOIN dim_store st ON st.store_no = TRIM(s.store_no)
WHERE st.store_key IS NULL;

SELECT 'unmatched_product' AS check_name, COUNT(*) AS value
FROM stg_iowa_liquor_sales s
LEFT JOIN dim_product p
  ON p.item_no = TRIM(s.item_no)
 AND p.im_desc = COALESCE(NULLIF(TRIM(s.im_desc), ''), 'UNKNOWN')
 AND p.pack = s.pack
 AND p.bottle_volume_ml = s.bottle_volume_ml
WHERE p.product_key IS NULL;

SELECT 'unmatched_vendor' AS check_name, COUNT(*) AS value
FROM stg_iowa_liquor_sales s
LEFT JOIN dim_vendor v ON v.vendor_number = TRIM(s.vendor_number)
WHERE v.vendor_key IS NULL;

SELECT 'unknown_category_lines' AS check_name, COUNT(*) AS value
FROM fact_purchase_line f
JOIN dim_category c ON c.category_key = f.category_key
WHERE c.category_code = 'UNKNOWN';

SELECT 'fact_minus_staging_rows' AS check_name,
       (SELECT COUNT(*) FROM fact_purchase_line) -
       (SELECT COUNT(*) FROM stg_iowa_liquor_sales) AS value;

SELECT *
FROM vw_mart_store_category_week
ORDER BY week_start DESC, sales_dollars DESC
LIMIT 20;