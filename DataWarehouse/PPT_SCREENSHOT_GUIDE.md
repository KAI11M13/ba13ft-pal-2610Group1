# PPT Screenshot Guide

Save all screenshots in:

`C:\Users\56426\Desktop\PAL\mysql_dw\ppt_images`

Use Windows Snipping Tool: `Win + Shift + S`.

## Screenshot 1 - Schema tree

1. In Workbench, refresh the `pal_dw` schema.
2. Expand `Tables`.
3. Make these visible:

- stg_iowa_liquor_sales
- dim_date
- dim_store
- dim_product
- dim_category
- dim_vendor
- fact_purchase_line
- mart_store_category_week

4. Expand `Views` so `vw_mart_store_category_week` is visible.
5. Capture the Schema tree.

Save as: `01_schema_tree.png`.

## Screenshot 2 - Validation summary

1. Open `PPT_PRESENTATION_QUERIES.sql`.
2. Select only the SQL under `SCREENSHOT 2`.
3. Press `Ctrl + Enter`.
4. Capture the Result Grid with `status = OK`.

Save as: `02_validation.png`.

## Screenshot 3 - Top categories

1. Select only the SQL under `SCREENSHOT 3`.
2. Press `Ctrl + Enter`.
3. Capture the 10-row Result Grid.

Save as: `03_top_categories.png`.

## Screenshot 4 - Monthly trend

1. Select only the SQL under `SCREENSHOT 4`.
2. Press `Ctrl + Enter`.
3. Capture the 9-row monthly result.

Save as: `04_monthly_trend.png`.

## Screenshot 5 - Latest-week store-category

1. Select only the SQL under `SCREENSHOT 5`.
2. Press `Ctrl + Enter`.
3. Capture the 15-row Result Grid.

Save as: `05_latest_week.png`.

## PPT placement

- Slide 1: architecture + Screenshot 1
- Slide 2: star schema
- Slide 3: Screenshot 2
- Slide 4: Screenshots 3 and 4
- Slide 5: Screenshot 5 + business takeaway

## Speaking point

"The MySQL warehouse is fully validated. The cleaned source data has 4.3 million lines, the fact table contains the same number of records, all dimension joins resolve, and the weekly Mart contains 1.64 million store-category-week observations."