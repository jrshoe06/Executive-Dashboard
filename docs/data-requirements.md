# Data requirements

Tables are described by **required content and grain**. `Candidate table` stays
`TBD — pending inventory` until [catalog-inventory.md](catalog-inventory.md) has
been run against the BAL Databricks catalog. Statuses used throughout:

| Status | Meaning |
| --- | --- |
| `Likely exists` | Expected in the current silver/gold layer; confirm by inventory |
| `In build` | Being built now by a known workstream |
| `Gap` | Believed not to exist; tracked in [data-gaps.md](data-gaps.md) |

## KPI tiles

One query per tile, daily snapshot grain. Each tile query must return the value,
the comparison anchor, and the trailing series for the sparkline.

### 1. Comp to Rev Ratio

| Field | Value |
| --- | --- |
| Content | Compensation and revenue by cluster, client, and period |
| Grain | cluster × client × period (daily snapshot of period-to-date) |
| Candidate table | TBD — pending inventory; likely a gold finance aggregate |
| Status | Partial — see gap G-05 |

The numerator and denominator must be **exposed separately**, not just the
ratio. A pre-computed ratio cannot be re-aggregated across clusters or clients,
and the drill-down needs to show whether a move came from compensation or from
revenue.

Individual compensation-level data is **not in the data lake today**. Whether
the available aggregate is sufficient depends on the cluster/client grain it is
held at — see gap G-05.

### 2. Staffing Needs Met

| Field | Value |
| --- | --- |
| Content | Forecast staffing demand versus confirmed supply |
| Grain | role × week |
| Candidate table | TBD — forecasting output currently being built with Uly |
| Status | In build |

Demand and supply must both be available at role × week; the metric is
`confirmed supply / forecast demand`. As with the ratio above, both sides must
be exposed, not just the percentage.

### 3. Data Quality Score

| Field | Value |
| --- | --- |
| Content | Data quality check results |
| Grain | dimension × source system × run date |
| Candidate table | TBD — may not exist as a curated table |
| Status | Gap G-01 — the most likely gap of the five |

### 4. Cases on Schedule

| Field | Value |
| --- | --- |
| Content | Case-level schedule and milestone data, planned versus actual dates |
| Grain | case (aggregated to a daily on-schedule rate for the tile) |
| Candidate table | TBD — likely silver case management, aggregated to a gold SLA table |
| Status | Likely exists |

### 5. Avg. Intercom Response Time

| Field | Value |
| --- | --- |
| Content | Intercom first response and resolution timestamps |
| Grain | conversation |
| Candidate table | TBD — pending inventory |
| Status | Gap G-04 if only pre-averaged data is available |

Conversation grain must be **retained, not pre-averaged**, so the drill-down can
show the distribution and percentiles. An average of averages is also wrong
whenever conversation volumes differ across the periods being combined.

## Cases on Schedule drill-down

| Requirement | Grain | Status |
| --- | --- | --- |
| Case fact: case ID, case type, client, owner, planned date, actual or projected date, current status | case | Likely exists |
| Roadblock / exception records with **coded** reasons | roadblock event | Likely exists — coding must be confirmed (gap G-06) |
| Status history, to derive how long each case has been at risk | case × status change | Gap G-02 |
| Daily on-schedule rate snapshot for the trend panel | day (× cluster, client) | Likely derivable from the case fact |

Reason codes must be coded values, not free text, because the roadblock panel
aggregates them.

## Staffing Needs Met drill-down

| Requirement | Grain | Status |
| --- | --- | --- |
| Forecast demand | role × week | In build (Uly) |
| Confirmed supply, including starts and known attrition | role × week | In build (Uly) |
| Requisition / pipeline records with state and state-entry dates, to derive time-in-state | requisition × state change | Pending inventory |
| Gap blocker reasons, **coded** | gap × reason | Pending inventory (gap G-06) |
| Staffing-to-case linkage mapping a role × week gap to specific cases at risk | role × week × case | Gap G-03 — main open feasibility question |
| Daily needs-met rate snapshot for the trend panel | day (× role) | Derivable once demand and supply land |

## Natural language search and report cards

| Field | Value |
| --- | --- |
| Content | Report metadata gold table already built for the report catalog |
| Grain | report |
| Index | Vector search index over `business_summary`, `technical_summary`, `intended_audience`, `questions_answered` |
| Status | Exists |

The same table supplies the client custom report row and the backing-report
links in each drill-down, so no parallel catalog is needed.

## ServiceNow

Write path only, via REST API or webhook. **No source table required.** A ticket
status read-back would need a ServiceNow ingestion into silver, which is out of
scope for the prototype.

## Targets and thresholds

Held as configuration data in [`config/kpis.yaml`](../config/kpis.yaml) so they
can change without a code deploy. If thresholds need to vary by client or
cluster, or need an edit UI, they should be promoted to a table instead — see
gap G-07.
