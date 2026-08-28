# Drill-down — Cases on Schedule

**Tile:** Cases on Schedule · higher is better · anchored to target % and prior
period.

**Metric:** share of in-flight cases whose projected or actual completion date
is on or before the planned date, as of the latest daily snapshot.

Header shows the "as of" snapshot date and a link to the backing report catalog
entry. See [functional-requirements.md](../functional-requirements.md#shared-drill-down-shell)
for the shell contract.

## Panel 1 — What drives the number

Decomposition of the rate into on-schedule, at-risk and late counts, each with
its change against the prior period.

| Requirement | Grain |
| --- | --- |
| Case fact: case ID, case type, client, owner, planned date, actual or projected date, current status | case |

Derived: `on_schedule = projected_or_actual_date <= planned_date`. Counts are
shown alongside the rate so a rate move caused by a change in denominator is
visible.

## Panel 2 — Where it concentrates

On-schedule rate by client, by case type, and by owner, each row anchored to the
overall rate as a peer comparison so the reader sees who is below the book.

| Requirement | Grain |
| --- | --- |
| Case fact, grouped by client / case type / owner | case |

## Panel 3 — Roadblocks

Count of at-risk and late cases by roadblock reason, ranked.

| Requirement | Grain |
| --- | --- |
| Roadblock or exception records with **coded** reasons | roadblock event |

Reasons must be coded, not free text, because this panel aggregates them. Free
text would have to be bucketed at query time, which is neither stable nor
auditable.

## Panel 4 — Aging

Distribution of how long each at-risk case has been at risk, bucketed
(0–7, 8–14, 15–30, 30+ days).

| Requirement | Grain |
| --- | --- |
| Status history, to derive time at risk | case × status change, with change timestamp |

This is [gap G-02](../data-gaps.md). Without status history the aging panel
cannot be built: a current-status snapshot says a case is at risk but not since
when. Interim fallback is to age from the planned date, which understates cases
that went at-risk early and overstates ones that slipped late — acceptable only
if labelled as such in the panel.

## Panel 5 — Trend

Daily on-schedule rate against the target line.

| Requirement | Grain |
| --- | --- |
| Daily on-schedule rate snapshot | day (× cluster, client) |

Same series as the tile sparkline, so tile and drill-down cannot disagree.

## Panel 6 — Exception list

Standard exception list shape, one row per case that is late or at risk, sorted
by severity then age.

| Column | Source |
| --- | --- |
| `entity_id` | case ID |
| `entity_label` | case name / case type |
| `owner` | case owner |
| `client` / `cluster` | case fact |
| `severity` | critical if late, caution if at risk — from the same thresholds as the tile |
| `value` | days early or late (projected minus planned) |
| `comparison` | planned date |
| `reason_code` | roadblock reason code |
| `age_days` | days at risk, from status history (gap G-02) |
| `action` | ServiceNow prefill, seeded with case ID, owner and reason code |

## Inbound navigation

Entered either from the KPI tile, or from a staffing gap row in the
[Staffing Needs Met](staffing-needs-met.md) drill-down, in which case the
drill-down opens pre-filtered to the cases exposed by that gap. That filter
depends on [gap G-03](../data-gaps.md).
