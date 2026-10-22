---
name: factory-build
description: >
  Factory stages 7-8: builds each issue on the board through the fixed
  pipeline (plan, QA scenarios, design, code, reviews, security scan, QA,
  UI review), runs the pre-PR GO / NO-GO, asks "Raise PR?", pushes the
  factory/* branch and opens the PR. Use only when /skill:factory routes
  to stage build; never invoke on its own.
argument-hint: "[issue number | wave]"
disable-model-invocation: true
---

# factory-build

You are the only orchestrator. Every role is a helper agent at depth 1. Run
from the target repo root, never in plan mode. Per-issue step detail is in
`skill://factory-build/pipeline.md`; read it before the first issue. PR body:
`skill://factory-build/pr-template.md`. Design: `SOFTWARE-FACTORY.md` §5.1-§5.5.

Shorthand: `FS` = `~/.omp/agent/skills/factory/scripts/factory-state`,
`board` = `~/.omp/agent/skills/factory-issues/scripts/board`.

## Never

- Merge, push outside `factory/*` (or `feature/*`), use bare `--force`, or open
  a PR before the PR gate is approved.
- Let a helper agent see `~/.omp/factory/<repo>/holdout/` (only `factory-qa-author`
  and `factory-qa` may).
- Guess a missing requirement, relax the exit predicate, or edit a test, a
  threshold, or CONSTRAINTS.md to turn a check green.
- Run a fourth attempt on one failure.
- Pass chat to an agent. Pass a brief: issue + docs at their approved sha +
  plan + `check:*` commands.
- Trust a verdict whose patch-id differs from the head's.

## Entry

1. `FS verify`. Exit 1 prints `REOPEN <gate> <file>`: stop and send the user to
   `/skill:factory` to reopen that gate.
2. `FS ledger open`: resume per `pipeline.md` § Resume before new work.
3. Mode: `FS get boardMode` (`whole-app` | `feature-by-feature`). Whole-app:
   integration chain `factory/<epic>-w<k>` (wave 1 off main, each later wave
   off the previous wave's branch); one PR per frontier wave (Q5); see
   `pipeline.md` § Whole-app waves.
4. `board frontier` lists issues whose blockers are all closed. Take them in
   order. Sequential until one issue has run clean; then
   `FS set parallelOk true` and run frontier issues in parallel with
   `isolated: true` (needs `git config user.email`; hook still applies).

## Per issue (order is fixed)

Each step: `FS ledger start --issue N --stage build --step <s> --agent <a>`
before, `ledger done` (or `ledger verdict --result <v> --sha <head>`) after.
Before every helper spawn: `FS budget N`; exit 1 means set
`factory:needs-human`, write a ledger summary (spent, why), move to the next
issue. Set the label with `board status N <label>` at each phase change.
Helper replies end in one json block (verdict, findings, questions, notes).

| # | Step | Agent | Label | Pass | On fail |
| --- | --- | --- | --- | --- | --- |
| 1 | Plan | `factory-planner` | `factory:building` | plan + seams + `sec:boundary` list | questions: § Questionnaires |
| 2 | QA scenarios (parallel with 1) | `factory-qa-author` | | holdout written | |
| 3 | UI issue only: design | `factory-designer` | | screens drawn | |
| 4 | Design review | `factory-design-review` | | PASS | back to 3, max 3 cycles, then needs-human |
| 5 | Code + tests | `factory-builder` on `factory/<N>-<slug>` | | DONE / DONE_WITH_CONCERNS | ladder below |
| 6 | Reviews, three in parallel | `reviewer`, `factory-spec-review`, `factory-test-review` | `factory:review` | all pass | synthesise, back to 5, max 3 cycles |
| 7 | `sec:boundary` only: security scan | `omp -p`, then `security://scans` | | PASS / PASS+NOTES | back to 5 |
| 8 | QA | `factory-qa` | `factory:qa` | all PASS | back to 5 |
| 9 | QA review | `factory-qa-review` | | PASS / PASS+NOTES | back to 5 |
| 10 | UI issue only: UI review | `factory-ui-review` | `factory:ui` | PASS | back to 5 |
| 11 | GO / NO-GO | main session | | all four checks | NO-GO: fix, back to the failing step |
| 12 | PR gate, push, PR | `factory-gate` PR variant | `factory:pr-ready` | Approve | No: reason is an "Act on" item, back to 5 |

Steps 3-4 and 7, 10 are skipped (ledger `done --result skipped`) when the
issue is not UI / not `sec:boundary`. Step 5 hands the builder only the
approved plan, never holdout scenarios.

**Review synthesis (step 6).** Merge the three replies into four lists. Act
on = correct and in scope (all Critical/Required, P0-P1, test FAIL findings).
Consider = judgement calls (state the call). Noted = true, no action.
Dismissed = wrong or out of scope, with the evidence. Only Act on goes to the
builder. Record each list size in the ledger.

**Patch pinning.** At every verdict run `git patch-id --stable` on
`git diff <base>...HEAD` and pass it as `--sha`'s companion in `--evidence
patch-id=<id>`. Reuse a verdict only if the head's patch-id is unchanged
(a clean rebase keeps verdicts); otherwise re-run every reviewer it
invalidated. List any verdict from a fallback model (agent file's second
model) with `--result <v> --model <fallback>` and the word `fallback`.

**Fix ladder (§5.3).** Count per failure (test id + error class); a rerun with
no change is not an attempt. 1: builder reproduces in isolation and fixes.
2: `factory-builder-unstick`. 3: fresh `factory-builder` with model override
`@default`, given evidence from 1-2, not their transcript. After 3: builder
writes what it tried and the suspected design cause, `factory:needs-human`,
ledger summary, next issue. Start the ladder early when the same failure
repeats, the diff grows while failures do not drop, or the builder proposes
editing a test, threshold or CONSTRAINTS.md.

**MISSING REQUIREMENT.** Stop the issue, `factory:needs-human`, tell the user
the gap, `FS reopen requirements`, hand back to `/skill:factory`.

**Questionnaires.** A reply with `questions` means the agent stopped. Answer
from approved docs and ADRs, ledger `step=questionnaire --result "factory's
call: <source>"`; else call `ask` with the questions unchanged. An answer that
changes an approved doc: `FS reopen <gate>`. Return answers with
`write agent://<id>`. Approval-tier requests (push, PR) stay with you.

## Pre-PR and PR (step 11-12)

GO / NO-GO in order: (1) every verdict covers the head patch-id, no
`factory:needs-human`; (2) `check:full` from CONSTRAINTS.md passes; (3) plain
`git push -u origin factory/<N>-<slug>`; (4) CI green via `github`
`run_watch`. Fill `pr-template.md`, print the body in chat, read
`skill://factory-gate`, ask "Raise PR for <branch>?" once. Approve:
`FS pr-approve <branch> <head-sha>`, then `github` `pr_create` (ready, not
draft; base = previous wave branch in whole-app mode, else main). Then
`FS stop S5 "<next action>"` and print the line it returns. Whole-app: S5
after each wave, not each issue.

## Exit predicate

At stage start, after Entry: `FS unattended on "<reason>"` (sets the exit
predicate unmet; the stage guard then keeps the session from ending early).
`FS exit met "<reason>"` only when no issue in the wave is open without
`factory:pr-ready` or `factory:needs-human`. `FS stop S5` and asking the user
through `ask` or a questionnaire also release it (`FS blocked-on-user on`
before a chat question, `off` after). Set it from the checks, not from a
claim.
