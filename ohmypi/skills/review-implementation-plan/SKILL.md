---
name: review-implementation-plan
description: >
  Reviews the single implementation-plan document written by another agent
  and updates it before anyone codes. Challenges sequence, missing commits,
  oversized windows, and any how-to that snuck in; leaves how-to-build to
  the implementer. Rejects any commit that creates or edits a markdown
  document. Does not write application code and does not start
  follow-implementation-plan. Use when the user asks to review the plan,
  "Opus review", "update the plan before implementing", or invokes
  /review-implementation-plan or /skill:review-implementation-plan. Do not
  use when the user asks to implement the plan.
argument-hint: "[path to plan file or directory]"
---

# Review implementation plan

You are reviewing a plan another model wrote with `implementation-plan`.
You may be stronger than the planner. Your job is to improve the
**sequence and the outcomes**, then stop. Do **not** implement. Do not
start `follow-implementation-plan`. A review that continues into a commit
is a failed review.

A better idea about *how* to build something is **not** a reason to write
that how into the plan. It is a reason to make sure the commit still states
the outcome clearly and does not block that how. The implementer — maybe
you, in a later session — still chooses internals.

## Read first

1. This skill, and the plan shape in
   [../implementation-plan/template.md](../implementation-plan/template.md).
2. The plan. Explicit path wins: a `.md` file is the plan; a directory
   means `plan.md` in it. Default `docs/implementation-plan/plan.md`.
   Missing → ask. Stop. If `plan.md` is missing and numbered `NN.md` files
   are there, those are an older plan: review them in numeric order, and
   do not merge them into `plan.md` unless the user asks. Skip a file, or
   a window, where every `### N.` step already has `**Landed:**`.
3. Every file under `docs/` except `docs/plain-english/` and except the
   plan directory.
4. `git log --oneline -20` and a quick look at the tree, so commits start
   from what is actually there.

Do not wait for a recap of the architecture conversation. The plan was
supposed to come from decisions finalized in the chat that wrote it. If
the plan and `docs/` contradict each other on something that changes which
commits exist, that is a defect: fix the plan to match its locked
decisions, or ask.

## What good looks like

The plan is one document, a contract for a later implementing agent that
does not have the planning chat.

- **How this file is followed** and **How to follow this plan** are present
  and match the template: one commit at a time, `git add` only that
  commit's non-markdown files, run the `commit` skill with no subject,
  stamp `**Landed:** \`<sha>\`` on the step, then the next step **in this
  window**; when every step in the window has `Landed`, start the next
  window in a **new chat with empty history**. Do not delete `plan.md`
  between windows. Delete it only when every window is done. Do not delete
  or weaken those sections. You may clarify them.
- The whole sequence is in this one file. Windows hold **at most five**
  commits. Commit numbers are global and contiguous. There is no `01.md` /
  `02.md` split.
- Each commit is one concern, reviewable in about ten minutes, preferably
  under ~300 lines.
- **What lands** / **Done when** are observable outcomes, not file trees
  and not markdown edits.
- Every commit's explanation — **Markdown**, **Done when**, and **Prompt**
  — contains, verbatim: `This commit does not create, edit, or delete any
  markdown document.`
- **Locked decisions** are only choices finalized in the planning chat that
  later commits would be written differently without. Everything else stays
  open.
- No new file, folder, function, type, or package names unless `docs/` or
  a locked decision already froze them.
- Prompts live **in the plan**, one per commit, copy-pastable. They say
  what must be true, what must not be started, and that the implementer
  chooses how — including a better approach than the planner implied. If
  that approach would change a later commit, the prompt says stop and ask.
  It does not say to edit the plan.
- Index table columns stay **#**, concern, what lands, review focus.
  **Concern** is a human label, not a git subject. Each window has its own
  table.

## What to challenge

Work through this list. Edit the plan in place when you find a hit.

1. **Wrong size.** Split a commit that hides two concerns. Merge commits
   that cannot land separately (a flag nobody reads, a type with no user).
2. **Wrong order.** A commit depends on something that appears later.
   Foundations before the features that need them.
3. **Missing outcome.** A locked product behaviour never becomes true in any
   **Done when**. Add a commit, or fold it into an existing one if it is the
   same concern. Locked means finalized in the chat that wrote the plan.
4. **Over-specified how.** File names, folder layouts, function names,
   "create `src/…`", guessed libraries, layer diagrams. Delete those from
   prompts, **What lands**, and locked decisions unless they were actually
   frozen. Do not replace them with *your* how.
5. **False lock.** A library, pattern, or structure listed as locked that
   later commits do not actually depend on, or that the planning chat never
   finalized. Move it out of locked decisions. The implementer of that
   commit decides.
6. **Contradiction.** Plan vs `docs/`, or two commits that cannot both be
   true. Product intent in `docs/product.md` wins user-facing conflicts
   among docs; spec and data-shapes win on locked tables and payloads;
   locked decisions in the plan win where the planning chat finalized
   them. This review fixes the plan, or asks if the product should change.
7. **No room to think.** Prompts that read like a recipe. Rewrite them as
   outcomes plus fences (prior commits must exist; the next commit and the
   next window must not start). Keep an explicit line: if you have a better
   way to reach **Done when**, take it; if that changes a later commit,
   stop and ask. Do not tell the implementer to edit the plan.
8. **Unexecutable protocol.** Several commits in one uncommitted change,
   a sixth commit in the same chat, skipping commit, a planned git subject
   to grep for, stopping because nothing was staged, or a **Done when**
   that requires a green typecheck/test/build when HEAD is already red.
   Restore the template's **How to follow this plan**. Rewrite whole-repo
   "must pass" gates to "this commit adds zero new failures versus the
   parent commit."
9. **Markdown in a commit.** A commit whose **What lands**, **Done when**,
   **Prompt**, or **Out of scope** writes, refreshes, or "keeps in sync"
   any markdown document — docs, README, changelog, ADR, `AGENTS.md`,
   `CLAUDE.md`, `.cursor/rules/`, or any other `.md` file. Delete that
   work from the commit. If the commit is only a markdown update, delete
   the commit. Every remaining commit must carry the verbatim sentence
   `This commit does not create, edit, or delete any markdown document.`
   in **Markdown**, **Done when**, and **Prompt**.
10. **Oversized window.** More than five commits in one window, or a second
    plan file that should be one document. Re-chunk unfinished commits into
    windows of at most five inside the same `plan.md`. Do not create
    `01.md`, `02.md`, or another plan file. Say which commits moved.

## What not to do

- Do not implement, scaffold, or "just start commit 1".
- Do not edit anything except the plan document. No app source, no tests,
  no other `docs/` files, no other markdown.
- Do not stage or commit the plan. It is gitignored scratch.
- Do not touch a step that has `**Landed:**`: no renumber, no rewording,
  no moving it between windows. Do not write `**Landed:**` yourself.
- Do not invoke or continue into `follow-implementation-plan`.
- Do not add approach hints, recommended libraries, or proposed file maps —
  even as "optional". They become de facto requirements.
- Do not invent product requirements the plan does not contain. The plan
  came from the chat that wrote it; do not grow it from docs the chat did
  not finalize.
- Do not drop a locked decision because you would have chosen otherwise. If
  the lock is real and you think it is wrong, ask; do not silently unlock it.
- Do not overwrite the plan with a different shape. Fill the template that
  is there. Restore missing headings from the template.
- Do not split the plan into several files.

## Blocking questions

Ask, and do **not** finish the review, when:

- You cannot tell which file is the plan.
- A product choice is still open **and** it would change which commits exist.
- `docs/` and the plan disagree on a locked user-facing behaviour and you
  cannot tell which the planning chat meant.

Number the questions. Wait. Then edit.

Non-blocking: pick the plan's default (or what is already in the repo), state
it in the changelog, still finish the review.

## Walk the windows

Review the plan one window at a time, in order:

1. Read the current window in full. Run **What to challenge** on it and edit
   it in place.
2. Check the seams with the windows already reviewed: nothing depends on a
   later window, commit numbers stay global and contiguous, no window holds
   more than five commits.
3. Note the window's changelog, then move to the next window. Do not wait
   for the user between windows.

On an older multi-file plan, walk files instead of windows. Do not convert
them unless the user asks.

A blocking question stops the walk at the current window. Report the windows
already reviewed, ask, and resume from that window after the answer.

## Write

Edit the plan in place. If a split or merge overflows five commits, move
the overflow into the next window in the same file (creating or shifting
later windows as needed); it is reviewed when the walk reaches it.
Renumber only steps with no `**Landed:**`, and say so. If you cannot write,
emit the updated file in one markdown fence labelled with its path and say
it still needs to be saved.

## After the walk — in chat, not in the plan

1. **Changelog** — per window, one bullet per edit: split, merge, reorder,
   unlocked a false lock, stripped how-to, added a missing outcome, moved
   commits between windows, stripped a markdown update. A window with no
   edits → say so and why it was already sound.
2. **Still open** — anything the implementer must decide, in one list.
   These are how-questions, not missing product.
3. **Ready** — whether the file can be executed as-is. If not, what is
   left. Ready is not permission to code. Confirm that no commit updates a
   markdown document.
4. **Stop.** Do not start commit 1. Do not offer to start it. Do not run
   `follow-implementation-plan`. Implementation needs a later, explicit ask.
