---
name: project-steps
description: Create or sync the steps-based planning document (plans/overview.md) that /step-plan consumes. With a project description it breaks the work into ordered, independently verifiable steps, iterates with the user (as PM) until approved, then persists the overview. Invoked with NO input mid-project, it reads the plans/ folder and updates the overview to match reality (step statuses, drift from approved step plans). Use when the user says "/project-steps", "break this project into steps", "create the project overview", "update the overview", or gives a new project description they want planned step by step. Companion/entry point to the step-plan skill.
---

# Project Steps (overview document for /step-plan)

Own `plans/overview.md` — the ordered step breakdown that `/step-plan`
deep-dives one step at a time. Two modes, chosen automatically:

- **Create mode** — the invocation has args, or the user just described a
  project/feature in conversation: build the overview from that description.
- **Sync mode** — invoked with no input and `plans/overview.md` exists:
  read the `plans/` folder and update the overview to match reality.
- No input and no `plans/overview.md`: ask for the project description,
  then proceed in create mode.

The output is **only** the overview document; no step deep-dives, no
implementation.

## Create mode

1. **Gather the project description** from the args or the conversation. If
   `plans/overview.md` already exists, read it and ask whether this new
   description extends it or replaces it — never silently overwrite.

2. **Ground it in the codebase.** If this is an existing repo, explore enough
   to know what already exists: structure, stack, conventions, and which parts
   the project touches. Steps proposed against an imagined codebase are
   useless. For a greenfield project, skip this.

3. **Clarify only what actually forks the plan.** At most a handful of
   questions, and only ones whose answer changes the step breakdown (scope
   boundaries, must-have vs nice-to-have, target environment). Use
   AskUserQuestion for crisp choices; skip entirely if the description is
   already unambiguous.

4. **Propose the step breakdown in-chat** (format below) and iterate. The
   user is the PM: they reorder, merge, split, cut, and add steps. Do not
   write the file until they approve. Present the full list each iteration
   so they always see the current state.

5. **On approval, write `plans/overview.md`**, then stop and tell the user to
   run `/step-plan 1` (or whichever step they want first).

## Sync mode

1. **Read everything in `plans/`**: the overview and every `plans/step-*.md`.

2. **Determine each step's real status:**
   - no `plans/step-NN-*.md` → `pending`
   - approved step plan exists → `planned`
   - step plan exists AND the work has landed (check git log and the code the
     plan says it touches) → `done`

3. **Detect drift** between the overview and the approved step plans: scope
   that a step plan moved, cut, or deferred (its `Decisions` and
   `Out of scope` sections), and deferred items that need a new tail step.

4. **Apply and report:**
   - Mechanical updates — per-step `Status:` lines, the overview's top
     `Status:` date, one-line notes on scope a step plan already settled —
     apply directly, then report exactly what changed.
   - Structural changes — adding, splitting, merging, or reordering steps —
     propose to the PM first and only apply what they approve.
   - Never renumber or rewrite steps that already have a `plans/step-*.md`;
     new steps go at the tail.

5. If nothing has drifted, say so and change nothing.

## Step sizing rules (create mode)

- Each step must be **independently implementable and verifiable** — it ends
  with something you can run, test, or observe. "Set up types" is not a step;
  "parse the config file and print the resolved settings" is.
- A step is roughly **one focused session** of work. If describing it needs
  more than a short paragraph, split it.
- **Order by dependency, walking skeleton first**: early steps produce a
  minimal end-to-end slice; later steps deepen it. Every step builds only on
  steps before it.
- Name what each step **deliberately leaves out** when that's likely to be
  asked ("no auth yet — step 5").
- Typical projects land between 4 and 10 steps. Fewer than 3 means the
  project probably doesn't need this process; more than ~12 means the steps
  are too fine — merge them.

## Overview file format

`plans/overview.md`:

```markdown
# <Project name>

Status: active, last synced <YYYY-MM-DD>

## Summary
<what is being built and why, 3-6 sentences>

## Stack & constraints
<languages, frameworks, conventions, hard requirements>

## Non-goals
<what this project explicitly will not do>

## Steps

### Step 01: <title>
Status: pending | planned | done
<2-4 sentences: what it delivers and how you can tell it works>
Depends on: none

### Step 02: <title>
Status: pending
<...>
Depends on: step 01
```

Keep step numbers two-digit (`01`, `02`, …) — `/step-plan` derives its
`plans/step-NN-<slug>.md` filenames from them.

## Hard rules

- **Overview only.** No step deep-dives (that's `/step-plan`), no code edits,
  no implementation.
- **Create mode writes nothing before the PM approves the breakdown.** Sync
  mode may apply mechanical status/drift updates directly but must report
  every change it made.
- **Never silently overwrite or restructure an existing overview.**
- **Never renumber steps that already have `plans/step-*.md` files.**
