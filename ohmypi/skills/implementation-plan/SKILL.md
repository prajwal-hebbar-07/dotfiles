---
name: implementation-plan
description: >
  Turns a finished architecture conversation into a commit-by-commit
  implementation plan. Each step is an outcome plus a prompt; how to build it
  is left to the implementing agent. Use when the user asks to build the
  implementation plan, "write the plan", "plan the commits", "the conversation
  is done, make the plan", or invokes /implementation-plan.
argument-hint: "[output path]"
---

# Implementation plan

Turn a finished design conversation into **one document** an implementing agent
can follow without this chat. Do **not** implement. Do **not** invent file
names, folder layouts, function names, or libraries that were not locked.

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
- Every file under `docs/` except `docs/plain-english/`
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

A technical choice belongs in **Locked decisions** only if later steps would
be written differently depending on it. Otherwise the implementer of that
step decides.

## Where it goes

Write `docs/implementation-plan.md` (create `docs/` if needed) unless the user
names another path. If that file already exists, ask before overwriting.

If you cannot write (ask mode, read-only), emit the full document in one
markdown fence and say it still needs to be saved.

## Document shape

Read [template.md](template.md) and fill it. Keep the **How to follow this plan**
section intact — that is the protocol the other agent runs. Do not shorten it,
and do not add implementation recipes to it.

Index table columns, in this order: **#**, commit message, what lands, review
focus. `implement-commit-prompt` reads those columns.

Each step's **Prompt** is for the implementing agent. It restates that step's
outcome, the locked decisions that apply, what must already exist, and what
must not be started. It does **not** prescribe design. Point at this plan and
at `docs/` (skip `docs/plain-english/`) rather than dumping the conversation.

## After writing

In the chat (not in the plan file):

1. A plain-English walk through the steps so the user can reject the sequence
   without reading prompts. Everyday words. Lead with what will be true at
   the end of the whole plan, then one sentence per step.
2. Tell them to pass **this plan file** plus the `review-implementation-plan`
   skill to the reviewing agent (often a different model) **before anyone
   codes**. The review skill is generic: it is a `SKILL.md`, not a Cursor
   feature.
3. Execution is `follow-implementation-plan`: one step exactly, stage those
   files, `commit` skill, then the next step. This skill does not start
   step 1.
