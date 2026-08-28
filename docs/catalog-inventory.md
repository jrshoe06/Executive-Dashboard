# BAL Databricks catalog inventory

The silver/gold layer has not been inventoried, so every table in
[data-requirements.md](data-requirements.md) is described by content and grain
rather than by name. This document is where those descriptions get resolved to
real objects.

> **Status: not yet run.** The inventory requires access to the BAL Databricks
> workspace, which is not available from the environment these documents were
> authored in. The scripts below are ready to run; the findings tables are
> empty until someone with catalog access runs them and fills them in. Until
> then, every `Likely exists` status in the data requirements and every gap in
> [data-gaps.md](data-gaps.md) is an expectation, not a finding.

## How to run

Scripts are in [`sql/inventory/`](../sql/inventory), run in order from a
Databricks SQL warehouse with a principal that can read the BAL catalog.

| Script | Purpose |
| --- | --- |
| `01_catalogs_and_schemas.sql` | Identify the BAL catalog and its silver/gold schemas |
| `02_silver_gold_tables.sql` | List every table and view in those schemas, plus column detail for one object |
| `03_candidate_tables_by_component.sql` | Keyword-match candidates to each dashboard component |
| `04_grain_checks.sql` | Confirm a candidate's grain, snapshot coverage, and reason-code coding |

Scripts use `:catalog`, `:schema` and `:table` parameter markers — create text
widgets with those names, or substitute literals.

A candidate is only accepted once `04_grain_checks.sql` confirms the grain
matches the requirement. A table with the right subject area but the wrong
grain — a pre-averaged metric, or a current-state-only record — does not close
the requirement, and several of the gaps in
[data-gaps.md](data-gaps.md) are exactly that failure mode.

## Findings — KPI tiles

Fill in one row per tile. `Grain confirmed` records the result of
`04_grain_checks.sql`.

| KPI | Required grain | Table found | Grain confirmed | Verdict |
| --- | --- | --- | --- | --- |
| Comp to Rev Ratio | cluster × client × period | | | |
| Staffing Needs Met | role × week | | | |
| Data Quality Score | dimension × source system × run date | | | |
| Cases on Schedule | case | | | |
| Avg. Intercom Response Time | conversation | | | |

## Findings — drill-down inputs

| Requirement | Required grain | Table found | Grain confirmed | Verdict |
| --- | --- | --- | --- | --- |
| Case fact | case | | | |
| Case roadblocks, coded | roadblock event | | | |
| Case status history | case × status change | | | |
| Daily on-schedule rate | day | | | |
| Forecast demand | role × week | | | |
| Confirmed supply | role × week | | | |
| Requisition pipeline with state-entry dates | requisition × state change | | | |
| Gap blocker reasons, coded | gap × reason | | | |
| Staffing-to-case linkage | role × week × case | | | |
| Daily needs-met rate | day | | | |
| Report metadata | report | | | |

## Verdict values

| Verdict | Meaning | Action |
| --- | --- | --- |
| `Confirmed` | Table exists at the required grain | Record the name in data-requirements.md |
| `Wrong grain` | Subject area exists but grain is insufficient | Raise as a gap; specify the grain needed |
| `Missing` | No candidate found | Raise as a gap |

## After running

1. Replace each `Candidate table — TBD` in
   [data-requirements.md](data-requirements.md) with the confirmed name.
2. Close, confirm or add gaps in [data-gaps.md](data-gaps.md) based on the
   verdicts, rather than leaving the pre-inventory expectations in place.
3. Flag any `Wrong grain` verdict to the owning data team early — those are
   source-side changes with lead times longer than the prototype build.
