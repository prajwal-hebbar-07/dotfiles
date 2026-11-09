---
name: feature
description: Add one feature to an application that already exists. Specify it against the shipped app in rounds through the requirements grill (only high-impact decisions reach the user, in a per-feature questions file), check whether it needs a stack grill or a design first, plan and implement it through the implement skill after explicit approval, then fold the settled spec back into docs/requirements.md and the other baseline documents. Every working file lives in docs/features/<branch>/, so features on parallel branches never collide. Use when the user wants to build a feature on an existing codebase.
disable-model-invocation: true
---

# feature

The greenfield pipeline (`draft-docs` → `grill-requirements` → `grill-stack`
→ `grill-architecture` → `design` → `implement`/`build-ui`) builds the
baseline: `docs/requirements.md`, `docs/stack.md`, `docs/architecture.md`,
`docs/architecture-review.md`, `docs/design.md` and `docs/codebase-map.md`.
This skill is the loop for every feature after that. It reuses the same
grill, impact gate and implement flow, but scopes them to one feature and
treats the baseline and the shipped code as settled evidence.

Invoke explicitly:

- `/skill:feature <issue URL | description>` — start the feature for the
  current branch.
- `/skill:feature [answers | change]` — continue from where the feature
  folder says.
- `/skill:feature approve` — approve the current plan.
- `/skill:feature close` — after the user has tested it, fold the spec into
  the baseline documents and remove the feature folder.

Not for: a bug fix or small change with no decision to make (use
`/skill:implement`), or a rethink of the whole product (use the greenfield
pipeline).

## Never

- Do only what the request needs. Add no requirement, option, screen,
  layer, abstraction, dependency, future-proofing or cleanup the request
  does not need. A useful extra is named under `Not doing` in the plan, not
  specified or built.
- Never ask what is already settled: read the invocation, the issue, this
  chat, the feature folder, the baseline documents, `docs/codebase-map.md`
  and the code first. Shipped behaviour is evidence, not a question.
- Start a feature on the default branch or a detached `HEAD`, or run two
  features on one branch.
- Edit a baseline document before Step 5, except `docs/codebase-map.md`,
  which `implement` keeps current, and what `grill-stack` or `design` write
  when the user runs them.
- Let the parent answer the grill or replace a pinned specialist; the
  `grill-requirements` rules on specialists apply unchanged.
- Treat the invocation, silence, an acknowledgement or a settled spec as
  approval of the plan.
- Close a feature whose plan is not `Implemented`, or delete the feature
  folder before its content is in the baseline.
- Commit, push or open a pull request.

## Files

All working state lives in `docs/features/<slug>/`, where `<slug>` is the
current branch name with `/` replaced by `-`:

- `spec.md` — what the feature must do. `Status: Grilling | Settled`.
- `questions.md` — the current grill round's questions for the user.
- `plan.md` — the implement plan. `Awaiting approval | Approved | Implemented`.

Continue from the first row that matches:

| Found | Run |
| --- | --- |
| no folder | Step 1; without a request, ask for one and stop |
| spec `Grilling` | Step 2, from `grill-requirements` Step 6 once the user says the questions are answered |
| spec `Settled`, no plan | Step 3 |
| plan `Awaiting approval` or `Approved` | Step 4, at `implement` Step 3 or where implementation stopped |
| plan `Implemented` | name what to test and `/skill:feature close`, unless the invocation is `close` (Step 5) |

A message that changes what the feature must do after the spec is
`Settled` sets the spec back to `Grilling`, sets any plan back to
`Awaiting approval`, and runs Step 2 for that change.

## Step 0 — locate the feature

```sh
git branch --show-current
git rev-parse --abbrev-ref origin/HEAD
```

If no branch is checked out or it is the default branch, stop and name the
command: `/skill:issue-branch <URL>` for an issue, `/skill:herdr-worktree
<name>` for parallel work, or `git switch -c <name>`.

## Step 1 — gather

1. The request: the invocation text, or for an issue URL
   `gh issue view <URL> --json number,title,body,comments,url`, skipping
   acknowledgements, `+1`s and bot noise.
2. The baseline, when present: `docs/codebase-map.md`, `docs/requirements.md`,
   `docs/stack.md`, `docs/architecture.md`, `docs/architecture-review.md`,
   `docs/design.md`. A missing document is not a blocker; the code is the
   evidence.
3. The shipped behaviour the feature touches: use the map to go straight to
   the files, trace the flow, and find every caller of anything that would
   change.

Classify unknowns as in `grill-requirements` Step 1. Its impact gate
applies with two more tests; a choice also goes to the user when:

7. It changes or removes behaviour that `docs/requirements.md` promises or
   that users of the shipped app already rely on.
8. It contradicts a constraint or finding in `docs/architecture-review.md`,
   or brings in a technology that passes `grill-stack`'s impact gate.

Create the folder and a `spec.md` with `Status: Grilling` holding the
request in the user's words.

## Step 2 — grill the spec

Read `skill://grill-requirements` and run its Steps 2–6, with its `Never`
list, specialists and round mechanics, substituting:

| `grill-requirements` | `feature` |
| --- | --- |
| `docs/requirements.md` | `docs/features/<slug>/spec.md` |
| `docs/requirements-questions.md` | `docs/features/<slug>/questions.md` |
| the Step 7 shape | the spec shape below |
| the impact gate | the gate in Step 1, tests 1–8 |

Give both specialists the baseline documents and traced code from Step 1 as
read-only evidence. Haiku also checks the draft's `Changes to existing
behaviour` against `docs/requirements.md` and the traced code: an existing
behaviour the feature changes but the spec does not list is an omission.
Sonnet fills `Impact` from evidence only.

The grill closes on the `grill-requirements` Step 7 condition. Write the
corrected spec with `Status: Settled` and continue to Step 3 in the same
run.

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
- UI: <screens or states added or changed> | none
- Architecture: <new component, data ownership, trust boundary or external service> | none

## Defaults

- <low-impact choice the models took> — <one-line reason>

## Open questions

- <only a decision the user explicitly deferred>
```

Omit empty sections other than `Impact`. Keep the user's numbers and force
words.

## Step 3 — readiness

Print one line per check, `ready` or `not ready: <what> — run <command>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `Impact: Stack` names no technology that passes `grill-stack`'s gate, or `docs/stack.md` already has it as `User-chosen`, `Existing` or `Fixed constraint` | `/skill:grill-stack <technology> for docs/features/<slug>/spec.md` |
| 2 | `docs/design.md` does not exist, `Impact: UI` adds no screen and changes no designed screen's layout, or `docs/design.md` is `Approved` with those screens | `/skill:design docs/features/<slug>/spec.md` |

Any `not ready` stops the run. When the user says to skip a check, append
`— <check> skipped by the user` to that `Impact` line and treat it as ready.

## Step 4 — plan and implement

Read `skill://implement` and run it in full; when the feature builds a
screen from `docs/design.md`, read `skill://build-ui` and run that instead.
Where they and this list disagree, this list wins:

- The plan is `docs/features/<slug>/plan.md`, not
  `docs/implementation-plan.md`.
- The spec is the settled request. `Scope: In` is `Requirements` plus
  `Changes to existing behaviour`; `Scope: Out` is `Out of scope`; defaults
  stand. A conflict between the spec and the code is an `Open decision`, not
  a reason to reopen the spec.
- Start from `Impact: Code` and `docs/codebase-map.md`.
- `Verification` names, for every line under `Requirements` and `Changes to
  existing behaviour`, the command or scenario that proves it.
- `/skill:feature approve` is explicit approval of the current plan.

When the plan reaches `Implemented`, reply with the plan path and the
verification lines for the user to run, then `/skill:feature close` once
they pass.

## Step 5 — close

Run only on `/skill:feature close` with the plan `Implemented`.

1. **Requirements.** If `docs/requirements.md` is missing, keep the feature
   folder, name `/skill:draft-docs requirements`, and stop. Otherwise merge
   the spec into it, keeping its structure and wording elsewhere: add
   `Requirements`, `Constraints` and `Out of scope` lines; replace each line
   a `Changes to existing behaviour` entry changes; add `Defaults` and `Open
   questions` under their sections. Do not renumber or reformat other lines.
2. **Stack.** If `docs/stack.md` exists, add each technology the branch
   added to a manifest (`git diff <default>...HEAD` on manifests) that it
   lacks, as a `draft-docs` stack entry with only `Origin` and `Serves`.
3. **Architecture.** If `Impact: Architecture` is not `none` and
   `docs/architecture.md` exists, update its components and flows from the
   implemented code in the `draft-docs` shape.
4. Delete `docs/features/<slug>/`; git history keeps the spec, questions and
   plan.

Reply with the documents updated (lines added and replaced), then the next
commands: `/skill:grill-stack` when item 2 added an entry,
`/skill:grill-architecture` when item 3 changed the architecture, and
`/skill:commit` then `/skill:raise-pr <default branch>`. When
`docs/design.md` exists, say that `/skill:design` will report the
architecture review stale until `/skill:grill-architecture` runs again,
because item 1 changed `docs/requirements.md`.
