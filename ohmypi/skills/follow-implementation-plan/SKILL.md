---
name: follow-implementation-plan
description: >
  Implements the next unfinished step of an implementation plan as code,
  stages only that step's files, commits through the commit skill (no
  subject), stamps Landed:<sha> on the step, then continues in this file.
  When every step in the file has Landed, deletes that file and starts the
  next remaining file in a new agent with empty history. Use only when the
  user explicitly asks to implement, execute, or follow the plan as code,
  "implement this doc", "next step", or /follow-implementation-plan. Do not
  use when the user asks to review, write, update, or look at the plan.
argument-hint: "[path to plan file or directory]"
---

# Follow implementation plan

Follow **every step exactly**, in order. The plan is the contract. One
invoke runs every remaining step **in the current file**. You do not wait
for the user to name the next file.

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

Explicit path wins: a `.md` file is the current file; a directory means
the numbered `NN.md` files in it.

Else `docs/implementation-plan/` numbered `NN.md` files, sorted.
If missing, ask. Stop. Do not search legacy single-file plan paths.

The current file is the first of those files that still has a step with
no `**Landed:**` line. Read **that file only**.

Also read every file under `docs/` except `docs/plain-english/` and except
other files in the plan directory.

## Never touch documentation

Implementing a step never writes, refreshes, or edits documentation. That
includes `docs/` of every kind, README files, and agent memory documents —
`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, and any other memory or rules
file. Not a line, not a "while I am here", not because a step's change
makes a doc stale. Docs are a later, deliberate pass the user runs.

Read them as source of truth; leave them exactly as they are. If a step's
plan text asks for a documentation edit, skip that part, say so in one
line, and continue. The only files this skill edits outside the step's
code are the current plan file, to stamp `**Landed:**` or record drift.

## Find the next step

The next step is the first `### N.` in **this file** with no
`**Landed:** \`<sha>\`` line. Do not grep `git log` for a planned subject.
The **commit** skill invents the git message from the staged diff.

If an earlier step's work is not in the tree — including a previous file's
last step — stop. Do not skip it. Do not start a later one.

## Implement that step only

Use that step's **Prompt**, **Done when**, **Must not start**, and any
**Locked decisions** that apply. Follow them exactly: do not drop an
outcome, do not add the next step, do not reorder.

You choose how. If a better how would change later steps **in this file**,
update this plan first, then continue this step. If it would change a
later plan file, **stop and ask**. Do not silently drift. Do not read
other plan files.

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

1. `git add` **only** the files this step created or changed. Leave
   unrelated dirty files unstaged. Do not stage plan files; they are
   gitignored. Do not `git add -A`.
2. If the index already contains files this step did not change: **stop**.
   Relay that. Do not unstage the user's other work. Do not commit a mixed
   index. Do not start the next step.
3. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself. Do not draft the message.
4. If commit reports nothing staged: you failed to add. Add this step's
   files and run commit **once** more. That is not a reason to end the plan.
   If it is still empty after that, stop and relay.
5. If identity is missing or a pre-commit hook fails: **stop**. Relay that.
   Do not start the next step. Do not `--no-verify`.
6. When commit returns a SHA, write `**Landed:** \`<sha>\`` on this step
   in the plan file (next to the step heading, not in git). Emit the step
   report (below), then take the **next** unfinished step **in this file**.
   Keep going until this file is done or a step cannot finish.
7. When every step in this file has `**Landed:**`: **delete this file**.
   Do not `git add` the deletion. If the plan directory is empty, remove
   it. Then **chain** (below). Do not ask the user to run the next file.

## Chain the next file

After a finished file is deleted:

- If no plan files remain: stop. The plan is done.
- If numbered files remain: you **must** start a **new agent**. This
  agent's context already holds this file's work. Continuing here fills
  the window. That is a bug.

How to start it — same prompt on every host, empty history, then this
agent stops implementing:

Prompt (implement ask, nothing else — no diffs, no reports, no deleted
file, no this chat):

Follow the implementation plan. This message is an implement ask.
Read the follow-implementation-plan skill and execute it on the
remaining files in docs/implementation-plan/. Do not wait for the
user.

- **Cursor:** new Task / subagent, `generalPurpose`, background. Do not
  resume. Do not self-fork.
- **Oh My Pi (omp):** `task` tool, agent `task` (never `planner` or
  `hand`). Batch: a one-line `context` ("Empty history. Follow the
  remaining implementation plan.") plus one item with that prompt as
  `task`. Do **not** set `isolated` — commits must land in this repo.
  Child sessions do not inherit this conversation.

Then **stop implementing in this agent**. One line in the report: next
file chained in a new agent. Do not read the next file. Do not take its
first step.

If you cannot start a new agent (`task` missing, recursion cap, unknown
host): **stop**. Name the remaining file. Do **not** continue it here.

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

**Verification**
- <commands you ran, and the result>
- Gate vs parent: <unchanged error set → met | this step added N | skipped, host rule>

**Next**
Step N+1 — <concern>. Or: stopped — <identity | hook | mixed index | this step added failures>.
Or: next file chained in a new agent. Or: plan done.
```

Unknown cells say "unknown". No "your call". A report is not permission to
skip the next step.

## Never

- Skip, merge, or reorder steps
- Several steps in one uncommitted change
- `git commit` yourself while the `commit` skill can run
- Pass a subject to commit
- Grep `git log` for a planned subject to decide if a step landed
- Stop the plan because nothing was staged (retry add + commit once)
- Commit when the index already holds files this step did not change
- Unstage the user's other work
- Stop the plan because a gate was already red at HEAD
- Pause to fix baseline errors that this step did not add
- Rewrite a later plan file while implementing
- Implement because a review in this chat just finished
- Write, refresh, or edit documentation (`docs/architecture/`,
  `docs/plain-english/`, area docs, README docs) or agent memory documents
  (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`)
- Wait for the user to name `02.md`
- Read other files in the plan directory besides the current one
- Stage or commit plan files
- Continue the next plan file in this same agent
- Resume or self-fork this conversation into the next file
- Pass this chat's history, diffs, or a finished plan file into the next agent
- Use omp `planner` or `hand` for the chain
- Spawn the next file `isolated` on omp
