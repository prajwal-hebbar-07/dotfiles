---
plan: The Great Cache Meltdown — Recovery Triage
slug: cache-meltdown-recovery
kind: incident-recovery
created: 2026-07-13
horizon: 72 hours
mood: field-hospital
structure: triage-queue
---

# The Great Cache Meltdown — Recovery Triage 🚑

Status: draft — 2026-07-13

## Goal
The 03:47 cache-cluster outage is extinguished; repair everything it scorched
in strict triage order — money first, trust second, tidiness third — within 72
hours.

## Shape

```text
🔴 RED (0–8h)          🟡 YELLOW (8–36h)      🟢 GREEN (36–72h)
├ stuck orders 1,204   ├ support macro        ├ flag cleanup ×14
├ double-charge check  ├ re-enable recs       ├ retire bypass endpoint
└ cache warm-up 50qps  ├ analytics backfill   └ 3am-crew thank-you
                       └ credential rotation
```
[DIAGRAM PROMPT: hospital triage board — three columns with wristband colors:
RED "treat now" (stuck orders, double-charge check, cache warm-up), YELLOW
"stabilized, treat today" (support macro, recommendations re-enable, analytics
backfill, credential rotation), GREEN "walking wounded" (feature-flag cleanup,
bypass-endpoint retirement, thank-you note). Patient cards with severity
vitals strip, owner avatar, ETA. Wall clock showing hours since incident.
Emphasize that RED items bleed money.]

```text
03:41 node OOM ─ 03:47 cascade ─ 03:52 pager ─ 04:10 wrong fix ✗
      ─ 05:30 actual fix ─ 06:02 checkout restored
customer lane:  fine │ checkout dead────────────│ slow │ fine
```
[DIAGRAM PROMPT: incident timeline autopsy — horizontal strip 03:41→09:15 with
event markers: cache node OOM (03:41), cascade begins (03:47), pager fires
(03:52), wrong fix attempted (04:10, gentle red ✗), actual fix (05:30),
checkout restored (06:02). Below it a parallel lane showing what customers
experienced at each moment. Emphasize the 04:10 wrong turn as a study point,
not a blame point.]

## Plan

### 🔴 RED — treat now (0–8h)
- [~] 1. reconcile 1,204 orders stuck in payment_captured_not_confirmed — batches of 100, human eyes on first three (owner: Rina) (effort: L)
- [ ] 2. double-charge cross-reference against provider logs; refund BEFORE they notice + apology credit (owner: Dev) (effort: M) needs: 1
- [ ] 3. cache warm-up: replay yesterday's top-10k queries, throttled 50 qps (owner: Sam) (effort: S)
- 🎉 MILESTONE: no customer is losing money anymore — everything after this is trust and tidiness

### 🟡 YELLOW — treat today (8–36h)
- [ ] 4. support macro + status-page note — one good answer for 340 tickets, not 340 improvised ones (owner: Kai) (effort: S)
- [ ] 5. re-enable recommendation engine (effort: S) needs: 3
- [ ] 6. backfill 6h of missing analytics events from raw logs (effort: L)
- [ ] 7. rotate the credentials pasted into the incident channel at 4am — you know who you are, it's fine, rotate them (effort: S)

### 🟢 GREEN — walking wounded (36–72h)
- [ ] 8. clean up 14 incident-flipped feature flags; document the 3 keepers that accidentally improved things (effort: M)
- [ ] 9. retire the "temporary" bypass endpoint before it becomes load-bearing lore (effort: M)
- [ ] 10. thank-you note + comp-day proposal for the 3am crew (effort: S)

### The debrief (hour 72)
- [ ] 11. blameless postmortem — the 04:10 wrong turn gets studied, not punished (effort: M) needs: 1,2,3
- [ ] 12. exactly 3 action items with owners and dates — a postmortem with 20 produces 0 (effort: S) needs: 11

## Edge cases & risks
⚠️ RISK: replaying warm-up traffic too fast melts the cluster again — 50 qps cap; we do not speedrun the sequel.
⚠️ RISK: reconciliation script double-confirming orders the payment provider already settled — first three batches get human eyeballs.
⚠️ RISK: the true root cause (no memory-headroom alerting on cache nodes) gets forgotten once adrenaline fades — it gets an owner and a date TODAY.

## Open questions
- Apology credit size for double-charged customers: flat $10 or order-proportional?
- Do the 3 accidentally-good feature flags become permanent defaults this week or next sprint?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
