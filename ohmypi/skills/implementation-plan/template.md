# Implementation plan: <product in a few words>

Part N of M. Steps A–B.

<One short paragraph: what is being built, for whom, and what "done" means for this plan. No architecture. No file names.>

## This window

This file is at most five commits. It is the whole plan for this agent.

- Read this file. Do not read other files in `docs/implementation-plan/`
  (or the same directory as this file).
- When every step in this file has `**Landed:** \`<sha>\``, **delete this
  file**. Do not `git add` the deletion.
- If another part remains, start it in a **new agent with empty
  history**. Do not continue that file in this agent.
- Previous: <path or none>
- Next: <path or none>

## How to follow this plan

This document is the contract. An implementing agent — possibly a different,
stronger model than the one that wrote it — executes it.

1. Read this whole file. Read every file under `docs/` if that folder exists
   (skip `docs/plain-english/` and skip other files in this plan's directory).
   Product intent in `docs/product.md` wins user-facing conflicts; this plan
   is the sequence; spec and data-shapes win on locked tables and payloads.
2. Implement **only the next unfinished step**, in order. Unfinished = the
   first `### N.` with no `**Landed:**` line. Do not start later steps in
   the same change. Do not grep `git log` for a planned subject.
3. You choose how: names, files, libraries, structure — unless a **Locked
   decision** says otherwise. If this plan implies an approach and you have
   a better one that still meets **Done when**, take yours.
4. If a better approach would change later steps **in this file**, update
   this plan first, then continue. If it would change a later file, **stop
   and ask**. Do not silently drift. Do not read other plan files.
5. When the step's **Done when** checks pass, `git add` only this step's
   files, then run the `commit` skill. Do not pass a subject. Do not
   `git commit` yourself. Do not stop because nothing was staged — add the
   files and commit once more. Then write `**Landed:** \`<sha>\`` on this
   step (the SHA commit reported). Then take the next unfinished step
   **in this file**.
6. If a step cannot be finished (missing decision, **this step added**
   check failures, earlier step not actually in the tree, hook/identity
   failure, mixed index), **stop**. Do not skip it. Do not start the next
   one. A gate that already failed at HEAD, with the same error set, is
   not a stop — continue. Do not leave the plan to fix that baseline.
7. Do not reopen a step that has `**Landed:**` unless a later step's prompt
   says to.
8. Do **not** write, refresh, or edit documentation — `docs/architecture/`,
   `docs/plain-english/`, area docs, README docs, or "update the twins".
   Agent memory documents are documentation too: never touch `AGENTS.md`,
   `CLAUDE.md`, `.cursor/rules/`, `README.md`, or any other memory or rules
   file, not even one line, not even "while you are in there".
   The user does that separately. Read `docs/` as needed; leave the files
   as they are. The plan files themselves are not in scope for the
   implementer except as this protocol says to update them on drift, and
   to stamp `Landed`.
9. When every step in this file has `**Landed:**`, **delete this file**.
   Do not `git add` the deletion. If another part remains, start a **new
   agent with empty history** and stop implementing here. Do not continue
   the next file in this agent. If none remain, stop. The plan is done.

Host rules that forbid starting apps, dev servers, or browsers still apply.
**Done when** is checks you can run without that, or an explicit note that
the user will verify.

## Locked decisions

Only decisions that later steps would be written differently without.
Copy into this file the ones that apply to **these** steps:

- **<name>:** <the decision>. Why: <one line from the conversation>.

If there are none: `None. The implementing agent chooses internals.`

## Out of scope

What this plan will not build, even if it came up in conversation.
Documentation is always out of scope: no architecture twins, no
plain-English, no README docs, and no agent memory documents (`AGENTS.md`,
`CLAUDE.md`, `.cursor/rules/`). The user does that separately, deliberately.
Later parts of this plan are out of scope until this file is deleted.

## Commit rules

- One concern per commit.
- Reviewable in about ten minutes. Prefer under ~300 lines.
- Typecheck / tests as that step states: this step must not **add**
  failures versus the parent commit. A command that is already red at HEAD
  is not a reason to stop.
- The **commit** skill writes the git message from the staged diff. Do not
  pass a subject. Do not invent a git subject for follow to grep.
- Do not start the next step in the same commit.
- Do not touch documentation, including `AGENTS.md`, `CLAUDE.md`, and other
  memory or rules files. Docs are a later, separate pass.
- Do not wait for the user to name the next part.

## Steps

| # | Concern | What lands | Review focus |
| --- | --- | --- | --- |
| 1 | <short human label of the concern> | <observable outcome> | <what a human checks> |

---

### 1. <short human label of the concern>

**What lands:** <observable outcome — capabilities, behaviour, invariants.
Not files.>

**Review focus:** <what a human should try or read to believe it.>

**Depends on:** nothing / step N must already be in the tree.

**Must not start:** step N+1 and later (including later parts).

**Done when:**

- <checkable outcome>
- <checkable outcome>

**Out of scope:** <the next step, and anything this commit must not grow into.>

**Prompt**

```
Implement only step 1 of docs/implementation-plan/01.md. Read that file and
every file under docs/ except docs/plain-english/ and except other files in
docs/implementation-plan/.

Product: <one or two sentences>.

Quote: step 1 — <concern>. What lands: <verbatim>. Review focus:
<verbatim>.

Locked decisions that apply: <list or "none">.

Already true before you start: <prior steps / current-repo facts. Name
existing paths only if they are already on disk>.

Must be true when you finish: <Done when, verbatim>.

Must not exist yet / must not start: <the next step>.

You choose how. Do not wait for file names, folder layout, or function
names. If you have a better way to reach Done when than anything this plan
implies, take it — unless a Locked decision forbids it. If that would change
later steps in this file, update this plan first. If it would change a
later file, stop and ask.

When Done when passes, git add only the files this step changed, then run
the commit skill. Do not pass a subject. Do not git commit yourself. After
commit returns a SHA, write **Landed:** `<sha>` on this step. That is how
the step is done. Do not start step 2 in the same uncommitted change. Do
not write or update documentation of any kind — docs/, README, AGENTS.md,
CLAUDE.md, .cursor/rules — the user does that separately. If this
was the last step in this file, delete this file, start a new agent with
empty history on the remaining plan files, and stop implementing here.
```

Repeat the `### N.` block for every step **in this file** (at most five).
Prompts stay in this file; do not move them into a side document. Further
steps go in the next numbered file. Numbers stay global (file `02.md`
starts at step 6, not 1).
