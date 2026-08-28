-- STEP 2 OF 2 -- confirm the grain of a candidate table.
--
-- Run only after 01_inventory_export.sql has identified candidates, once per
-- shortlisted table. A candidate only satisfies a requirement if its grain
-- matches the one stated in docs/data-requirements.md. This script checks a
-- proposed key: it is the grain if the row count equals the distinct key count.
--
-- UNLIKE STEP 1, THIS READS TABLE DATA -- row counts, snapshot dates and
-- reason-code values. Review the output before attaching it to an issue or PR.
--
-- Set :catalog, :schema, :table and edit the key expression list below.

SELECT
  count(*)                        AS row_count,
  count(DISTINCT grain_key)       AS distinct_key_count,
  count(*) = count(DISTINCT grain_key) AS key_is_grain
FROM (
  SELECT concat_ws('|',
    /* EDIT HERE ONLY -- replace with the proposed grain columns, e.g.
       cast(case_id AS string), or for a role x week grain:
       cast(role_id AS string), cast(week_start AS string).
       Left as an obvious placeholder so an unedited run fails loudly. */
    cast(replace_with_your_grain_column AS string)
  ) AS grain_key
  FROM identifier(:catalog || '.' || :schema || '.' || :table)
);

-- Snapshot coverage: the KPI tiles need a daily snapshot grain, so confirm the
-- snapshot column is populated daily and how far back the history runs. Edit
-- the date column name to match the table.
SELECT
  min(snapshot_date)                        AS first_snapshot,
  max(snapshot_date)                        AS latest_snapshot,
  count(DISTINCT snapshot_date)             AS distinct_days,
  datediff(max(snapshot_date), min(snapshot_date)) + 1 AS calendar_day_span,
  count(DISTINCT snapshot_date)
    = datediff(max(snapshot_date), min(snapshot_date)) + 1 AS is_complete_daily
FROM identifier(:catalog || '.' || :schema || '.' || :table);

-- Reason-code check: the roadblock and blocker panels aggregate reasons, so the
-- reason column must be a bounded code set rather than free text. A high
-- distinct count relative to row count indicates free text (gap G-06).
SELECT
  reason_code,
  count(*) AS occurrences
FROM identifier(:catalog || '.' || :schema || '.' || :table)
GROUP BY reason_code
ORDER BY occurrences DESC
LIMIT 100;
