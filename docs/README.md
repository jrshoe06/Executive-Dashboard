# Executive Dashboard — specification

Design and data specification for the BAL Executive Dashboard: a single page of
five KPI tiles, each clickable into a drill-down, plus report search, a client
custom report row, and a ServiceNow request path.

| Document | Purpose |
| --- | --- |
| [functional-requirements.md](functional-requirements.md) | What the page and drill-downs must do |
| [data-requirements.md](data-requirements.md) | Required content and grain per component |
| [drilldowns/cases-on-schedule.md](drilldowns/cases-on-schedule.md) | Full drill-down spec (built for prototype) |
| [drilldowns/staffing-needs-met.md](drilldowns/staffing-needs-met.md) | Full drill-down spec (built for prototype) |
| [catalog-inventory.md](catalog-inventory.md) | How to inventory the BAL Databricks catalog, and findings |
| [data-gaps.md](data-gaps.md) | Where the required data does not appear to exist today |

Thresholds, targets and tile definitions are held as configuration data in
[`config/kpis.yaml`](../config/kpis.yaml) rather than in code, so they can change
without a deploy.

## Naming convention in these documents

The silver/gold layer has not been inventoried yet, so tables are described by
**required content and grain**, not by actual name. Each requirement carries a
`Candidate table` field that stays `TBD — pending inventory` until the catalog
inventory in [catalog-inventory.md](catalog-inventory.md) has been run against
the BAL Databricks catalog and the real object has been identified.
