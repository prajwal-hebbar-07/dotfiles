---
name: follow-implementation-plan
description: >
  Implements the next unfinished window of an implementation plan as code,
  at most five commits. Stages only that step's non-markdown files, commits
  through the commit skill (no subject), stamps Landed:<sha> on the step,
  then continues in the same window. When the window is done, starts the
  next window in a new chat with empty history. Use only when the user
  explicitly asks to implement, execute, or follow the plan as code,
  "implement this doc", "next step", or /follow-implementation-plan. Do not
  use when the user asks to review, write, update, or look at the plan.
argument-hint: "[path to plan file or directory]"
---

# Follow implementation plan

Follow **every step exactly**, in order. The plan is the contract. One
invoke runs the current window only: at most five commits. You do not wait
for the user to name the next window. When the window is done, a new chat
starts automatically.

## This turn must be an implement ask

This skill runs only when **this message** asks to implement, execute,
follow the plan as code, do the next step, or names
`/follow-implementation-plan`.

It does **not** run because:

- this chat earlier reviewed or wrote the plan
- the plan is marked ready
- you are already looking at a plan file

If this message is a review, a plan write, or "look at the plan": **do not
implement**. Do not touch application code.

If one message asks to review **and** implement: review only, then stop.
Wait for a later message that asks to implement.

## Find the plan

Explicit path wins. A `.md` file is the plan. A directory means `plan.md`
in that directory.

Else `docs/implementation-plan/plan.md`.

If that file is missing and numbered `NN.md` files are there, those are an
older plan. Treat the first file that still has a step with no
`**Landed:**` as the current window. When that file is done, delete it (do
not `git add` the deletion) and start the next file in a new chat. Do not
merge them into `plan.md` while implementing.

If nothing is there, ask. Stop.

Read **the plan file**. On `plan.md`, the current window is the first
`## Window` that still has a `### N.` step with no `**Landed:**` line.
Implement only that window. Do not start the next `## Window` in this chat.

Also read every file under `docs/` except `docs/plain-english/` and except
other files in the plan directory. Read them. Do not edit them.

## Never touch markdown

Implementing a step never creates, edits, or deletes a markdown document.
That includes `docs/` of every kind, README files, changelogs, ADRs, and
agent memory documents — `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, and
any other `.md` file. Not a line, not a "while I am here", not because a
step's change makes a document stale. Docs are a later, deliberate pass
the user runs.

The git commit contains no `.md` file. Do not `git add` one.

The only write allowed on the plan file is `**Landed:** \`<sha>\`` on the
step you just committed. That stamp is not part of the commit. Do not
redesign the plan. Do not stage the plan file.

If a step's plan text asks for a markdown edit, skip that part, say so in
one line, and continue. If you already changed a markdown file other than
the `**Landed:**` stamp, restore that file before you commit and say so.
Do not restore a markdown file that was already dirty when you started.

## Find the next step

The next step is the first `### N.` **in the current window** with no
`**Landed:** \`<sha>\`` line. Do not grep `git log` for a planned subject.
The **commit** skill invents the git message from the staged diff.

If the current window contains more than five steps, **stop**. Say so. Do
not implement a sixth.

If an earlier step's work is not in the tree — including an earlier
window's last step — stop. Do not skip it. Do not start a later one.

## Implement that step only

Use that step's **Prompt**, **Done when**, **Must not start**, and any
**Locked decisions** that apply. Follow them exactly: do not drop an
outcome, do not add the next step, do not reorder.

You choose how. The how must not touch a markdown document. If a better
how would change a later step, **stop and ask**. Do not edit the plan to
redesign it. Do not silently drift.

## Gates

A named typecheck / lint / test command is a gate on **this step**, not on
the whole repo.

- If it already fails at the parent commit (HEAD before this step's files),
  that is not a stop. Prove it: same command, same error set with this
  step stashed or compared. Unchanged set → the gate is met. Continue.
- Stop only if **this step added** failures.
- Do not pause the plan to fix unrelated baseline errors. Do not open a
  commit outside this plan for that. Do not ask the user to choose "fix
  baseline first" versus "continue" — continue.
- Host rules that forbid a build or dev suite still apply. If the plan
  names a command you must not run, skip it, say so in one line, and
  continue. That is not a stop.

## Stage, commit, stamp, continue

When **Done when** passes, the step is not finished until its commit
exists and `**Landed:**` is on the step. Do not stop because commit could
not run.

1. `git add` **only** the non-markdown files this step created or changed.
   Leave unrelated dirty files unstaged. Do not stage any `.md` file. Do
   not stage the plan. Do not `git add -A`.
2. If the index already contains files this step did not change: **stop**.
   Relay that. Do not unstage the user's other work. Do not commit a mixed
   index. Do not start the next step.
3. If the index contains a markdown file: **stop**. Relay that. Do not
   commit it.
4. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself. Do not draft the message.
5. If commit reports nothing staged: you failed to add. Add this step's
   non-markdown files and run commit **once** more. That is not a reason to
   end the plan. If it is still empty after that, stop and relay.
6. If identity is missing or a pre-commit hook fails: **stop**. Relay that.
   Do not start the next step. Do not `--no-verify`.
7. When commit returns a SHA, write `**Landed:** \`<sha>\`` on this step
   in the plan file (next to the step heading, not in git). Emit the step
   report (below), then take the **next** unfinished step **in this
   window**. Keep going until this window is done or a step cannot finish.
8. When every step in this window has `**Landed:**`, **chain** (below). Do
   not ask the user to start the next window. Do not delete `plan.md`
   between windows. On an older `NN.md` plan, delete that finished file
   instead (do not `git add` the deletion), then chain. If the plan
   directory is empty after that deletion, remove it.

## Chain the next window

After the current window is done:

- If no unfinished window remains: delete `plan.md` if it is still there.
  Do not `git add` the deletion. If the plan directory is empty, remove
  it. Stop. The plan is done.
- If a later window remains: you **must** start a **new chat**. This
  chat's context already holds this window's work. Continuing here fills
  the window. That is a bug.

How to start it — same prompt on every host, empty history, then this
agent stops implementing:

Prompt (implement ask, nothing else — no diffs, no reports, no this chat):

Follow the implementation plan. This message is an implement ask.
Read the follow-implementation-plan skill and execute the next window
of docs/implementation-plan/plan.md. This chat has empty history. Do
not wait for the user. Stop after that window and start another new
chat if a further window remains.

On an older `NN.md` plan, name the plan directory instead of `plan.md`.

- **Cursor:** new Task / subagent, `generalPurpose`, background. Do not
  resume. Do not self-fork.
- **Oh My Pi (omp):** `task` tool, agent `task` (never `planner` or
  `hand`). Batch: a one-line `context` ("Empty history. Follow the next
  window of the implementation plan.") plus one item with that prompt as
  `task`. Do **not** set `isolated` — commits must land in this repo.
  Child sessions do not inherit this conversation.

Then **stop implementing in this agent**. One line in the report: next
window started in a new chat. Do not take the next window's first step.

If you cannot start a new chat (`task` missing, recursion cap, unknown
host): **stop**. Name the next window. Do **not** continue it here.

## Report

After every step — committed or blocked — emit one report in this shape.
Do not write `docs/reports/`. Chat only.

```
<one-line status: Step N implemented and committed | implemented, commit blocked | stopped — <reason>>

**Step N** — <concern> — committed `<sha>` (`<file count>` files)
(If not committed: say **not committed**. Drop SHA and file count.)

| Done when | State |
| --- | --- |
| <outcome from the plan, verbatim> | <what is true now, in this tree> |

**Changed**
- <what this step actually did — outcomes or existing paths only>

**Left unstaged**
- <paths this step did not own, or `none`>

**Markdown**
- no markdown document created, edited, or deleted

**Verification**
- <commands you ran, and the result>
- Gate vs parent: <unchanged error set → met | this step added N | skipped, host rule>

**Next**
Step N+1 — <concern>. Or: stopped — <identity | hook | mixed index | markdown in the index | this step added failures>.
Or: next window started in a new chat. Or: plan done.
```

Unknown cells say "unknown". No "your call". A report is not permission to
skip the next step. If the **Markdown** line is not true, the step is not
done: restore the markdown, say so, and do not stamp `**Landed:**`.

## Never

- Skip, merge, or reorder steps
- Several steps in one uncommitted change
- More than the current window (five commits) in this chat
- `git commit` yourself while the `commit` skill can run
- Pass a subject to commit
- Grep `git log` for a planned subject to decide if a step landed
- Stop the plan because nothing was staged (retry add + commit once)
- Commit when the index already holds files this step did not change
- Commit a markdown file
- Unstage the user's other work
- Stop the plan because a gate was already red at HEAD
- Pause to fix baseline errors that this step did not add
- Rewrite the plan while implementing, except the `**Landed:**` stamp
- Implement because a review in this chat just finished
- Create, edit, or delete a markdown document (`docs/`, README,
  changelog, ADR, `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, any other
  `.md`)
- Wait for the user to name the next window
- Stage or commit the plan file
- Continue the next window in this same chat
- Resume or self-fork this conversation into the next window
- Pass this chat's history, diffs, or a finished window into the next chat
- Use omp `planner` or `hand` for the chain
- Spawn the next window `isolated` on omp
