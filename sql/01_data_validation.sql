-- Project: Construction Operations & Project Performance Intelligence
-- Purpose: Validate the imported Portfolio WBS table.
-- Platform: Google BigQuery

-- 1. Check table size and financial completeness.
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(BAC IS NOT NULL) AS rows_with_bac,
  COUNTIF(`Final Cost` IS NOT NULL) AS rows_with_final_cost,
  COUNTIF(BAC IS NOT NULL AND `Final Cost` IS NOT NULL)
    AS rows_with_both,
  COUNTIF(BAC IS NULL AND `Final Cost` IS NULL)
    AS rows_with_neither
FROM `peak-engine-510514.construction_analytics.portfolio_wbs`;

-- 2. Check for duplicate WBS identifiers among financial records.
SELECT
  `Portfolio WBS`,
  COUNT(*) AS row_count
FROM `peak-engine-510514.construction_analytics.portfolio_wbs`
WHERE BAC IS NOT NULL
   OR `Final Cost` IS NOT NULL
GROUP BY `Portfolio WBS`
HAVING COUNT(*) > 1
ORDER BY row_count DESC;
