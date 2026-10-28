
-- Project: Construction Operations & Project Performance Intelligence
-- Purpose: Validate the cleaned analytical table.
-- Expected result: 63 work packages.

SELECT
  COUNT(*) AS total_work_packages,
  COUNTIF(bac IS NOT NULL) AS packages_with_budget,
  COUNTIF(final_cost IS NOT NULL) AS packages_with_final_cost,
  COUNTIF(
    bac IS NOT NULL AND final_cost IS NOT NULL
  ) AS packages_with_both
FROM
  `peak-engine-510514.construction_analytics.portfolio_wbs_clean`;
