---
name: work
description: Create a developer-facing, evidence-backed implementation plan in docs/implementation-plan.md, wait for explicit user approval, then implement and verify only the approved changes as the smallest complete change that reuses existing code. Use when the user wants to review a plan before code changes.
disable-model-invocation: true
---

# work

Turn an implementation request into a reviewable Markdown plan written for the developer: what will change, how it works, and which existing code it reuses. Do not change the product, source, tests, configuration, dependencies, or user documentation until the user explicitly approves that plan. After approval, implement the approved plan as the smallest complete change, verify the changed behavior, and record the result in the same document.

Invoke explicitly as `/skill:work [request]`.

## Never

- Add a feature, option, layer, abstraction, dependency, future-proofing, cleanup, or requirement the user did not request. Name a useful extra as optional; do not put it in the plan or implementation.
- Ask what the request, earlier answers, requirements, stack report, architecture documents, repository, authoritative sources, or current plan already settle.
- Generate a Claude Artifact prompt, use Claude Artifacts, create an HTML preview, or send the plan to an external artifact tool. The review surface is `docs/implementation-plan.md` only.
- Treat the initial implementation request, silence, a general acknowledgement, or approval of a different plan as approval. Approval must explicitly accept the current plan.
- Make implementation changes while the plan is awaiting approval or has unresolved decisions.
- Expand the approved scope while implementing. A necessary material deviation requires a plan update and new approval.
- Leave stubs, placeholders, fake fallbacks, disabled checks, or unfinished plan items.
- Commit unless the user separately requests a commit.
- Write code that duplicates an existing helper, component, service, pattern, or dependency. Reuse or extend the shared code instead.
- Add a wrapper, option, configuration, type conversion, boilerplate, or "for later" code nobody asked for.

## Code style — smallest complete change

Adapted from [ponytail](https://github.com/DietrichGebert/ponytail) (MIT) so this skill works whether or not ponytail is installed or active.

Apply this to both the plan and the implementation. For each needed piece, take the first option that fully works:

1. **Does it need to exist?** Drop anything the request does not need; name it once under `Not included`.
2. **Already in this repository?** Reuse the existing helper, component, service, or pattern the way surrounding code uses it.
3. **Standard library or platform feature?** Use it, unless the repository has its own equivalent.
4. **Installed dependency?** Use it. Never add a dependency for a few lines.
5. **Otherwise** write the minimum new code, following the repository's existing structure, layers, and conventions.

- Deletion beats addition; the shortest diff that reaches every affected caller, test, fixture, config, and export wins. A dense one-liner that needs decoding is not short.
- Fix bugs once at the root in shared code after finding every caller, not per call site.
- Moved or merged code keeps its error handling and validation.
- Between options of equal size, take the one correct on edge cases.
- Comment only the why the code cannot show. A shortcut with a known limit gets `shortcut: <limit>, <when to upgrade>`.
- New non-trivial logic (a branch, loop, parser, money or security path, or a new script) gets one small test or assert-based self-check; trivial changes need none.
- Never cut validation at trust boundaries, error handling that prevents data loss, security, accessibility, or anything the user asked for.
- A change that adds or changes UI also follows `skill://ui-craft` and the parts it lists.

## Approval contract

Use `docs/implementation-plan.md` as the single current plan.

The workflow has three states:

1. `Awaiting approval` — planning and plan revisions only.
2. `Approved` — the user explicitly approved the current plan; implementation may begin immediately.
3. `Implemented` — every approved change is complete and verified, or the document names a concrete verification limit.

A message that changes scope, behavior, files, constraints, or checks revises the plan and returns it to `Awaiting approval`; it is not approval. A message such as “approve,” “approved,” “accept the plan,” or an equally explicit statement approves the current plan when it does not also request material changes.

If no current plan exists, or the invocation requests a materially different implementation, always create or replace the plan first and stop for review. Never infer approval from `/skill:work` itself.

## Step 1 — establish the requested behavior

Read the invocation and settled chat context. Then read only the repository evidence needed to plan correctly, including when relevant:

- `docs/requirements.md`, `docs/stack.md`, `docs/architecture-review.md`, and the current implementation plan;
- repository instructions, manifests, lockfiles, configuration, and deployment files;
- affected source, tests, documentation, and every call site of an exported symbol that would change;
- authoritative external documentation only when repository evidence cannot establish a required API or constraint.

Before proposing new code, search the repository for existing helpers, components, services, patterns, and installed dependencies that already do the job or can be extended, and record what you found. Run the current behavior when practical if the request fixes or changes an observable path. Record observed facts, not assumptions. Do not edit implementation files during this step.

Classify uncertainty:

- **Repository fact** — inspect and settle it without asking the user.
- **Already decided** — preserve the user's exact decision.
- **User decision** — a material behavior or trade-off the available evidence does not settle.

Ask the whole current frontier of user decisions together. Give a smallest-sufficient recommendation and its main trade-off for each. Do not write an approvable plan while a material decision is unanswered; record unanswered decisions under `Open decisions` and keep the status `Awaiting approval`.

## Step 2 — write the review document

Create or update `docs/implementation-plan.md`. Preserve no stale content from an unrelated prior request. Use this shape:

```markdown
# Implementation plan: <short request name>

Status: Awaiting approval
Updated: YYYY-MM-DD

## Summary

<3–6 sentences for the developer: what will change, how it works end to end, and the key design choice>

## Request

<concise statement of the requested outcome and explicit exclusions>

## Current behavior

- <relevant observed behavior — evidence: path, symbol, command, or output>

## Proposed implementation

1. <ordered change, naming the file or component and exact responsibility>

## Reuse

- `path:symbol` — <existing code, platform feature, or installed dependency reused, and for what>
- New code: <each piece of new code and why nothing existing covers it>

## Files affected

- `path` — <specific change>

## Behavior and edge cases

- <observable behavior, invariant, error case, compatibility constraint, or migration consequence>

## Verification

- `<specific command or scenario>` — <what it must prove>

## Risks and limits

- <only concrete risks, assumptions, or unavailable runtime proof>

## Not included

- <useful extra deliberately left out, one line each>

## Open decisions

- <only unresolved user decisions>
```

Omit empty sections except `Summary`, `Request`, `Proposed implementation`, `Reuse`, `Files affected`, and `Verification`. If nothing is reusable, say what was searched under `Reuse`. The plan must be specific enough that approval authorizes one bounded implementation: name affected files or explicitly bounded discovery work, behavior changes, migration or compatibility effects, and proof of completion. Do not paste speculative code or restate entire source files.

Writing or revising this Markdown document is the only mutation allowed before approval. Reply with the path, a one-sentence scope, the number of implementation steps and open decisions, and ask the user to approve or request changes. Do not repeat the document in chat. Stop without implementing.

## Step 3 — process the review response

When the user requests changes, inspect any new evidence, update the plan, set `Status: Awaiting approval`, update the date, and stop for another review.

When the user explicitly approves the current plan:

1. Re-read the complete plan and the affected repository sections.
2. Confirm that the files and assumptions have not materially changed since planning.
3. If a material change invalidates scope, behavior, risk, or verification, update the plan, return it to `Awaiting approval`, explain the changed fact, and request new approval.
4. Otherwise set `Status: Approved` and implement immediately in the same run. Do not ask for another confirmation.

Minor line movement or implementation detail that preserves the approved behavior, scope, risks, and file responsibilities does not require reapproval.

## Step 4 — implement the approved plan

Follow the plan in order and the code style above while adapting to repository conventions. Update every affected caller, test, configuration file, and user-facing document required by the approved cutover. Remove code made obsolete by the approved change; do not retain compatibility shims unless the plan explicitly requires them. Reusing existing code found during implementation, where it preserves the approved behavior and makes the diff smaller, is not a material deviation; record it under `Reuse`.

If implementation exposes a new material decision or requires a material deviation, finish any independently safe work, update the plan with the finding, set it back to `Awaiting approval`, and stop before the unapproved change. Do not choose for the user.

## Step 5 — verify and close

Run the repository checks named in the plan and a smoke scenario that exercises the changed behavior. For a bug, reproduce the failure before the fix when practical and observe it passing afterward. Do not claim checks that were not run.

After successful implementation:

- set `Status: Implemented`;
- add `Completed: YYYY-MM-DD`;
- replace the planned verification expectations with the commands or scenarios actually run and their concise outcomes;
- retain any genuine verification limit under `Risks and limits`.

If a check fails because of the implementation, fix it before closing. If completion is blocked by an external prerequisite, keep the status `Approved`, record the exact blocker and completed work in the plan, and report it without claiming completion.

Reply with the plan path, changed behavior, affected files, verification run, and any remaining limit. End with one or two lines naming what was skipped or not checked. Do not repeat the full plan in chat.
