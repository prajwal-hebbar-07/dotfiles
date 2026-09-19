---
name: implementation-plan
description: >
  Turns a finished architecture conversation into a commit-by-commit
  implementation plan, split into markdown files of at most five commits.
  Follow deletes each finished file and starts the next on its own. Each
  step is an outcome plus a prompt; how to build it is left to the
  implementing agent. Use when the user asks to build the implementation
  plan, "write the plan", "plan the commits", "the conversation is done,
  make the plan", or invokes /implementation-plan.
argument-hint: "[output directory]"
---

# Implementation plan

Turn a finished design conversation into plan files an implementing agent
can follow without this chat. **At most five commits per file.** Follow
deletes a finished file and starts the next in a **new agent with empty
history** (never the same agent), so the user does not name `02.md` and
one file stays under ~30% of context. Do **not** implement. Do **not** invent file names, folder layouts,
function names, or libraries that were not locked. Do **not** document the
product, and do **not** put documentation work in the plan. The user updates
docs separately (`repo-docs` / `docs-twins`).

The planner and the implementer may be different models. You are the planner.
A later, possibly stronger, model will choose how. Over-specifying how is a
bug in the plan.

## When to start

The user says the architecture conversation is done, or asks for the plan.
If a choice would change **which steps exist**, ask numbered questions and wait.
If a choice only changes **how one step is built**, leave it open.

Do not wait for a recap. This conversation, plus `docs/` and the repo, are the
source.

## Read first

- This conversation: locked decisions, out of scope, "we'll see" items
- Every file under `docs/` except `docs/plain-english/` and except any
  existing files in the plan output directory
- `git log --oneline -20` and a quick look at the tree so steps start from
  what is actually there

If there is no conversation and no `docs/`, ask for architecture notes. Stop.

## What a step is

One git commit. One concern. Reviewable in about ten minutes. Prefer under
~300 lines. A later step may exist because of this one; this step must still
make sense on its own.

Each step states **what is true when it is done**, not how to make it true.
No new file, folder, function, type, or package names unless this conversation
or an existing `docs/` file already froze them. A typecheck/test gate is
"this step adds no new failures versus the parent commit", not "the whole
repo is green".

**No documentation steps.** Do not add a commit that writes, refreshes, or
"keeps the docs in sync". Do not list docs as **What lands**. Existing `docs/`
are read as source of truth for the plan; the implementer must not edit them.
The only markdown this skill writes is the numbered plan files.

A technical choice belongs in **Locked decisions** only if later steps would
be written differently depending on it. Otherwise the implementer of that
step decides.

## Where it goes

Write under `docs/implementation-plan/` (create it if needed) unless the user
names another directory.

Split the sequence into files of **at most five steps** each:

- `01.md` — steps 1–5
- `02.md` — steps 6–10
- …

Step numbers are global. The last file may have fewer than five. Never put a
sixth step in a file. Never pad with filler.

If that directory already has plan files, ask before replacing them.

Add `docs/implementation-plan/` to the repo's `.gitignore` if it is not
already there. Create `.gitignore` if needed. That is not a plan step.

If you cannot write (ask mode, read-only), emit each file in its own markdown
fence, labelled with the path, and say they still need to be saved.

## Document shape

Read [template.md](template.md) and fill it **once per file**. Keep the
**This window** and **How to follow this plan** sections intact — that is the
protocol the other agent runs. Do not shorten them, and do not add
implementation recipes to them.

Each file is self-contained for one chat: its own locked decisions (those
that apply to its steps), out of scope, commit rules, index table, and
prompts. Do not copy later files' prompts into this one. Point **Previous**
and **Next** at the sibling files.

Index table columns, in this order: **#**, commit message, what lands, review
focus. `implement-commit-prompt` reads those columns. The table in a file
lists only that file's steps.

Each step's **Prompt** is for the implementing agent. It restates that step's
outcome, the locked decisions that apply, what must already exist, and what
must not be started. It does **not** prescribe design. Point at **this file**
and at `docs/` (skip `docs/plain-english/` and skip other plan files) rather
than dumping the conversation.

## After writing

In the chat (not in the plan files):

1. A plain-English walk through **all** steps so the user can reject the
   sequence without reading prompts. Everyday words. Lead with what will be
   true at the end of the whole plan, then one sentence per step.
2. List the files and their step ranges. One `/follow-implementation-plan`
   runs them all. Finished files are deleted; the next file starts in a
   new agent with empty history. They do not name `02.md`.
3. Tell them to pass **one plan file** (start with `01.md`) plus the
   `review-implementation-plan` skill to the reviewing agent (often a
   different model) **before anyone codes**. Review the next file in a new
   window. The review skill is generic: it is a `SKILL.md`, not a Cursor
   feature.
4. Execution is `follow-implementation-plan` once: one step exactly, stage
   those files, `commit` skill, next step in that file, delete the file
   when it is done, chain the rest. This skill does not start step 1.
