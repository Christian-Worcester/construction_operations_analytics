
-- Project: Construction Operations & Project Performance Intelligence
-- Purpose: Compare budgeted costs with final costs.
-- Platform: Google BigQuery

SELECT
  portfolio_wbs,
  description,
  bac,
  final_cost,
  final_cost - bac AS cost_variance,
  SAFE_DIVIDE(final_cost - bac, bac) * 100
    AS variance_pct
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs_clean`
WHERE
  bac IS NOT NULL
  AND final_cost IS NOT NULL
ORDER BY
  cost_variance DESC;

-- Query 2: Summarize budget performance across comparable work packages.
-- Scope: Records with both budget and final cost available.

WITH variance_analysis AS (
  SELECT
    bac,
    final_cost,
    final_cost - bac AS cost_variance
  FROM
    `peak-engine-510514.construction_analytics.portfolio_wbs_clean`
  WHERE
    bac IS NOT NULL
    AND final_cost IS NOT NULL
)

SELECT
  COUNT(*) AS work_packages_analyzed,
  SUM(bac) AS combined_budget,
  SUM(final_cost) AS combined_final_cost,
  SUM(cost_variance) AS net_cost_variance,
  COUNTIF(cost_variance > 0) AS packages_over_budget,
  COUNTIF(cost_variance < 0) AS packages_under_budget,
  COUNTIF(cost_variance = 0) AS packages_on_budget,
  SAFE_DIVIDE(SUM(cost_variance), SUM(bac)) * 100
    AS weighted_variance_pct
FROM
  variance_analysis;

-- Query 3: Separate gross overruns from underspends.
-- Purpose: Identify how positive and negative variances
-- combine to produce the net cost variance.

WITH variance_analysis AS (
  SELECT
    portfolio_wbs,
    description,
    bac,
    final_cost,
    final_cost - bac AS cost_variance
  FROM
    `peak-engine-510514.construction_analytics.portfolio_wbs_clean`
  WHERE
    bac IS NOT NULL
    AND final_cost IS NOT NULL
)

SELECT
  COUNTIF(cost_variance > 0) AS over_budget_packages,

  SUM(
    CASE
      WHEN cost_variance > 0 THEN cost_variance
      ELSE 0
    END
  ) AS total_over_budget_amount,

  COUNTIF(cost_variance < 0) AS under_budget_packages,

  SUM(
    CASE
      WHEN cost_variance < 0 THEN ABS(cost_variance)
      ELSE 0
    END
  ) AS total_under_budget_amount,

  SUM(cost_variance) AS net_cost_variance

FROM
  variance_analysis;
  
-- Query 4: Identify work packages missing financial values.
-- Purpose: Investigate records excluded from variance analysis.

SELECT
  portfolio_wbs,
  description,
  bac,
  final_cost,
  CASE
    WHEN bac IS NULL AND final_cost IS NULL
      THEN 'Missing budget and final cost'
    WHEN bac IS NULL
      THEN 'Missing budget'
    WHEN final_cost IS NULL
      THEN 'Missing final cost'
  END AS missing_data_status
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs_clean`
WHERE
  bac IS NULL
  OR final_cost IS NULL
ORDER BY
  missing_data_status,
  portfolio_wbs;
  
-- Query 5: Reconcile cleaned work-package totals.
-- Purpose: Compare totals across all available financial records
-- against the original workbook's reported portfolio totals.

SELECT
  COUNT(*) AS total_work_packages,

  COUNTIF(bac IS NOT NULL) AS packages_with_budget,
  SUM(bac) AS total_available_budget,

  COUNTIF(final_cost IS NOT NULL) AS packages_with_final_cost,
  SUM(final_cost) AS total_available_final_cost,

  SUM(
    CASE
      WHEN bac IS NOT NULL AND final_cost IS NOT NULL
      THEN bac
      ELSE 0
    END
  ) AS comparable_packages_budget,

  SUM(
    CASE
      WHEN bac IS NOT NULL AND final_cost IS NOT NULL
      THEN final_cost
      ELSE 0
    END
  ) AS comparable_packages_final_cost

FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs_clean`;

-- Query 6: Top 10 Work Packages by Dollar Overrun

SELECT
  portfolio_wbs,
  description,
  bac,
  final_cost,
  final_cost - bac AS cost_variance,
  SAFE_DIVIDE(final_cost - bac, bac) * 100 AS variance_pct
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs_clean`
WHERE
  bac IS NOT NULL
  AND final_cost IS NOT NULL
  AND final_cost > bac
ORDER BY
  cost_variance DESC
LIMIT 10;

-- Query 7: Top 10 Work Packages by Percentage Overrun

SELECT
  portfolio_wbs,
  description,
  bac,
  final_cost,
  final_cost - bac AS cost_variance,
  SAFE_DIVIDE(final_cost - bac, bac) * 100 AS variance_pct
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs_clean`
WHERE
  bac IS NOT NULL
  AND final_cost IS NOT NULL
  AND bac > 0
  AND final_cost > bac
ORDER BY
  variance_pct DESC
LIMIT 10;
