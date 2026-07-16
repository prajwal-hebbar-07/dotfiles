<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Cache meltdown — recovery triage

Status: draft — 2026-07-13

## Summary
The 03:47 cache-cluster outage is contained; this plan repairs everything it
damaged, in strict triage order over 72 hours — customer money first, customer
trust second, operational tidiness third. It also closes the loop with a
blameless postmortem producing exactly three owned action items, including the
missing alert that would have prevented the outage.

## Context and current state
- Timeline: cache node OOM at 03:41, cascade at 03:47, pager at 03:52, a failed
  fix attempt at 04:10, the actual fix at 05:30, checkout restored at 06:02.
- Damage: 1,204 orders stuck in `payment_captured_not_confirmed`; possible
  double-charges; a cold cache; 6 hours of missing analytics events; 14
  feature flags flipped during the incident; a "temporary" bypass endpoint
  still live; credentials pasted into the incident channel at 04:00.
- Root cause: cache nodes have no memory-headroom alerting, so the OOM arrived
  with no warning.

## Goals
- No customer is losing money: stuck orders reconciled, double-charges refunded
  with an apology credit.
- Service fully restored: cache warm, recommendations back, analytics
  backfilled.
- Cleanup complete: flags reconciled, bypass endpoint retired, credentials
  rotated.
- A blameless postmortem with three owned, dated action items.

## Non-goals
- Assigning blame for the 04:10 failed fix — it is studied, not punished.
- Large architectural rework beyond the specific preventive alert.

## Proposed design
Work is triaged into three severity lanes by time-to-treat.

RED (0–8h) covers anything costing customers money: reconcile the 1,204 stuck
orders in batches of 100 with human review of the first three batches;
cross-reference double-charges against provider logs and refund proactively;
warm the cache by replaying yesterday's top-10k queries throttled to 50 qps.

YELLOW (8–36h) covers trust and stabilization: a single support macro and
status-page note; re-enable recommendations; backfill analytics from raw logs;
rotate the leaked credentials.

GREEN (36–72h) covers tidiness: reconcile the 14 incident flags, retire the
bypass endpoint, thank the on-call crew. The debrief at hour 72 produces the
three action items — the top one being memory-headroom alerting on cache nodes.

## Change inventory
| Lane | Item | Owner |
| --- | --- | --- |
| RED | Reconcile 1,204 stuck orders | Rina |
| RED | Double-charge refunds + credit | Dev |
| RED | Cache warm-up at 50 qps | Sam |
| YELLOW | Support macro + status note | Kai |
| YELLOW | Re-enable recommendations, backfill analytics, rotate creds | — |
| GREEN | Flag cleanup, retire bypass endpoint, thank crew | — |

## Implementation plan

### RED — treat now (0–8h)
- [~] 1. Reconcile 1,204 orders in `payment_captured_not_confirmed`, batches of
  100, human eyes on the first three batches (owner: Rina).
- [ ] 2. Cross-reference double-charges against provider logs; refund before
  customers notice, plus an apology credit (owner: Dev). Depends on 1.
- [ ] 3. Cache warm-up: replay yesterday's top-10k queries, throttled to 50 qps
  (owner: Sam).

### YELLOW — treat today (8–36h)
- [ ] 4. Support macro + status-page note — one answer for ~340 tickets
  (owner: Kai).
- [ ] 5. Re-enable the recommendation engine. Depends on 3.
- [ ] 6. Backfill 6h of missing analytics events from raw logs.
- [ ] 7. Rotate the credentials pasted into the incident channel at 04:00.

### GREEN — walking wounded (36–72h)
- [ ] 8. Reconcile 14 incident-flipped feature flags; document the 3 that
  should stay.
- [ ] 9. Retire the temporary bypass endpoint before it becomes permanent.
- [ ] 10. Thank-you note and comp-day proposal for the on-call crew.

### Debrief (hour 72)
- [ ] 11. Blameless postmortem; the 04:10 failed fix is studied, not punished.
  Depends on 1, 2, 3.
- [ ] 12. Exactly three action items with owners and dates. Depends on 11.

## Verification
- Reconciled order count reaches zero for `payment_captured_not_confirmed`.
- Double-charge refunds reconciled against provider logs (no residual
  duplicates).
- Cache hit rate returns to baseline without re-triggering OOM.
- Analytics event counts for the 6-hour gap match raw-log totals.
- All 14 flags accounted for; bypass endpoint returns 404/removed; leaked
  credentials invalidated.

## Rollout and rollback
Cache warm-up is the only step that can re-cause the incident, so it is rate-
limited to 50 qps and can be paused instantly if node memory climbs. Order
reconciliation is reversible per batch: the human-reviewed first three batches
validate the script before it runs unattended. Everything else is additive
cleanup with no rollback needed.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Warm-up traffic too fast | Re-melts the cluster | 50 qps cap; pause on rising node memory |
| Reconciliation double-confirms already-settled orders | Duplicate confirmations | Human review of first three batches |
| Root cause forgotten once adrenaline fades | Recurrence | Memory-headroom alert gets an owner and date today |

## Open questions
- Apology-credit size for double-charged customers: flat $10 or
  order-proportional?
- Do the three accidentally-beneficial flags become permanent defaults this
  week or next sprint?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
