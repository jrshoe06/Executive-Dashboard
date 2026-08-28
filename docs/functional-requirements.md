# Functional requirements

## 1. KPI tiles

Five KPI tiles on a single page. Each tile shows the current value, a comparison
anchor, a trend sparkline, and a colour band of good / caution / critical
evaluated against configurable thresholds.

| # | KPI | Direction | Comparison anchor |
| --- | --- | --- | --- |
| 1 | Comp to Rev Ratio | lower is better | target ratio |
| 2 | Staffing Needs Met | higher is better | target % |
| 3 | Data Quality Score | higher is better | target score |
| 4 | Cases on Schedule | higher is better | target %, plus prior period |
| 5 | Avg. Intercom Response Time | lower is better | target, plus prior period |

Three KPIs are higher-is-better (2, 3, 4) and two are lower-is-better (1, 5).
Direction is a property of the KPI in [`config/kpis.yaml`](../config/kpis.yaml),
not a branch in the rendering code: the band evaluator reads `direction`,
`good`, `caution` and picks the band accordingly.

Rules that apply to every tile:

- **One query per tile**, at a daily snapshot grain, so the page issues five
  independent queries and a slow tile cannot block the others.
- **No bare values.** Every displayed metric carries a comparison anchor —
  target, prior period, or peer. A value with no anchor is a defect.
- **Sparkline** over the trailing window defined per KPI (default 90 daily
  snapshots).
- **Clickable.** The whole tile navigates to its drill-down.

## 2. Drill-downs

Each drill-down must answer three questions, in this order:

1. **What drives the number** — decomposition of the metric into its parts.
2. **Where it concentrates** — which clusters, clients, roles or case types
   carry the shortfall.
3. **What needs a decision** — an exception list of rows a leader can act on.

Built in full for the prototype:

- [Cases on Schedule](drilldowns/cases-on-schedule.md)
- [Staffing Needs Met](drilldowns/staffing-needs-met.md)

Left undefined pending Bruce's input: Comp to Rev Ratio, Data Quality Score,
Avg. Intercom Response Time. Their tiles are still built and still link to a
drill-down route; the route renders a placeholder that states the panels are
pending definition. This keeps the tile contract uniform across all five.

### Shared drill-down shell

Every drill-down, defined and undefined alike, renders:

- An **"as of" timestamp** taken from the snapshot date of the backing query,
  not from wall-clock time at render.
- A **link to the backing report catalog entry** for each panel, resolved from
  the report metadata gold table (see §4) — no parallel catalog is maintained.
- The **standard exception list** described below.

### Standard exception list shape

One shape shared across all drill-downs, so the component is written once:

| Column | Meaning |
| --- | --- |
| `entity_id` | Case ID, requisition ID, role×week key — whatever the row is |
| `entity_label` | Human-readable name for the row |
| `owner` | Person accountable for the row |
| `client` / `cluster` | Scoping attributes |
| `severity` | critical / caution, derived from the same thresholds as the tile |
| `value` | The metric value for the row |
| `comparison` | Anchor for that row — target, prior period, or peer |
| `reason_code` | Coded exception reason (never free text) |
| `age_days` | How long the row has been in exception |
| `action` | ServiceNow prefill action |

Each row carries a **ServiceNow prefill action** that opens a request
pre-populated with the entity, the reason code and the drill-down context.

### Cross-drill-down navigation

From a staffing gap row in Staffing Needs Met, the user can navigate to the
cases at risk from that gap, landing in Cases on Schedule filtered to those
cases. This requires a staffing-to-case linkage that almost certainly does not
exist today — see [data-gaps.md](data-gaps.md), gap G-03.

## 3. Natural language search bar

A search bar returning report metadata cards. Backed by a vector search index
over `business_summary`, `technical_summary`, `intended_audience` and
`questions_answered` on the existing report metadata gold table. Results render
as cards showing the report name, summary, audience and a link to open it.

## 4. Report catalog reuse

The report metadata gold table already built for the report catalog supplies
three things: the search index, the client custom report row, and the
backing-report links on every drill-down. No parallel catalog is created.

## 5. Client custom report row

A row of client custom report slots, currently six. The slot count is
configuration, not a hardcoded literal, so it can grow without a code change.

## 6. ServiceNow special request

A button to submit a special request to ServiceNow. **Write path only**, via
REST API or webhook; no source table is required. Ticket status read-back is
out of scope for the prototype — it would require a ServiceNow ingestion into
silver.

## 7. Row-level scoping

Row-level scoping by user or AD group, applied at deployment. Scoping is
enforced in the data layer (row filters / dynamic views on the underlying
tables), not in the dashboard queries, so an unscoped query cannot leak rows.
