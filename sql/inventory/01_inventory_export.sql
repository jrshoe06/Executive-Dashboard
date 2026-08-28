-- STEP 1 OF 2 -- Executive Dashboard catalog inventory, one-shot export.
--
-- Run this as-is in a Databricks SQL warehouse. No widgets, no parameters, no
-- edits required. Download the result as CSV and attach it to the issue or PR.
--
-- READS METADATA ONLY. Every table referenced here is system.information_schema,
-- which holds object names, column names and comments. This query does not read
-- a single row of business data, so the output contains no client, case,
-- personnel or compensation values and is safe to share.
--
-- Output: one row per table or view in the metastore that is either in a
-- silver/gold schema or keyword-matches a dashboard requirement.
--
--   requirements   which dashboard component(s) the object might serve, or
--                  '(unmatched)' for silver/gold objects nothing matched
--   column_list    full column list, so grain can be assessed without a second
--                  round trip
--
-- Catalogs excluded below are Databricks-managed ones. Note that
-- `hive_metastore` is NOT excluded: it is a common default catalog that can
-- hold real user tables, so it is left in deliberately. If your workspace has
-- other system-like catalogs, add them to the exclusion list.
--
-- See docs/catalog-inventory.md for what happens with the output.

WITH cols AS (
  SELECT
    table_catalog,
    table_schema,
    table_name,
    array_join(array_sort(collect_set(lower(column_name))), ', ') AS column_list
  FROM system.information_schema.columns
  GROUP BY table_catalog, table_schema, table_name
),

objects AS (
  SELECT
    t.table_catalog,
    t.table_schema,
    t.table_name,
    t.table_type,
    coalesce(t.comment, '')       AS table_comment,
    coalesce(c.column_list, '')   AS column_list,
    t.last_altered
  FROM system.information_schema.tables AS t
  LEFT JOIN cols AS c
    ON  c.table_catalog = t.table_catalog
    AND c.table_schema  = t.table_schema
    AND c.table_name    = t.table_name
  WHERE lower(t.table_catalog) NOT IN ('system', 'samples', '__databricks_internal')
),

-- Keyword patterns per dashboard component. Deliberately broad: reviewing a
-- false positive is cheap, missing an existing table and rebuilding it is not.
requirements AS (
  SELECT * FROM VALUES
    ('comp_to_rev',         'compensation|comp_|payroll|salary|revenue|billing|finance|invoice'),
    ('staffing_demand',     'forecast|demand|capacity|headcount|fte|resourc'),
    ('staffing_supply',     'supply|roster|assignment|allocation|attrition|hire|start_date'),
    ('requisition',         'requisition|req_|pipeline|recruit|candidate|vacanc'),
    ('data_quality',        'data_quality|dq_|quality_check|expectation|validation|dqm'),
    ('cases',               'case|matter|milestone|sla|planned_date|due_date|deadline'),
    ('case_status_history', 'status_history|state_history|audit|transition|scd|history|event_log'),
    ('intercom',            'intercom|conversation|first_response|response_time|ticket'),
    ('report_metadata',     'report_metadata|report_catalog|business_summary|questions_answered')
    AS r(requirement, pattern)
),

matched AS (
  SELECT
    o.table_catalog,
    o.table_schema,
    o.table_name,
    array_join(array_sort(collect_set(r.requirement)), ', ') AS requirements
  FROM objects AS o
  JOIN requirements AS r
    ON lower(concat_ws(' ', o.table_name, o.table_comment, o.column_list)) RLIKE r.pattern
  GROUP BY o.table_catalog, o.table_schema, o.table_name
)

SELECT
  o.table_catalog,
  o.table_schema,
  o.table_name,
  o.table_type,
  coalesce(m.requirements, '(unmatched)') AS requirements,
  o.table_comment,
  o.column_list,
  o.last_altered
FROM objects AS o
LEFT JOIN matched AS m
  ON  m.table_catalog = o.table_catalog
  AND m.table_schema  = o.table_schema
  AND m.table_name    = o.table_name
-- Keep silver/gold objects even when nothing matched, so a table with an
-- unexpected name is not silently dropped from the inventory.
WHERE m.requirements IS NOT NULL
   OR lower(o.table_schema) LIKE '%silver%'
   OR lower(o.table_schema) LIKE '%gold%'
ORDER BY o.table_catalog, o.table_schema, o.table_name;
