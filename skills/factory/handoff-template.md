# Handoff — <feature slug or app name>

Paused: <UTC timestamp> · mode: <feature | app> · stage: <stage> · step: <step>
Branch: `<branch>` at `<short sha>` · Run state: `.factory/state.json`, `.factory/ledger.tsv`
Brief or approved docs: <`.factory/feature/<slug>.md` | `docs/factory/*` at their stamped sha>

The next chat reads this file first, then the brief or docs, then the ledger.
It never acts on this file alone: every claim here is re-checked against the
branch, the ledger, and GitHub before a step is skipped.

## Where the run is

One paragraph: what the run is building, which step was running when it was
paused, and what that step had produced so far.

## Done (do not redo)

- <step or task id> — <what landed> — `<commit sha>` / PR <url> / comment <url>

## In progress when paused

- <step> — <helper agent and its last reported state, or "main session">
  — <partial output worth keeping, with the file or agent:// path>

## Decided in this chat, not yet in the brief or approved docs

Each item: the decision, who made it (you or "factory's call" with its
source), and whether it changes an approved doc. A change to an approved doc
reopens that gate in the next chat; it is never applied silently.

- <decision> — <you | factory's call: source> — <changes approved doc? which section>

## Waiting on the user

- <question, with the recommended answer>

## Open review findings

- Act on: <finding — file:line — from which reviewer>
- Consider: <finding — the call made>

## Working tree

- `git status --short`: <clean | the listed paths>
- Uncommitted changes belong to: <step>. Their tests: <pass | fail | not run>.
- Stashes made: <`wip/<slug>/<step>` | none>

## Next action

One sentence the next chat starts with, naming the step and the agent to
spawn (for example: "Spawn factory-builder for task T3 on feature/<slug>; T1
and T2 are done").
