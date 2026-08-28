-- Inventory: locate candidate objects for each dashboard component.
--
-- Keyword search across table names, table comments and column names, tagged
-- with the requirement the candidate would serve. Deliberately broad: it is
-- cheaper to review false positives than to miss an existing table and rebuild
-- something that already exists.
--
-- Set the :catalog widget before running. Feed the results into the tables in
-- docs/catalog-inventory.md.

WITH searchable AS (
  SELECT
    t.table_schema,
    t.table_name,
    t.table_type,
    lower(concat_ws(
      ' ',
      t.table_name,
      coalesce(t.comment, ''),
      coalesce(array_join(collect_list(c.column_name), ' '), '')
    )) AS haystack
  FROM system.information_schema.tables AS t
  LEFT JOIN system.information_schema.columns AS c
    ON  c.table_catalog = t.table_catalog
    AND c.table_schema  = t.table_schema
    AND c.table_name    = t.table_name
  WHERE t.table_catalog = :catalog
    AND lower(t.table_schema) NOT LIKE '%bronze%'
  GROUP BY t.table_schema, t.table_name, t.table_type, t.comment
),
requirements AS (
  SELECT * FROM VALUES
    ('comp_to_rev',        'compensation|comp_|payroll|salary|revenue|billing|finance'),
    ('staffing_demand',    'forecast|demand|capacity|headcount|fte'),
    ('staffing_supply',    'supply|roster|assignment|attrition|hire|start_date'),
    ('requisition',        'requisition|req_|pipeline|recruit|candidate'),
    ('data_quality',       'data_quality|dq_|quality_check|expectation|validation'),
    ('cases',              'case|matter|milestone|sla|planned_date|due_date'),
    ('case_status_history','status_history|state_history|audit|transition|scd|history'),
    ('intercom',           'intercom|conversation|first_response|ticket'),
    ('report_metadata',    'report_metadata|report_catalog|business_summary|questions_answered')
    AS r(requirement, pattern)
)
SELECT
  r.requirement,
  s.table_schema,
  s.table_name,
  s.table_type
FROM searchable AS s
JOIN requirements AS r
  ON s.haystack RLIKE r.pattern
ORDER BY r.requirement, s.table_schema, s.table_name;
