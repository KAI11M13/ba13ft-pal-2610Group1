-- ================================================================
-- PAL | Iowa Liquor Sales | Step 04: confirm every file loaded completely
-- ================================================================
-- Expected rows per file come from the Power Query row count of the same CSV files.
-- This step checks the load only; data cleaning is a separate step.
-- ================================================================

USE pal_liquor;

-- 4.1 Rows per file: expect diff = 0 on all 9 rows
SELECT e.source_file,
       e.expected_rows,
       COALESCE(a.loaded_rows, 0)                   AS loaded_rows,
       COALESCE(a.loaded_rows, 0) - e.expected_rows AS diff
FROM (
  SELECT 'iowa_liquor_sales_2025_1262_rows_part_0001.csv' AS source_file, 598080 AS expected_rows
  UNION ALL SELECT 'iowa_liquor_sales_2025_1262_rows_part_0002.csv', 775752
  UNION ALL SELECT 'iowa_liquor_sales_2025_1262_rows_part_0003.csv', 628867
  UNION ALL SELECT 'iowa_liquor_sales_2025_1262_rows_part_0004.csv', 487921
  UNION ALL SELECT 'iowa_liquor_sales_2025_1262_rows_part_0005.csv', 429989
  UNION ALL SELECT 'iowa_liquor_sales_2026_1263_rows_part_0001.csv', 445274
  UNION ALL SELECT 'iowa_liquor_sales_2026_1263_rows_part_0002.csv', 437005
  UNION ALL SELECT 'iowa_liquor_sales_2026_1263_rows_part_0003.csv', 506780
  UNION ALL SELECT 'iowa_liquor_sales_2026_1263_rows_part_0004.csv', 425797
) AS e
LEFT JOIN (
  SELECT source_file, COUNT(*) AS loaded_rows
  FROM iowa_liquor_sales_raw
  GROUP BY source_file
) AS a ON a.source_file = e.source_file
ORDER BY e.source_file;

-- 4.2 Total: expect 4,735,465
SELECT COUNT(*) AS total_rows FROM iowa_liquor_sales_raw;

-- 4.3 Dates: expect bad_date = 0 and dates within each file's year
SELECT LEFT(source_file, 22)   AS file_group,
       MIN(ordered_on)         AS first_day,
       MAX(ordered_on)         AS last_day,
       SUM(ordered_on IS NULL) AS bad_date
FROM iowa_liquor_sales_raw
GROUP BY file_group
ORDER BY file_group;

-- ================================================================
-- Notes for the data cleaning step
-- ================================================================
-- 1. Official row counts (Iowa Data Hub, release published 2026-10-06):
--      2025 = 2,490,620 ; 2026 = 1,814,856
-- 2. 2025 parts 0001-0004 add up to exactly 2,490,620 rows. Part 0005 adds
--    429,989 rows beyond the official count; check whether they duplicate
--    invoice_id values in parts 0001-0004 before using 2025 data.
-- 3. invoice_id identifies one invoice line, so it should be unique after cleaning.
--    Current duplicate count:
SELECT COUNT(*) - COUNT(DISTINCT invoice_id) AS duplicate_invoice_rows
FROM iowa_liquor_sales_raw;
