---
name: review-implementation-plan
description: >
  Reviews an implementation plan written by another agent and updates it
  before anyone codes. Challenges sequence, missing steps, over-sized
  commits, and any how-to that snuck in; leaves how-to-build to the
  implementer. Use when the user asks to review the plan, "Opus review",
  "update the plan before implementing", or invokes
  /review-implementation-plan. Works as a generic Agent Skill: pass this
  SKILL.md plus the plan file to any agent.
argument-hint: "[path to plan]"
---

# Review implementation plan

You are reviewing a plan another model wrote. You may be stronger than the
planner. Your job is to improve the **sequence and the outcomes**, then stop.
Do **not** implement.

A better idea about *how* to build something is **not** a reason to write
that how into the plan. It is a reason to make sure the step still states
the outcome clearly and does not block that how. The implementer — maybe
you, in a later session — still chooses internals.

## Read first

1. This skill.
2. The plan — default `docs/implementation-plan.md`, then
   `implementation-plan.md`, then `docs/plan.md`. An explicit path wins. If
   missing, ask. Stop.
3. Every file under `docs/` except `docs/plain-english/`.
4. `git log --oneline -20` and a quick look at the tree, so steps start from
   what is actually there.

Do not wait for a recap of the architecture conversation. If the plan and
`docs/` contradict each other on something that changes which steps exist,
that is a defect: fix it or ask.

## What good looks like

The plan is a contract for a later implementing agent.

- **How to follow this plan** is present and is the execution protocol:
  one step, then stop for that commit (do not stage or commit), then the
  next step only after that subject exists in git. Do not delete or weaken
  it. You may clarify it.
- Each step is one commit, one concern, reviewable in about ten minutes,
  preferably under ~300 lines.
- **What lands** / **Done when** are observable outcomes, not file trees.
- **Locked decisions** are only choices that later steps would be written
  differently without. Everything else stays open.
- No new file, folder, function, type, or package names unless `docs/` or
  a locked decision already froze them.
- Prompts live **in the plan**, one per step, copy-pastable. They say what
  must be true, what must not be started, and that the implementer chooses
  how — including a better approach than the planner implied.
- Index table columns stay **#**, commit message, what lands, review focus.

## What to challenge

Work through this list. Edit the plan in place when you find a hit.

1. **Wrong size.** Split a step that hides two concerns. Merge steps that
   cannot land separately (a flag nobody reads, a type with no user).
2. **Wrong order.** A step depends on something that appears later. Foundations
   before the features that need them.
3. **Missing outcome.** A locked product behaviour never becomes true in any
   **Done when**. Add a step, or fold it into an existing one if it is the
   same concern.
4. **Over-specified how.** File names, folder layouts, function names,
   "create `src/…`", guessed libraries, layer diagrams. Delete those from
   prompts, **What lands**, and locked decisions unless they were actually
   frozen. Do not replace them with *your* how.
5. **False lock.** A library, pattern, or structure listed as locked that
   later steps do not actually depend on. Move it out of locked decisions.
   The implementer of that step decides.
6. **Contradiction.** Plan vs `docs/`, or two steps that cannot both be true.
   Product intent in `docs/product.md` wins user-facing conflicts; spec and
   data-shapes win on locked tables and payloads; this review fixes the plan
   to match, or asks if the product should change.
7. **No room to think.** Prompts that read like a recipe. Rewrite them as
   outcomes plus fences (prior steps must exist; next step must not start).
   Keep an explicit line: if you have a better way to reach **Done when**,
   take it; if that changes later steps, update this plan first.
8. **Unexecutable protocol.** Several steps in one change, auto-commit, or
   skipping the stop-at-commit. Restore **How to follow this plan**: implement
   one step, stop, do not stage or commit, next only after that subject
   exists in git.

## What not to do

- Do not implement, scaffold, or "just start step 1".
- Do not add approach hints, recommended libraries, or proposed file maps —
   even as "optional". They become de facto requirements.
- Do not invent product requirements the plan and `docs/` do not contain.
- Do not drop a locked decision because you would have chosen otherwise. If
  the lock is real and you think it is wrong, ask; do not silently unlock it.
- Do not overwrite the plan with a different template. Fill the one that is
  there. Add missing headings from the original shape if they were omitted.

## Blocking questions

Ask, and do **not** finish the review, when:

- You cannot tell which file is the plan.
- A product choice is still open **and** it would change which steps exist.
- `docs/` and the plan disagree on a locked user-facing behaviour and you
  cannot tell which the user meant.

Number the questions. Wait. Then edit.

Non-blocking: pick the plan's default (or what is already in the repo), state
it in the changelog, still finish the review.

## Write

Update the plan file. If you cannot write, emit the full updated document in
one markdown fence and say it still needs to be saved.

Preserve step numbers that have already landed in git (match `git log` to
commit messages). Renumber only steps that have not landed, and say so.

## After writing

In the chat (not in the plan):

1. **Changelog** — what you changed and why. One bullet per edit: split,
   merge, reorder, unlocked a false lock, stripped how-to, added a missing
   outcome. If you changed nothing, say that and why it was already sound.
2. **Still open** — anything the implementer must decide, in one list. These
   are how-questions, not missing product.
3. **Ready** — whether the plan can be executed as-is. If not, what is left.
4. Do not start step 1.
