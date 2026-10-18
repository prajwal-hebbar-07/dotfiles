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
   a better one that still meets **Done when**, take yours. That how may
   update existing architecture pages this step makes stale, and may create
   or update the markdown documents this step names.
4. If a better approach would change a later step, **stop and ask**. Do not
   edit this file to redesign the plan. Do not edit a markdown document
   this step does not name, other than an existing architecture page it
   makes stale.
5. When the step's **Done when** checks pass, `git add` this step's code
   and tests, any existing `docs/architecture` pages it updated, and any
   markdown document this step names — or, for a step with **Kind:** docs,
   the markdown documents it created or updated — then run the `commit`
   skill. Do not pass a subject. Do not `git commit` yourself. Do not
   `git add` this plan or a markdown file this step does not name. Do not
   stop because nothing was staged — add the files and commit once more.
   Then write `**Landed:** \`<sha>\`` on this step (the SHA commit
   reported). That stamp is not part of the commit. It is the only edit
   you may make to this file. Then take the next unfinished step **in this
   window**.
6. If a step cannot be finished (missing decision, **this step added**
   check failures, earlier step not actually in the tree, hook/identity
   failure, mixed index), **stop**. Do not skip it. Do not start the next
   one. A gate that already failed at HEAD, with the same error set, is
   not a stop — continue. Do not leave the plan to fix that baseline.
7. Do not reopen a step that has `**Landed:**` unless a later step's prompt
   says to.
8. Update existing architecture pages this step makes stale, in the same
   commit, when `docs/README.md` has `architecture: on` (or the pin is
   absent and those pages already exist). Create or update every other
   markdown document this step names, in that same commit. Do not create,
   edit, or delete a markdown document this step does not name. Do not
   stamp `docs-baseline:` unless the step says so. The only write allowed
   in this plan file is the `**Landed:**` stamp after a commit.

   A step with **Kind:** docs follows the docs-commit rule instead: it
   creates or updates the markdown documents it names, where its decisions
   or findings make them stale, keeping them consistent and following the
   repo's own documentation conventions. It touches no code or tests and
   does not edit the plan directory. A throwaway experiment the step asks
   for lives outside the repository and is never staged. An issue-tracker
   update the step asks for happens after its commit.
9. When every step in the current window has `**Landed:**`, start a **new
   chat with empty history** on this same file and stop implementing here.
   Do not continue the next window in this chat. If no window remains,
   delete this file, do not `git add` the deletion, and stop.

Host rules that forbid starting apps, dev servers, or browsers still apply.
For a code step, code-level tests are required: write them and run them
for this step. A docs step adds no code-level tests; its **Done when**
checks that the documents agree. A docs step may start the local services
its throwaway experiment needs only when the step says so; if the host
forbids it, stop and ask. **Done when** does not require a manual pass or
a UI test. The user does that.

## Locked decisions

Only decisions finalized in the chat that wrote this plan, and only ones
later commits would be written differently without. Copy the ones that
apply:

- **<name>:** <the decision>. Why: <one line from that chat>.

If there are none: `None. The implementing agent chooses internals.`

## Out of scope

What this plan will not build, even if it came up in the chat.
A commit creates or updates a markdown document only when that step names
it. Existing architecture pages that a commit makes stale are updated in
that same commit. Later windows are out of scope until a new chat starts
them.

## Commit rules

- One concern per commit.
- Reviewable in about ten minutes. Prefer under ~300 lines.
- At most five commits per window, then a new chat.
- Typecheck / tests as that commit states: this commit must not **add**
  failures versus the parent commit. A command that is already red at HEAD
  is not a reason to stop.
- Each code commit adds or updates code-level tests for a sanity check and
  for the functionality it changes, and those tests are run. Each docs
  commit is checked by the documents it touches agreeing with the decision
  and with each other. No commit asks for a manual pass or a UI test.
- The **commit** skill writes the git message from the staged diff. Do not
  pass a subject. Do not invent a git subject for follow to grep.
- Do not start the next step in the same commit.
- Do not start the next window in the same chat.
- A code commit updates the existing architecture pages it makes stale,
  and creates or updates only the markdown documents that step names.
- A docs commit creates or updates only the markdown documents that step
  names, and touches no code. Nothing from a throwaway experiment is
  committed.
- Do not wait for the user to name the next window.

## Window 1

Steps 1–5, or fewer if the whole plan is shorter. This chat stops when
every step below has `**Landed:**`.

| # | Concern | What lands | Review focus |
| --- | --- | --- | --- |
| 1 | <short human label of the concern> | <observable outcome> | <what a human checks> |

### 1. <short human label of the concern>

**What lands:** <observable outcome — capabilities, behaviour, invariants.
Not files. Existing architecture pages that describe it are true.>

**Review focus:** <what a human should try or read to believe it.>

**Depends on:** nothing / step N must already be in the tree.

**Must not start:** step N+1 and later, including the next window.

**Kind:** code

**Markdown:** This commit updates the existing architecture pages it makes stale, and creates or updates only the markdown documents this step names.

**Tests:** This commit adds or updates code-level tests for the behaviour it changes and runs them. Manual testing and UI testing are left to the user.

**Done when:**

- <checkable outcome>
- <checkable outcome>
- This commit updates the existing architecture pages it makes stale, and creates or updates only the markdown documents this step names.
- This commit adds or updates code-level tests for the behaviour it changes and runs them. Manual testing and UI testing are left to the user.

**Out of scope:** <the next step, the next window, and anything this commit must not grow into. Markdown documents this step does not name.>

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

This commit updates the existing architecture pages it makes stale, and creates or updates only the markdown documents this step names.

This commit adds or updates code-level tests for the behaviour it changes and runs them. Manual testing and UI testing are left to the user.

You choose how. Do not wait for file names, folder layout, or function
names. If you have a better way to reach Done when than anything this plan
implies, take it — unless a Locked decision forbids it. If that would change
a later step, stop and ask. Do not edit this plan. Create or update the
markdown documents this step names. Do not edit a markdown document this
step does not name, other than an existing architecture page it makes stale.

When Done when passes, git add this step's code and tests, any existing
docs/architecture pages it updated, and any markdown document this step
names, then
run the commit skill. Do not pass a subject. Do not git commit yourself.
Do not git add this plan or a markdown file this step does not name. After commit returns a SHA,
write **Landed:** `<sha>` on this step. That stamp is not part of the
commit. Do not start the next step in the same uncommitted change. Do not
start the next window in this chat. If this was the last step in this
window, start a new chat with empty history on this same file and stop
implementing here.
```

**Docs commit variant.** A step with **Kind:** docs uses the same block
with these differences:

- **What lands:** the decisions or findings now recorded, and which
  documents now state them. For an experiment: what was tested and that
  the finding is written down.
- **Markdown:** This docs commit creates or updates only the markdown documents this step names, and touches no code.
- **Tests:** This docs commit changes no code, so it adds no code-level tests; it is checked by every document it touches agreeing with the decision and with each other.
- **Done when:** consistency checks (where each decision now appears; no
  document still contradicts it; answered questions marked answered and
  removed from the open list), plus both sentences above verbatim. For an
  experiment: the check actually ran, the finding records version, what
  was tried and what was observed, nothing from it is staged, and (in the
  step the plan names) it is deleted.
- **Prompt:** says Kind: docs, carries both sentences above instead of the
  code-commit sentences, and tells the implementer to `git add` only the
  documents the step changed. If the step updates an issue tracker, the
  prompt names the items and says to do it after the commit.

Repeat the `### N.` block for every commit **in this window** (at most
five). Each block carries the **Kind** line, the **Markdown** and
**Tests** lines for its kind, the same **Done when** checks for both, and
both sentences inside **Prompt**. Do not move prompts out of this file.

## Window 2

Steps 6–10. Omit this heading when the plan fits in Window 1.

Same table and `### N.` blocks. Numbers continue (6, not 1). The prompt
says Window 2 and forbids Window 3. Add further windows the same way.
Never put a sixth commit in a window. Never start another plan file.
