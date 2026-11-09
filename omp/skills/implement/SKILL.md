---
name: implement
description: Turn a GitHub issue, a requested change or a supplied plan into a short developer-facing plan in docs/implementation-plan.md that follows the architecture the user gives for it (or the structure the code already has), wait for explicit approval, then implement the smallest complete change (YAGNI, reuse first) — building a designed screen from Paper and docs/design.md when the issue has one — update the existing documents it makes stale, and keep docs/codebase-map.md current as the AI-readable map every later session reads first.
disable-model-invocation: true
---

# implement

Invoke explicitly as `/skill:implement [issue URL | request | plan]`.

The user gives a GitHub issue (usually one `/skill:raise-issues` raised) with the architecture they want for it, supplies a plan, or describes what to build. Read the codebase map first, produce a short plan a developer can read in a minute, stop for approval, then implement only that plan. While implementing, keep the codebase map that every OMP session reads before it works in the repository.

Two documents:

- `docs/implementation-plan.md` — the current plan and its status. Replaced per request.
- `docs/codebase-map.md` — persistent map of files, what each does, and how they connect. Updated, never replaced.

## Never

- Do only what the request needs. Add no feature, option, layer, abstraction, wrapper, config, dependency, future-proofing or cleanup nobody asked for. A useful extra is named under `Not doing`, not built.
- Never ask what is already settled: read the issue, the request, the supplied plan, chat answers, `docs/codebase-map.md`, `docs/requirements.md`, `docs/stack.md`, `docs/blueprint.html`, `docs/design.md` and the repository first.
- Redesign a plan the user supplied or reinterpret an issue. Keep their decisions; condense them, fill in only repository facts, and raise a conflict with the code as an open decision.
- Choose the architecture yourself. Which component owns the change, any new module or layer, data ownership, dependency direction and trust boundaries come from the architecture the user gave for this change (invocation, issue, chat) or, where they gave none, the structure the code already follows. A change that needs structure neither settles is an open decision with a recommendation; a technology `docs/stack.md` lacks is an open decision naming `/skill:grill-stack`. Never work around either in code.
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
- A change that adds or changes UI also follows `skill://ui-craft` and the parts it lists, and `UI from the design` below when it builds a screen from `docs/design.md`.

## UI from the design

When the issue or request names a screen (`S<n>`), a Paper board or the current Paper selection:

1. **Source of truth.** Build from `docs/design.md` when it is `Approved`; if it is not, say so and stop unless the user says to build anyway, then record that under `Risks`. In Paper, confirm the file from the `Paper:` line with `get_basic_info`, call `get_guide` once, then `get_jsx` for structure (Tailwind format when the repository uses Tailwind), `get_computed_styles` for exact values and `get_fill_image` or `export` for images and icons. Never read a value off a screenshot when Paper has it, and never edit the design.
2. **Tokens.** Map each design token to the repository's equivalent (Tailwind `@theme`, CSS variables, MUI theme, RN theme file); reuse matches and add missing ones to that one source. A design value that conflicts with an existing token is an open decision. No raw color, size, spacing, radius, duration or easing in a component.
3. **Components.** Name the existing component, library primitive (the component library in `docs/stack.md`) or new component for each element; a new one only where none exists.
4. **States and worst case.** Build every state the design shows, and each dynamic field's wrap, truncate or clamp rule (`stress.md`). A state the data can produce but the design omits is an open decision with a recommendation.
5. **Motion.** Take each recipe from `docs/design.md` with its reduced-motion fallback, using the cheapest tool for the platform (`platforms.md`).

The plan adds `## Design mapping` after `Reuse`: one row per design element with its component or file, tokens and states. `Verification` adds the screens and states to open, the widths or devices to check, dark mode, reduced motion, largest text, a keyboard-only pass and a side-by-side comparison with the Paper board; `/skill:review-ui` makes that comparison afterwards.

## States

`docs/implementation-plan.md` carries one status:

1. `Awaiting approval` — planning and plan revisions only.
2. `Approved` — the user explicitly approved the current plan; implement immediately.
3. `Implemented` — every step is done and verified, or a concrete verification limit is recorded.

“Approve”, “approved”, “accept”, “go ahead with the plan” or an equally explicit statement approves the current plan when it requests no material change. A message that changes scope, behavior, files or checks revises the plan and returns it to `Awaiting approval`.

If no current plan exists, or the invocation asks for something materially different, write a new plan and stop.

## Step 1 — understand the request

1. Read `docs/codebase-map.md` first when it exists and use it to go straight to the relevant files. Treat it as a guide; the code wins when they disagree, and the disagreement is fixed in Step 5.
2. For an issue URL, read it with `gh issue view <URL> --json number,title,body,comments,url`. Its acceptance checklist is the scope, its `Source` lines are the requirements it builds, and its notes (blueprint chunk, stack choices, design screens) are settled. Skip acknowledgements, `+1`s and bot noise in the comments. If it is closed, or blocked by an open issue (`gh issue view <URL> --json blockedBy`), say so and stop.
3. Take the architecture for this change from the user's words (invocation, issue, chat), then read `docs/stack.md` and the code of the components the change touches. Note which component owns each part of the change, the layer it belongs in, and the existing pattern for that kind of change (how a route, screen, query or job is added today). Where the user gave no architecture and the change needs a structural choice the code does not settle, that choice is a user decision for this step.
4. Read only what else correct planning needs: the supplied plan, the settled documents listed under `Never`, repository instructions, manifests, affected source, tests and docs, and every caller of an exported symbol that would change. Use external documentation only when the repository cannot settle an API or constraint.
5. Run the current behavior when practical for a bug or an observable change. Record observed facts.
6. Search for existing code the change can reuse, and note it for the plan.

Classify each uncertainty as a **repository fact** (settle it yourself), **already decided** (keep the user's decision) or a **user decision** (a material trade-off the evidence does not settle). Ask all open user decisions together, each with a smallest-sufficient recommendation and its main trade-off. Do not mark a plan approvable while a decision is open.

Make no implementation changes in this step.

## Step 2 — write the plan

Write `docs/implementation-plan.md`, replacing content from an unrelated earlier request. Keep it short: a developer should understand what will change, where, and how it will be proved without reading code. No pasted code beyond a signature or one-line example where wording would be ambiguous.

```markdown
# Implementation plan: <short name>

Status: Awaiting approval
Updated: YYYY-MM-DD
Source: <issue URL | chat | supplied plan>

## Summary

<two or three sentences: what changes, why, and the approach>

## Architecture

- <owner component or module, new modules or layers, data ownership, boundaries> — Source: <the user's direction | existing pattern at `path`>

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

`Summary`, `Architecture`, `Steps`, `Files` and `Verification` are required; omit other empty sections. The plan must bound one implementation: named files (or explicitly bounded discovery), behavior changes, and proof of completion. Each step names the component it changes and follows the architecture section. For an issue, every acceptance item has a `Verification` line.

Reply with the plan path, the one-sentence scope, the step count and any open decisions, and ask the user to approve or request changes. Do not repeat the plan in chat. Stop.

## Step 3 — handle the review

- Change requested: inspect new evidence, revise the plan, keep `Status: Awaiting approval`, update the date, stop again.
- Explicit approval: re-read the plan and the affected code. If a material fact changed since planning, update the plan, explain the change and ask again. Otherwise set `Status: Approved` and continue in the same run without asking for further confirmation.

Line movement or implementation detail that keeps the approved behavior, scope, risks and file responsibilities needs no reapproval.

## Step 4 — implement

Follow the steps in order, applying the YAGNI rules above, the plan's architecture and the repository's conventions. Update every affected caller, test, configuration and user-facing document the change breaks or obsoletes.

Update every existing document the change makes inaccurate — README, guides, API or CLI docs, changelog, `.env.example`, inline usage docs — in the same change, keeping each document's structure and wording elsewhere. Create no new document other than the codebase map. The planning documents (`docs/requirements.md`, `docs/stack.md`, `docs/blueprint.html`, `docs/design.md`, `docs/issues.md`) belong to their own skills: a change that would make one of them wrong is a material deviation, not an edit.

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
