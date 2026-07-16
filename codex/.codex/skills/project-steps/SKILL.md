---
name: project-steps
description: Create or sync the steps-based planning document (plans/overview.md) consumed by the step-plan skill. With a project description, break work into ordered, independently verifiable steps, iterate with the user as PM until approved, then persist the overview. With no input mid-project, read plans/ and update the overview to match actual step status and drift from approved step plans. Use when the user says "/project-steps", "$project-steps", "break this project into steps", "create the project overview", "update the overview", or asks to plan a new project step by step.
---

# Project Steps

Own `plans/overview.md`, the ordered project breakdown that the `step-plan`
skill deep-dives one step at a time. Choose the mode automatically:

- **Create mode** — the invocation has arguments, or the user described a
  project or feature in conversation. Build the overview from that description.
- **Sync mode** — the invocation has no input and `plans/overview.md` exists.
  Read `plans/` and update the overview to match reality.
- With no input and no `plans/overview.md`, ask for the project description,
  then proceed in create mode.

Produce only the overview document. Do not deep-plan a step or implement code.

## Create mode

1. **Gather the project description** from the invocation or conversation. If
   `plans/overview.md` already exists, read it and ask whether the new
   description extends or replaces it. Never silently overwrite it.

2. **Ground the breakdown in the codebase.** In an existing repository,
   inspect enough structure, stack, conventions, implementation, and tests to
   understand what exists and which areas the project touches. Skip repository
   grounding only for a genuinely greenfield project.

3. **Clarify only decisions that fork the breakdown.** Ask at most a handful
   of concise questions about choices such as scope boundaries, must-have
   versus optional work, or target environment. Prefer crisp choices when the
   alternatives are known; skip questions when the request is unambiguous.

4. **Propose the complete step breakdown in chat** using the format below and
   iterate with the user as PM. They may reorder, merge, split, cut, or add
   steps. Present the complete revised list each round. Do not write the file
   until the user explicitly approves the breakdown.

5. **After approval, write `plans/overview.md`**, then stop and suggest using
   `$step-plan 1`, or whichever step the user wants to plan first.

## Sync mode

1. **Read the complete planning set:** `plans/overview.md` and every
   `plans/step-*.md`.

2. **Determine each step's actual status:**
   - no matching `plans/step-NN-*.md` means `pending`;
   - an approved step plan exists means `planned`;
   - a step plan exists and its work has landed means `done`. Verify this in
     git history and the implementation areas named by the plan.

3. **Detect drift** between the overview and approved step plans. Look for
   scope a plan moved, cut, or deferred through its `Decisions` and
   `Out of scope` sections, including deferred work that needs a new tail step.

4. **Apply and report updates:**
   - Apply mechanical updates directly: step `Status:` lines, the overview's
     top `Status:` date, and one-line notes about scope already settled by a
     step plan. Report each change.
   - Propose structural changes before applying them: adding, splitting,
     merging, or reordering steps requires PM approval.
   - Never renumber or rewrite a step that already has a step-plan file. Add
     new work at the tail.

5. If nothing has drifted, report that and leave the files unchanged.

## Step sizing rules

- Make each step independently implementable and verifiable. End with
  something that can be run, tested, or observed. "Set up types" is not a
  step; "parse the config and print the resolved settings" is.
- Size a step for roughly one focused implementation session. Split anything
  that needs more than a short paragraph to explain.
- Order by dependency and build a walking skeleton first. Early steps produce
  a minimal end-to-end slice; later steps deepen it. Each step builds only on
  earlier steps.
- State deliberate omissions when users are likely to expect them, such as
  "no authentication yet; added in step 05."
- Aim for 4–10 steps. Fewer than 3 often does not need this workflow; more
  than about 12 usually means the steps are too fine-grained.

## Overview file format

Write `plans/overview.md` as:

```markdown
# <Project name>

Status: active, last synced <YYYY-MM-DD>

## Summary
<what is being built and why, in 3–6 sentences>

## Stack & constraints
<languages, frameworks, conventions, and hard requirements>

## Non-goals
<what this project explicitly will not do>

## Steps

### Step 01: <title>
Status: pending | planned | done
<2–4 sentences explaining what it delivers and how to verify it>
Depends on: none

### Step 02: <title>
Status: pending
<...>
Depends on: step 01
```

Keep step numbers two-digit (`01`, `02`, and so on). The `step-plan` skill
derives `plans/step-NN-<slug>.md` filenames from them.

## Hard rules

- **Overview only.** Do not deep-plan a step or implement code.
- **Write nothing in create mode before PM approval.** Sync mode may apply
  mechanical status and drift updates directly, but report every change.
- **Never silently overwrite or restructure an existing overview.**
- **Never renumber steps that already have `plans/step-*.md` files.**
