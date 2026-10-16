-- ================================================================
-- PAL | Iowa Liquor Sales | Step 06: clean the data
-- ================================================================
-- Input : iowa_liquor_sales_raw   (left unchanged, so this step can be rerun)
-- Output: iowa_liquor_sales_clean
--
-- Cleaning rules, applied in this order
--   R1 Standardise text : trim spaces, upper case, empty string -> NULL
--   R2 Fill store location : a missing address, city, ZIP or county is taken from the
--      location that the same store_no reports most often
--   R3 Fill category : a missing category is taken from the category that the same
--      item_no is filed under most often; a missing category_name is then taken from
--      its category_code
--   R4 Remove exact duplicates : rows identical in every column after R1-R3 are kept once
--      (source_file is ignored, so a row delivered in two files counts as one)
--   R5 Flag returns : is_return = 1 when sales_bottles < 0; returns are kept, because
--      they reduce the net quantity a store bought
-- Values that cannot be filled stay NULL and are counted in Step 07.
--
-- Run the whole file in one go in the same Workbench tab (it uses temporary tables).
-- Allow 10 to 20 minutes on 4.7 million rows.
-- ================================================================

USE pal_liquor;

-- Workbench blocks UPDATE on tables without a key column ("safe updates", Error 1175).
-- The working table below has no key, so the check is switched off for this session
-- and switched back on at the end of the file.
SET SQL_SAFE_UPDATES = 0;

-- ---------------------------------------------------------------
-- R1  Standardised working copy of the raw table
-- ---------------------------------------------------------------
DROP TABLE IF EXISTS iowa_liquor_sales_stage;   -- working table, rebuilt on every run

CREATE TABLE iowa_liquor_sales_stage AS
SELECT NULLIF(UPPER(TRIM(invoice_id)), '')       AS invoice_id,
       ordered_on,
       store_no,
       NULLIF(UPPER(TRIM(store_name)), '')       AS store_name,
       NULLIF(UPPER(TRIM(store_address)), '')    AS store_address,
       NULLIF(UPPER(TRIM(store_city)), '')       AS store_city,
       NULLIF(TRIM(store_zip_code), '')          AS store_zip_code,
       NULLIF(TRIM(county_fips_code), '')        AS county_fips_code,
       NULLIF(UPPER(TRIM(county_name)), '')      AS county_name,
       NULLIF(TRIM(category_code), '')           AS category_code,
       NULLIF(UPPER(TRIM(category_name)), '')    AS category_name,
       NULLIF(TRIM(vendor_number), '')           AS vendor_number,
       NULLIF(UPPER(TRIM(vendor_name)), '')      AS vendor_name,
       NULLIF(UPPER(TRIM(item_no)), '')          AS item_no,
       NULLIF(UPPER(TRIM(im_desc)), '')          AS im_desc,
       pack,
       bottle_volume_ml,
       state_bottle_cost,
       state_bottle_retail,
       sales_bottles,
       sales_dollars,
       sales_liters,
       sales_gallons
FROM iowa_liquor_sales_raw;

-- ---------------------------------------------------------------
-- R2  Fill missing store location from the same store_no
-- ---------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS store_location_mode;

CREATE TEMPORARY TABLE store_location_mode (PRIMARY KEY (store_no)) AS
SELECT store_no, store_address, store_city, store_zip_code, county_fips_code, county_name
FROM (
  SELECT store_no, store_address, store_city, store_zip_code, county_fips_code, county_name,
         ROW_NUMBER() OVER (PARTITION BY store_no
                            ORDER BY COUNT(*) DESC, store_address, store_city) AS rn
  FROM iowa_liquor_sales_stage
  WHERE store_address IS NOT NULL AND store_city IS NOT NULL AND store_zip_code IS NOT NULL
    AND county_fips_code IS NOT NULL AND county_name IS NOT NULL
  GROUP BY store_no, store_address, store_city, store_zip_code, county_fips_code, county_name
) AS t
WHERE rn = 1;

UPDATE iowa_liquor_sales_stage AS s
JOIN store_location_mode AS m ON m.store_no = s.store_no
SET s.store_address    = COALESCE(s.store_address,    m.store_address),
    s.store_city       = COALESCE(s.store_city,       m.store_city),
    s.store_zip_code   = COALESCE(s.store_zip_code,   m.store_zip_code),
    s.county_fips_code = COALESCE(s.county_fips_code, m.county_fips_code),
    s.county_name      = COALESCE(s.county_name,      m.county_name)
WHERE s.store_address IS NULL OR s.store_city IS NULL OR s.store_zip_code IS NULL
   OR s.county_fips_code IS NULL OR s.county_name IS NULL;

-- ---------------------------------------------------------------
-- R3  Fill missing category from the same item_no, then name from code
-- ---------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS item_category_mode;

CREATE TEMPORARY TABLE item_category_mode (PRIMARY KEY (item_no)) AS
SELECT item_no, category_code, category_name
FROM (
  SELECT item_no, category_code, category_name,
         ROW_NUMBER() OVER (PARTITION BY item_no
                            ORDER BY COUNT(*) DESC, category_code) AS rn
  FROM iowa_liquor_sales_stage
  WHERE item_no IS NOT NULL AND category_code IS NOT NULL AND category_name IS NOT NULL
  GROUP BY item_no, category_code, category_name
) AS t
WHERE rn = 1;

UPDATE iowa_liquor_sales_stage AS s
JOIN item_category_mode AS m ON m.item_no = s.item_no
SET s.category_code = COALESCE(s.category_code, m.category_code),
    s.category_name = COALESCE(s.category_name, m.category_name)
WHERE s.category_code IS NULL OR s.category_name IS NULL;

DROP TEMPORARY TABLE IF EXISTS category_name_mode;

CREATE TEMPORARY TABLE category_name_mode (PRIMARY KEY (category_code)) AS
SELECT category_code, category_name
FROM (
  SELECT category_code, category_name,
         ROW_NUMBER() OVER (PARTITION BY category_code
                            ORDER BY COUNT(*) DESC, category_name) AS rn
  FROM iowa_liquor_sales_stage
  WHERE category_code IS NOT NULL AND category_name IS NOT NULL
  GROUP BY category_code, category_name
) AS t
WHERE rn = 1;

UPDATE iowa_liquor_sales_stage AS s
JOIN category_name_mode AS m ON m.category_code = s.category_code
SET s.category_name = m.category_name
WHERE s.category_name IS NULL;

-- ---------------------------------------------------------------
-- R4 + R5  Remove exact duplicates and flag returns
-- ---------------------------------------------------------------
DROP TABLE IF EXISTS iowa_liquor_sales_clean;   -- output table, rebuilt on every run

CREATE TABLE iowa_liquor_sales_clean (
  row_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
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
  is_return           TINYINT(1) NOT NULL
) ENGINE=InnoDB;

INSERT INTO iowa_liquor_sales_clean
      (invoice_id, ordered_on, store_no, store_name, store_address, store_city,
       store_zip_code, county_fips_code, county_name, category_code, category_name,
       vendor_number, vendor_name, item_no, im_desc, pack, bottle_volume_ml,
       state_bottle_cost, state_bottle_retail, sales_bottles, sales_dollars,
       sales_liters, sales_gallons, is_return)
SELECT DISTINCT
       invoice_id, ordered_on, store_no, store_name, store_address, store_city,
       store_zip_code, county_fips_code, county_name, category_code, category_name,
       vendor_number, vendor_name, item_no, im_desc, pack, bottle_volume_ml,
       state_bottle_cost, state_bottle_retail, sales_bottles, sales_dollars,
       sales_liters, sales_gallons,
       IF(sales_bottles < 0, 1, 0)
FROM iowa_liquor_sales_stage;

-- ---------------------------------------------------------------
-- Tidy up
-- ---------------------------------------------------------------
DROP TABLE iowa_liquor_sales_stage;
DROP TEMPORARY TABLE store_location_mode;
DROP TEMPORARY TABLE item_category_mode;
DROP TEMPORARY TABLE category_name_mode;
SET SQL_SAFE_UPDATES = 1;

SELECT COUNT(*) AS clean_rows FROM iowa_liquor_sales_clean;
