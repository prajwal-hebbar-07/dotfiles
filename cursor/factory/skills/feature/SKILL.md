---
name: feature
description: >
  The feature factory in Cursor: one feature in an existing app, fitted to
  the current architecture with the smallest change that does the job, and
  delivered as a reviewed PR. Scout, short interview, one solution sketch,
  one brief gate, plan, build, two parallel reviews, QA through what the
  repo already has, then a PR gate. Use when the user invokes /feature or
  asks to add one feature to an existing project.
argument-hint: "[<feature description> | #<issue> | resume | pause]"
disable-model-invocation: true
---

# feature (Cursor)

Design: `FEATURE-FACTORY.md` (decisions D1–D12). This file is the Cursor
procedure. Do not follow `skills/feature/SKILL.md`; that copy is the Oh My
Pi procedure. Tool names and subagents: `cursor/factory/runtime.md`. Read
it before step 1.

## Resolve

```sh
SKILL=$(python3 -c "import os; print(os.path.realpath(os.path.expanduser('~/.cursor/skills/factory/SKILL.md')))")
DOTFILES=$(cd "$(dirname "$SKILL")/../../../.." && pwd)
FS="$DOTFILES/skills/factory/scripts/factory-state"
```

## Never

- Create or edit GitHub issues. `#N` is read only (`gh issue view N --comments`).
- Merge, force-push, or push any branch except `feature/<slug>`.
- Open the PR before the Gate 2 Approve.
- Write the feature's code yourself. `factory-builder` does, and every
  commit goes through the `commit` skill.
- Design a new module, service, datastore, or runtime (stop rule, step 3).
- Run Paper or a design stage unless the user asked for one.
- Use `implementation-plan` or `follow-implementation-plan`.

## 0. Preflight

1. `git rev-parse --show-toplevel` succeeds; `cd` there. Else stop.
2. `git config user.email` is non-empty. Else stop and tell the user. Do
   not set it yourself.
3. Root `AGENTS.md` exists. If it is missing, say so and stop. Do not
   invent one.
4. `gh auth status` succeeds. Else stop.
5. `"$FS" init --mode feature --slug <slug>`. `<slug>` is lowercase, with
   non-alphanumerics turned into `-`, from the description or the issue title.

**Pause** (`/feature pause`, in this chat, after Stop): skip step 5. Follow
"Pause" in `$DOTFILES/skills/factory/state.md` using the runtime's pause
rule. Write `.factory/handoff.md` from
`$DOTFILES/skills/factory/handoff-template.md`, then
`"$FS" pause "<next action>"`. Print its line and end.

**Resume** (no arguments, or `resume`, and an unfinished
`.factory/feature/*.md` exists; if several, ask which): follow "Resume
protocol" in `state.md`. `"$FS" resume`. If it prints `HANDOFF`, read the
handoff and archive it. A handoff decision that changes the approved brief
goes back through Gate 1. Re-arm with `"$FS" unattended on "<reason>"` when
the run was unattended. Continue at the step Status and `git log` show.
Never redo a commit, push, or PR. An interrupted gate is asked again in full.

Ledger: around every subagent, `"$FS" ledger start|done|verdict` with
`--issue <slug> --stage feature`. Keep Status in the brief current.

## Steps

1. **Scout.** Task `explore`. Map where the feature lands: architecture
   docs, `AGENTS.md`, nearby code, tests, and the lint, type, test, and
   E2E commands (and any `verify-<app>` skill). Ask for `path:line` facts
   only. Start the brief from `$DOTFILES/skills/feature/brief-template.md`
   at `.factory/feature/<slug>.md`. Fill Repo checks. Do not ask the user
   what the repo already answers.
2. **Interview.** Read `$DOTFILES/skills/factory-grill/SKILL.md` and run it
   under the runtime (chat, not AskQuestion), including its Language
   section. Fix the outcome, acceptance criteria AC1.. as Given / When /
   Then, and out of scope. Read the repo glossary if it has one
   (`docs/factory/GLOSSARY.md`, else `GLOSSARY.md` or `GLOSSARY-MAP.md` at
   the root) and leave that file alone. Write each settled term into the
   brief's **Terms** section as it settles (`**Term**:` definition,
   `_Avoid_:` synonyms). A code cross-check uses `explore`. Stop when the
   next three answers can be predicted and every settled term is in Terms.
3. **Sketch.** Write one design into the brief: **Reuses** (modules, files,
   patterns, each with a path) and **New pieces** (every new file,
   dependency, table, abstraction, config option). A sketch whose Reuses
   names nothing is redone before the user sees it. Then the simplicity
   round from factory-grill, Language included: one question per new piece,
   the simpler option recommended, and any new term folded into **Terms**.
   **Stop rule:** a new module, service, datastore, or runtime,
   a module-boundary change, or more than 10 commits:
   `"$FS" stop S5 "split the feature, or run /factory"`, tell the user why,
   and end. A new library dependency is a question, not a stop. UI features
   reuse the app's existing components.
4. **Gate 1.** Read `$DOTFILES/skills/factory-gate/SKILL.md`, feature
   variant, gate `brief`, file `.factory/feature/<slug>.md`. Show the whole
   brief, then one AskQuestion (runtime rules). Approve runs
   `"$FS" stamp brief <file>`. Do not commit the brief. Record the sha256
   in the ledger and immediately `"$FS" reopen brief`, so later Tasks and
   Status edits are not blocked. No: grill on the reasons, back to step 2
   or 3.
5. **Plan.** `git switch -c feature/<slug>` off the default branch. Unless
   the user asked for step-by-step, `"$FS" unattended on "feature not at the PR gate yet"`.
   Spawn `factory-planner` (read-only) with the brief path and `DOTFILES`.
   Write its 1–10 tasks (XS–L) into the brief. `BLOCKED` (any XL, or more
   than 10 tasks): stop as in step 3.
6. **Build.** For each task, spawn `factory-builder` with the brief path,
   task id, and `DOTFILES`. Tests first. Commits go through `commit`.
   If the user asked for step-by-step, record `Mode: step-by-step`, stop
   after each commit, and wait. Mark each task `done <sha>`.
   `NEEDS_CONTEXT` or `BLOCKED`: the runtime's questionnaire. Unresolved
   after two tries, stop and flag the user. No unstick agent.
7. **Review.** In one message, spawn `factory-reviewer` (correctness) and
   `factory-spec-review` (spec, simplicity, tests). Synthesise with
   `$DOTFILES/skills/factory-review/SKILL.md`: Act on / Consider / Noted /
   Dismissed. Act on items go back to `factory-builder`, then review again.
   At most 3 rounds. After the third with Act on items left,
   `"$FS" stop S5 "review round limit; user decides"` and end. Anything
   `factory-spec-review` marks Required for being unrequested code is Act on.
8. **QA.** Spawn `factory-qa` with the brief path, the E2E or `verify-<app>`
   command, the head sha, and `DOTFILES`. No holdout scenarios. Evidence
   goes to `qa-evidence/<slug>/<sha>/`. FAIL goes back to step 6 and counts
   as a review round. `BLOCKED` whose notes start "no automated check
   available" is not a failure: put the manual-check list in the PR body.
9. **PR.** Run the repo's lint, type, and test commands again. All must
   pass. Write the PR body from
   `$DOTFILES/skills/factory-build/pr-template.md`. Include **Manual check**.
   End with `Closes #N` only when the input was an issue. Print the body,
   then the PR gate (runtime: one AskQuestion, "Raise PR for feature/<slug>?").
   No: the reason is an Act on item. Approve:
   - `git push -u origin feature/<slug>`. If the repo has CI, `gh run watch`.
     Red CI is an Act on item.
   - `"$FS" pr-approve feature/<slug> $(git rev-parse HEAD)`, then
     `gh pr create` (ready, not draft).
   - Record the URL, `"$FS" exit met "PR open"`, `"$FS" done`. Last line
     to the user: the PR URL.

## Questionnaires

A helper reply with `questions` stopped instead of guessing. Answer from
the approved brief when the answer is there (ledger `factory-call`).
Otherwise relay with AskQuestion (`blocked-on-user on`, then `off`) and
spawn the helper again with the answer. An answer that changes the brief
reopens Gate 1. Helpers never push or open PRs.
