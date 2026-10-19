# MySQL Data Warehouse - PPT Outline

## Slide 1 - Scope and architecture

Source: Iowa Liquor Sales 2025-2026, 4,305,455 cleaned transaction lines.

Architecture:

Cleaned CSV -> MySQL staging -> dimensions -> fact -> weekly mart.

## Slide 2 - Star schema

Fact table:

- fact_purchase_line

Dimensions:

- dim_date
- dim_store
- dim_product
- dim_category
- dim_vendor

Grain: one source purchase line per fact row.

## Slide 3 - Data quality and validation

Show the validation query result:

- staging_rows = 4,305,455
- fact_rows = 4,305,455
- mart_rows = 1,644,490
- unmatched_store = 0
- unmatched_product = 0
- fact_minus_staging = 0

## Slide 4 - OLAP demonstration

Show one or two query results:

1. Top 10 categories by sales value.
2. Weekly sales trend in 2026.
3. Latest-week top store-category combinations.

## What to say

"The warehouse is validated end to end. Every cleaned source line is traceable to one fact record, all dimension joins resolve, and the weekly mart is ready for the forecasting team."