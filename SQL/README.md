# Iowa Liquor Sales: MySQL load and cleaning

Loads the frozen Iowa Data Hub release (published 2026-10-06, orders 2025-01-01 to 2026-09-30) into MySQL and builds a cleaned table.

**Setup**: MySQL 8.0 and Workbench. Add `OPT_LOCAL_INFILE=1` under the connection's Advanced > Others, and set the SQL Editor read timeout to 3600. Update the file paths in 02, 03 and 08.

## Steps

| Step | Purpose | Pass check |
|---|---|---|
| 00 | Allow local file loading | `local_infile` = ON |
| 01 | Create `pal_liquor` and `iowa_liquor_sales_raw` | No errors |
| 02 | Load the first file | 598,080 rows, 0 warnings |
| 03 | Load the other 8 files | 0 warnings |
| 04 | Check rows per file | All `diff` = 0, 4,735,465 rows |
| 05 | Profile data quality (read-only) | Record results |
| 06 | Build `iowa_liquor_sales_clean` | Row count printed |
| 07 | Compare raw and clean (read-only) | Record results |
| 08 | Export the clean table to CSV | File rows = count + 1 |

## Cleaning rules (06)

1. Trim and upper-case text; empty strings become NULL.
2. Fill missing store location from the same `store_no`.
3. Fill missing category from the same `item_no`.
4. Remove rows identical in every column.
5. Flag returns (`sales_bottles < 0`) as `is_return = 1` and keep them.

## Known issues

- 2025 part 0005 adds 429,989 rows beyond the official 2,490,620.
- The raw table has 2,970,327 repeated `invoice_id` rows; only exact duplicates are removed.

## Notes

- 05 and 06 take about 10 and 20 minutes; run 06 in one Workbench tab.
- Error 2068: add `OPT_LOCAL_INFILE=1`. Error 2013: raise the read timeout. Error 1290: export to the `secure_file_priv` folder.
