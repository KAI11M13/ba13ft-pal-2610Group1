-- 01_create_database_and_staging.sql
-- MySQL 8+
-- Source file: C:/Users/56426/Desktop/PAL/Cleaned/iowa_liquor_sales_clean.csv

CREATE DATAstg_iowa_liquor_salesBASE IF NOT EXISTS pal_dw
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE pal_dw;

CREATE TABLE IF NOT EXISTS stg_iowa_liquor_sales (
  row_id BIGINT NOT NULL,
  invoice_id VARCHAR(40) NOT NULL,
  ordered_on DATE NOT NULL,
  store_no VARCHAR(20) NOT NULL,
  store_name VARCHAR(255) NULL,
  store_address VARCHAR(255) NULL,
  store_city VARCHAR(100) NULL,
  store_zip_code VARCHAR(10) NULL,
  county_fips_code VARCHAR(5) NULL,
  county_name VARCHAR(100) NULL,
  category_code VARCHAR(20) NULL,
  category_name VARCHAR(255) NULL,
  vendor_number VARCHAR(20) NOT NULL,
  vendor_name VARCHAR(255) NULL,
  item_no VARCHAR(20) NOT NULL,
  im_desc VARCHAR(255) NULL,
  pack INT NOT NULL,
  bottle_volume_ml INT NOT NULL,
  state_bottle_cost DECIMAL(10,2) NOT NULL DEFAULT 0,
  state_bottle_retail DECIMAL(10,2) NOT NULL DEFAULT 0,
  sales_bottles INT NOT NULL DEFAULT 0,
  sales_dollars DECIMAL(12,2) NOT NULL DEFAULT 0,
  sales_liters DECIMAL(12,2) NOT NULL DEFAULT 0,
  sales_gallons DECIMAL(12,4) NOT NULL DEFAULT 0,
  is_return TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (row_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;