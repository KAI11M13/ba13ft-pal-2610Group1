# Iowa Liquor MySQL Data Warehouse

Source file:

`C:/Users/56426/Desktop/PAL/Cleaned/iowa_liquor_sales_clean.csv`

Data profile:

- 4,305,455 rows
- 25 columns
- Date range: 2025-01-01 to 2026-09-30
- `row_id` is unique and is used as the fact-table primary key
- 3,812 return lines
- 1,957 rows with missing store geography
- 26 rows with missing category
- IDs such as `store_no`, `store_zip_code`, `county_fips_code`, `category_code`, `vendor_number` and `item_no` are stored as text, not numbers

## Run order in MySQL Workbench

Open each file with **File > Open SQL Script** and execute it with the lightning-bolt button.

1. `01_create_database_and_staging.sql`
2. `02_load_staging.sql`
3. `03_build_dimensions.sql`
4. `04_build_fact.sql`
5. `05_build_mart.sql`
6. `99_validation.sql`

After step 1, refresh the Schemas panel and select `pal_dw`.

## If `LOAD DATA LOCAL INFILE` is blocked

Run this in Workbench:

```sql
SHOW VARIABLES LIKE 'local_infile';
```

If it is `OFF`, try as an administrator:

```sql
SET GLOBAL local_infile = 1;
```

Then reconnect and run `02_load_staging.sql` again.

If Workbench still rejects the command, use the server-side alternative:

1. Run `02b_load_staging_server_side.sql` only after checking:

```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

2. Copy `iowa_liquor_sales_clean.csv` into the folder returned by `secure_file_priv`.
3. Update the path in `02b_load_staging_server_side.sql`.
4. Run `02b_load_staging_server_side.sql`.

A 1.2 GB CSV may take several minutes to load. Do not close Workbench while it is running.

## Warehouse layers

- `stg_iowa_liquor_sales`: loaded source rows
- `dim_date`: date and week attributes
- `dim_store`: store master, latest non-empty attributes
- `dim_category`: category master plus `UNKNOWN`
- `dim_vendor`: vendor master
- `dim_product`: product version keyed by item, description, pack and volume
- `fact_purchase_line`: one row per cleaned source line
- `mart_store_category_week`: weekly store-category aggregates
- `vw_mart_store_category_week`: readable mart view with store and category names

## Important modelling note

The mart contains observed store-category weeks only. After selecting the modelling cohort, create a dense calendar grid for those store-category pairs and fill absent weeks with zero demand where source coverage is confirmed.

Return lines remain in the fact table as negative quantities. The mart separates:

- `positive_bottles`
- `return_bottles` (negative)
- `net_bottles`

## Data caveats

`item_no` alone is not a stable product key: some item numbers have multiple descriptions, categories, vendors, pack sizes or bottle volumes. The product dimension therefore uses the composite key:

`item_no + im_desc + pack + bottle_volume_ml`

Category and vendor are kept as separate dimension keys in the fact table.

Zero price values are retained as reported records, but should be treated as unreported or missing for modelling rather than as genuine zero-price sales.