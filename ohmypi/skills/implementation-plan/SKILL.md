---
name: implementation-plan
description: >
  Turns a finished architecture conversation into a commit-by-commit
  implementation plan, split into markdown files of at most five steps.
  Follow stamps Landed:<sha> on each step, deletes a finished file, and
  starts the next in a new agent with empty history. Use when the user
  asks to build the implementation plan, "write the plan", "plan the
  commits", "the conversation is done, make the plan", or invokes
  /implementation-plan or /skill:implementation-plan.
argument-hint: "[output directory]"
---

# Implementation plan

Turn a finished design conversation into plan files an implementing agent
can follow without this chat. **At most five steps per file.** Follow
deletes a finished file and starts the next in a **new agent with empty
history** (never the same agent), so the user does not name `02.md`.

Do **not** implement. Do **not** invent file names, folder layouts,
function names, or libraries that were not locked. Do **not** document
the product, and do **not** put documentation work in the plan. The user
updates docs separately (`docs`).

The planner and the implementer may be different models. You are the
planner. Over-specifying how is a bug in the plan.

## When to start

The user says the architecture conversation is done, or asks for the plan.
If a choice would change **which steps exist**, ask numbered questions and
wait. If a choice only changes **how one step is built**, leave it open.

Do not wait for a recap. This conversation, plus `docs/` and the repo, are
the source.

## Read first

- This conversation: locked decisions, out of scope, "we'll see" items
- Every file under `docs/` except `docs/plain-english/` and except any
  existing files in the plan output directory
- `git log --oneline -20` and a quick look at the tree so steps start from
  what is actually there

If there is no conversation and no `docs/`, ask for architecture notes. Stop.

## What a step is

One git commit. One concern. Reviewable in about ten minutes. Prefer under
~300 lines (soft). A later step may exist because of this one; this step
must still make sense on its own.

Each step states **what is true when it is done**, not how to make it true.
No new file, folder, function, type, or package names unless this
conversation or an existing `docs/` file already froze them. A typecheck /
test gate is "this step adds no new failures versus the parent commit",
not "the whole repo is green".

**No documentation steps.** Do not add a commit that writes, refreshes, or
"keeps the docs in sync". Do not list docs as **What lands**. Existing
`docs/` are read as source of truth; the implementer must not edit them.
This covers agent memory documents too — `AGENTS.md`, `CLAUDE.md`,
`.cursor/rules/`, `README.md` and any other memory or rules file are never
written, refreshed, or "kept in sync" by a plan step. Documentation is a
later, deliberate pass the user runs; never a side effect of implementing.
Every plan file must say this to the implementing agent, in its
**How to follow this plan** and **Out of scope** sections.
The only markdown this skill writes is the numbered plan files (and a
`.gitignore` line if needed).

A technical choice belongs in **Locked decisions** only if later steps
would be written differently depending on it. Otherwise the implementer
of that step decides.

The **commit** skill invents the git subject from the staged diff. Do not
treat a step's concern line as a string to put in `git log`. Follow records
done-ness with `**Landed:** \`<sha>\`` on the step. Do not write `Landed`
yourself.

## Where it goes

Write under `docs/implementation-plan/` (create it if needed) unless the
user names another directory.

Split the sequence into files of **at most five steps** each:

- `01.md` — steps 1–5
- `02.md` — steps 6–10
- …

Step numbers are global. The last file may have fewer than five. Never put
a sixth step in a file. Never pad with filler.

If that directory already has plan files, ask before replacing them.

Add `docs/implementation-plan/` to the repo's `.gitignore` if it is not
already there. Create `.gitignore` if needed. That is not a plan step.

If you cannot write (ask mode, read-only), emit each file in its own
markdown fence, labelled with the path, and say they still need to be saved.

## Document shape

Read [template.md](template.md) and fill it **once per file**. Keep the
**This window** and **How to follow this plan** sections intact — that is
the protocol the other agent runs. Do not shorten them, and do not add
implementation recipes to them.

Each file is self-contained for one chat: its own locked decisions (those
that apply to its steps), out of scope, commit rules, index table, and
prompts. Do not copy later files' prompts into this one. Point **Previous**
and **Next** at the sibling files.

Index table columns, in this order: **#**, concern, what lands, review
focus. The table in a file lists only that file's steps. **Concern** is a
human label, not a git subject.

Each step's **Prompt** is for the implementing agent. It restates that
step's outcome, the locked decisions that apply, what must already exist,
and what must not be started. It does **not** prescribe design. Point at
**this file** and at `docs/` (skip `docs/plain-english/` and skip other
plan files) rather than dumping the conversation.

## After writing the files — gitignore commit only

If you added or changed the `.gitignore` line:

1. `git add` **only** `.gitignore`.
2. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself.
3. If commit reports nothing staged: add `.gitignore` once more and run
   commit once. If identity/hook fails: STOP and relay that.

Do not stage plan files. They are gitignored. If `.gitignore` did not
change, do not commit.

## After writing — in chat

1. A plain-English walk through **all** steps so the user can reject the
   sequence without reading prompts. Everyday words. Lead with what will
   be true at the end of the whole plan, then one sentence per step.
2. List the files and their step ranges. One `/follow-implementation-plan`
   runs the current file; finished files are deleted; the next file starts
   in a new agent with empty history. They do not name `02.md`.
3. Review is **optional**. If they want a second model on the plan, they
   invoke `review-implementation-plan` themselves, one file per chat,
   **before** follow. This skill does not require review and does not
   start it.
4. This skill does not start step 1.
