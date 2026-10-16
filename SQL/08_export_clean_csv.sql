-- ================================================================
-- PAL | Iowa Liquor Sales | Step 08: export the cleaned table to CSV
-- ================================================================
-- Writes iowa_liquor_sales_clean to one CSV file with a header row.
-- The MySQL server writes the file, so it can only write into the folder named by
-- secure_file_priv. Run 8.1 first and use that folder in 8.2.
--
-- CSV format: comma separated, UTF-8, text in double quotes, a quote inside text
-- written as two quotes (standard CSV), missing values as empty fields, and a line
-- break inside a text value (for example a two-line address) written as a space.
-- The table itself is not changed.
-- Readable by Python (pandas), Power BI and LOAD DATA without extra settings.
-- ================================================================

USE pal_liquor;

-- 8.1 The folder MySQL may write to
--   Typical result on Windows: C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
--   (ProgramData is a hidden folder: type the path into File Explorer's address bar)
--   NULL means exporting is disabled; see the note at the end of this file.
SHOW VARIABLES LIKE 'secure_file_priv';

-- 8.2 Export
--   Replace the folder below with the result of 8.1, using forward slashes.
--   MySQL never overwrites a file: delete an earlier export first, or change the name.
SELECT 'row_id', 'invoice_id', 'ordered_on', 'store_no', 'store_name', 'store_address',
       'store_city', 'store_zip_code', 'county_fips_code', 'county_name', 'category_code',
       'category_name', 'vendor_number', 'vendor_name', 'item_no', 'im_desc', 'pack',
       'bottle_volume_ml', 'state_bottle_cost', 'state_bottle_retail', 'sales_bottles',
       'sales_dollars', 'sales_liters', 'sales_gallons', 'is_return'
UNION ALL
SELECT row_id,
       IFNULL(invoice_id, ''),
       IFNULL(ordered_on, ''),
       IFNULL(store_no, ''),
       IFNULL(REPLACE(REPLACE(store_name,    '\r', ' '), '\n', ' '), ''),
       IFNULL(REPLACE(REPLACE(store_address, '\r', ' '), '\n', ' '), ''),
       IFNULL(REPLACE(REPLACE(store_city,    '\r', ' '), '\n', ' '), ''),
       IFNULL(store_zip_code, ''),
       IFNULL(county_fips_code, ''),
       IFNULL(REPLACE(REPLACE(county_name,   '\r', ' '), '\n', ' '), ''),
       IFNULL(category_code, ''),
       IFNULL(REPLACE(REPLACE(category_name, '\r', ' '), '\n', ' '), ''),
       IFNULL(vendor_number, ''),
       IFNULL(REPLACE(REPLACE(vendor_name,   '\r', ' '), '\n', ' '), ''),
       IFNULL(item_no, ''),
       IFNULL(REPLACE(REPLACE(im_desc,       '\r', ' '), '\n', ' '), ''),
       IFNULL(pack, ''),             IFNULL(bottle_volume_ml, ''),    IFNULL(state_bottle_cost, ''),
       IFNULL(state_bottle_retail, ''), IFNULL(sales_bottles, ''),    IFNULL(sales_dollars, ''),
       IFNULL(sales_liters, ''),     IFNULL(sales_gallons, ''),       is_return
FROM iowa_liquor_sales_clean
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/iowa_liquor_sales_clean.csv'
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n';

-- 8.3 Rows to expect in the file: this number plus 1 header row
SELECT COUNT(*) AS rows_exported FROM iowa_liquor_sales_clean;

-- ----------------------------------------------------------------
-- If 8.1 returns NULL: open my.ini (usually C:\ProgramData\MySQL\MySQL Server 8.0\my.ini),
-- set   secure-file-priv="C:/ProgramData/MySQL/MySQL Server 8.0/Uploads"
-- under [mysqld], restart the MySQL80 service, then run this file again.
-- ----------------------------------------------------------------
