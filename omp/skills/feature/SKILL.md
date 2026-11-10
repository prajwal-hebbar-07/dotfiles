---
name: feature
description: Add one feature to an application that already exists. Specify it against the shipped app in rounds through the requirements grill (only high-impact decisions reach the user, through an interview in the session), run the stack grill only when the feature brings in new technology and the design (wireframes, then Paper) only when it changes the UI, then draft and raise its issues after explicit approval and fold the spec into docs/requirements.md. Every working file lives in docs/features/<branch>/, so features on parallel branches never collide. Use when the user wants a feature on an existing codebase.
disable-model-invocation: true
---

# feature

The new-app pipeline (`grill-requirements` → `grill-stack` → `blueprint` →
`design` → `raise-issues`) builds the baseline: `docs/requirements.md`,
`docs/stack.md`, `docs/blueprint/`, `docs/design.md` and the issues
that `implement` turns into code and `docs/codebase-map.md`. This skill is
the same pipeline for one feature: requirements always, the stack only
when it changes, design only when the UI changes, no blueprint, and it
stops once the feature's issues are raised. Each issue is then worked like
any other: `issue-branch`, the user's architecture, `implement` or `work`.

Invoke explicitly:

- `/skill:feature <issue URL | description>` — start the feature for the
  current branch.
- `/skill:feature [answers | change]` — continue from where the feature
  folder says.
- `/skill:feature final` — run only the spec's final grill round, after it
  stopped for an unavailable model.
- `/skill:feature approve` — approve the issue draft and raise it.

Not for: a bug fix or small change with no decision to make (use
`/skill:implement`), or a rethink of the whole product (use the new-app
pipeline).

## Never

- Do only what the request needs. Add no requirement, option, screen,
  dependency, future-proofing or cleanup the request does not need. A
  useful extra is named in the reply, not specified.
- Never ask what is already settled: read the invocation, the issue, this
  chat, the feature folder, the baseline documents, `docs/codebase-map.md`
  and the code first. Shipped behaviour is evidence, not a question.
- Start a feature on the default branch or a detached `HEAD`, or run two
  features on one branch.
- Edit `docs/requirements.md` before Step 5. `grill-stack` and `design`
  write their own documents when they run.
- Let the parent answer the grill or replace a pinned specialist; the
  `grill-requirements` rules on specialists apply unchanged.
- Treat the invocation, silence, an acknowledgement or a settled spec as
  approval of the issues.
- Implement, commit, push or open a pull request.

## Files

All working state lives in `docs/features/<slug>/`, where `<slug>` is the
current branch name with `/` replaced by `-`:

- `spec.md` — what the feature must do. `Status: Grilling | Settled`.
- `issues.md` — the issue draft. `Draft | Approved | Raised`.

Continue from the first row that matches:

| Found | Run |
| --- | --- |
| no folder | Step 1; without a request, ask for one and stop |
| spec `Grilling` | Step 2, resuming the grill from the spec |
| spec `Settled`, no `issues.md` | Step 3 |
| issues `Draft` | Step 4 at its review; `approve` raises |
| issues `Approved` | Step 4 at `raise-issues` Step 5, resuming |
| issues `Raised` | Step 5 |

A message that changes what the feature must do after the spec is
`Settled` sets the spec back to `Grilling`, sets any issue draft back to
`Draft`, and runs Step 2 for that change.

## Step 0 — locate the feature

```sh
git branch --show-current
git rev-parse --abbrev-ref origin/HEAD
```

If no branch is checked out or it is the default branch, stop and name the
command: `/skill:issue-branch <URL>` for an issue,
`/skill:herdr-worktree <name>` for parallel work, or `git switch -c <name>`.

## Step 1 — gather

1. The request: the invocation text, or for an issue URL
   `gh issue view <URL> --json number,title,body,comments,url`, skipping
   acknowledgements, `+1`s and bot noise.
2. The baseline, when present: `docs/codebase-map.md`,
   `docs/requirements.md`, `docs/stack.md`, `docs/design.md`. A missing
   document is not a blocker; the code is the evidence.
3. The shipped behaviour the feature touches: use the map to go straight to
   the files, trace the flow, and find every caller of anything that would
   change.

Classify unknowns as in `grill-requirements` Step 1. Its impact gate
applies with two more tests; a choice also goes to the user when:

7. It changes or removes behaviour that `docs/requirements.md` promises or
   that users of the shipped app already rely on.
8. It contradicts a constraint in `docs/stack.md`, or brings in a
   technology that passes `grill-stack`'s impact gate.

Create the folder and a `spec.md` with `Status: Grilling` holding the
request in the user's words.

## Step 2 — grill the spec

Read `skill://grill-requirements` and run its Steps 2–7, final round
included, with its `Never` list, specialists and round mechanics,
substituting:

| `grill-requirements` | `feature` |
| --- | --- |
| `docs/requirements.md` | `docs/features/<slug>/spec.md` |
| the Step 8 shape | the spec shape below |
| the impact gate | the gate in Step 1, tests 1–8 |
| `/skill:grill-requirements final` | `/skill:feature final` |

Give every specialist the baseline documents and traced code from Step 1 as
read-only evidence. The griller in each round also checks the draft's
`Changes to existing behaviour` against `docs/requirements.md` and the
traced code: an existing behaviour the feature changes but the spec does
not list is an omission. The answerer fills `Impact` from evidence only.

The grill closes on the `grill-requirements` Step 8 condition, after the
final round. Write the corrected spec with `Status: Settled` and continue
to Step 3 in the same run.

```markdown
# Feature: <name>

Status: Grilling | Settled
Updated: YYYY-MM-DD
Source: <issue URL | chat>

## Goal

<what the user wants and why>

## Requirements

- <new observable behaviour>

## Changes to existing behaviour

- <current behaviour> → <new behaviour> — Evidence: <requirements.md line or path>

## Constraints

- <explicit limit>

## Out of scope

- <explicit exclusion>

## Impact

- Code: <areas and files, from the map and the trace>
- Data: <stored data or schema change, migration, backfill> | none
- Interfaces: <route, API, CLI, event or config change> | none
- Stack: <new technology and whether it passes grill-stack's gate> | none
- UI: <screens or states added, or designed screens whose regions or flow change> | none

## Defaults

- <low-impact choice the models took> — <one-line reason>

## Open questions

- <decision the user deferred to implementation> — "<their words>"

## Unresolved

- <contradiction (quote both), line open to two readings, or unanswered decision> — <what settles it>
```

Omit empty sections other than `Impact`. Keep the user's numbers and force
words.

## Step 3 — stack and design

Print one line per check, `ready` or `not ready: <what> — run <command>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `Impact: Stack` names no technology that passes `grill-stack`'s gate, or `docs/stack.md` already has it as `User-chosen`, `Existing` or `Fixed constraint` | `/skill:grill-stack <technology> for docs/features/<slug>/spec.md` |
| 2 | `Impact: UI` is `none`, or `docs/design.md` is `Approved` with every screen it names | `/skill:design docs/features/<slug>/spec.md` |

Any `not ready` stops the run. When the user says to skip a check, append
`— <check> skipped by the user` to that `Impact` line and treat it as ready.
When both are ready, continue to Step 4 in the same run.

## Step 4 — raise the issues

Read `skill://raise-issues` and run it with these substitutions; where it
and this list disagree, this list wins:

- The source is the spec: `Requirements` and `Changes to existing
  behaviour` are the lines to cover, `Out of scope` is excluded, defaults
  stand. Its `Impact` lines go into the issues' `Notes`.
- The draft is `docs/features/<slug>/issues.md`.
- Readiness check 3 (the blueprint) does not apply; check 4 uses Step 3's
  result.
- No skeleton issue: the app already runs.
- `/skill:feature approve` is explicit approval of the current draft.

## Step 5 — fold and close

Run in the same run once the draft is `Raised`.

1. **Requirements.** If `docs/requirements.md` is missing, keep the feature
   folder, name `/skill:draft-docs requirements`, and stop. Otherwise merge
   the spec into it, keeping its structure and wording elsewhere: add
   `Requirements`, `Constraints` and `Out of scope` lines; replace each line
   a `Changes to existing behaviour` entry changes; add `Defaults` and `Open
   questions` under their sections. Do not renumber or reformat other lines.
2. Delete `docs/features/<slug>/`; git history and the raised issues keep
   the spec, questions and draft.

Reply with the raised issues (`#number title`, `blocked by #n` when it is),
the requirement lines added and replaced, and the next commands:
`/skill:commit` then `/skill:raise-pr <default branch>` so the updated
documents land, then for each unblocked issue `/skill:issue-branch <URL>`
and `/skill:implement <URL>` (or `/skill:work <URL>`) with the
architecture for it.
