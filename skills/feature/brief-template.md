# Feature brief: <feature name>

<!-- File: .factory/feature/<slug>.md. Not committed. Gate 1 (`brief`) stamps
     everything above "## Tasks". The planner fills "## Tasks"; the main
     session keeps "## Status" current. Task format: addyosmani
     `planning-and-task-breakdown` (acceptance criteria + verification). -->

## Outcome

<One or two sentences: what a user can do after this ships that they cannot
do now. Source: chat text, or issue #N (read only).>

## Acceptance criteria

<!-- Numbered, each Given / When / Then, each checkable. -->

- **AC1** Given <state>, when <action>, then <observable result>.
- **AC2** Given …, when …, then ….

## Out of scope

- <Thing a reader might assume is included, and is not.>

## Repo checks

<!-- Found by the scout. Exact commands. These are the checks (no CONSTRAINTS.md). -->

| Check | Command |
| --- | --- |
| Lint | `<cmd>` |
| Types | `<cmd>` |
| Tests | `<cmd>` |
| E2E / `verify-<app>` | `<cmd or skill name, or "none">` |

## Solution sketch

One design.

**Reuses:** <existing modules, files, patterns, components, each with `path`.
At least one; a sketch that names none is rejected.>

**New pieces:** <every new file, dependency, table, abstraction, config
option. Write "none" only if true.>

| New piece | Why it must exist | Simpler option considered | Answer |
| --- | --- | --- | --- |
| `<path or name>` | <which AC needs it> | <the recommended simpler option> | <kept / dropped, and why> |

**Size estimate:** <N commits, at most 10.>

## Tasks

<!-- Filled by factory-planner after Gate 1: 1 to 10 tasks, sized XS/S/M/L.
     XL = stop and split. -->

| ID | Size | Covers | Task | Verification | Status |
| --- | --- | --- | --- | --- | --- |
| T1 | S | AC1 | <what to change, files> | <test or command that proves it> | todo |

Status values: `todo`, `doing`, `done <short sha>`, `blocked <why>`.

## Status

- Step: <1 scout, 2 interview, 3 sketch, 4 Gate 1, 5 plan, 6 build, 7 review, 8 QA, 9 PR>
- Branch: `feature/<slug>` (base: `<default branch>`)
- Mode: <unattended | step-by-step>
- Review round: <0-3>
- Last verdicts: <reviewer: …; factory-spec-review: …; factory-qa: …>
- PR: <url, or "not raised">
