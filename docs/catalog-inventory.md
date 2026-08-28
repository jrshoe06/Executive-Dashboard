# BAL Databricks catalog inventory

The silver/gold layer has not been inventoried, so every table in
[data-requirements.md](data-requirements.md) is described by content and grain
rather than by name. This document is where those descriptions get resolved to
real objects.

> **Status: not yet run.** The scripts are ready; the findings tables below are
> empty until someone with catalog access runs them. Until then, every
> `Likely exists` status in the data requirements and every gap in
> [data-gaps.md](data-gaps.md) is an expectation, not a finding.

## Runbook

Two steps, in order. Step 1 is a single query with no parameters; step 2 is
targeted and only makes sense once step 1 has named the candidate tables.

### Step 1 — Export the object inventory

Run [`sql/inventory/01_inventory_export.sql`](../sql/inventory/01_inventory_export.sql)
as-is in a Databricks SQL warehouse, using a principal that can see the BAL
catalog. No widgets, no parameters, no edits.

Download the result as CSV and attach it to the issue or PR. That one file is
enough to resolve most of the `Candidate table — TBD` placeholders in
[data-requirements.md](data-requirements.md), because it returns the full
column list per object alongside a `requirements` tag suggesting which
dashboard component each object might serve.

**What it reads:** `system.information_schema` only — object names, column
names and comments. It does not read a single row of business data, so the
output contains no client, case, personnel or compensation values and is safe
to attach.

**If it returns nothing or looks wrong:** the likely causes are that the
warehouse principal cannot see the BAL catalog, or that the schemas are not
named `*silver*` / `*gold*`. The query already keeps any object that
keyword-matches a requirement regardless of schema name, so a near-empty result
points at permissions rather than naming. Send `SHOW CATALOGS;` output instead
and the query can be re-scoped.

### Step 2 — Confirm grain on the shortlisted tables

Once step 1 has identified candidates, run
[`sql/inventory/02_grain_checks.sql`](../sql/inventory/02_grain_checks.sql)
against each shortlisted table. Unlike step 1, this one **does read table
data** — row counts, snapshot dates and reason-code values — so review its
output before attaching it. Set `:catalog`, `:schema` and `:table` via text
widgets or literals, and edit the grain key expression to the grain being
tested.

A candidate is only accepted once step 2 confirms the grain matches the
requirement. A table with the right subject area but the wrong grain — a
pre-averaged metric, or a current-state-only record — does not close the
requirement, and several of the gaps in [data-gaps.md](data-gaps.md) are
exactly that failure mode.

### The three questions step 1 cannot answer

These need a person, not a query, and are worth answering in the same pass:

1. **Is the forecast output (Uly) already landing anywhere?** If it is not yet
   in the catalog it will not appear in the export, and it backs the Staffing
   Needs Met tile.
2. **Do the finance aggregates expose compensation and revenue separately, or
   only a ratio?** The column list from step 1 usually answers this, but a view
   that computes the ratio may hide it.
3. **Are roadblock and blocker reasons coded or free text?** Step 2's
   reason-code query answers this where the column exists; where it does not,
   it is a question for the owning team.

## Findings — KPI tiles

Fill in one row per tile. `Grain confirmed` records the result of
step 2.

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
