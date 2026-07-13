---
plan: The Onboarding Experiment
slug: onboarding-ab-test
kind: experiment
created: 2026-07-13
horizon: 4 weeks
mood: mad-scientist-lab-notebook
structure: hypothesis-loop
---

# Lab Notebook: The Onboarding Experiment 🧪⚗️

Status: draft — 2026-07-13

## Goal
Test whether cutting signup from 9 fields to 2 lifts setup completion 32% →
45%+, with sales-lead quality guarded. Actual science: pre-registered metric,
no peeking, verdict rules decided in advance.

## Shape

```text
landing 100% ─▶ signup started 61% ─▶ form completed 32% ─▶ first action 19%
                                 ▲
                     THE LEAK (suspect #1: the 9-field form —
                     71% of abandoners stall on the same 3 fields)
```
[DIAGRAM PROMPT: conversion funnel as laboratory glassware — users pour into a
beaker "landing: 100%", drip through narrowing flasks "signup started: 61%",
"form completed: 32%", "first action: 19%". The biggest leak circled in red
ink, annotated "THE FORM (suspect #1)", coffee-stain ring for authenticity.
Emphasize the 61→32 drop as the experiment's target.]

```text
run 2 wks ─▶ B wins + guardrails hold ─▶ ship 100% ─▶ next: magic links?
         ├─▶ B wins, profiles crater  ─▶ ship B + day-3 nudge, re-measure
         ├─▶ inconclusive             ─▶ extend 1 wk max, else keep A
         └─▶ A wins                   ─▶ fascinating!! autopsy, new hypothesis
```
[DIAGRAM PROMPT: decision loop as a lab flowchart with stamped verdict boxes —
from "experiment runs 2 weeks" four arrows: "B wins + guardrails hold" →
stamp SHIP IT; "B wins but day-7 profile completion craters" → ship B plus a
day-3 complete-your-profile nudge, re-measure; "inconclusive" → extend one
week max, ties go to the incumbent; "A wins" → autopsy recordings, new
hypothesis Monday. Hand-drawn ink style. Emphasize every outcome was decided
BEFORE the data arrived.]

## Plan

### Week 0 — preparation
- [x] 1. instrument every funnel step — found two events double-firing; the funnel was lying by 4 points (effort: M)
- [~] 2. build variant B: email + password only, rest deferred past first value (effort: M) needs: 1
- [ ] 3. A/A test for 3 days to prove the splitter isn't biased (effort: S) needs: 1
- 🎉 MILESTONE: A/A shows no difference — our instruments don't lie; NOW we may science

### Weeks 1–2 — the experiment runs
- [ ] 4. launch A/B: 50/50, sticky by device, 2,100/arm for 80% power, minimum 2 full weekends (effort: S) needs: 2,3
- [ ] 5. hands OFF signup — the specimen must not be disturbed mid-observation (effort: S) needs: 4
- [ ] 6. day-7 checkpoint: sample-size pace ONLY, not results (effort: S) needs: 4

### Week 3 — analysis
- [ ] 7. primary metric (setup completion %) with confidence intervals, pre-registered method (effort: M) needs: 4
- [ ] 8. guardrails: week-1 retention + day-7 profile completion ≥ 50% (effort: M) needs: 7
- [ ] 9. ONLY the 3 pre-registered segments: mobile/desktop, weekday/weekend, organic/paid (effort: S) needs: 7

### Week 4 — the loop closes
- [ ] 10. apply the pre-decided verdict rule (see Shape decision loop) — no relitigating (effort: S) needs: 8,9
- [ ] 11. write it in the lab notebook forever, win or lose (effort: S) needs: 10
- 🎉 MILESTONE: we learned something TRUE about our users — that's the real deliverable

## Edge cases & risks
⚠️ RISK: peeking — checking daily and stopping at first "significance" is how labs explode; dashboard is READ-ONLY until day 14, tape over the button.
⚠️ RISK: sales needs company-size data for lead routing — if day-7 profile completion craters below 50%, B's win is counterfeit money.
⚠️ RISK: post-hoc segment fishing finds "wins" in noise — three pre-registered cuts, that way lies retracted papers.
⚠️ RISK: weekend users are a different species — any run not spanning 2 full weekends is invalid.

## Open questions
- Deferred-field collection: day-3 email nudge vs in-app banner vs both?
- If B ships, next hypothesis: defer even the password (magic links) — same funnel or new experiment?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
