---
name: review-implementation-plan
description: >
  Reviews an implementation plan written by another agent and updates it
  before anyone codes. Challenges sequence, missing steps, over-sized
  commits, and any how-to that snuck in; leaves how-to-build to the
  implementer. Does not write application code and does not start
  follow-implementation-plan. Use when the user asks to review the plan,
  "Opus review", "update the plan before implementing", or invokes
  /review-implementation-plan or /skill:review-implementation-plan. Do not
  use when the user asks to implement the plan. Reviews every numbered
  plan file in order (01.md, 02.md, …), one after the other.
argument-hint: "[path to plan file or directory]"
---

# Review implementation plan

You are reviewing a plan another model wrote with `implementation-plan`.
You may be stronger than the planner. Your job is to improve the
**sequence and the outcomes**, then stop. Do **not** implement. Do not
start `follow-implementation-plan`. A review that continues into a step is
a failed review.

A better idea about *how* to build something is **not** a reason to write
that how into the plan. It is a reason to make sure the step still states
the outcome clearly and does not block that how. The implementer — maybe
you, in a later session — still chooses internals.

## Read first

1. This skill, and the plan shape in
   [../implementation-plan/template.md](../implementation-plan/template.md).
2. The plan. Explicit path wins: a `.md` file means review only that file;
   a directory means all its numbered `NN.md` files. Default
   `docs/implementation-plan/`. Missing or no `NN.md` files → ask. Stop.
   The queue is every `NN.md` in numeric order, skipping files where every
   `### N.` step already has `**Landed:**`.
3. Every file under `docs/` except `docs/plain-english/` and except the
   plan directory.
4. `git log --oneline -20` and a quick look at the tree, so steps start from
   what is actually there.

Do not wait for a recap of the architecture conversation. If the plan and
`docs/` contradict each other on something that changes which steps exist,
that is a defect: fix it or ask.

## What good looks like

The plan is a contract for a later implementing agent.

- **This window** and **How to follow this plan** are present and match the
  template: one step at a time, `git add` only that step's files, run the
  `commit` skill with no subject, stamp `**Landed:** \`<sha>\`` on the step,
  then the next step **in this file**; when every step has `Landed`, delete
  the file (not staged) and start the next file in a **new agent with empty
  history**. Do not delete or weaken them. You may clarify them.
- Each file has **at most five** steps. Step numbers are global. Each step
  is one commit, one concern, reviewable in about ten minutes, preferably
  under ~300 lines.
- **What lands** / **Done when** are observable outcomes, not file trees.
- **Locked decisions** are only choices that later steps would be written
  differently without. Everything else stays open.
- No new file, folder, function, type, or package names unless `docs/` or
  a locked decision already froze them.
- Prompts live **in the plan**, one per step, copy-pastable. They say what
  must be true, what must not be started, and that the implementer chooses
  how — including a better approach than the planner implied.
- Index table columns stay **#**, concern, what lands, review focus.
  **Concern** is a human label, not a git subject.

## What to challenge

Work through this list. Edit the plan in place when you find a hit.

1. **Wrong size.** Split a step that hides two concerns. Merge steps that
   cannot land separately (a flag nobody reads, a type with no user).
2. **Wrong order.** A step depends on something that appears later.
   Foundations before the features that need them.
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
   take it; if that changes later steps in this file, update this plan
   first; if it changes a later file, stop and ask.
8. **Unexecutable protocol.** Several steps in one uncommitted change,
   skipping commit, a planned git subject to grep for, stopping because
   nothing was staged, or a **Done when** that requires a green
   typecheck/test/build when HEAD is already red. Restore the template's
   **How to follow this plan**. Rewrite whole-repo "must pass" gates to
   "this step adds zero new failures versus the parent commit."
9. **Documentation in the plan.** A step whose **What lands** is docs,
   twins, README, or agent memory files (`AGENTS.md`, `CLAUDE.md`,
   `.cursor/rules/`), or "keep the docs in sync". Delete that step. The
   user documents separately (`docs`). **How to follow this plan** and
   **Out of scope** must both say the implementer never writes docs.
10. **Oversized file.** More than five steps in one file. Re-chunk
    unfinished steps into files of at most five. Fix **Previous** /
    **Next**. Say which files moved.

## What not to do

- Do not implement, scaffold, or "just start step 1".
- Do not edit anything except the plan files. No app source, no tests, no
  other `docs/` files.
- Do not stage or commit plan files. They are gitignored scratch.
- Do not touch a step that has `**Landed:**`: no renumber, no rewording,
  no moving it between files. Do not write `**Landed:**` yourself.
- Do not invoke or continue into `follow-implementation-plan`.
- Do not add approach hints, recommended libraries, or proposed file maps —
  even as "optional". They become de facto requirements.
- Do not invent product requirements the plan and `docs/` do not contain.
- Do not drop a locked decision because you would have chosen otherwise. If
  the lock is real and you think it is wrong, ask; do not silently unlock it.
- Do not overwrite the plan with a different shape. Fill the template that
  is there. Restore missing headings from the template.

## Blocking questions

Ask, and do **not** finish the review, when:

- You cannot tell which file is the plan.
- A product choice is still open **and** it would change which steps exist.
- `docs/` and the plan disagree on a locked user-facing behaviour and you
  cannot tell which the user meant.

Number the questions. Wait. Then edit.

Non-blocking: pick the plan's default (or what is already in the repo), state
it in the changelog, still finish the review.

## Walk the files

Review the queue one file at a time, in order:

1. Read the current file in full. Run **What to challenge** on it and edit
   it in place.
2. Check the seams with the files already reviewed: nothing depends on a
   later file, **Previous** / **Next** point at the right siblings, step
   numbers stay global and contiguous.
3. Note the file's changelog, then move to the next file in the queue. Do
   not wait for the user between files.

A blocking question stops the walk at the current file. Report the files
already reviewed, ask, and resume from that file after the answer.

## Write

Edit each file in place. If a split or merge overflows five steps, move
the overflow into the next numbered file (creating or shifting later files
as needed); it is reviewed when the walk reaches it. Renumber only steps
with no `**Landed:**`, and say so. If you cannot write, emit each updated
file in its own markdown fence labelled with its path and say they still
need to be saved.

## After the walk — in chat, not in the plan

1. **Changelog** — per file, one bullet per edit: split, merge, reorder,
   unlocked a false lock, stripped how-to, added a missing outcome, moved
   steps between files. A file with no edits → say so and why it was
   already sound.
2. **Still open** — anything the implementer must decide, in one list.
   These are how-questions, not missing product.
3. **Ready** — per file, whether it can be executed as-is. If not, what is
   left. Ready is not permission to code.
4. **Stop.** Do not start step 1. Do not offer to start it. Do not run
   `follow-implementation-plan`. Implementation needs a later, explicit ask.
