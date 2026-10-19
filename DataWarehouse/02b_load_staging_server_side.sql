-- 02b_load_staging_server_side.sql
-- Alternative if LOAD DATA LOCAL INFILE is blocked by Workbench.
-- 1) Run: SHOW VARIABLES LIKE 'secure_file_priv';
-- 2) Copy the CSV into that folder.
-- 3) Replace the path below with the copied file path.
-- 4) Run this script as a user with FILE privilege.

USE pal_dw;

LOAD DATA INFILE 'D:/MySQL/Uploads/iowa_liquor_sales_clean.csv'
REPLACE INTO TABLE stg_iowa_liquor_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  row_id,
  invoice_id,
  ordered_on,
  store_no,
  store_name,
  store_address,
  store_city,
  store_zip_code,
  county_fips_code,
  county_name,
  category_code,
  category_name,
  vendor_number,
  vendor_name,
  item_no,
  im_desc,
  pack,
  bottle_volume_ml,
  state_bottle_cost,
  state_bottle_retail,
  sales_bottles,
  sales_dollars,
  sales_liters,
  sales_gallons,
  is_return
);