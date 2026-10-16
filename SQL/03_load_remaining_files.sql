-- ================================================================
-- PAL | Iowa Liquor Sales | Step 03: load the remaining 8 files
-- ================================================================
-- Run only after Step 02 passes. Check Skipped: 0 and Warnings: 0 for each statement.
-- 2025 part 0005 is loaded as delivered; see the notes in Step 04.
-- ================================================================

USE pal_liquor;

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2025_1262_rows_part_0002.csv'
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
    source_file = 'iowa_liquor_sales_2025_1262_rows_part_0002.csv';

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2025_1262_rows_part_0003.csv'
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
    source_file = 'iowa_liquor_sales_2025_1262_rows_part_0003.csv';

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2025_1262_rows_part_0004.csv'
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
    source_file = 'iowa_liquor_sales_2025_1262_rows_part_0004.csv';

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2025_1262_rows_part_0005.csv'
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
    source_file = 'iowa_liquor_sales_2025_1262_rows_part_0005.csv';

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2026_1263_rows_part_0001.csv'
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
    source_file = 'iowa_liquor_sales_2026_1263_rows_part_0001.csv';

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2026_1263_rows_part_0002.csv'
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
    source_file = 'iowa_liquor_sales_2026_1263_rows_part_0002.csv';

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2026_1263_rows_part_0003.csv'
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
    source_file = 'iowa_liquor_sales_2026_1263_rows_part_0003.csv';

LOAD DATA LOCAL INFILE 'D:/202606-202703_grad/Courses/00_0914-10_PAL Practice Module/data/raw data/iowa_liquor_sales_2026_1263_rows_part_0004.csv'
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
    source_file = 'iowa_liquor_sales_2026_1263_rows_part_0004.csv';
