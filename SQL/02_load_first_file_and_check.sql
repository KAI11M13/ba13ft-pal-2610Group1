-- ================================================================
-- PAL | Iowa Liquor Sales | Step 02: load the first file and check it
-- ================================================================
-- Load one file first to confirm the settings before loading the rest.
-- After it runs, the Output panel should show Skipped: 0 and Warnings: 0.
-- The SET clause reads both date formats: MM/DD/YYYY and YYYY-MM-DD.
-- ================================================================

USE pal_liquor;

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2025_1262_rows_part_0001.csv'
INTO TABLE iowa_liquor_sales_raw
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(invoice_id, @ordered_on, store_no, store_name, store_address, store_city,
 store_zip_code, county_fips_code, county_name, category_code, category_name,
 vendor_number, vendor_name, item_no, im_desc, pack, bottle_volume_ml,
 state_bottle_cost, state_bottle_retail, sales_bottles, sales_dollars,
 sales_liters, sales_gallons)
SET ordered_on  = IF(@ordered_on LIKE '%/%',
                     STR_TO_DATE(SUBSTRING_INDEX(@ordered_on, ' ', 1), '%m/%d/%Y'),
                     DATE(LEFT(@ordered_on, 10))),
    source_file = 'iowa_liquor_sales_2025_1262_rows_part_0001.csv';

-- If Warnings > 0, review the messages:
SHOW WARNINGS LIMIT 20;

-- Expect n_rows = 598,080, bad_date = 0, dates within 2025
SELECT COUNT(*) AS n_rows, MIN(ordered_on) AS first_day, MAX(ordered_on) AS last_day,
       SUM(ordered_on IS NULL) AS bad_date
FROM iowa_liquor_sales_raw;

-- Eyeball 5 rows: each value should sit under the right column
SELECT * FROM iowa_liquor_sales_raw LIMIT 5;

-- Many warnings on sales_gallons mean the files use Windows line endings:
-- TRUNCATE the table, change '\n' to '\r\n' in Step 02 and Step 03, then rerun Step 02.
