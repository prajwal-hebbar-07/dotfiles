<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# recipe-radar — reviving an abandoned side project

Status: draft — 2026-07-13

## Summary
Bring `recipe-radar` (last commit 14 months ago, "wip fix later") from a broken
local build to a deployed URL in 30 days of weekday scraps. The strategy is
running-before-pretty: fix the build, replace the dead parts with managed
services, ship the core search feature it was actually built for, then deploy.
A strict work-in-progress limit of 2 is the load-bearing rule — the project
originally died from too many half-finished branches.

## Context and current state
- Repository: last commit 14 months ago; an abandoned `feat/auth-wip-2` branch
  holds incomplete hand-rolled auth.
- The build is broken on the current machine (Node/lockfile/dependency drift).
- Good parts worth keeping: the core recipe model and recipe seed data.
- Dead parts to replace: hand-rolled auth (replace with a managed service) and
  a custom CSS framework (replace with a classless one).
- Missing parts to add: a search index and a deploy pipeline.

## Goals
- A deployed, publicly reachable URL running the app.
- Working recipe search (the core feature) over real seed data.
- A restoration log (`RESTORE.md`) documenting how the build was recovered.
- Momentum preserved: every session ends with a commit; WIP never exceeds 2.

## Non-goals
- Broad dependency upgrades beyond security-critical packages.
- A sophisticated search stack (vectors/embeddings) — plain SQL search first.
- Visual polish beyond a single timeboxed styling pass.

## Proposed design
Work flows through a kanban with a hard WIP limit of 2. Week 1 answers "does it
run": fresh clone, document every error in `RESTORE.md` [new], fix the build on
Node 20, and bump only the ~6 security-critical packages. Week 2 replaces dead
parts: delete the abandoned auth branch and its code, wire in a managed auth
service, and delete dead code aggressively (target −3,000 lines). Week 3 ships
the core: search v1 as plain SQL `ILIKE`, plus ten real recipes as seed data.
Week 4 makes it street-legal: one-command deploy to a real URL, one timeboxed
day for a classless CSS framework, and sharing with three friends whose
confusion becomes the roadmap.

## Change inventory
| Component | Current state | Planned change |
| --- | --- | --- |
| Core recipe model | Good | Keep |
| Recipe seed data | Good | Keep; expand to 10 real recipes |
| Auth | Dead `feat/auth-wip-2` branch | Delete; `[new]` managed auth service |
| CSS | Custom framework, corroded | Replace with a classless framework |
| Search | Missing | `[new]` SQL `ILIKE` search v1 |
| Deploy | Missing | `[new]` one-command deploy pipeline |
| Restore log | — | `[new] RESTORE.md` |

## Implementation plan

### Week 1 — does it run?
- [~] 1. Fresh clone on the current machine; document every error in
  `[new] RESTORE.md`.
- [ ] 2. Fix the build: Node 20, delete lockfile, bump only the ~6
  security-critical packages. Depends on 1.

### Week 2 — replace dead parts
- [ ] 3. Delete `feat/auth-wip-2` and its dead auth code. Depends on 2.
- [ ] 4. Wire in a managed auth service. Depends on 3.
- [ ] 5. Delete dead code aggressively — target −3,000 lines. Depends on 2.

### Week 3 — the core feature
- [ ] 6. Search v1: plain SQL `ILIKE`, no vector DB. Depends on 2.
- [ ] 7. Ten real recipes as seed data; cook one as an integration check.

### Week 4 — street legal
- [ ] 8. One-command deploy to a real URL. Depends on 6.
- [ ] 9. One timeboxed day for a classless CSS framework. Depends on 8.
- [ ] 10. Share with three friends who cook; their confusion is the roadmap.
  Depends on 8.

## Verification
- `npm run dev` renders the app (even if ugly) — the week-1 gate.
- Searching "miso" returns the miso recipe — the core-loop gate.
- The deployed URL loads and serves search to an external visitor.
- Every session ends with a commit, so progress is always recoverable.

## Rollout and rollback
Deployment is a single command to a real URL; rollback is redeploying the prior
commit, which is safe because every session commits. The WIP limit of 2 is the
process safeguard: the moment a third item is in progress, work stops until it's
back to 2. Replacing auth with a managed service means there is no
self-maintained auth to roll back.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| "While I'm at it" dependency upgrades in week 1 | Rabbit hole, broken build | Only the ~6 security-critical packages; stop there |
| Over-engineering search | Repeats the failure that killed v0 | Plain SQL `ILIKE` shippable this week |
| WIP creeping past 2 | Same death by half-finished branches | Hard stop at 3 until back to 2 |
| Sessions without commits | Lost momentum | Every session ends with a commit |

## Open questions
- Managed auth provider: pick whichever has the least setup for a hobby
  project — decide in week 2 with a 30-minute cap?
- Post-day-30 cadence: one improvement per week from user confusion only, or
  add a monthly dependency-bump chore?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
