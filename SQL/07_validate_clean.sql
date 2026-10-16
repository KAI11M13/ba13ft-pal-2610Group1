-- ================================================================
-- PAL | Iowa Liquor Sales | Step 07: validate the cleaned table (read-only)
-- ================================================================
-- Compares iowa_liquor_sales_clean with iowa_liquor_sales_raw.
-- Record the results for the Data Preparation section of the report.
-- ================================================================

USE pal_liquor;

-- 7.1 Rows removed by de-duplication, per year
--   Official counts: 2025 = 2,490,620 ; 2026 = 1,814,856
SELECT r.yr,
       r.raw_rows,
       c.clean_rows,
       r.raw_rows - c.clean_rows AS removed_duplicates,
       c.distinct_ids
FROM (
  SELECT YEAR(ordered_on) AS yr, COUNT(*) AS raw_rows
  FROM iowa_liquor_sales_raw GROUP BY YEAR(ordered_on)
) AS r
JOIN (
  SELECT YEAR(ordered_on) AS yr, COUNT(*) AS clean_rows, COUNT(DISTINCT invoice_id) AS distinct_ids
  FROM iowa_liquor_sales_clean GROUP BY YEAR(ordered_on)
) AS c ON c.yr = r.yr
ORDER BY r.yr;

-- 7.2 Repeats left after cleaning
--   repeated_invoice_item > 0 : the same product appears twice on one invoice with
--   different values, which needs a decision before modelling
SELECT COUNT(*) - COUNT(DISTINCT invoice_id) AS repeated_invoice_id,
       COUNT(*) - (SELECT COUNT(*) FROM (SELECT DISTINCT invoice_id, item_no
                                         FROM iowa_liquor_sales_clean) AS t) AS repeated_invoice_item
FROM iowa_liquor_sales_clean;

-- 7.3 Missing values before and after cleaning
WITH raw_m AS (
  SELECT SUM(COALESCE(TRIM(store_city), '')    = '') AS store_city,
         SUM(COALESCE(TRIM(county_name), '')   = '') AS county_name,
         SUM(COALESCE(TRIM(category_code), '') = '') AS category_code,
         SUM(COALESCE(TRIM(category_name), '') = '') AS category_name
  FROM iowa_liquor_sales_raw
), clean_m AS (
  SELECT SUM(store_city IS NULL)    AS store_city,
         SUM(county_name IS NULL)   AS county_name,
         SUM(category_code IS NULL) AS category_code,
         SUM(category_name IS NULL) AS category_name
  FROM iowa_liquor_sales_clean
)
SELECT 'store_city' AS column_name, r.store_city AS missing_raw, c.store_city AS missing_clean FROM raw_m r, clean_m c
UNION ALL SELECT 'county_name',   r.county_name,   c.county_name   FROM raw_m r, clean_m c
UNION ALL SELECT 'category_code', r.category_code, c.category_code FROM raw_m r, clean_m c
UNION ALL SELECT 'category_name', r.category_name, c.category_name FROM raw_m r, clean_m c;

-- 7.4 Returns kept in the cleaned table
SELECT SUM(is_return)                       AS return_rows,
       SUM(IF(is_return = 1, sales_bottles, 0)) AS returned_bottles,
       SUM(sales_bottles)                   AS net_bottles
FROM iowa_liquor_sales_clean;

-- 7.5 Dates are unchanged by cleaning
SELECT MIN(ordered_on) AS first_day, MAX(ordered_on) AS last_day, SUM(ordered_on IS NULL) AS bad_date
FROM iowa_liquor_sales_clean;
