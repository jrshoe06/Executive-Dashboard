-- Inventory: catalogs and schemas visible to the current principal.
--
-- Run first. Establishes which catalog holds the BAL medallion layers and what
-- the silver/gold schemas are actually called, so the later scripts can be
-- pointed at the right place.
--
-- Usage (Databricks SQL): run as-is.

SHOW CATALOGS;

-- Replace :catalog with the BAL catalog identified above before running the
-- remaining scripts in this directory.
SELECT
  catalog_name,
  schema_name,
  schema_owner,
  comment
FROM system.information_schema.schemata
WHERE lower(catalog_name) NOT IN ('system', 'samples', '__databricks_internal')
ORDER BY catalog_name, schema_name;
