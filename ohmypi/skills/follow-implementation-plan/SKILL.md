---
name: follow-implementation-plan
description: >
  Implements the next unfinished step of an implementation plan as code,
  stages that step's files, commits through the commit skill with the plan's
  subject, then continues to the next step. Use only when the user
  explicitly asks to implement, execute, or follow the plan as code,
  "implement this doc", "next step", or /follow-implementation-plan. Do not
  use when the user asks to review, write, update, or look at the plan.
argument-hint: "[path to plan]"
---

# Follow implementation plan

Follow **every step exactly**, in order. The plan is the contract. This
skill does not invent a second protocol.

## This turn must be an implement ask

This skill runs only when **this message** asks to implement, execute,
follow the plan as code, do the next step, or names `/follow-implementation-plan`.

It does **not** run because:

- this chat earlier reviewed or wrote the plan
- the plan is marked ready
- you are already looking at `docs/implementation-plan.md`

If this message is a review, a plan write, or "look at the plan": **do not
implement**. Do not touch application code. That is a different skill.

If one message asks to review **and** implement: review only, then stop.
Wait for a later message that asks to implement.

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

## Gates

A named typecheck / lint / test command is a gate on **this step**, not on
the whole repo.

- If it already fails at the parent commit (HEAD before this step's files),
  that is not a stop. Prove it: same command, same error set with this
  step stashed or compared. Unchanged set → the gate is met. Continue.
- Stop only if **this step added** failures.
- Do not pause the plan to fix unrelated baseline errors. Do not open a
  commit outside this plan for that. Do not ask the user to choose "fix
  baseline first" versus "continue" — continue.
- Host rules that forbid a build or dev suite still apply. If the plan
  names a command you must not run, skip it, say so in one line, and
  continue. That is not a stop.

## Commit, then continue

When **Done when** passes, the step is not finished until its commit exists.
Do not stop because commit could not run.

1. `git add` **only** the files this step created or changed. Leave unrelated
   dirty files alone.
2. Run the `commit` skill. Pass the plan's exact subject as the user's
   wording. Do not `git commit` yourself while `commit` can run. Do not
   draft the message.
3. If `commit` reports nothing staged: you failed to add. Add this step's
   files and run `commit` once more. That is not a reason to end the plan.
4. If identity is missing or a pre-commit hook fails: **stop**. Relay that.
   Do not start the next step.
5. When `git log` shows that subject, emit the step report (see below), then
   take the **next** unfinished step in this same follow. Keep going until
   the plan is done or a step cannot finish.

## Report

After every step — committed or blocked — emit one report in the **report-arc**
shape. Read that skill's `template.md` if it is available. Status line, Done
when table, Changed, Left unstaged, Verification (gate vs parent), Next. No
"your call". A report is not permission to skip the next step.

## Never

- Skip, merge, or reorder steps
- Several steps in one uncommitted change
- `git commit` yourself while the `commit` skill can run
- Stop the plan because nothing was staged
- Stop the plan because a gate was already red at HEAD
- Pause to fix baseline errors that this step did not add
- Rewrite the plan while implementing (that is `review-implementation-plan`)
- Implement because a review in this chat just finished