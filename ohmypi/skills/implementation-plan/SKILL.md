---
name: implementation-plan
description: >
  Turns the decisions finalized in the chat where it is called into one
  commit-by-commit plan document. The document is split into windows of
  at most five commits; follow runs one window, then starts a new chat
  with empty history for the next window. No commit updates a markdown
  document. Use when the user asks to build the implementation plan,
  "write the plan", "plan the commits", "the conversation is done, make
  the plan", or invokes /implementation-plan or /skill:implementation-plan.
argument-hint: "[output directory]"
---

# Implementation plan

Turn this chat into **one** plan document an implementing agent can follow
without this chat. The document holds the whole sequence, in windows of
**at most five commits**. Follow runs one window, then starts the next in
a **new chat with empty history**. The user does not open that chat and
does not name a second file.

Do **not** implement. Do **not** invent file names, folder layouts,
function names, or libraries that were not locked in this chat. Do **not**
document the product. Do **not** put documentation work in the plan.

The planner and the implementer may be different models. You are the
planner. Over-specifying how is a bug in the plan.

## Source

The plan is the decisions **taken and finalized in this chat** — the chat
where this skill was called. Nothing else becomes a commit.

Finalized means the chat closed on it: the user chose it, agreed to it, or
the last word was a definite behaviour. Discussed, offered as an option, or
left open is not finalized.

If a missing decision would change **which commits exist**, ask numbered
questions and wait. If it would only change **how one commit is built**,
leave it open. Do not invent the answer. Do not wait for a recap.

If this chat has no finalized decisions, ask for them. Stop. Do not plan
from docs alone.

## Read first

- This conversation: finalized decisions, out of scope, anything still open
- Every file under `docs/` except `docs/plain-english/` and except any
  existing files in the plan output directory — only to see what is already
  true, so you do not re-plan work that already landed
- `git log --oneline -20` and a quick look at the tree, for the same reason

`docs/` and the tree do not add commits this chat did not finalize. If a
doc and this chat disagree, this chat wins. Say that in the walkthrough.

## What a commit is

One git commit. One concern. Reviewable in about ten minutes. Prefer under
~300 lines (soft). A later commit may exist because of this one; this
commit must still make sense on its own.

Each commit states **what is true when it is done**, not how to make it
true. No new file, folder, function, type, or package names unless this
chat already froze them. A typecheck / test gate is "this commit adds no
new failures versus the parent commit", not "the whole repo is green".

**No markdown.** No commit creates, edits, or deletes a markdown document.
That includes `docs/`, README files, `AGENTS.md`, `CLAUDE.md`,
`.cursor/rules/`, changelogs, ADRs, and any other `.md` file. Do not add a
commit that writes, refreshes, or "keeps the docs in sync". Do not list a
markdown path as **What lands**. Existing `docs/` are read as background;
the implementer must not edit them. Documentation is a later, deliberate
pass the user runs (`docs`). Never a side effect of implementing.

Every commit's own explanation carries this sentence, verbatim, in
**Markdown**, in **Done when**, and in **Prompt**:

`This commit does not create, edit, or delete any markdown document.`

Before saving, re-read every commit. If **What lands**, **Done when**,
**Out of scope**, or **Prompt** tells the implementer to write or update
markdown, rewrite the commit so the outcome needs no markdown edit, or
drop the commit and name it in the walkthrough. A plan that updates a
markdown document is not finished.

The only markdown this skill writes is the one plan document (and a
`.gitignore` line if needed). That write is not a commit in the plan.

A technical choice belongs in **Locked decisions** only if it was finalized
in this chat **and** later commits would be written differently without it.
Otherwise the implementer of that commit decides.

The **commit** skill invents the git subject from the staged diff. Do not
treat a commit's concern line as a string to put in `git log`. Follow
records done-ness with `**Landed:** \`<sha>\`` on the commit. Do not write
`Landed` yourself. That stamp is the resume marker for the next chat. It
is not part of the git commit, and it is the only edit follow may make to
the plan document.

## Where it goes

Write **one** file: `docs/implementation-plan/plan.md` (create the directory
if needed) unless the user names another directory. If they do, the file is
still `plan.md` inside that directory.

Do not write `01.md`, `02.md`, or any second plan file. The whole sequence
lives in this document.

Inside it, split the sequence into windows of **at most five commits**:

- Window 1 — commits 1–5
- Window 2 — commits 6–10
- …

Commit numbers are global and contiguous. The last window may have fewer
than five. Never put a sixth commit in a window. Never pad with filler.
Never start a second document for the overflow.

If that directory already has a plan (`plan.md` or older `NN.md` files),
ask before replacing them.

Add `docs/implementation-plan/` to the repo's `.gitignore` if it is not
already there. Create `.gitignore` if needed. That is not a plan commit.

If you cannot write (ask mode, read-only), emit the one file in a markdown
fence, labelled with the path, and say it still needs to be saved.

## Document shape

Read [template.md](template.md) and fill it **once**. Keep **How this file
is followed** and **How to follow this plan** intact — that is the protocol
the other agent runs. Do not shorten them, and do not add implementation
recipes to them.

The file is self-contained: locked decisions from this chat, out of scope,
commit rules, one window per five commits, and a prompt per commit. A later
chat has none of this conversation; the document is all it gets.

Index table columns, in this order: **#**, concern, what lands, review
focus. Each window has its own table, listing only that window's commits.
**Concern** is a human label, not a git subject.

Each commit's **Prompt** is for the implementing agent. It restates that
commit's outcome, the locked decisions that apply, what must already exist,
what must not be started, and the markdown sentence above. It does **not**
prescribe design. It names **this file**. It does not dump the conversation
and it does not point at a second plan file.

## After writing the file — gitignore commit only

If you added or changed the `.gitignore` line:

1. `git add` **only** `.gitignore`.
2. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself.
3. If commit reports nothing staged: add `.gitignore` once more and run
   commit once. If identity/hook fails: STOP and relay that.

Do not stage the plan document. It is gitignored. If `.gitignore` did not
change, do not commit.

## After writing — in chat

1. A plain-English walk through **all** commits so the user can reject the
   sequence without reading prompts. Everyday words. Lead with what will
   be true at the end of the whole plan, then one sentence per commit.
   State once that no commit creates or edits a markdown document. Do not
   describe a markdown update for any commit.
2. Give the one path. List each window and its commit range. One
   `/follow-implementation-plan` runs the current window only. When that
   window has landed, follow starts a new chat with empty history for the
   next window. The user does not name that window.
3. Review is **optional**. If they want a second model on the plan, they
   invoke `review-implementation-plan` themselves **before** follow. This
   skill does not require review and does not start it.
4. This skill does not start commit 1.
