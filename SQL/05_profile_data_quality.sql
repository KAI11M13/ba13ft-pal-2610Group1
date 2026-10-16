-- ================================================================
-- PAL | Iowa Liquor Sales | Step 05: profile data quality (read-only)
-- ================================================================
-- Measures every issue the cleaning step (06) handles, on the raw table.
-- Nothing is changed. Record the results for the Data Understanding section.
-- Each query scans 4.7 million rows; allow a few minutes in total.
-- ================================================================

USE pal_liquor;

-- 5.1 Repeated rows, per year
--   raw_rows - distinct_rows        = exact duplicate rows (same values in every column)
--   distinct_rows vs distinct_ids   = equal  : each invoice_id is one unique sales line
--                                     larger : one invoice_id covers several different lines
--   Official counts: 2025 = 2,490,620 ; 2026 = 1,814,856
SELECT r.yr,
       r.raw_rows,
       d.distinct_rows,
       r.raw_rows - d.distinct_rows AS exact_duplicate_rows,
       d.distinct_ids
FROM (
  SELECT YEAR(ordered_on) AS yr, COUNT(*) AS raw_rows
  FROM iowa_liquor_sales_raw
  GROUP BY YEAR(ordered_on)
) AS r
JOIN (
  SELECT YEAR(ordered_on) AS yr, COUNT(*) AS distinct_rows, COUNT(DISTINCT invoice_id) AS distinct_ids
  FROM (
    SELECT DISTINCT invoice_id, ordered_on, store_no, store_name, store_address, store_city,
           store_zip_code, county_fips_code, county_name, category_code, category_name,
           vendor_number, vendor_name, item_no, im_desc, pack, bottle_volume_ml,
           state_bottle_cost, state_bottle_retail, sales_bottles, sales_dollars,
           sales_liters, sales_gallons
    FROM iowa_liquor_sales_raw
  ) AS x
  GROUP BY YEAR(ordered_on)
) AS d ON d.yr = r.yr
ORDER BY r.yr;

-- 5.2 Missing values per text column (empty string or NULL), one table scan
WITH m AS (
  SELECT COUNT(*) AS n_rows,
         SUM(COALESCE(TRIM(store_name), '')       = '') AS store_name,
         SUM(COALESCE(TRIM(store_address), '')    = '') AS store_address,
         SUM(COALESCE(TRIM(store_city), '')       = '') AS store_city,
         SUM(COALESCE(TRIM(store_zip_code), '')   = '') AS store_zip_code,
         SUM(COALESCE(TRIM(county_fips_code), '') = '') AS county_fips_code,
         SUM(COALESCE(TRIM(county_name), '')      = '') AS county_name,
         SUM(COALESCE(TRIM(category_code), '')    = '') AS category_code,
         SUM(COALESCE(TRIM(category_name), '')    = '') AS category_name,
         SUM(COALESCE(TRIM(vendor_number), '')    = '') AS vendor_number,
         SUM(COALESCE(TRIM(vendor_name), '')      = '') AS vendor_name,
         SUM(COALESCE(TRIM(item_no), '')          = '') AS item_no,
         SUM(COALESCE(TRIM(im_desc), '')          = '') AS im_desc
  FROM iowa_liquor_sales_raw
)
SELECT 'store_name' AS column_name, store_name AS missing_rows, ROUND(100 * store_name / n_rows, 2) AS missing_pct FROM m
UNION ALL SELECT 'store_address',    store_address,    ROUND(100 * store_address    / n_rows, 2) FROM m
UNION ALL SELECT 'store_city',       store_city,       ROUND(100 * store_city       / n_rows, 2) FROM m
UNION ALL SELECT 'store_zip_code',   store_zip_code,   ROUND(100 * store_zip_code   / n_rows, 2) FROM m
UNION ALL SELECT 'county_fips_code', county_fips_code, ROUND(100 * county_fips_code / n_rows, 2) FROM m
UNION ALL SELECT 'county_name',      county_name,      ROUND(100 * county_name      / n_rows, 2) FROM m
UNION ALL SELECT 'category_code',    category_code,    ROUND(100 * category_code    / n_rows, 2) FROM m
UNION ALL SELECT 'category_name',    category_name,    ROUND(100 * category_name    / n_rows, 2) FROM m
UNION ALL SELECT 'vendor_number',    vendor_number,    ROUND(100 * vendor_number    / n_rows, 2) FROM m
UNION ALL SELECT 'vendor_name',      vendor_name,      ROUND(100 * vendor_name      / n_rows, 2) FROM m
UNION ALL SELECT 'item_no',          item_no,          ROUND(100 * item_no          / n_rows, 2) FROM m
UNION ALL SELECT 'im_desc',          im_desc,          ROUND(100 * im_desc          / n_rows, 2) FROM m;

-- 5.3 Numeric checks, one table scan
--   Negative bottles or dollars are returns (credit lines); zero or negative pack and
--   volume, and retail below cost, point to data entry problems.
SELECT SUM(sales_bottles < 0)                      AS negative_bottles,
       SUM(sales_bottles = 0)                      AS zero_bottles,
       SUM(sales_dollars < 0)                      AS negative_dollars,
       SUM(pack <= 0)                              AS pack_zero_or_less,
       SUM(bottle_volume_ml <= 0)                  AS volume_zero_or_less,
       SUM(state_bottle_retail < state_bottle_cost) AS retail_below_cost,
       MIN(sales_bottles)                          AS min_bottles,
       MAX(sales_bottles)                          AS max_bottles,
       MAX(sales_dollars)                          AS max_dollars
FROM iowa_liquor_sales_raw;

-- 5.4 Inconsistent descriptions behind one code
--   Codes whose rows carry more than one name or location
SELECT 'category_code with several category_name' AS check_name, COUNT(*) AS n_codes
FROM (
  SELECT category_code FROM iowa_liquor_sales_raw
  WHERE TRIM(category_code) <> '' AND TRIM(category_name) <> ''
  GROUP BY category_code HAVING COUNT(DISTINCT UPPER(TRIM(category_name))) > 1
) AS t
UNION ALL
SELECT 'item_no with several category_code', COUNT(*)
FROM (
  SELECT item_no FROM iowa_liquor_sales_raw
  WHERE TRIM(item_no) <> '' AND TRIM(category_code) <> ''
  GROUP BY item_no HAVING COUNT(DISTINCT category_code) > 1
) AS t
UNION ALL
SELECT 'store_no with several store_city', COUNT(*)
FROM (
  SELECT store_no FROM iowa_liquor_sales_raw
  WHERE TRIM(store_city) <> ''
  GROUP BY store_no HAVING COUNT(DISTINCT UPPER(TRIM(store_city))) > 1
) AS t;
