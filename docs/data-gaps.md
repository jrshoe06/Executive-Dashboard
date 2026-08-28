# Data gaps

Areas where the data the dashboard needs does not appear to be available today.
Each gap blocks a named panel, so the cost of leaving it open is explicit.

Gaps G-01 to G-07 are stated from the requirements, ahead of the catalog
inventory. Every one of them must be **confirmed or closed** by running the
inventory in [catalog-inventory.md](catalog-inventory.md) against the BAL
Databricks catalog — a gap listed here is a strong prior, not a finding.

| ID | Gap | Blocks | Severity |
| --- | --- | --- | --- |
| G-01 | Data quality check results as a queryable curated table | Data Quality Score tile and its drill-down | High |
| G-02 | Case status history at sufficient granularity to derive aging | Cases on Schedule aging panel, `age_days` on the exception list | High |
| G-03 | Staffing-to-case exposure linkage | Cross-drill-down navigation from staffing gaps to cases at risk | High |
| G-04 | Intercom data at conversation grain rather than pre-aggregated averages | Distribution and percentiles on the Intercom drill-down | Medium |
| G-05 | Compensation at the grain the ratio is reported at | Comp to Rev Ratio decomposition | Medium |
| G-06 | Coded reason codes for roadblocks and staffing blockers | Roadblock and blocker panels | Medium |
| G-07 | Targets and thresholds stored as data rather than config | Threshold changes without a deploy | Low |

---

## G-01 — Data quality check results

The tile needs check results at dimension × source system × run date. This is
the most likely gap of the five KPIs: DQ results commonly live in job logs or a
monitoring tool rather than as a curated table.

**Needed:** a gold table with one row per check run — `run_date`,
`source_system`, `dimension` (completeness, timeliness, validity, …),
`checks_passed`, `checks_run`, and a score derived from those counts.

**If unavailable:** the tile cannot be built with a real number. Do not ship a
hardcoded or hand-maintained score — a governance metric that is not itself
measured is worse than an absent tile.

## G-02 — Case status history

Current status tells us a case is at risk; it does not tell us since when. The
aging panel and the `age_days` column both need status transitions with
timestamps at case × status change.

**Needed:** either a status history/audit table in silver case management, or a
daily case status snapshot that can be differenced to reconstruct transitions.

**Interim:** age from the planned date, labelled in the UI as an approximation.

## G-03 — Staffing-to-case exposure linkage

The join that maps a role × week staffing gap to the specific cases at risk.
**This almost certainly does not exist today and is the main open feasibility
question for the prototype.**

**Needed:** one of —
1. demand forecast rows carrying the originating case IDs, or
2. a case staffing assignment/requirement record at case × role × week.

Option 1 is preferable because it comes from the forecasting work already in
build with Uly and needs no new source; it requires the forecast to retain case
lineage rather than only emitting aggregated role × week totals. **Raise this
with Uly now**, while the forecast output is still being designed — retaining
lineage during the build is far cheaper than reconstructing it afterwards.

**If unavailable:** cross-drill-down navigation degrades to a client/case-type
filter, labelled as an approximation.

## G-04 — Intercom conversation grain

The tile needs conversation-level first response and resolution timestamps, not
a pre-averaged metric. Averages cannot be re-aggregated correctly across
periods or teams, and they hide the tail that response-time management is
actually about.

**Needed:** conversation-grain records with `conversation_id`, `created_at`,
`first_response_at`, `resolved_at`, team and client attributes.

## G-05 — Compensation grain

**Individual compensation-level data is not in the data lake at the moment.**

The Comp to Rev Ratio does not require individual-level data — a cluster ×
client × period aggregate is sufficient for both the tile and the
decomposition, provided compensation and revenue are exposed as separate
measures rather than only as a ratio.

Confirm during inventory: (a) that a finance aggregate exists at or below
cluster × client × period, and (b) that compensation is present as its own
column. If only the ratio is materialised, request the numerator and
denominator be added — deriving them back out of a ratio is not possible.

Individual-level compensation should not be brought into scope for this
dashboard. It is sensitive data, it is not needed for any specified panel, and
it would pull row-level access requirements well beyond the AD-group scoping
described in the functional requirements.

## G-06 — Coded reason codes

Both the case roadblock panel and the staffing blocker panel aggregate reasons,
so reasons must be coded values against a maintained reference list. If the
source captures free text today, a code set has to be agreed and applied at
source; bucketing free text at query time is neither stable nor auditable.

## G-07 — Thresholds as data

Thresholds currently live in [`config/kpis.yaml`](../config/kpis.yaml), which
requires a deploy to change. If thresholds are expected to change without a
deploy, or to vary by client or cluster, promote them to a table at
`kpi × scope × effective_date` and read them at query time. The config file is
shaped to make that migration mechanical: it is already keyed by KPI with an
explicit direction and band values.
