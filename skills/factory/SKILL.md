---
name: factory
description: >
  Entry and router for the software factory. Checks the environment, reads
  .factory/state.json, the ledger and the issue labels, then resumes the
  right stage: requirements, stack, architecture, issues, build, land.
  `change <text>` runs the requirement-change flow; `status` prints where
  the run is. Use when the user invokes /skill:factory to start or resume
  building a whole app. For one feature in an existing app use
  /skill:feature instead.
argument-hint: "[status | change <text>]"
disable-model-invocation: true
---

# factory

Run from the target repo's root. Design: `SOFTWARE-FACTORY.md` in the
dotfiles repo. Schema, ledger, labels, stops, retry table: `skill://factory/state.md`.
State tool (every call below): `FS=~/.omp/agent/skills/factory/scripts/factory-state`.

This builds a **whole app**. For a single feature in an existing app, tell the
user to run `/skill:feature` and stop.

## 1. Preflight (every start, including `status`)

Report all failures at once, fix only what is listed as fixable.

1. `git rev-parse --show-toplevel` succeeds, and cwd is that root. Else stop.
2. `git config user.email` is non-empty. Else stop: isolated merges fail
   without a git identity (§5.3). Tell the user to set it in this repo.
3. **Context files** (§8 item 7): root `AGENTS.md` exists, and
   `.claude/CLAUDE.md` has a bare `@../AGENTS.md` line outside any code
   fence. A root `CLAUDE.md` is never loaded next to `AGENTS.md`. If one
   exists, show it, ask (`ask`) before deleting it, then merge its content
   into `.claude/CLAUDE.md` and remove it. If `AGENTS.md` is missing, say so
   and have the user create it (or let `factory-bootstrap` do it); do not invent one.
4. Settings, each with `omp config get <key>`: `github.enabled`,
   `secrets.enabled`, `security.enabled`, `compaction.handoffSaveToDisk`,
   `task.isolation.enabled` all true; `task.isolation.merge` is `branch`;
   `task.isolation.commits` is `ai`. List the ones that are off or wrong and
   the command to fix each. Do not change settings yourself.
5. `gh auth status` shows the `project` scope (board access). Else tell the
   user to run `gh auth refresh -s project`.

Steps 1–2 failing stops the run. Steps 3–5: stop until fixed, except in
`status`, which only reports.

## 2. State

- No `.factory/state.json` and arguments are not `status`: `$FS init --mode app`.
  A new repo starts at **requirements**.
- `status` with no state: say "no factory run here" and stop.
- `$FS verify`. Each `REOPEN <gate> <file>` line means an approved doc
  changed after approval. Tell the user, `$FS reopen <gate>`, and route to
  that gate's stage (the earliest reopened one) to approve it again.
- `$FS ledger open`: unfinished steps. Apply the resume protocol in
  `state.md` when routing to `build` or `land`.
- `$FS get`: read `stage`, `stop`, `nextAction`, `issues`.

## 3. Arguments

| Arguments | Action |
| --- | --- |
| none | **resume**: route (section 4) |
| `status` | print stage, each gate (approved or open, file, approvedAt), `stop`, `nextAction`, open ledger rows, and each issue's status from `issues` (and its label via `gh issue list --label factory:...` if GitHub is reachable). Change nothing. |
| `change <text>` | requirement change (section 5) |

## 4. Route

Clear the stop first: `$FS set stop null` once you act on it.

| `stage` | Read and follow |
| --- | --- |
| `requirements` | `skill://factory-requirements` |
| `stack` | `skill://factory-stack` |
| `architecture` | `skill://factory-architecture` |
| `issues` | `skill://factory-issues` |
| `build` | `skill://factory-build` |
| `land` | `skill://factory-land` |

On `build` or `land`, first list open factory PRs
(`gh pr list --search "head:factory/" --state open`) and `read pr://<N>` for
each (comments included). A PR with unresolved review comments, a conflict,
or failing CI, or a merged PR with post-merge work pending, goes to
`skill://factory-land` before any new issue starts (§5.7). A stop `S5` with
open PRs always routes to `land` first. Otherwise follow `nextAction`.
Stage skills own their gate, stamp, commit and stop; do not duplicate them here.

## 5. `change <text>` (§4.8)

1. Stop building: no new helper agents; let none run unattended.
   `$FS blocked-on-user on` while talking to the user.
2. `$FS reopen requirements`, set `stage` to `requirements`
   (`$FS set stage '"requirements"'`), then read `skill://factory-requirements`
   with the change text. It edits REQUIREMENTS.md and shows the gate with a
   "what changed" header: each added, changed or removed `R` number and every
   issue and PR citing it, with what happens to each.
3. Reopen STACK.md or ARCHITECTURE.md (`$FS reopen stack|architecture`) only
   if the change touches them.
4. After approval, read `skill://factory-issues` in update mode. It applies
   the §4.8 table: not started → rewrite issue, new doc sha, comment; in
   progress → stop builder, rewrite, `factory:queued`, keep branch, old
   verdicts void; PR open → "Act on" item to the builder on the same branch,
   rerun invalidated reviews, ask "Raise PR?" again; merged → follow-up
   issue; removed `R` closes its issues as not planned; added `R` gets
   new issues. `factory-qa-author` rewrites holdouts for changed `R`.

## Never

- Change omp settings, delete a user's root `CLAUDE.md` without asking, or
  edit product code from this skill.
- Merge, open a PR, or push; the stage skills and the guard hook own that.
- Rely on earlier chat: state, ledger and labels are the source of truth.
- Use `implementation-plan`, `review-implementation-plan`,
  `follow-implementation-plan`, or `follow-plan-with-review` as a step; they
  serve the manual chat flow, not the factory.
