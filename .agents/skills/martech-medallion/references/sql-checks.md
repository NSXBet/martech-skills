# Read-only SQL checks

Examples for Databricks SQL; they are not a live audit or a complete test suite. Verify actual schema, runtime, permissions, and the contract before adapting them. Replace synthetic object names with inspected fully qualified names. Use explicit scope predicates; `LIMIT` limits output, not necessarily scan cost. Keep customer records out of review reports.

## Metadata inventory

```sql
-- Replace example_marketing_dev and the schema list with the approved scope.
SELECT table_catalog, table_schema, table_name, table_type, table_owner, comment
FROM system.information_schema.tables
WHERE table_catalog = 'example_marketing_dev'
  AND table_schema IN ('bronze', 'silver', 'gold')
ORDER BY table_schema, table_name;

SELECT table_catalog, table_schema, table_name, ordinal_position,
       column_name, full_data_type, is_nullable, comment
FROM system.information_schema.columns
WHERE table_catalog = 'example_marketing_dev'
  AND table_schema IN ('bronze', 'silver', 'gold')
ORDER BY table_schema, table_name, ordinal_position;
```

These results are filtered by access and exclude legacy Hive metastore objects. Reconcile visibility to the expected inventory. Inspect definitions with `SHOW CREATE TABLE` or `DESCRIBE TABLE EXTENDED` on verified objects to understand actual transformations; metadata alone cannot establish layer fit.

## Null and duplicate keys at a contracted grain

```sql
-- Synthetic daily campaign contract with NO additional report breakdowns.
-- Extend the key for every contracted breakdown before using this check.
WITH scoped AS (
  SELECT source_system, brand_id, account_id, campaign_id, report_date
  FROM example_marketing_dev.silver.campaign_daily
  WHERE report_date >= DATE '2026-08-01'
    AND report_date < DATE '2026-09-01'
    AND brand_id = 'example_brand'
), key_counts AS (
  SELECT source_system, brand_id, account_id, campaign_id, report_date,
         COUNT(*) AS n
  FROM scoped
  GROUP BY source_system, brand_id, account_id, campaign_id, report_date
)
SELECT
  (SELECT COUNT(*) FROM scoped) AS scoped_rows,
  (SELECT COUNT(*) FROM scoped
   WHERE source_system IS NULL OR brand_id IS NULL OR account_id IS NULL
      OR campaign_id IS NULL OR report_date IS NULL) AS null_key_rows,
  COALESCE(SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END), 0) AS duplicate_groups,
  COALESCE(SUM(CASE WHEN n > 1 THEN n - 1 ELSE 0 END), 0) AS excess_rows
FROM key_counts;
```

The date predicate excludes null dates, and the brand predicate excludes missing brand context. Audit those separately using a trusted ingestion manifest/window over the same delivery population. Empty `scoped_rows` is not a passing key test unless the contract proves no rows were expected. Do not expose raw keys merely to report duplicate counts.

## Reconciliation: missing is different from zero

This self-contained synthetic fixture demonstrates explicit expected coverage and zero-baseline handling. The 1% and zero absolute tolerances below belong only to the fixture. Production tolerances require the contract owner's decision.

```sql
WITH expected(metric_key, expected_amount) AS (
  VALUES ('within_tolerance', 100.0), ('zero_match', 0.0),
         ('zero_mismatch', 0.0), ('missing_actual', 50.0),
         ('missing_both', CAST(NULL AS DOUBLE)),
         ('negative_baseline', -100.0)
), actual(metric_key, actual_amount) AS (
  VALUES ('within_tolerance', 100.5), ('zero_match', 0.0),
         ('zero_mismatch', 1.0), ('unexpected_actual', 20.0),
         ('negative_baseline', -98.0)
), all_keys AS (
  SELECT metric_key FROM expected
  UNION
  SELECT metric_key FROM actual
), compared AS (
  SELECT k.metric_key, e.expected_amount, a.actual_amount,
         ABS(a.actual_amount - e.expected_amount) AS absolute_difference,
         CASE WHEN e.expected_amount <> 0
              THEN ABS(a.actual_amount - e.expected_amount)
                   / ABS(e.expected_amount) END AS relative_difference
  FROM all_keys k
  LEFT JOIN expected e ON k.metric_key = e.metric_key
  LEFT JOIN actual a ON k.metric_key = a.metric_key
)
SELECT *,
       CASE WHEN expected_amount IS NULL OR actual_amount IS NULL
              THEN 'Inconclusive'
            WHEN expected_amount = 0 AND absolute_difference = 0
              THEN 'Pass'
            WHEN expected_amount = 0 THEN 'Fail'
            WHEN relative_difference <= 0.01 THEN 'Pass'
            ELSE 'Fail' END AS result
FROM compared
ORDER BY metric_key;
```

Expected outcomes: `within_tolerance`, `zero_match` pass; `zero_mismatch`, `negative_baseline` fail; `missing_actual`, `missing_both`, `unexpected_actual` are inconclusive. In production, create the expected population from the contractual calendar/account inventory, not only existing records, so holes on both sides remain visible. Aggregate both inputs to the same full comparison key and prove key uniqueness before joining. Include record counts and test row coverage independently of metric totals.

## Additional checks to generate from inspected contracts

- Orphans: anti-join each nullable/non-nullable relationship with the complete namespace key and, for historical dimensions, the correct effective interval. Report the eligible denominator and unresolved late dimensions.
- Taxonomy: count unmapped rows and total eligible rows by source/brand/report day; distinguish source null, unknown mapping, and deliberate Unassigned classification.
- Disposition: compare the extraction manifest to raw capture and terminal record dispositions. Avoid adding overlapping rule-failure counts as if they represented distinct rejected records.
- Join fanout: compare measure totals and record multiplicities before/after joins at the measure's original grain.
- Replay: in an authorized test environment, repeat a fixed input window and inject a later revision; compare keys, row counts, history and measures. Read-only profiling alone cannot prove replay idempotency.

Store generated query artifacts and observed results separately. Label these examples Not run against the workspace until executed there; local synthetic execution does not validate Databricks schemas, feature support, or production data.
