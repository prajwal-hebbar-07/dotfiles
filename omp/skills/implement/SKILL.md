---
name: implement
description: Turn a requested change or a supplied plan into a short developer-facing plan in docs/implementation-plan.md, wait for explicit approval, then implement the smallest complete change (YAGNI, reuse first) and keep docs/codebase-map.md current so later OMP sessions can find files and connections fast.
disable-model-invocation: true
---

# implement

Invoke explicitly as `/skill:implement [request or plan]`.

The user either supplies a plan or describes what to build. Produce a short plan a developer can read in a minute, stop for approval, then implement only that plan. While implementing, keep a codebase map that every OMP session reads before it works in the repository.

Two documents:

- `docs/implementation-plan.md` — the current plan and its status. Replaced per request.
- `docs/codebase-map.md` — persistent map of files, what each does, and how they connect. Updated, never replaced.

## Never

- Do only what the request needs. Add no feature, option, layer, abstraction, wrapper, config, dependency, future-proofing or cleanup nobody asked for. A useful extra is named under `Not doing`, not built.
- Never ask what is already settled: read the request, the supplied plan, chat answers, `docs/codebase-map.md`, `docs/requirements.md`, `docs/stack.md`, `docs/architecture-review.md` and the repository first.
- Redesign a plan the user supplied. Keep their decisions; condense it, fill in only repository facts, and raise a conflict with the code as an open decision.
- Treat the invocation, silence, a general acknowledgement or approval of an older plan as approval.
- Change anything except `docs/implementation-plan.md` before approval.
- Expand the approved scope while implementing. A material deviation goes back to the plan for new approval.
- Write new code where the codebase, standard library, platform or an installed dependency already does the job.
- Leave stubs, placeholders, fake fallbacks, disabled checks, dead code or unfinished plan items.
- Use Claude Artifacts, HTML previews or external review tools. The review surface is the Markdown plan.
- Commit unless the user separately asks.

## Smallest complete change (YAGNI)

Before Step 1, read `skill://ponytail` and apply it at the level the user set, default `full`, when planning and when writing code. If it is not installed, stop and tell the user to run `npx skills add DietrichGebert/ponytail -g --skill ponytail`; do not substitute your own version of its rules.

This workflow adds to ponytail:

- Before writing code, check the codebase map's `Reuse first` section, then search the repository.
- Extras that ponytail drops go under `Not doing` in the plan; the code that will be reused goes under `Reuse`.
- Duplicated logic in the touched path is fixed once in shared code when the change needs it; unrelated duplication is named, not refactored.
- Code made obsolete by the change is removed in the same change; no compatibility shims unless the plan requires them.

## States

`docs/implementation-plan.md` carries one status:

1. `Awaiting approval` — planning and plan revisions only.
2. `Approved` — the user explicitly approved the current plan; implement immediately.
3. `Implemented` — every step is done and verified, or a concrete verification limit is recorded.

“Approve”, “approved”, “accept”, “go ahead with the plan” or an equally explicit statement approves the current plan when it requests no material change. A message that changes scope, behavior, files or checks revises the plan and returns it to `Awaiting approval`.

If no current plan exists, or the invocation asks for something materially different, write a new plan and stop.

## Step 1 — understand the request

1. Read `docs/codebase-map.md` if it exists and use it to go straight to the relevant files. Treat it as a guide; the code wins when they disagree, and the disagreement is fixed in Step 5.
2. Read only what correct planning needs: the supplied plan, the settled documents listed under `Never`, repository instructions, manifests, affected source, tests and docs, and every caller of an exported symbol that would change. Use external documentation only when the repository cannot settle an API or constraint.
3. Run the current behavior when practical for a bug or an observable change. Record observed facts.
4. Search for existing code the change can reuse, and note it for the plan.

Classify each uncertainty as a **repository fact** (settle it yourself), **already decided** (keep the user's decision) or a **user decision** (a material trade-off the evidence does not settle). Ask all open user decisions together, each with a smallest-sufficient recommendation and its main trade-off. Do not mark a plan approvable while a decision is open.

Make no implementation changes in this step.

## Step 2 — write the plan

Write `docs/implementation-plan.md`, replacing content from an unrelated earlier request. Keep it short: a developer should understand what will change, where, and how it will be proved without reading code. No pasted code beyond a signature or one-line example where wording would be ambiguous.

```markdown
# Implementation plan: <short name>

Status: Awaiting approval
Updated: YYYY-MM-DD

## Summary

<two or three sentences: what changes, why, and the approach>

## Scope

- In: <requested outcomes>
- Out: <explicit exclusions>

## Current behavior

- <observed fact — evidence: path, symbol, command or output>

## Steps

1. <ordered change: file or component and its exact responsibility>

## Files

- `path` — <new | changed | removed>: <what changes>

## Reuse

- `path:symbol` — <existing code used instead of writing new code>

## Not doing

- <extra left out on purpose, one line each>

## Edge cases

- <behavior, invariant, error case, compatibility or migration consequence>

## Verification

- `<command or scenario>` — <what it proves>

## Risks

- <concrete risk, assumption or unavailable proof>

## Open decisions

- <unresolved user decision with recommendation>
```

`Summary`, `Steps`, `Files` and `Verification` are required; omit other empty sections. The plan must bound one implementation: named files (or explicitly bounded discovery), behavior changes, and proof of completion.

Reply with the plan path, the one-sentence scope, the step count and any open decisions, and ask the user to approve or request changes. Do not repeat the plan in chat. Stop.

## Step 3 — handle the review

- Change requested: inspect new evidence, revise the plan, keep `Status: Awaiting approval`, update the date, stop again.
- Explicit approval: re-read the plan and the affected code. If a material fact changed since planning, update the plan, explain the change and ask again. Otherwise set `Status: Approved` and continue in the same run without asking for further confirmation.

Line movement or implementation detail that keeps the approved behavior, scope, risks and file responsibilities needs no reapproval.

## Step 4 — implement

Follow the steps in order, applying the YAGNI rules above and the repository's conventions. Update every affected caller, test, configuration and user-facing document the change breaks or obsoletes.

Update `docs/codebase-map.md` as you go (Step 5 format): whenever a step adds, removes, renames or moves a file, changes what a file is responsible for, changes which files depend on each other, or adds a reusable helper.

If implementation reveals a new material decision or requires a material deviation, finish the independently safe work, record the finding in the plan, set it back to `Awaiting approval`, and stop before the unapproved change.

## Step 5 — maintain the codebase map

`docs/codebase-map.md` is the navigation entry point for every later OMP session: implementing, changing or fixing bugs. It records where things are and how they connect, not how the code works line by line.

Create it on the first approved implementation in a repository. Map the entry points, the touched files and their direct neighbors at file level, and the rest of the repository at directory level. Deepen other areas when later work touches them. Keep entries to one line; describe only what reading the file list would not show.

```markdown
# Codebase map

Updated: YYYY-MM-DD
Read this before working in the repository. Keep it current when files or their connections change.

## Layout

- `dir/` — <responsibility>

## Entry points

- `path` — <how it starts: command, route, export, job>

## Files

- `path` — <what it does>. Uses: `path`, `path`. Used by: `path`.

## Flows

- <action>: `a` → `b` → `c`

## Reuse first

- `path:symbol` — <shared helper, component or pattern to reuse instead of rewriting>

## Conventions

- <repository-wide rule a change must follow: naming, error handling, tests>
```

Omit empty sections. Large repositories may split `Files` into `docs/codebase-map/<area>.md`, linked from the root map; keep the root map as the single entry point.

Make the map load automatically: OMP reads root `AGENTS.md` (and other context files such as `CLAUDE.md`) at the start of every session. Ensure the repository's existing root context file — or a new `AGENTS.md` when none exists — contains exactly one short pointer, adding it once:

```markdown
## Codebase map

Before working in this repository, read `docs/codebase-map.md` to locate files and their connections. After changing files, responsibilities, dependencies or shared helpers, update it in the same change.
```

Before closing, check that every path in the map exists and that the entries for touched files match the code.

## Step 6 — verify and close

Run the checks named in the plan and a smoke scenario that exercises the changed behavior. For a bug, reproduce it before the fix when practical and observe it fixed afterward. Never claim checks that were not run.

Then in the plan:

- set `Status: Implemented` and add `Completed: YYYY-MM-DD`;
- replace the expected verification with the commands or scenarios actually run and their outcomes;
- keep any real verification limit under `Risks`.

Fix failures caused by the change before closing. If an external prerequisite blocks completion, keep `Status: Approved`, record the blocker and finished work, and report it without claiming completion.

Reply with the plan path, the changed behavior, affected files, verification run, map updates, and anything skipped or left at risk. Do not repeat the plan in chat.
