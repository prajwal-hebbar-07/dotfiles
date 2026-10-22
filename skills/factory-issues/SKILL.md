---
name: factory-issues
description: >
  Stage 6 of the software factory. Splits the approved requirements into
  vertical-slice GitHub issues (issue #0 bootstrap first, every other issue
  blocked by it), checks every requirement is covered, shows the breakdown for
  one Approve/No, publishes it to GitHub and the board through the `board`
  script, then stops at S4. Also holds the procedure for updating issues after
  a requirement changes. Use when the factory router reaches stage 6 or a
  requirement changed after issues exist.
disable-model-invocation: true
---

# factory-issues

Stage 6. Design: `SOFTWARE-FACTORY.md` §4.6–§4.8. Run from the target repo.
`FS=~/.omp/agent/skills/factory/scripts/factory-state`,
`BOARD=~/.omp/agent/skills/factory-issues/scripts/board`. Every issue and
board write goes through `$BOARD`; never run `gh issue|project|api` by hand.

## Never

- Publish anything before the `issues` gate is approved.
- Publish with an uncovered requirement.
- Write file paths or line numbers into an issue body.
- Close or edit the parent (epic) issue's body after publishing.
- Skip issue #0, or leave an issue not blocked by it.

## Steps

1. **Entry check.** `$FS verify requirements stack architecture`. Exit 1 →
   print its `REOPEN` lines and stop; nothing is built on an unapproved or
   edited doc. Read the three docs, CONSTRAINTS.md, GLOSSARY.md, the ADRs.
   Record each doc's approved sha: `git log -1 --format=%h -- <file>`.
2. **Mode.** Take it from the user's prompt ("build it all", "feature by
   feature"); else pick by the rule and say which:

   | Mode | Use when | Branching | PRs |
   | --- | --- | --- | --- |
   | whole-app | new repo, or slices tightly coupled | one integration branch `factory/<epic>`; each issue in its own worktree, merged into it after its review/QA | one PR per frontier wave (Q5) |
   | feature-by-feature | existing app, slices independent | one branch per issue off `main` | one PR per issue; an issue whose blocker is unmerged waits, or stacks on the blocker's branch |

   `$FS set boardMode '"whole-app"'` (or `"feature-by-feature"`).
3. **Explore** the repo if existing: look for prefactoring that makes the
   change easy first ("make the change easy, then make the easy change"
   (mattpocock `to-tickets`)). Use GLOSSARY.md words in titles; respect ADRs.
4. **Slice** (mattpocock `to-tickets`, verbatim rules):
   - each slice is a narrow but complete path through every layer (schema,
     API, UI, tests), not a horizontal slice of one layer;
   - a completed slice is demoable or verifiable on its own;
   - each slice fits one fresh context window;
   - prefactoring goes first;
   - a wide mechanical refactor goes expand, then migrate in batches (each
     blocked by the expand), then contract (blocked by every batch);
   - test each ticket with "what can I demo when this is done?". No answer
     means a horizontal slice: redraw it.
5. **Issue #0** is always first: `factory-bootstrap` (slice key `bootstrap`).
   Every other issue lists it in Blocked by. Add further edges only where an
   issue truly needs another.
6. **Bodies.** One per slice from `issue-template.md` (this dir): Parent,
   Requirements covered, What to build, Acceptance criteria copied from the
   requirement's Given/When/Then each with its falsifying observation, Out of
   scope, Blocked by, UI yes/no, `sec:boundary` section when it touches a
   threat-model boundary in ARCHITECTURE.md, links to the approved docs at the
   shas from step 1 (mattpocock `triage/AGENT-BRIEF.md`).
7. **Coverage check.** Build the table R-number → issues from the Requirements
   covered lines. Any R in no issue **blocks publishing**: add or widen a
   slice, or tell the user the requirement has none and stop. Print the table.
8. **Write `docs/factory/ISSUES.md`:** header (mode, integration branch
   `factory/<epic-slug>` in whole-app, approved doc shas), the coverage
   table, the frontier waves (issues startable together; one PR each in
   whole-app), then each issue: key (`bootstrap`, `s01-…`), title, blocked by
   (keys), UI, sec, and its full body. No issue numbers yet.
9. **Gate Q2.** `read skill://factory-gate`, run it on `docs/factory/ISSUES.md`
   with gate name `issues` (one Approve/No; issues are public and slow to
   undo). Approve → it stamps and commits via `commit`. No → fix the
   breakdown, re-ask every section.
10. **Publish** only after the gate, in dependency order, blockers first:
    1. `$BOARD labels`; `$BOARD project-init` (exit 2 with a `project` scope
       message → tell the user `gh auth refresh -s project`, stop; resume
       here). Projects are optional only if the user says so: skip
       `project-init`/`add` then.
    2. Epic parent: `$BOARD create --key epic --title "Epic: <app>" --body-file <f>`
       (body: requirement list and ISSUES.md link). The epic is not queued.
    3. Per issue in order: write its body to `$TMPDIR/<key>.md`;
       `$BOARD create --key <key> --title … --body-file … [--label ui] [--label sec:boundary]`
       (prints the number; re-running prints the same one);
       `$BOARD sub-issue <epic> <n>`; `$BOARD blocked-by <n> <blocker>` per
       edge (blockers' numbers are known; replace keys with `#n` in the
       body's Blocked by); `$BOARD add <n>`.
    4. `$BOARD status <n> factory:queued` for every issue; then
       `$BOARD frontier` must print exactly the issues with no open blockers
       (issue #0 alone at first). If not, fix edges.
    5. `$FS set issues.<n> '{"status":"factory:queued","branch":null,"attempts":{}}'`
       per issue.
11. **Stop.** `git status` clean; `$FS stop S4 "Run /skill:factory to build the frontier, starting with issue #0"`
    and print the line it returns.

Resuming after a crash: `create` is idempotent by marker, so re-running step 10
never makes duplicates.

## Changed requirements (§4.8) — called by the router's `change` flow

Requirements were edited and re-approved (the gate header listed every issue and
PR citing each changed R). For each changed R, find citing issues
(ISSUES.md keys + `$BOARD list`) and act by state (`$FS get issues.<n>.status`, PR open?):

| Issue state | Action |
| --- | --- |
| Not started | Rewrite the body with `$BOARD edit`: re-copy acceptance criteria from the new Given/When/Then, links to the new approved sha. `$BOARD comment <n> --step req-change-<sha7> --body-file <f>` says what changed |
| In progress | Builder stopped first. Rewrite as above, `$BOARD status <n> factory:queued`; keep the branch; its verdicts no longer count |
| PR open | Pass the change to the builder as an "Act on" item on the same branch (factory-land); every invalidated review reruns; ask "Raise PR?" again |
| Merged | New follow-up issue citing the changed R and the merged issue, blocked by nothing open; same slicing and coverage rules |

- A removed R closes the issues that covered only it:
  `$BOARD close <n> --reason not-planned`. `$BOARD list` prints
  `number key state labels` for every factory issue; `$BOARD edit <n>
  --body-file <f>` rewrites a body and keeps its key marker.
- An added R gets new issues through steps 4–10 (new `ISSUES.md` rows, gate
  `issues` reopened and re-approved first).
- Update `docs/factory/ISSUES.md` to match and re-run the gate; then
  `factory-qa-author` rewrites holdout scenarios for every changed R.
