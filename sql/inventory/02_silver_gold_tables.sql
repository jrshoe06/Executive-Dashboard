-- Inventory: tables and views in the silver and gold layers.
--
-- Produces the raw object list that docs/catalog-inventory.md is filled in
-- from. Set the :catalog widget (or substitute the literal) before running.
--
-- Usage (Databricks SQL): create a text widget named `catalog`, or replace
-- :catalog with the catalog name.

SELECT
  t.table_catalog,
  t.table_schema,
  t.table_name,
  t.table_type,
  t.comment,
  t.last_altered
FROM system.information_schema.tables AS t
WHERE t.table_catalog = :catalog
  AND (
    lower(t.table_schema) LIKE '%silver%'
    OR lower(t.table_schema) LIKE '%gold%'
  )
ORDER BY t.table_schema, t.table_name;

-- Column-level detail for a single object, to confirm the grain and check that
-- required measures are exposed separately (for example that a finance
-- aggregate carries compensation and revenue, not only the ratio).
SELECT
  c.table_schema,
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.full_data_type,
  c.comment
FROM system.information_schema.columns AS c
WHERE c.table_catalog = :catalog
  AND c.table_schema = :schema
  AND c.table_name = :table
ORDER BY c.ordinal_position;
