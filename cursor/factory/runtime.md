# Cursor runtime for the factory

The stage procedures stay in `skills/factory*` and `skills/feature/` at the
root of this repo. They were written for Oh My Pi. In Cursor, this file wins
wherever a stage skill names an omp tool. The sequence, gates, artifacts, and
stop rules in those skills stay as written.

Poteto's pstack (`poteto-mode` and its playbooks) does not replace this. It
has no stored approval, no whole-document No loop, no tech-stack stage, and
its shipping playbooks merge on their own. The factory stops before the PR
until you approve.

## Paths

Resolve once, from the target repo:

```sh
SKILL=$(python3 -c "import os; print(os.path.realpath(os.path.expanduser('~/.cursor/skills/factory/SKILL.md')))")
DOTFILES=$(cd "$(dirname "$SKILL")/../../../.." && pwd)
FS="$DOTFILES/skills/factory/scripts/factory-state"
BOARD="$DOTFILES/skills/factory-issues/scripts/board"
```

`FS` is every `~/.omp/agent/skills/factory/scripts/factory-state` in a stage
skill. `BOARD` is every `~/.omp/agent/skills/factory-issues/scripts/board`.
Pass `DOTFILES` in every subagent prompt.

## Reading skills

`skill://name` means Read `$DOTFILES/skills/name/SKILL.md`.
`skill://factory/state.md` means `$DOTFILES/skills/factory/state.md`.
`skill://factory/handoff-template.md` and `skill://factory-build/pr-template.md`
are the same idea. Do not call an omp `skill://` URI.

`commit` is the skill at `~/.cursor/skills/commit/SKILL.md`.

## Asking the user

Grill in chat. Number the questions, attach the recommended answer, then
wait. Do not use AskQuestion for grilling. "Whatever you think" and "sounds
good" are not answers. Follow `factory-grill`'s Language section in every
round: challenge a word that clashes with the glossary, sharpen a fuzzy
word, and when the user states how the code works, check it with `explore`.
App mode writes each settled term into `docs/factory/GLOSSARY.md` as it
settles. Feature mode reads the repo glossary and does not edit it; settled
terms go in the brief's **Terms** section. Renaming a term an approved doc
uses reopens that gate (`"$FS" reopen <gate>`). Adding a definition does not.

Gates use the AskQuestion tool, once, for the whole document.

- One question per top-level section. `id` is the section slug. `label`s are
  exactly `No` then `Approve`. Do not mark a recommended option.
- The PR gate is one question, id `pr`, header `PR`, text `Raise PR for <branch>?`,
  same two options.
- AskQuestion adds Other. Other, typed text, a skipped dialog, or any choice
  other than Approve is **No**. There is no timeout and no "Chat about this".
- On No, ask in chat for the reason if the user did not type one, then grill
  and show the **whole** document again.
- A cancelled dialog stamps nothing.
- Before the question, run `"$FS" blocked-on-user on`. After the answer,
  `"$FS" blocked-on-user off`.

## Subagents

Spawn with the Task tool. `subagent_type` is the file name in
`~/.cursor/agents/`. One message with several Task calls runs them in
parallel. Pass a brief: the issue or feature file, the doc paths and their
approved shas, the checks, and `DOTFILES`. Do not pass the chat.

The subagent returns once. There is no `agent://` write-back. If its json
block has `questions`, answer from the approved docs (ledger
`factory-call`) or relay them with AskQuestion, then spawn the same
subagent again with the answers in the prompt.

| Stage skill says | Cursor `subagent_type` |
| --- | --- |
| `scout` | `explore` (path:line facts only; also the Language code cross-check) |
| `reviewer` | `factory-reviewer` |
| `factory-planner`, `factory-builder`, `factory-spec-review`, `factory-test-review`, `factory-qa`, `factory-qa-author`, `factory-qa-review`, `factory-ui-review`, `factory-designer`, `factory-design-director`, `factory-design-review`, `factory-builder-check`, `factory-builder-unstick`, `factory-explainer` | the same name |

Models are pinned on those files. Do not pass `@default`, `@plan`, `@review`,
`@slow`, or `@vision`.

Attempt 2 of the fix ladder: spawn `factory-reviewer` on the failure evidence
only, then spawn `factory-builder-unstick` with that note as the advisor.
Attempt 3: spawn `factory-builder` again. There is no live advisor.

## GitHub

Use `gh`. There is no github tool.

| Stage skill says | Do this |
| --- | --- |
| `read issue://N` | `gh issue view N --comments` |
| `read pr://N` | `gh pr view N --comments` |
| `pr_create` | `gh pr create` (ready, not draft) after `pr-approve` |
| `run_watch` | `gh run watch` |
| `board status` | `"$BOARD" status …` |
| `board reset` | `"$BOARD" reset` (and `reset --dry-run` for the inventory) |

## Reset

`/factory reset` and `/feature reset` read
`$DOTFILES/skills/factory-reset/SKILL.md` and follow it with these
substitutions. Show the inventory and get Approve before changing anything.

- `"$FS"` and `"$BOARD"` are the paths resolved above, not the `~/.omp` paths
  in that skill.
- The confirm question is AskQuestion: id `reset`, header `Reset`, options
  `No` then `Approve`. When `.factory/state.json` exists, run
  `"$FS" blocked-on-user on` before the question and `"$FS" blocked-on-user off`
  after a No. Ask it in the same turn as the inventory, so the stop hook does
  not continue into the wipe.
- The docs commit is `~/.cursor/skills/commit/SKILL.md`.
- Remote deletes are `git push origin --delete <branch>` for `factory/*` and
  for `feature/<slug>` the run created. The hook allows those. Do not delete
  any other branch, and do not push the default branch.
- `"$FS" done` turns the guard off before those deletes. The last wipe step
  removes `.factory/`, which drops this chat's arm file.
- The last line names the docs-removal commit and says the user pushes the
  default branch. Then: a feature-mode run ends with *Run `/feature` with the
  new prompt.*; any other run ends with *Run `/factory` with the new prompt
  to start from requirements.*

## What Cursor does not do

- No `omp config`. The factory and feature skills have their own preflight.
- No task isolation and no parallel issue branches. Build frontier issues
  one at a time in this checkout. Do not set `parallelOk`.
- No `omp -p` and no `security://scans`. For a `sec:boundary` issue, run the
  security command named in CONSTRAINTS.md. If none is named, ledger the
  step `skipped` with evidence `no security command in CONSTRAINTS` and
  continue.
- No `proc://`. On pause, you cannot kill a subagent by id. Record it as
  interrupted in the handoff.
- Holdouts are `~/.cursor/factory/holdout/<repo>/<issue>/`. Only
  `factory-qa-author` writes them and only `factory-qa` reads them.
- Paper tools come from the Paper MCP. If they are not connected, stop that
  issue at `factory:needs-human` and say so. Do not draw the screens in code.

## Hooks

User hooks in `~/.cursor/hooks.json` enforce the guard while
`.factory/state.json` has `guard: true`: no merge, no `gh pr create` unless
`prApprovals` matches HEAD, no push outside `factory/*` and `feature/*`, no
`--force` without `--force-with-lease`, no edit of a stamped gate file.

`factory-state unattended on` arms this chat only. The stop hook keeps
submitting a follow-up until the exit predicate is met, the run is parked
(`stop`), or `blocked-on-user` is on. Press Stop to end the turn; the hook
does not continue an aborted turn. Resume with `/factory` or `/feature`.

## State

Same schema as `$DOTFILES/skills/factory/state.md`. Run `"$FS"` from the
target repo root. Exit 0 ok, 1 check failed, 2 usage error.
