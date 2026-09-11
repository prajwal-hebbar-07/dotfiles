# Implementation plan: <product in a few words>

<One short paragraph: what is being built, for whom, and what "done" means for this plan. No architecture. No file names.>

## How to follow this plan

This document is the contract. An implementing agent — possibly a different,
stronger model than the one that wrote it — executes it.

1. Read this whole file. Read every file under `docs/` if that folder exists
   (skip `docs/plain-english/`). Product intent in `docs/product.md` wins
   user-facing conflicts; this plan is the sequence; spec and data-shapes
   win on locked tables and payloads.
2. Implement **only the next unfinished step**, in order. Do not start later
   steps in the same change.
3. You choose how: names, files, libraries, structure — unless a **Locked
   decision** says otherwise. If this plan implies an approach and you have a
   better one that still meets **Done when**, take yours.
4. If a better approach would change later steps, **update this plan first**,
   then continue. Do not silently drift.
5. When the step's **Done when** checks pass, **stop**. The commit subject
   is the message on that step. Do not stage. Do not commit. Do not start
   the next step until that subject exists in git.
6. If a step cannot be finished (missing decision, failing checks, earlier
   step not actually in the tree), **stop**. Do not skip it. Do not start
   the next one.
7. Do not reopen finished steps unless a later step's prompt says to.

Host rules that forbid starting apps, dev servers, or browsers still apply.
**Done when** is checks you can run without that, or an explicit note that the
user will verify.

## Locked decisions

Only decisions that later steps would be written differently without:

- **<name>:** <the decision>. Why: <one line from the conversation>.

If there are none: `None. The implementing agent chooses internals.`

## Out of scope

What this plan will not build, even if it came up in conversation.

## Commit rules

- One concern per commit.
- Reviewable in about ten minutes. Prefer under ~300 lines.
- Typecheck / tests as that step states. An empty or partial workspace must
  still pass whatever that step requires.
- Subject is the conventional-commit message on the step. Do not invent a
  different subject. Body may add pointer bullets for what changed and why.
- Do not start the next step in the same commit.

## Steps

| # | Commit | What lands | Review focus |
| --- | --- | --- | --- |
| 1 | `<type>(<scope>): <imperative summary>` | <observable outcome> | <what a human checks> |

---

### 1. `<type>(<scope>): <imperative summary>`

**What lands:** <observable outcome — capabilities, behaviour, invariants.
Not files.>

**Review focus:** <what a human should try or read to believe it.>

**Depends on:** nothing / step N must already be in the tree.

**Must not start:** step N+1 and later.

**Done when:**

- <checkable outcome>
- <checkable outcome>

**Out of scope:** <the next step, and anything this commit must not grow into.>

**Prompt**

```
Implement only step 1 of docs/implementation-plan.md. Read that file and every
file under docs/ except docs/plain-english/.

Product: <one or two sentences>.

Quote: step 1 — <commit message>. What lands: <verbatim>. Review focus:
<verbatim>.

Locked decisions that apply: <list or "none">.

Already true before you start: <prior steps / current-repo facts. Name
existing paths only if they are already on disk>.

Must be true when you finish: <Done when, verbatim>.

Must not exist yet / must not start: <the next step>.

You choose how. Do not wait for file names, folder layout, or function
names. If you have a better way to reach Done when than anything this plan
implies, take it — unless a Locked decision forbids it. If that would change
later steps, update the plan first.

When Done when passes, stop. The commit subject is:

<type>(<scope>): <imperative summary>

Do not stage. Do not commit. Do not start step 2.
```

Repeat the `### N.` block for every step. Prompts stay in this file; do not
move them into a side document.
