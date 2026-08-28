# Drill-down — Staffing Needs Met

**Tile:** Staffing Needs Met · higher is better · anchored to target %.

**Metric:** confirmed supply divided by forecast demand, across the forecast
horizon, as of the latest daily snapshot.

Header shows the "as of" snapshot date and a link to the backing report catalog
entry. See [functional-requirements.md](../functional-requirements.md#shared-drill-down-shell)
for the shell contract.

## Panel 1 — What drives the number

Forecast demand, confirmed supply, and the resulting gap, each shown as a count
rather than only as a percentage, with change against the prior week.

| Requirement | Grain |
| --- | --- |
| Forecast staffing demand | role × week |
| Confirmed supply, including starts and known attrition | role × week |

Starts and known attrition must be visible as separate components: a flat
supply number can hide simultaneous hiring and churn, which have different
decisions attached.

## Panel 2 — Where it concentrates

Gap by role and by week across the horizon, so the reader sees which roles are
short and when the shortfall lands. Each row is anchored to the target
needs-met rate.

| Requirement | Grain |
| --- | --- |
| Demand and supply, grouped by role and by week | role × week |

## Panel 3 — Pipeline

Requisitions by state, with time-in-state, to show whether a gap is being worked
and where it is stuck.

| Requirement | Grain |
| --- | --- |
| Requisition / pipeline records with state and **state-entry dates** | requisition × state change |

Time-in-state must be derived from state-entry dates. A current-state-only
record cannot distinguish a requisition opened yesterday from one stalled for
two months.

## Panel 4 — Blockers

Gaps by blocker reason, ranked.

| Requirement | Grain |
| --- | --- |
| Gap blocker reasons, **coded** | gap × reason |

Coded for the same reason as case roadblocks: the panel aggregates them.

## Panel 5 — Trend

Daily needs-met rate against the target line.

| Requirement | Grain |
| --- | --- |
| Daily needs-met rate snapshot | day (× role) |

Same series as the tile sparkline.

## Panel 6 — Exception list

Standard exception list shape, one row per role × week gap, sorted by severity
then age.

| Column | Source |
| --- | --- |
| `entity_id` | role × week key |
| `entity_label` | role name and week starting date |
| `owner` | staffing owner for the role |
| `client` / `cluster` | from the demand forecast |
| `severity` | from the same thresholds as the tile |
| `value` | headcount gap (demand minus supply) |
| `comparison` | forecast demand for that role × week |
| `reason_code` | gap blocker reason code |
| `age_days` | time-in-state of the oldest open requisition for the gap |
| `action` | ServiceNow prefill, seeded with role, week, gap size and reason code |

## Outbound navigation — cases at risk

Each exception row offers "view cases at risk", navigating into the
[Cases on Schedule](cases-on-schedule.md) drill-down filtered to the cases
exposed by that role × week gap.

| Requirement | Grain |
| --- | --- |
| Staffing-to-case linkage | role × week × case |

This is [gap G-03](../data-gaps.md) and the **main open feasibility question**
for the prototype. It almost certainly does not exist today. It requires a join
path from a role × week demand line back to the cases that generated the demand
— either demand forecast rows carrying their originating case IDs, or a case
staffing assignment/requirement record at case × role × week.

If neither exists by prototype time, the fallback is a coarse navigation that
filters Cases on Schedule to the same client and case type as the gap, clearly
labelled as an approximation rather than a true exposure list. That fallback is
a placeholder, not a solution, and should not be allowed to close the gap.
