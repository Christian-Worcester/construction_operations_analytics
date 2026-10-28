
-- Project: Construction Operations & Project Performance Intelligence
-- File: 03_create_clean_table.sql
-- Purpose: Create a clean analytical table from the imported source.
-- Platform: Google BigQuery

CREATE OR REPLACE TABLE
  `peak-engine-510514.construction_analytics.portfolio_wbs_clean` AS

SELECT
  TRIM(`Portfolio WBS`) AS portfolio_wbs,
  TRIM(Description) AS description,
  Quantity AS quantity,
  NULLIF(TRIM(UOM), '') AS uom,

  SAFE_CAST(
    REPLACE(NULLIF(TRIM(BAC), '-'), ',', '')
    AS NUMERIC
  ) AS bac,

  SAFE_CAST(
    REPLACE(NULLIF(TRIM(`BAC Rate`), '-'), ',', '')
    AS NUMERIC
  ) AS bac_rate,

  SAFE_CAST(
    REPLACE(NULLIF(TRIM(`Final Qty`), '-'), ',', '')
    AS NUMERIC
  ) AS final_qty,

  SAFE_CAST(
    REPLACE(NULLIF(TRIM(`Final Cost`), '-'), ',', '')
    AS NUMERIC
  ) AS final_cost,

  SAFE_CAST(
    REPLACE(NULLIF(TRIM(`Final Rate`), '-'), ',', '')
    AS NUMERIC
  ) AS final_rate

FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs`

WHERE
  NULLIF(TRIM(`Portfolio WBS`), '') IS NOT NULL
  AND NULLIF(TRIM(Description), '') IS NOT NULL;
