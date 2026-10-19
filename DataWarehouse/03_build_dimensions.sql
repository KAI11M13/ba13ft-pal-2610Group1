-- 03_build_dimensions.sql
USE pal_dw;

-- Date dimension: one row per transaction date present in staging.
CREATE TABLE IF NOT EXISTS dim_date (
  date_key INT NOT NULL,
  full_date DATE NOT NULL,
  year SMALLINT NOT NULL,
  quarter TINYINT NOT NULL,
  month TINYINT NOT NULL,
  month_name VARCHAR(20) NOT NULL,
  week_of_year TINYINT NOT NULL,
  week_start_date DATE NOT NULL,
  day_of_week TINYINT NOT NULL,
  is_weekend TINYINT NOT NULL,
  PRIMARY KEY (date_key),
  UNIQUE KEY uq_dim_date_full_date (full_date),
  KEY idx_dim_date_week_start (week_start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dim_store (
  store_key INT NOT NULL AUTO_INCREMENT,
  store_no VARCHAR(20) NOT NULL,
  store_name VARCHAR(255) NULL,
  store_address VARCHAR(255) NULL,
  store_city VARCHAR(100) NULL,
  store_zip_code VARCHAR(10) NULL,
  county_fips_code VARCHAR(5) NULL,
  county_name VARCHAR(100) NULL,
  PRIMARY KEY (store_key),
  UNIQUE KEY uq_dim_store_no (store_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dim_category (
  category_key INT NOT NULL AUTO_INCREMENT,
  category_code VARCHAR(20) NOT NULL,
  category_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (category_key),
  UNIQUE KEY uq_dim_category_code (category_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dim_vendor (
  vendor_key INT NOT NULL AUTO_INCREMENT,
  vendor_number VARCHAR(20) NOT NULL,
  vendor_name VARCHAR(255) NOT NULL,
  PRIMARY KEY (vendor_key),
  UNIQUE KEY uq_dim_vendor_number (vendor_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dim_product (
  product_key BIGINT NOT NULL AUTO_INCREMENT,
  item_no VARCHAR(20) NOT NULL,
  im_desc VARCHAR(255) NOT NULL,
  pack INT NOT NULL,
  bottle_volume_ml INT NOT NULL,
  PRIMARY KEY (product_key),
  UNIQUE KEY uq_dim_product (item_no, im_desc, pack, bottle_volume_ml)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

TRUNCATE TABLE dim_date;
TRUNCATE TABLE dim_store;
TRUNCATE TABLE dim_category;
TRUNCATE TABLE dim_vendor;
TRUNCATE TABLE dim_product;

INSERT INTO dim_date (
  date_key, full_date, year, quarter, month, month_name,
  week_of_year, week_start_date, day_of_week, is_weekend
)
SELECT
  CAST(DATE_FORMAT(d.ordered_on, '%Y%m%d') AS UNSIGNED) AS date_key,
  d.ordered_on AS full_date,
  YEAR(d.ordered_on) AS year,
  QUARTER(d.ordered_on) AS quarter,
  MONTH(d.ordered_on) AS month,
  MONTHNAME(d.ordered_on) AS month_name,
  WEEK(d.ordered_on, 3) AS week_of_year,
  DATE_SUB(d.ordered_on, INTERVAL WEEKDAY(d.ordered_on) DAY) AS week_start_date,
  WEEKDAY(d.ordered_on) + 1 AS day_of_week,
  CASE WHEN WEEKDAY(d.ordered_on) >= 5 THEN 1 ELSE 0 END AS is_weekend
FROM (
  SELECT DISTINCT ordered_on
  FROM stg_iowa_liquor_sales
  WHERE ordered_on IS NOT NULL
) d;

INSERT INTO dim_store (
  store_no, store_name, store_address, store_city,
  store_zip_code, county_fips_code, county_name
)
SELECT
  TRIM(store_no) AS store_no,
  MAX(NULLIF(TRIM(store_name), '')) AS store_name,
  MAX(NULLIF(TRIM(store_address), '')) AS store_address,
  MAX(NULLIF(TRIM(store_city), '')) AS store_city,
  MAX(NULLIF(TRIM(store_zip_code), '')) AS store_zip_code,
  MAX(NULLIF(TRIM(county_fips_code), '')) AS county_fips_code,
  MAX(NULLIF(TRIM(county_name), '')) AS county_name
FROM stg_iowa_liquor_sales
WHERE NULLIF(TRIM(store_no), '') IS NOT NULL
GROUP BY TRIM(store_no);

INSERT INTO dim_category (category_code, category_name)
VALUES ('UNKNOWN', 'UNKNOWN');

INSERT IGNORE INTO dim_category (category_code, category_name)
SELECT
  COALESCE(NULLIF(TRIM(category_code), ''), 'UNKNOWN') AS category_code,
  COALESCE(MAX(NULLIF(TRIM(category_name), '')), 'UNKNOWN') AS category_name
FROM stg_iowa_liquor_sales
GROUP BY COALESCE(NULLIF(TRIM(category_code), ''), 'UNKNOWN');

INSERT INTO dim_vendor (vendor_number, vendor_name)
SELECT
  TRIM(vendor_number) AS vendor_number,
  COALESCE(MAX(NULLIF(TRIM(vendor_name), '')), 'UNKNOWN') AS vendor_name
FROM stg_iowa_liquor_sales
WHERE NULLIF(TRIM(vendor_number), '') IS NOT NULL
GROUP BY TRIM(vendor_number);

INSERT INTO dim_product (item_no, im_desc, pack, bottle_volume_ml)
SELECT
  TRIM(item_no) AS item_no,
  COALESCE(NULLIF(TRIM(im_desc), ''), 'UNKNOWN') AS im_desc,
  pack,
  bottle_volume_ml
FROM stg_iowa_liquor_sales
GROUP BY
  TRIM(item_no),
  COALESCE(NULLIF(TRIM(im_desc), ''), 'UNKNOWN'),
  pack,
  bottle_volume_ml;