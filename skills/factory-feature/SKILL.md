---
name: factory-feature
description: >
  The feature factory: takes one feature for an existing app, fits it into
  the current architecture with the smallest change that fully does the job,
  and delivers it as a reviewed PR. Scout, short interview, one solution
  sketch with a simplicity round, one brief gate, plan, unattended build,
  two parallel reviews, QA through what the repo already has, PR gate. Use
  when the user invokes /skill:factory-feature or asks to add one feature to
  an existing project.
argument-hint: "[<feature description> | #<issue> | resume]"
disable-model-invocation: true
---

# factory-feature

Design: `FEATURE-FACTORY.md` in the dotfiles repo (decisions D1-D12). Run from
the target repo's root. Agents are spawned by name; their files carry the
models. Briefs and results follow the helper-agent contract in
`SOFTWARE-FACTORY.md` §5.5 (final fenced `json` block).

## Never

- Create or edit GitHub issues (D3). `#N` is read only.
- Merge, force-push, or push any branch except `feature/<slug>`. Open the PR before the Gate 2 Approve.
- Write code yourself; `factory-builder` does, and every commit goes through `commit`.
- Design a new module, service, datastore, or runtime (stop rule, step 3).
- Run Paper or a design stage unless the user asked for one (D9).
- Reference or use `implementation-plan` or `follow-implementation-plan`.

## 0. Preflight
1. `git rev-parse --show-toplevel` succeeds; `cd` there. Else stop.
2. `git config user.email` is non-empty (task isolation merges need it). Else stop.
3. Layout (as `/skill:factory` checks): `AGENTS.md` at the root, and `.claude/CLAUDE.md` containing a bare `@../AGENTS.md` line. A root `CLAUDE.md` would shadow it: move its content into `.claude/CLAUDE.md` under the import line and delete the root file. Tell the user; do not commit it.
4. The `github` tool is usable (`github.enabled`; see `omp://tools/github.md`). Else stop and say so.
5. `~/.omp/agent/skills/factory/scripts/factory-state init --mode feature --slug <slug>` (called `FS` below). `<slug>`: lowercase, non-alphanumerics to `-`, from the description or issue title.

**Input.** Chat text, or `#N` via `read issue://N` (title, body, comments). **Resume:** no arguments, and an unfinished `.factory/feature/*.md` exists: read its Status, `git log` on `feature/<slug>`, and `FS ledger open`; continue at that step. Each step first checks whether it is already done (task marked `done <sha>`, PR open); never redo a commit or PR. Several unfinished briefs: ask which.

Ledger: around every agent run, `FS ledger start|done|verdict --issue <slug> --stage feature --step <step> --agent <name> --result <verdict>`. Keep Status in the brief current after each step.

## Steps

1. **Scout.** One `scout` (`task`) maps where the feature lands: architecture docs, `AGENTS.md`, nearby code, tests, and the repo's lint, type, test, and E2E commands (and any `verify-<app>` skill). Ask it for `path:line` facts only. Start the brief from `skill://factory-feature/brief-template.md` at `.factory/feature/<slug>.md`; fill Repo checks. Never ask the user what the repo answers.
2. **Interview.** `read skill://factory-grill`. Fix the outcome, acceptance criteria numbered AC1.. as Given / When / Then, and out of scope. Short: stop when the next three answers can be predicted.
3. **Sketch.** Write one design into the brief: **Reuses** (modules, files, patterns, each with a path) and **New pieces** (every new file, dependency, table, abstraction, config option). A sketch whose Reuses names nothing is rejected and redone before the user sees it. Then the simplicity round, in the grill's question format: one question per new piece, ponytail ladder (does it need to exist; does the codebase, standard library, platform, or an installed dependency already do it), the simpler option recommended; "we might need it later" is not a reason. Fold answers in. **Stop rule (D5):** a new module, service, datastore, or runtime, a module-boundary change, or more than 10 commits: `FS stop S5 "split the feature, or run /skill:factory"`, tell the user why, suggest splitting or the full factory, end. A new library dependency is a question with the simpler option recommended, not a stop. UI features reuse the app's existing components (D9).
4. **Gate 1.** `read skill://factory-gate`, feature variant, gate `brief`, file `.factory/feature/<slug>.md`: whole brief in chat, one `ask`, Approve stamps (`FS stamp brief …`). Not committed. The same file later gets the Tasks table and Status updates, which the guard blocks while the stamp stands, so right after the Approve record the approved sha256 in the ledger (`ledger verdict --step gate-brief --result approved --evidence <sha256>`) and run `FS reopen brief`. No: grill on the reasons, back to step 2 or 3.
5. **Plan.** `git switch -c feature/<slug>` off the default branch. Unless the user asked for step-by-step, `FS unattended on "feature not at the PR gate yet"`: from here to step 9 the stage guard keeps the session from ending early. Spawn `factory-planner` (read-only) with the brief path (feature-mode brief); it returns 1-10 tasks sized XS-L, each with the acceptance criteria it covers and its verification, and you write them into the brief's Tasks table. Planner `BLOCKED` (any XL, or more than 10 tasks): stop as in step 3. Update Status.
6. **Build.** For each task in order, spawn `factory-builder` with the brief path and task id (tests first; its commits go through `commit`). Unattended (D6b); if the user asked for step-by-step at invocation, record `Mode: step-by-step`, stop after each commit with a summary, and wait. After each `DONE`, mark the task `done <sha>`. `DONE_WITH_CONCERNS`: carry the note to review. `NEEDS_CONTEXT` or `BLOCKED`: see Questionnaires; unresolved after two tries, flag the user and stop. No unstick agent (D7).
7. **Review.** In one `task` batch: `reviewer` (correctness; gets the diff `<default>...HEAD`, brief path, repo checks) and `factory-spec-review` (spec, simplicity, tests; gets the brief path and diff). Synthesise per `read skill://factory-review`: Act on / Consider / Noted / Dismissed, with the reason for each dismissal. Act on items go to `factory-builder` as a fix task, then review again. At most 3 rounds; after the third with Act on items left, `FS stop S5 "review round limit; user decides"`, flag the user with the open items, end. Anything `factory-spec-review` marks Required for being unrequested code is an Act on.
8. **QA (D8).** Spawn `factory-qa` with the brief path, the E2E command or `verify-<app>` skill from Repo checks, and the head sha; it runs what the repo already has against the acceptance criteria. No holdout scenarios. Evidence goes to `qa-evidence/<slug>/<sha>/`. FAIL: back to step 6 as a fix task (counts as a review round). `BLOCKED` whose notes start "no automated check available" is not a failure here: put its manual-check list in the PR body and go on. Any other `BLOCKED`: questionnaire.
9. **PR.** Run the repo's lint, type, and test commands once more; all must pass. Write the PR body from `skill://factory-build/pr-template.md` (Why from the approved brief, What changed, Scope, Tradeoffs, Blast Radius, Verification with the ledger summary and QA evidence). Always include **Manual check**: the acceptance criteria as short steps (how to start, what to click, what to see). End with `Closes #N` only when the input was an issue; otherwise no closing line. Print the body, then the PR gate (`skill://factory-gate`, PR variant, one question "Raise PR for feature/<slug>?"). No: the reason becomes an Act on item. Approve:
   - `git push -u origin feature/<slug>`; wait for CI with `github` `run_watch` when the repo has CI; red CI is an Act on item.
   - `FS pr-approve feature/<slug> $(git rev-parse HEAD)`, then `github` `pr_create` (ready, not draft).
   - Record the URL in Status, `FS exit met "PR open"`, `FS done`. Last line to the user: the PR URL.

## Questionnaires

A helper reply with `questions` means it stopped instead of guessing. Answer first from the approved brief; an answer found there is a ledger "factory's call" row (`ledger verdict --result factory-call --evidence "<brief section>"`). Else relay through `ask` unchanged (`FS blocked-on-user on`, then `off`). Send the answer back with `write agent://<id>`. An answer that changes the brief reopens Gate 1 (`FS reopen brief`, back to step 4). Helpers never push or open PRs; do those yourself.

## Credits

Simplicity ladder: ponytail (DietrichGebert). Question format: mattpocock `grilling`. Task format and sizing: addyosmani `planning-and-task-breakdown`. PR sections: pstack `opening-a-pr`.
