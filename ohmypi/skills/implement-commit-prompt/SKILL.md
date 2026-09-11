---
name: implement-commit-prompt
description: >
  Builds a copy-pastable prompt to implement one commit from the repo's
  implementation plan, using every file in docs/ as context. Asks blocking
  questions first, then regenerates the prompt after answers. Leads with a
  plain-English summary (no jargon) so the user can decide quickly without
  reading the technical prompt. Use when the user asks for a prompt to
  implement a commit, "copy pastable prompt", "implement commit N", names a
  conventional commit from the plan (e.g. chore: add typecheck and test
  scripts), or invokes /implement-commit-prompt.
argument-hint: "[commit number or message]"
---

# Implement-commit prompt

Do **not** implement the commit. Produce a prompt another chat can paste, plus
human explanations the user can skim without re-reading every technical term.

## Resolve the commit

The focused commit is, in order:

1. Whatever the user named (number, `feat(…)`, or the message text).
2. Else a branch / chat title that matches a plan row.
3. Else ask which commit — do not guess.

Find `docs/` at the repo root. If it is missing, ask where it lives. Stop.

Read **every** file under `docs/` — markdown, nested dirs, fixtures. Skip
`docs/plain-english/` entirely. Do not wait for the commit row to mention a
file. The implementation plan is the sequence; the rest of `docs/` is the
product, spec, and shape context the prompt must absorb.

Find the plan (first hit): `docs/implementation-plan.md`, `implementation-plan.md`, `docs/plan.md`. If the plan is outside `docs/`, read it in addition to the folder.

If the plan is missing, ask where it lives. Stop.

Pull the matching table row: **#**, commit message, what lands, review focus. Read the surrounding phase, locked decisions, commit rules, and the rows immediately before and after (those are out of scope).

If that step already has a **Prompt** fenced block, that fence **is** the
copy-paste. Do not rewrite it. Add current-repo facts and the user's answers
only if they are missing from it. This skill extracts one step into a fresh
chat. It does not implement, and it does not commit. Whole-plan execution is
`follow-implementation-plan`.

## Inspect the repo (read only)

- `git log --oneline -20` — which plan commits already landed.
- `git status` and a quick look at what already exists (so the prompt can state current-repo facts).
- Prior commit in the plan: is its work actually present? If not, that is blocking.

Do not edit files. Do not run the implementation.
Do not invent the files, folders, or function names the implementing chat should create — that chat chooses them.

## Questions vs prompt

**Blocking** (ask these, do not emit the copy-paste block yet):

- Which commit is unclear.
- This commit depends on earlier plan work that is not in the tree.
- Docs disagree on something this commit needs (product vs spec vs plan vs data-shapes).
- A tooling/shape choice the docs leave open and that would change the prompt (test runner, CI yes/no, etc.). Do not treat new file names or folder layout as a question — the implementing chat chooses those.

List numbered questions. Tell the user to answer them, then you will regenerate the prompt.

**Non-blocking:** pick the plan's default (or the repo's existing tool), state the assumption in the explanation, and still emit the prompt.

When the user answers, regenerate all three output sections. Do not make them
re-state the commit.

## Output

Always **three** parts, in this order. The user should be able to read only
section 1 and know whether to paste section 3.

### 1. Plain English

A quick read for someone who already knows the project but does **not** want
to decode jargon on every commit. Write like you're telling a colleague what
this step is for — not like you're writing the AI prompt.

**Tone and rules:**

- Short sentences. Everyday words. No bullet soup unless it genuinely helps.
- Lead with the outcome: *when this is done, you will be able to…*
- Say what the other chat will **do**, **leave alone**, and **not start yet**
  — as actions, not as files to add.
- Avoid or gloss jargon. If a term is unavoidable, explain it once in
  parentheses and move on (e.g. "typecheck (make sure the code has no type
  errors)"). Do not assume the reader remembers pnpm flags, tsconfig fields,
  or package layout from earlier commits.
- Name the commit once (# and message), then mostly use plain descriptions.
- One short paragraph on *why this step exists* in the build order.
- One short paragraph on *what comes next* so they know they're not skipping
  ahead.
- Optional: a single "You'll know it worked when…" line with concrete checks
  (commands that should succeed, things that should still be missing).

**Do not** repeat the copy-paste block. **Do not** dump locked decisions or
fixture field mappings here — those belong in section 3 for the implementing
chat.

### 2. What's in the prompt

Slightly more precise summary for when the user wants detail without reading
the full prompt. Still human-facing; still no fenced prompt. Cover:

- Which commit (# and message) and what "done" means.
- Why this commit exists (one sentence from the docs).
- In scope / out of scope (especially the next commit).
- Assumptions you made.

Do **not** list files the other chat will likely add or change, or suggest names
for new files, folders, functions, or configs. The implementing chat chooses
those. Existing-repo facts belong in section 3.

Technical terms are fine here — the user opts into this section.

### 3. Copy-paste

One fenced markdown block. Nothing before or after inside the fence except the prompt itself. The prompt is for another AI. It must:

- Name the product in one or two sentences from the docs.
- Quote the plan row verbatim (number, message, what lands, review focus).
- Fold in the facts from **every** `docs/` file this commit needs except `docs/plain-english/` (product, spec, data-shapes, fixtures, …). Not a dump of the folder — enough locked decisions, shapes, and examples that the other chat does not have to rediscover them.
- Say **implement only this commit**. Do not start the next row. Do not expand scope.
- Include locked decisions and commit rules that apply to this row.
- Name prior commits that must already exist, and next commits that must not be done.
- Include relevant current-repo facts (what is already on disk). Name existing
  paths only when they are already in the tree or are docs the chat must read.
- Include the user's answers to questions.
- Require the change to typecheck / tests as the plan states (empty workspace still passes, one concern, reviewable in ~10 minutes, under ~300 lines when possible).
- Forbid committing unless the user of that chat asks.
- Point at `docs/` as the source of truth (skip `docs/plain-english/`). Product intent in `docs/product.md` wins user-facing conflicts; the plan is the sequence; spec and data-shapes win on locked tables and payloads.

**Leave design of the change to the implementing chat.** The prompt says what
must exist when the commit is done, and what must not be started. It does **not**
prescribe:

- Names for new files, folders, or packages (unless the plan already named them)
- Function, type, or export names to add (unless quoting a type the plan already froze)
- Where to put tests or configs
- A “likely files” / “files you will change” list

Tell that chat to choose layout and names itself, matching what is already in
the repo. Keep `docs/` pointers, skip `docs/plain-english/`, and keep the in-scope
/ out-of-scope and next-commit fences.

If the plan step already contained a Prompt fence, emit that fence (plus any
missing current-repo facts or answers). Do not produce a second, competing
prompt.

## Example trigger

User: `Give me a copy pastable prompt to implement chore: add typecheck and test scripts`

→ Resolve to commit 3 in this repo's plan after reading all of `docs/`. Ask only if the test runner or CI choice is actually open and would change the work. Otherwise emit all three sections. Plain English might say: "We're adding two commands you can run from the project root — one to check types, one to run tests. Right now there's no app code yet, so both should succeed immediately and do almost nothing. We're not setting up GitHub automation or picking a test framework yet; that waits until there's code to test." Section 2 states done / in-scope / out-of-scope without guessing file names. Section 3 is the full implementing prompt.
