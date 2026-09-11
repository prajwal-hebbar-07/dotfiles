---
name: follow-implementation-plan
description: >
  Follows an implementation plan document step by step, exactly as written.
  Implements only the next unfinished step, then stops at that commit and
  does not stage or commit. Use when the user says implement the plan,
  "follow the implementation plan", "implement this doc", "next step in
  the plan", or invokes /follow-implementation-plan.
argument-hint: "[path to plan]"
---

# Follow implementation plan

Whenever you are following the implementation plan, follow **every step
exactly**, in order. The plan is the contract. This skill does not invent a
second protocol.

## Find the plan

Default `docs/implementation-plan.md`, then `implementation-plan.md`, then
`docs/plan.md`. An explicit path wins. If missing, ask. Stop.

Read the whole plan and every file under `docs/` except `docs/plain-english/`.

## Find the next step

Match `git log` to the plan's commit subjects. The next step is the first whose
subject is not in history. If an earlier step's work is not in the tree, stop.
Do not skip it. Do not start a later one.

## Implement that step only

Use that step's **Prompt**, **Done when**, **Must not start**, and any
**Locked decisions** that apply. Follow them exactly: do not drop an outcome,
do not add the next step, do not reorder.

You choose how. If a better how would change later steps, update the plan first,
then continue this step. Do not silently drift.

## Stay at commit

When **Done when** passes: **stop**. Name the step and the exact commit
subject from the plan. Do not `git add`. Do not `git commit`. Do not start
the next step.

The commit is not this skill's job. Staging stays with the user. The `commit`
skill (or the user) makes the commit. After that subject exists in `git log`,
the next turn may take the next step — only if they are still following the
plan.

## Never

- Skip, merge, or reorder steps
- Several steps in one change
- Stage or commit from this skill
- Rewrite the plan while implementing (that is `review-implementation-plan`)
