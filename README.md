# Executive-Dashboard
Dashboard intended for executives at BAL and senior legal team or account leads to see the current status of the account and manage their business with integrated chat bot for investigating data, access to common reports, and direct button to request new reporting. One integrated place for legal team leaders to go for BI needs.

## Specification

The dashboard is specified before it is built. See [`docs/`](docs/README.md):

- [Functional requirements](docs/functional-requirements.md) — five KPI tiles, drill-downs, search, ServiceNow, row-level scoping
- [Data requirements](docs/data-requirements.md) — required content and grain per component
- Full drill-down specs for [Cases on Schedule](docs/drilldowns/cases-on-schedule.md) and [Staffing Needs Met](docs/drilldowns/staffing-needs-met.md)
- [Catalog inventory](docs/catalog-inventory.md) — procedure and [SQL](sql/inventory) for inventorying the BAL Databricks catalog
- [Data gaps](docs/data-gaps.md) — where the required data does not appear to exist today

KPI thresholds and targets are configuration data in [`config/kpis.yaml`](config/kpis.yaml), not hardcoded values.

Table names are described by content and grain rather than by actual name until the BAL Databricks catalog inventory has been run.
