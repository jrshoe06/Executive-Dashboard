-- STEP 1b (optional) -- full column detail for a shortlist of tables.
--
-- Run only if step 1's key_columns were not enough to judge a candidate's
-- grain. Scoped to a handful of named tables so the output stays small enough
-- to attach -- do not widen this to the whole catalog, which is what made the
-- original export too large.
--
-- READS METADATA ONLY (system.information_schema), so the output is safe to
-- share: column names and types, no business data.
--
-- EDIT the table list below to the shortlist, then run.

SELECT
  c.table_catalog,
  c.table_schema,
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.full_data_type,
  substr(coalesce(c.comment, ''), 1, 200) AS column_comment
FROM system.information_schema.columns AS c
WHERE concat_ws('.', lower(c.table_schema), lower(c.table_name)) IN (
  -- EDIT HERE -- 'schema.table', lowercase, one per line.
  'replace_with_schema.replace_with_table'
)
ORDER BY c.table_catalog, c.table_schema, c.table_name, c.ordinal_position;
