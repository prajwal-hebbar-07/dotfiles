---
name: factory
description: >
  Entry and router for the software factory in Cursor. Checks the repo,
  reads .factory/state.json, and resumes requirements, stack, architecture,
  issues, build, or land. `change <text>` revises a requirement; `status`
  prints where the run is. Use when the user invokes /factory or asks to
  start or resume building a whole app with the software factory. For one
  feature in an existing app, use /feature instead.
argument-hint: "[status | change <text> | pause]"
disable-model-invocation: true
---

# factory (Cursor)

Builds a whole app. For one feature in an existing app, tell the user to
run `/feature` and stop.

Design: `SOFTWARE-FACTORY.md` at the dotfiles root. Tool names, subagents,
and hooks: `cursor/factory/runtime.md` in that same repo. Read the runtime
first and follow it wherever a stage skill names an omp tool. Schema and
resume rules: `skills/factory/state.md`.

## Resolve

```sh
SKILL=$(python3 -c "import os; print(os.path.realpath(os.path.expanduser('~/.cursor/skills/factory/SKILL.md')))")
DOTFILES=$(cd "$(dirname "$SKILL")/../../../.." && pwd)
FS="$DOTFILES/skills/factory/scripts/factory-state"
BOARD="$DOTFILES/skills/factory-issues/scripts/board"
```

Read `$DOTFILES/cursor/factory/runtime.md` before routing.

## 1. Preflight (every start, including `status`)

Report every failure at once. Fix nothing that is not listed as fixable.

1. `git rev-parse --show-toplevel` succeeds and the cwd is that root. Else stop.
2. `git config user.email` is non-empty. Else stop and tell the user to set
   it in this repo. Do not set it yourself.
3. Root `AGENTS.md` exists. If it is missing, say so. Do not invent one.
   `factory-bootstrap` may create it during issue #0.
4. `gh auth status` succeeds. For the board, the token needs the `project`
   scope. If it does not, tell the user to run `gh auth refresh -s project`.

Steps 1–2 stop the run. Steps 3–4 stop until fixed, except `status`, which
only reports.

## 2. State

- No `.factory/state.json`, and the argument is not `status`:
  `"$FS" init --mode app`. A new repo starts at **requirements**.
- `status` with no state: say "no factory run here" and stop.
- `"$FS" verify`. Each `REOPEN <gate> <file>` line means an approved doc
  changed. Tell the user, `"$FS" reopen <gate>`, and route to that stage.
- `"$FS" resume` (skip for `pause` and `status`). If it prints `HANDOFF`,
  read `.factory/handoff.md` first and follow the resume protocol in
  `state.md`.
- `"$FS" get`: read `stage`, `stop`, `nextAction`, `issues`.

## 3. Arguments

| Arguments | Action |
| --- | --- |
| none | resume: route (section 4) |
| `status` | print stage, each gate, `stop`, `nextAction`, open ledger rows, and each issue's status. Change nothing. |
| `change <text>` | section 5 |
| `pause` | follow "Pause" in `state.md`, with the runtime's pause rule (no `proc://`). Write `.factory/handoff.md` from `skills/factory/handoff-template.md`, then `"$FS" pause "<next action>"`. Print its line and end. Skip preflight 3–4 and section 4. |

Clear a stop with `"$FS" set stop null` once you act on it.

## 4. Route

Read the stage skill and follow it under the runtime. Grilling is
`factory-grill`, including its Language section: every round challenges
clashing words, sharpens fuzzy ones, and checks claims against the code
(`explore`). Settled terms go into `docs/factory/GLOSSARY.md` as they
settle, starting in the requirements grill. The requirements gate and, when
the grill changed the file, the stack gate commit that glossary with the
stage doc. Architecture adds draft terms as questions in that grill, not as
a glossary written on its own. Renaming a term an approved doc already uses
reopens that doc's gate.

| `stage` | Read |
| --- | --- |
| `requirements` | `$DOTFILES/skills/factory-requirements/SKILL.md` |
| `stack` | `$DOTFILES/skills/factory-stack/SKILL.md` |
| `architecture` | `$DOTFILES/skills/factory-architecture/SKILL.md` |
| `issues` | `$DOTFILES/skills/factory-issues/SKILL.md` |
| `build` | `$DOTFILES/skills/factory-build/SKILL.md` |
| `land` | `$DOTFILES/skills/factory-land/SKILL.md` |

On `build` or `land`, first list open factory PRs
(`gh pr list --search "head:factory/" --state open`) and read each with
`gh pr view N --comments`. Unresolved comments, a conflict, failing CI, or
a merged PR with post-merge work goes to `factory-land` before any new
issue. A stop `S5` with open PRs routes to land first. Otherwise follow
`nextAction`.

## 5. `change <text>`

1. Stop building. `"$FS" blocked-on-user on` while talking to the user.
2. `"$FS" reopen requirements`, set stage to `requirements`, then follow
   `factory-requirements` with the change text. Show the gate with a
   "what changed" header.
3. Reopen STACK.md or ARCHITECTURE.md when the change touches them, and
   when it renames a term that doc already uses. Adding a definition leaves
   the gate shut.
4. After approval, follow `factory-issues` in update mode, as that skill
   describes.

## Never

- Merge, open a PR, or push. The stage skills do that, and the hook blocks
  it until the PR gate records approval.
- Edit product code from this skill.
- Rely on an earlier chat. State, the ledger, and GitHub labels are the
  source of truth.
- Use `implementation-plan`, `review-implementation-plan`,
  `follow-implementation-plan`, or `follow-plan-with-review`.
