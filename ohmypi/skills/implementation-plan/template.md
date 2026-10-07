# Implementation plan: <product in a few words>

<One short paragraph: what is being built, for whom, and what "done" means.
Only decisions finalized in the chat that wrote this file. No architecture.
No file names.>

## How this file is followed

This file is the whole plan. There is no second plan file.

An agent implements **one window**, then a new chat with empty history
implements the next. That refresh is automatic. Do not keep going in the
same chat. Do not wait for the user to name the next window.

- A window is at most five commits, marked by an `## Window` heading.
- The current window is the first `## Window` that still has a `### N.`
  step with no `**Landed:**` line.
- Read this file. Implement only the unfinished steps in that window, in
  order. Do not start a later window in this chat.
- When every step in the current window has `**Landed:** \`<sha>\``, start
  the next window in a **new chat with empty history** and stop
  implementing here. Do not delete this file between windows.
- When every window has `**Landed:**`, delete this file. Do not `git add`
  the deletion. The plan is done.
- Do not create another plan file.

## How to follow this plan

This document is the contract. An implementing agent — possibly a different,
stronger model than the one that wrote it — executes it. The agent does not
have the chat that wrote the plan. This file is the source.

1. Read this whole file. Read every file under `docs/` if that folder exists
   (skip `docs/plain-english/` and skip other files in this plan's directory).
   Product intent in `docs/product.md` wins user-facing conflicts with other
   docs; this plan is the sequence; spec and data-shapes win on locked tables
   and payloads. This plan wins over docs where the chat that wrote it
   finalized something else — the locked decisions below are that chat.
2. Implement **only the next unfinished step in the current window**.
   Unfinished = the first `### N.` in that window with no `**Landed:**`
   line. Do not start a later window. Do not start later steps in the same
   change. Do not grep `git log` for a planned subject.
3. You choose how: names, files, libraries, structure — unless a **Locked
   decision** says otherwise. If this plan implies an approach and you have
   a better one that still meets **Done when**, take yours. That how must
   still not touch a markdown document.
4. If a better approach would change a later step, **stop and ask**. Do not
   edit this file to redesign the plan. Do not edit any markdown document.
5. When the step's **Done when** checks pass, `git add` only this step's
   non-markdown files, then run the `commit` skill. Do not pass a subject.
   Do not `git commit` yourself. Do not `git add` any `.md` file, including
   this plan. Do not stop because nothing was staged — add the files and
   commit once more. Then write `**Landed:** \`<sha>\`` on this step (the
   SHA commit reported). That stamp is not part of the commit. It is the
   only edit you may make to this file. Then take the next unfinished step
   **in this window**.
6. If a step cannot be finished (missing decision, **this step added**
   check failures, earlier step not actually in the tree, hook/identity
   failure, mixed index), **stop**. Do not skip it. Do not start the next
   one. A gate that already failed at HEAD, with the same error set, is
   not a stop — continue. Do not leave the plan to fix that baseline.
7. Do not reopen a step that has `**Landed:**` unless a later step's prompt
   says to.
8. Do **not** create, edit, or delete any markdown document. No `docs/`,
   no README, no `AGENTS.md`, no `CLAUDE.md`, no `.cursor/rules/`, no
   changelog, no ADR, no other `.md` file. Not one line. Not "while you
   are in there". Not because a change made a document stale. The user
   does that separately. Read `docs/` as needed; leave the files as they
   are. The only write allowed in this file is the `**Landed:**` stamp
   after a commit.
9. When every step in the current window has `**Landed:**`, start a **new
   chat with empty history** on this same file and stop implementing here.
   Do not continue the next window in this chat. If no window remains,
   delete this file, do not `git add` the deletion, and stop.

Host rules that forbid starting apps, dev servers, or browsers still apply.
**Done when** is checks you can run without that, or an explicit note that
the user will verify.

## Locked decisions

Only decisions finalized in the chat that wrote this plan, and only ones
later commits would be written differently without. Copy the ones that
apply:

- **<name>:** <the decision>. Why: <one line from that chat>.

If there are none: `None. The implementing agent chooses internals.`

## Out of scope

What this plan will not build, even if it came up in the chat.
Markdown is always out of scope: no architecture pages, no plain-English,
no README, no changelog, no ADR, and no agent memory documents
(`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`). No commit creates, edits, or
deletes a markdown document. The user does that separately, deliberately.
Later windows are out of scope until a new chat starts them.

## Commit rules

- One concern per commit.
- Reviewable in about ten minutes. Prefer under ~300 lines.
- At most five commits per window, then a new chat.
- Typecheck / tests as that commit states: this commit must not **add**
  failures versus the parent commit. A command that is already red at HEAD
  is not a reason to stop.
- The **commit** skill writes the git message from the staged diff. Do not
  pass a subject. Do not invent a git subject for follow to grep.
- Do not start the next step in the same commit.
- Do not start the next window in the same chat.
- This commit does not create, edit, or delete any markdown document. The
  git commit contains no `.md` file.
- Do not wait for the user to name the next window.

## Window 1

Steps 1–5, or fewer if the whole plan is shorter. This chat stops when
every step below has `**Landed:**`.

| # | Concern | What lands | Review focus |
| --- | --- | --- | --- |
| 1 | <short human label of the concern> | <observable outcome> | <what a human checks> |

### 1. <short human label of the concern>

**What lands:** <observable outcome — capabilities, behaviour, invariants.
Not files. Not a markdown document.>

**Review focus:** <what a human should try or read to believe it.>

**Depends on:** nothing / step N must already be in the tree.

**Must not start:** step N+1 and later, including the next window.

**Markdown:** This commit does not create, edit, or delete any markdown document.

**Done when:**

- <checkable outcome>
- <checkable outcome>
- This commit does not create, edit, or delete any markdown document.

**Out of scope:** <the next step, the next window, and anything this commit must not grow into. Markdown documents, always.>

**Prompt**

```
Implement only step 1 of docs/implementation-plan/plan.md (Window 1). Read
that file. Read every file under docs/ except docs/plain-english/ and except
other files in docs/implementation-plan/. Do not implement a later window.

Product: <one or two sentences from the chat that finalized this plan>.

Quote: step 1 — <concern>. What lands: <verbatim>. Review focus:
<verbatim>.

Locked decisions that apply: <list or "none">. These were finalized in the
chat that wrote the plan. Do not expand scope past them.

Already true before you start: <prior steps / current-repo facts. Name
existing paths only if they are already on disk>.

Must be true when you finish: <Done when, verbatim>.

Must not exist yet / must not start: <the next step and the next window>.

This commit does not create, edit, or delete any markdown document.

You choose how. Do not wait for file names, folder layout, or function
names. If you have a better way to reach Done when than anything this plan
implies, take it — unless a Locked decision forbids it. If that would change
a later step, stop and ask. Do not edit this plan and do not edit any
markdown document.

When Done when passes, git add only the non-markdown files this step
changed, then run the commit skill. Do not pass a subject. Do not git
commit yourself. Do not git add any .md file. After commit returns a SHA,
write **Landed:** `<sha>` on this step. That stamp is not part of the
commit. Do not start the next step in the same uncommitted change. Do not
start the next window in this chat. If this was the last step in this
window, start a new chat with empty history on this same file and stop
implementing here.
```

Repeat the `### N.` block for every commit **in this window** (at most
five). Each block carries the same **Markdown** line, the same **Done
when** markdown check, and the same sentence inside **Prompt**. Do not
move prompts out of this file.

## Window 2

Steps 6–10. Omit this heading when the plan fits in Window 1.

Same table and `### N.` blocks. Numbers continue (6, not 1). The prompt
says Window 2 and forbids Window 3. Add further windows the same way.
Never put a sixth commit in a window. Never start another plan file.
