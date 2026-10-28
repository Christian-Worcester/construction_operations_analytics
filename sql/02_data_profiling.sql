
-- ============================================================
-- Project: Construction Operations & Project Performance Intelligence
-- File: 02_data_profiling.sql
-- Platform: Google BigQuery
-- Source: Airport Carpark - Portfolio WBS
-- Purpose: Understand the structure, completeness, and quality
--          of the imported financial data before cleaning.
-- ============================================================


-- QUERY 1: Inspect column names and data types
-- Business purpose:
-- Understand how BigQuery imported each column, especially
-- whether budget and cost fields are numeric or text.

SELECT
  column_name,
  data_type
FROM
  `peak-engine-510514.construction_analytics.INFORMATION_SCHEMA.COLUMNS`
WHERE
  table_name = 'portfolio_wbs'
ORDER BY
  ordinal_position;


-- QUERY 2: Inspect common budget and cost values
-- Business purpose:
-- Identify missing values, dash placeholders, and the formatting
-- used for budget and final-cost figures.

SELECT
  BAC,
  `Final Cost`,
  COUNT(*) AS row_count
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs`
GROUP BY
  BAC,
  `Final Cost`
ORDER BY
  row_count DESC
LIMIT 30;


-- QUERY 3: Test conversion of text financial values to numbers
-- Business purpose:
-- Check whether budget and final-cost values can be converted
-- safely before performing financial calculations.
-- This query does not modify the source table.

SELECT
  `Portfolio WBS`,
  Description,
  BAC AS original_bac,
  SAFE_CAST(
    REPLACE(NULLIF(TRIM(BAC), '-'), ',', '')
    AS NUMERIC
  ) AS bac_numeric,
  `Final Cost` AS original_final_cost,
  SAFE_CAST(
    REPLACE(NULLIF(TRIM(`Final Cost`), '-'), ',', '')
    AS NUMERIC
  ) AS final_cost_numeric
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs`
WHERE
  BAC IS NOT NULL
  OR `Final Cost` IS NOT NULL
ORDER BY
  `Portfolio WBS`;


-- QUERY 4: Count usable financial values after conversion
-- Business purpose:
-- Establish how many rows contain usable budget and final-cost
-- values, including how many have both values available.

WITH cleaned AS (
  SELECT
    `Portfolio WBS`,
    SAFE_CAST(
      REPLACE(NULLIF(TRIM(BAC), '-'), ',', '')
      AS NUMERIC
    ) AS bac_numeric,
    SAFE_CAST(
      REPLACE(NULLIF(TRIM(`Final Cost`), '-'), ',', '')
      AS NUMERIC
    ) AS final_cost_numeric
  FROM
    `peak-engine-510514.construction_analytics.portfolio_wbs`
)
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(
    bac_numeric IS NOT NULL
    OR final_cost_numeric IS NOT NULL
  ) AS rows_with_financial_data,
  COUNTIF(bac_numeric IS NOT NULL) AS rows_with_budget,
  COUNTIF(final_cost_numeric IS NOT NULL) AS rows_with_final_cost,
  COUNTIF(
    bac_numeric IS NOT NULL
    AND final_cost_numeric IS NOT NULL
  ) AS rows_with_both,
  COUNTIF(
    bac_numeric IS NULL
    AND final_cost_numeric IS NULL
  ) AS rows_missing_both
FROM cleaned;


-- QUERY 5: Identify unexpected nonnumeric financial values
-- Business purpose:
-- Find nonmissing budget or cost values that fail numeric
-- conversion so they can be investigated before analysis.

SELECT
  `Portfolio WBS`,
  Description,
  BAC,
  `Final Cost`
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs`
WHERE
  (
    BAC IS NOT NULL
    AND TRIM(BAC) != ''
    AND TRIM(BAC) != '-'
    AND SAFE_CAST(
      REPLACE(TRIM(BAC), ',', '') AS NUMERIC
    ) IS NULL
  )
  OR
  (
    `Final Cost` IS NOT NULL
    AND TRIM(`Final Cost`) != ''
    AND TRIM(`Final Cost`) != '-'
    AND SAFE_CAST(
      REPLACE(TRIM(`Final Cost`), ',', '') AS NUMERIC
    ) IS NULL
  );

-- Project: Construction Operations & Project Performance Intelligence
-- Purpose: Inspect rows that contain work-package identifiers
-- and descriptions before creating a cleaned table.

SELECT
  `Portfolio WBS`,
  Description,
  Quantity,
  UOM,
  BAC,
  `Final Cost`
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs`
WHERE
  `Portfolio WBS` IS NOT NULL
  OR Description IS NOT NULL
ORDER BY
  `Portfolio WBS`
LIMIT 100;

-- Project: Construction Operations & Project Performance Intelligence
-- Purpose: Profile work-package identifiers and descriptions.
-- This helps distinguish actual records from blank spreadsheet rows.

SELECT
  COUNT(*) AS total_rows,
  COUNTIF(
    NULLIF(TRIM(`Portfolio WBS`), '') IS NOT NULL
  ) AS rows_with_wbs,
  COUNTIF(
    NULLIF(TRIM(Description), '') IS NOT NULL
  ) AS rows_with_description,
  COUNTIF(
    NULLIF(TRIM(`Portfolio WBS`), '') IS NOT NULL
    AND NULLIF(TRIM(Description), '') IS NOT NULL
  ) AS rows_with_both,
  COUNTIF(
    NULLIF(TRIM(`Portfolio WBS`), '') IS NULL
    AND NULLIF(TRIM(Description), '') IS NULL
  ) AS rows_missing_both
FROM
  `peak-engine-510514.construction_analytics.portf
