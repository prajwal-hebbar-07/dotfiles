---
plan: Project Lazarus — Reviving recipe-radar
slug: recipe-radar-rescue
kind: refactor
created: 2026-07-13
horizon: 30 days
mood: garage-restoration
structure: kanban-swimlanes
---

# Project Lazarus: Reviving the Abandoned Side Project 🔧🕸️

Status: draft — 2026-07-13

## Goal
Get `recipe-radar` (last commit 14 months ago, message: "wip fix later") from
garage to a deployed URL in 30 days of weekday scraps. Running before pretty;
WIP limit 2, because seventeen half-open hoods is how it died.

## Shape

```text
RUSTED (backlog)   ON THE BENCH ≤2   TEST DRIVE     ROADWORTHY
├ dep graveyard    ├ fresh clone     │              │
├ dead auth branch │  + RESTORE.md   │              │
├ node 20 build    │                 │              │
├ search (the pt.) │                 │              │
├ That CSS         │                 │              │
└ deploy pipeline  │                 │              │
```
[DIAGRAM PROMPT: kanban board as a garage workbench — four pegboard columns:
"RUSTED (backlog)", "ON THE BENCH (WIP limit 2)", "TEST DRIVE (verifying)",
"ROADWORTHY (done)". Task cards as parts tags tied with string. Oil-stained
sign on the bench column: "MAX 2 ON BENCH — YES, EVEN YOU". Emphasize the WIP
limit as the load-bearing rule.]

```text
KEEP                     REPLACE                 ORDER NEW PART
core recipe model ✓      hand-rolled auth ✗      search index [new]
recipe seed data ✓       custom CSS fwk  ✗      deploy pipeline [new]
                         (14-mo wip = haunting)
```
[DIAGRAM PROMPT: exploded mechanical drawing of a car engine, parts labeled as
software components with keep/replace color coding — "core recipe model
(GOOD, keep)", "hand-rolled auth (SEIZED, replace with managed service)",
"custom CSS framework (CORRODED, replace with classless)", "search index
(MISSING, order part)", "deploy pipeline (MISSING, order part)". Emphasize
how few parts are actually good — and that that's fine.]

## Plan

### Week 1 — does the engine turn over?
- [~] 1. fresh clone on current machine; every error documented in RESTORE.md [new] — the manual for future-you (effort: S)
- [ ] 2. fix the build: Node 20, delete lockfile, bump ONLY the 6 security-screaming packages (effort: M) needs: 1
- 🎉 MILESTONE: npm run dev shows the app — ugly, search broken, ALIVE; take the screenshot

### Week 2 — replace the dead parts
- [ ] 3. delete feat/auth-wip-2 entirely — 14-month-old WIP auth is not a part, it's a haunting (effort: S) needs: 2
- [ ] 4. managed auth service instead: 2 evenings, not 2 months (effort: M) needs: 3
- [ ] 5. delete dead code with joy — target −3,000 lines; deletion is measurable progress (effort: M) needs: 2

### Week 3 — the part it was built for
- [ ] 6. search v1: plain SQL ILIKE — no vector DB, no embeddings, no essays about embeddings (effort: M) needs: 2
- [ ] 7. ten real recipes as seed data; cook one, call it integration testing (effort: S)
- 🎉 MILESTONE: type "miso", find the miso recipe — the core loop works

### Week 4 — street legal
- [ ] 8. one-command deploy to a real URL (effort: M) needs: 6
- [ ] 9. That CSS gets exactly ONE timeboxed day: classless framework, accept it (effort: S) needs: 8
- [ ] 10. link to three friends who cook — their confusion is the roadmap (effort: S) needs: 8
- 🎉 MILESTONE: it's on the road — before/after screenshots posted; RESTORE.md final entry: "garage to street: 30 days"

## Edge cases & risks
⚠️ RISK: "while I'm at it" dependency upgrades in week 1 — you are NOT at it; six packages, walk away.
⚠️ RISK: architecture astronautics on search (the disease that killed v0) — the cure is something searchable THIS week.
⚠️ RISK: WIP creep past 2 — the moment it hits 3, everything stops until it's back to 2; that's the whole maintenance manual.
⚠️ RISK: sessions without commits kill momentum — every session ends with a commit, even an ugly one.

## Open questions
- Managed auth provider: whichever has the least ceremony for a hobby project — decide in week 2's first session, 30 min cap?
- Post-day-30 cadence: one improvement per week from user confusion only — enough, or add a monthly dep-bump chore?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
