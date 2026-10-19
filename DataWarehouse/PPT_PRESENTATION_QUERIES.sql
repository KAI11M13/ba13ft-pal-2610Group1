-- PPT_PRESENTATION_QUERIES.sql
-- Select ONE query at a time and press Ctrl+Enter.
USE pal_dw;

-- SCREENSHOT 2: warehouse validation summary
SELECT
  check_name, actual_value, expected_value,
  CASE WHEN actual_value = expected_value THEN 'OK' ELSE 'CHECK' END AS status
FROM (
  SELECT 'staging_rows' AS check_name, COUNT(*) AS actual_value, 4305455 AS expected_value FROM stg_iowa_liquor_sales
  UNION ALL SELECT 'fact_rows', COUNT(*), 4305455 FROM fact_purchase_line
  UNION ALL SELECT 'mart_rows', COUNT(*), 1644490 FROM mart_store_category_week
  UNION ALL SELECT 'unmatched_store', COUNT(*), 0
    FROM stg_iowa_liquor_sales s LEFT JOIN dim_store st ON st.store_no = TRIM(s.store_no)
    WHERE st.store_key IS NULL
  UNION ALL SELECT 'unmatched_product', COUNT(*), 0
    FROM stg_iowa_liquor_sales s LEFT JOIN dim_product p
      ON p.item_no = TRIM(s.item_no)
     AND p.im_desc = COALESCE(NULLIF(TRIM(s.im_desc), ''), 'UNKNOWN')
     AND p.pack = s.pack
     AND p.bottle_volume_ml = s.bottle_volume_ml
    WHERE p.product_key IS NULL
  UNION ALL SELECT 'fact_minus_staging',
    (SELECT COUNT(*) FROM fact_purchase_line) - (SELECT COUNT(*) FROM stg_iowa_liquor_sales), 0
) checks;

-- SCREENSHOT 3: top 10 categories by sales value
SELECT
  c.category_name,
  ROUND(SUM(f.sales_dollars), 2) AS sales_dollars,
  SUM(f.sales_bottles) AS bottles
FROM fact_purchase_line f
JOIN dim_category c ON c.category_key = f.category_key
GROUP BY c.category_name
ORDER BY sales_dollars DESC
LIMIT 10;

-- SCREENSHOT 4: monthly sales trend in 2026
SELECT
  d.year,
  d.month,
  d.month_name,
  ROUND(SUM(f.sales_dollars), 2) AS sales_dollars,
  SUM(f.sales_bottles) AS bottles
FROM fact_purchase_line f
JOIN dim_date d ON d.date_key = f.date_key
WHERE d.year = 2026
GROUP BY d.year, d.month, d.month_name
ORDER BY d.month;

-- SCREENSHOT 5: top store-category combinations in latest week
SELECT
  m.week_start,
  s.store_name,
  c.category_name,
  m.positive_bottles,
  m.net_bottles,
  m.sales_dollars
FROM mart_store_category_week m
JOIN dim_store s ON s.store_key = m.store_key
JOIN dim_category c ON c.category_key = m.category_key
WHERE m.week_start = (SELECT MAX(week_start) FROM mart_store_category_week)
ORDER BY m.sales_dollars DESC
LIMIT 15;