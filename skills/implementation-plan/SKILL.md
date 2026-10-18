---
name: implementation-plan
description: >
  Turns the decisions finalized in the chat where it is called into one
  commit-by-commit plan document. The document is split into windows of
  at most five commits; follow runs one window, then starts a new chat
  with empty history for the next window. Each commit is a code commit
  or a docs commit.   A code commit updates the existing architecture pages
  it makes stale, creates or updates only the markdown documents that
  step names, and adds or updates code-level tests for the behaviour it
  changes and runs them. A docs commit records decisions or findings this
  chat finalized by creating or updating the markdown documents they make
  stale, touches no code, and may answer a question with a throwaway
  experiment outside the repo. Manual and UI testing stay with the user.
  Use when the user asks to build the implementation plan,
  "write the plan", "plan the commits", "the conversation is done, make
  the plan", or invokes /implementation-plan.
argument-hint: "[output directory]"
---

# Implementation plan

Turn this chat into **one** plan document an implementing agent can follow
without this chat. The document holds the whole sequence, in windows of
**at most five commits**. Follow runs one window, then starts the next in
a **new chat with empty history**. The user does not open that chat and
does not name a second file.

Do **not** implement. Do **not** invent file names, folder layouts,
function names, or libraries that were not locked in this chat. When this
chat finalized a markdown document, name it on the step that owns it.
`follow-implementation-plan` creates or updates that document. A code
step may name documents that travel with the change. A docs step is for
when the documents are the deliverable (see **Docs commits**). Do not add
a markdown document this chat did not finalize.

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

## Two kinds of commit

Every commit has a **Kind**: `code` or `docs`.

- **code** (the default): changes the product. The architecture-page rule
  and the code-level test rule under **Code commits** apply.
- **docs**: the deliverable is the documents themselves, because this chat
  finalized it: recording decisions, answering open questions, changing
  requirement or design documents to match a decision, or writing up the
  findings of a throwaway experiment. A docs commit never touches code.

Use `docs` only for documentation work this chat finalized. Refreshing docs
after code changed is not a docs commit: the code commit updates its own
stale architecture pages, and the `docs` skill owns full refreshes, new
areas, plain-English pages and the baseline. A plan may be all docs commits
(for example a decisions-and-checks phase) or mix both kinds. Do not split
one concern into a code commit plus a docs commit just to update docs.

### Docs commits

A docs commit may create or update the markdown documents its decisions
or findings make stale, or whose path this chat froze. That includes a
new document. It leaves every document it touches consistent with the
decision and with each other. When the repo has its own documentation
conventions (a decision log, stable requirement IDs, an open-questions
list, "answered" markers), the commit follows them, and the plan says so
instead of restating them. Name each document in the step.
`follow-implementation-plan` creates and updates those documents.

A docs commit does not touch code or tests, and does not stamp
`docs-baseline:`. It does not edit the plan's directory.

Its **Done when** replaces code-level tests with consistency checks: where
the decision now appears, that no document still contradicts it, and that
answered questions are marked answered and removed from wherever open
questions are tracked.

**Throwaway experiments.** When this chat said a question must be answered
by testing it, a docs commit may run a throwaway experiment (a spike). The
experiment lives **outside the repository**, nothing from it is staged, and
the plan names the step that deletes it. The finding must come from what
actually ran (versions, what was tried, what was observed). If this chat
finalized a fallback for a failed check, the step states it. A step may
allow starting local services the experiment needs (for example databases
in Docker); say so in the step.

**Outside the repository.** A step may update an issue tracker or similar
only when this chat authorized it, naming which items and what changes.
That update happens after the step's commit and never closes anything this
chat did not say to close.

Every docs commit's own explanation carries these sentences, verbatim. The
first in **Markdown**, in **Done when**, and in **Prompt**:

`This docs commit creates or updates only the markdown documents this step names, and touches no code.`

The second in **Tests**, in **Done when**, and in **Prompt**:

`This docs commit changes no code, so it adds no code-level tests; it is checked by every document it touches agreeing with the decision and with each other.`

### Code commits

The rest of this section applies to code commits.

**Architecture pages travel with the code.** When a commit changes
behaviour an existing page under `docs/architecture/` describes, that same
commit updates those pages so they stay true. Do that when this repo's
`architecture:` pin in `docs/README.md` is `on` (or the pin is absent and
those pages already exist). A new architecture document is allowed when
this chat finalized it and the step names it. Do not stamp
`docs-baseline:` unless the step says so.

A code commit may also create or update other markdown documents when
this chat finalized them as part of that commit. Name each one in the
step. `follow-implementation-plan` creates and updates the documents the
step names, and does not create or edit a markdown document the step does
not name. Do not list a markdown path as **What lands** unless this chat
already froze that path. The `docs` skill still owns a full refresh the
chat did not finalize.

Every code commit's own explanation carries this sentence, verbatim, in
**Markdown**, in **Done when**, and in **Prompt**:

`This commit updates the existing architecture pages it makes stale, and creates or updates only the markdown documents this step names.`

Before saving, re-read every commit. If a code commit creates or updates
a markdown document, the step must name it. If a docs commit touches code,
or records something this chat did not finalize, rewrite it. A plan that
leaves a described architecture page stale, or that creates or updates a
markdown document the step does not name, is not finished.

**Code-level tests travel with the code.** Every code commit adds or updates
tests that sanity-check the behaviour it changes and that exercise that
functionality. Typecheck alone is not that coverage. The tests run under
the project's unit-test command for the tests that commit touches. The
plan does not ask for a manual pass, a browser session, or a UI test.
The user does those.

Every code commit's own explanation carries this sentence, verbatim, in
**Tests**, in **Done when**, and in **Prompt**:

`This commit adds or updates code-level tests for the behaviour it changes and runs them. Manual testing and UI testing are left to the user.`

Before saving, re-read every code commit. If **Done when** changes behaviour
and names no sanity check and no functionality check, add them. If it
tells the implementer to open a browser or do a manual or UI pass, delete
that. A plan that leaves changed behaviour untested at code level is not
finished.

## Both kinds

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

Every commit block carries a **Kind:** line (`code` or `docs`) and the
sentences for its kind. The template shows both variants.

Each commit's **Prompt** is for the implementing agent. It restates that
commit's outcome, its kind, the locked decisions that apply, what must
already exist, what must not be started, and the sentences for its kind.
It does **not**
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
   be true at the end of the whole plan, then one sentence per commit,
   saying which commits are docs commits. State once that each code commit
   updates the existing architecture pages it makes stale, and creates or
   updates only the markdown documents that step names. Docs commits
   create or update only the markdown documents they name, and touch no
   code. Name any throwaway experiment and any issue-tracker update.
2. Give the one path. List each window and its commit range. One
   `/follow-implementation-plan` runs the current window only. When that
   window has landed, follow starts a new chat with empty history for the
   next window. The user does not name that window.
3. Review is **optional**. If they want a second model on the plan, they
   invoke `review-implementation-plan` themselves **before** follow. This
   skill does not require review and does not start it.
4. This skill does not start commit 1.
