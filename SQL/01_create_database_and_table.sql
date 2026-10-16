-- ================================================================
-- PAL | Iowa Liquor Sales | Step 01: create the database and the raw table
-- ================================================================
-- iowa_liquor_sales_raw keeps every row exactly as delivered (no cleaning, no primary key),
-- so duplicates or other issues stay visible for the data cleaning step.
-- source_file records which CSV each row came from.
-- ================================================================

CREATE DATABASE IF NOT EXISTS pal_liquor DEFAULT CHARACTER SET utf8mb4;
USE pal_liquor;

CREATE TABLE IF NOT EXISTS iowa_liquor_sales_raw (
  invoice_id          VARCHAR(30),
  ordered_on          DATE,
  store_no            INT,
  store_name          VARCHAR(255),
  store_address       VARCHAR(255),
  store_city          VARCHAR(100),
  store_zip_code      VARCHAR(10),
  county_fips_code    VARCHAR(10),
  county_name         VARCHAR(100),
  category_code       VARCHAR(20),
  category_name       VARCHAR(255),
  vendor_number       VARCHAR(20),
  vendor_name         VARCHAR(255),
  item_no             VARCHAR(20),
  im_desc             VARCHAR(255),
  pack                INT,
  bottle_volume_ml    INT,
  state_bottle_cost   DECIMAL(10,2),
  state_bottle_retail DECIMAL(10,2),
  sales_bottles       INT,
  sales_dollars       DECIMAL(12,2),
  sales_liters        DECIMAL(12,2),
  sales_gallons       DECIMAL(12,2),
  source_file         VARCHAR(60)
) ENGINE=InnoDB;

-- To start the load again from Step 02, empty the table first:
-- TRUNCATE TABLE iowa_liquor_sales_raw;
