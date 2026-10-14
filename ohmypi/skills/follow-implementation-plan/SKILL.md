---
name: follow-implementation-plan
description: >
  Implements the next unfinished window of an implementation plan, at
  most five commits.   For a code step, stages that step's code, any existing
  architecture pages it updates, and any markdown document that step names
  for creation or update, and writes and runs code-level tests for the
  behaviour it changes. For a docs step, creates or updates the markdown
  documents the step names (running any throwaway experiment outside the
  repo) and touches no code. Commits
  through the commit skill (no subject), stamps Landed:<sha> on the step,
  then continues in the same window. When the window is done, starts the
  next window in a new chat with empty history, and keeps going window
  after window until the whole plan has landed — the user never starts a
  window by hand. Use only when the user
  explicitly asks to implement, execute, or follow the plan as code,
  "implement this doc", "next step", or /follow-implementation-plan. Do not
  use when the user asks to review, write, update, or look at the plan.
argument-hint: "[path to plan file or directory]"
---

# Follow implementation plan

Follow **every step exactly**, in order. The plan is the contract. Each
chat implements one window only: at most five commits. But one invoke by
the user runs the **whole plan**: when a window is done, the next window
starts automatically in a new chat with empty history, and so on until
every window has landed or a step cannot finish. You never wait for the
user to name, start, or confirm the next window. See **Chain the next
window** for how each host does that.

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
other files in the plan directory. Read them so you know which documents
this step will make stale.

## Step kind

Each step has a **Kind:** line, `code` or `docs`. A step with no **Kind**
line is `code` (older plans). A step is `docs` only when the plan says so;
do not turn a code step into a docs step, or the reverse.

- **code** steps follow **Architecture pages, and the markdown this step names** and
  **Tests** below.
- **docs** steps follow **Docs steps** below instead of those two
  sections. Everything else (one step at a time, staging, commit, stamp,
  chain, report) is the same.

## Docs steps

A docs step records the decisions or findings its plan text names. It
creates or updates the markdown documents the step names. Leave every
document it touches consistent with the decision and with each other.
When the repo has its own documentation conventions (a decision log,
stable requirement IDs, an open-questions list, "answered" markers),
follow them.

It does not touch code or tests. It does not edit the plan directory. It
does not stamp `docs-baseline:` unless the step says so. It does not
create or update a markdown document the step does not name. It does not
record a decision the plan does not contain; if one is missing, stop and
ask.

**Checks instead of tests.** A docs step adds no code-level tests. Before
committing, check what its **Done when** names: each decision appears
where it lives, no document still contradicts it (search for the old
wording), and answered questions are marked answered and removed from
wherever open questions are tracked.

**Throwaway experiments.** If the step says to test something, build the
experiment **outside the repository**, in a folder you choose. Never stage
anything from it. Start local services it needs (for example databases in
Docker) only when the step says so; if the host forbids it, stop and say
so. Write the finding from what actually ran: versions, what was tried,
what was observed. If the check fails, apply the fallback the step names,
record it, and list alternatives the user can research; if the step names
no fallback, record the failure and stop and ask. Keep the experiment for
later steps that reuse it; delete it in the step the plan names.

**Issue trackers.** If the step says to update issues (or similar), do it
after the step's commit, change only the items it names, read each current
body first, and close nothing the step does not say to close.

## Architecture pages, and the markdown this step names

This section and **Tests** apply to code steps.

When this step changes behaviour an existing page under `docs/architecture/`
describes, update that page in the same commit so it stays true. Do it when
`docs/README.md` has `architecture: on`, or when that pin is absent and
those pages already exist. If the pin is `off`, do not edit an architecture
page unless this step names it.

Create or update every other markdown document this step names, in the
same commit. That includes a new architecture page, a README, a changelog,
an ADR, `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, or any other `.md`
the step names. Do not create, edit, or delete a markdown document the
step does not name. Do not stamp `docs-baseline:` unless the step says so.

The git commit may contain the architecture pages this step updated and
the markdown documents this step names. No other `.md` file.

The only write allowed on the plan file is `**Landed:** \`<sha>\`` on the
step you just committed. That stamp is not part of the commit. Do not
redesign the plan. Do not stage the plan file.

If the plan text still says not to touch architecture pages, ignore that
line and update the pages this step makes stale — the skill wins over an
older plan. If the plan names a markdown document and also carries an
older sentence that forbids every markdown document except architecture
pages, create or update the named document anyway. If you already changed
a markdown file this step does not name, restore that file before you
commit and say so. Do not restore a markdown file that was already dirty
when you started. The `**Landed:**` stamp stays.

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

You choose how. In a code step, the how may update existing architecture
pages this step makes stale, and creates or updates the markdown documents
this step names. In a docs step, you choose wording and layout within the
docs-step rules, and you create or update the markdown documents the step
names. If a better how would
change a later step, **stop and ask**. Do not edit the plan to redesign
it. Do not silently drift.

## Tests

Write code-level tests for the behaviour this step changes, in the same
commit. That is a sanity check and a functionality check: the obvious
case, and the rules the step claims. Unit tests and frontend tests that
run in the project's test runner both count. Typecheck alone does not.

Run those tests with the project's unit-test command, scoped to the tests
this step added or changed. A failure this step added is a stop. A failure
that already existed at the parent commit, with the same error set, is
not.

Do not open a browser, drive the UI, start the app, or do a manual pass.
The user does manual testing and UI testing.

## Gates

A named typecheck / lint / test command is a gate on **this step**, not on
the whole repo. Gates apply to code steps; a docs step has none unless its
**Done when** names one.

- If it already fails at the parent commit (HEAD before this step's files),
  that is not a stop. Prove it: same command, same error set with this
  step stashed or compared. Unchanged set → the gate is met. Continue.
- Stop only if **this step added** failures.
- Do not pause the plan to fix unrelated baseline errors. Do not open a
  commit outside this plan for that. Do not ask the user to choose "fix
  baseline first" versus "continue" — continue.
- Host rules that forbid a build, a dev server, or a browser still apply.
  They do not skip this step's code-level tests. If that test command
  cannot be run, **stop** and say so. Do not stamp `**Landed:**`.

## Stage, commit, stamp, continue

When **Done when** passes, the step is not finished until its commit
exists and `**Landed:**` is on the step. Do not stop because commit could
not run.

1. Code step: `git add` the code and tests this step created or changed,
   any existing `docs/architecture` pages it updated, and any markdown
   document this step names. Docs step: `git add` only the markdown
   documents this step created or updated. Leave unrelated dirty files
   unstaged. Do not stage a markdown file this step does not name. Do not
   stage the plan. Do not stage anything from a throwaway experiment. Do
   not `git add -A`.
2. If the index already contains files this step did not change: **stop**.
   Relay that. Do not unstage the user's other work. Do not commit a mixed
   index. Do not start the next step.
3. Code step: if the index contains a markdown file that is not an
   architecture page this step updated and is not a markdown document this
   step names: **stop**. Docs step: if the index contains code, tests, or
   a markdown file the step does not name: **stop**.
   Relay that. Do not commit it.
4. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself. Do not draft the message.
5. If commit reports nothing staged: you failed to add. Add this step's
   files (per step 1) and run commit **once** more. That
   is not a reason to end the plan. If it is still empty after that, stop
   and relay.
6. If identity is missing or a pre-commit hook fails: **stop**. Relay that.
   Do not start the next step. Do not `--no-verify`.
7. When commit returns a SHA, write `**Landed:** \`<sha>\`` on this step
   in the plan file (next to the step heading, not in git). Do any
   issue-tracker update the step names. Emit the step report (below),
   then take the **next** unfinished step **in this window**. Keep going until this window is done or a step cannot finish.
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

- **Claude Code** (the `Agent` tool is available): see **Claude Code:
  driver and workers** below. Do not use the prompt above there; use the
  worker prompt.
- **Cursor:** new Task / subagent, `generalPurpose`, background. Do not
  resume. Do not self-fork.
- **Oh My Pi (omp):** `task` tool, agent `task` (never `planner` or
  `hand`). Batch: a one-line `context` ("Empty history. Follow the next
  window of the implementation plan.") plus one item with that prompt as
  `task`. Do **not** set `isolated` — commits must land in this repo.
  Child sessions do not inherit this conversation.

On Cursor and omp, then **stop implementing in this agent**. One line in
the report: next window started in a new chat. Do not take the next
window's first step. (On Claude Code the driver does not implement the
next window either; it keeps running workers until the plan is done.)

If you cannot start a new chat (`task` missing, recursion cap, unknown
host): **stop**. Name the next window. Do **not** continue it here.

### Claude Code: driver and workers

On Claude Code a subagent cannot start a subagent of its own, so a window
that runs as a subagent can never chain the window after it. The chat the
user invoked the skill in is therefore the **driver**, and every later
window runs in a fresh **worker** subagent that the driver starts and waits
for. The user is never asked to start a window.

**Driver** (the top-level chat, where the user typed the implement ask):

1. Implement the current window yourself, exactly as this skill says.
2. While an unfinished window remains, loop:
   - Start one worker with the `Agent` tool: `subagent_type:
     "general-purpose"`, **no** `isolation` (commits must land in this
     repo), `run_in_background: false` (the next action depends on it),
     and the worker prompt below. One worker per window; never two at
     once; never resume a finished worker for the next window.
   - When it returns, re-read the plan file. If every step of that window
     now has `**Landed:**`, relay the worker's per-step reports to the user
     in a few lines, then start the next window's worker. Do not ask the
     user anything between windows.
   - If the window is not fully landed (the worker stopped: identity,
     hook, mixed index, added failures, missing decision, denied
     permission), **stop the loop**. Relay the worker's stop reason and
     which step is unfinished. Do not implement that window in the driver.
3. When no unfinished window remains, the driver (not a worker) deletes
   `plan.md` (do not `git add` the deletion) and removes the plan
   directory if it is empty. If that deletion is denied, say so in one
   line and leave the file. The plan is done.

Driver context stays small: it holds its own window plus short worker
summaries. It never re-implements, re-reviews, or re-runs a worker's
window.

**Worker prompt** (implement ask, nothing else — no diffs, no reports, no
this chat; on an older `NN.md` plan name the plan directory instead):

Follow the implementation plan. This message is an implement ask, and you
are a worker started by a driver chat. Read the follow-implementation-plan
skill at ~/.claude/skills/follow-implementation-plan/SKILL.md and execute
the next unfinished window of docs/implementation-plan/plan.md in the
repository at <absolute repo path>. This chat has empty history. Do not
wait for the user. Implement that one window only. Do not start another
chat or subagent and do not delete the plan file — the driver chains the
next window and finishes the plan. End with the per-step reports and one
line: window done, or stopped at step N and why.

**Worker** (a chat whose implement ask says it was started by a driver):
implement the current window exactly as this skill says, then stop. At
chain time do **not** start a new chat or subagent and do **not** delete
`plan.md`, even if no window remains; your final report's **Next** line
says "window done — back to the driver" or the stop reason. This wins
over a step **Prompt** in the plan that says to start a new chat or to
delete the plan file: as a worker, ignore those two lines and leave both
jobs to the driver.

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
- code step: architecture pages updated: <paths, or `none — nothing this step describes was stale`>; other markdown created or updated: <paths this step names, or `none`>
- docs step: documents created or updated: <paths>; no code touched

**Verification**
- code step: code-level tests: <command and result, including the sanity check and the functionality check>; Gate vs parent: <unchanged error set → met | this step added N | could not run>
- docs step: consistency checks: <what was searched or compared, and the result>; experiment: <what ran, where outside the repo, kept or deleted | none>
- issue tracker: <items updated | none>
- manual / UI: left to the user

**Next**
Step N+1 — <concern>. Or: stopped — <identity | hook | mixed index | markdown outside the step's rules | this step added failures | experiment could not run>.
Or: next window started in a new chat. Or: next window running in a worker (Claude Code driver).
Or: window done — back to the driver (Claude Code worker). Or: plan done.
```

Keep only the lines for this step's kind. Unknown cells say "unknown". No
"your call". A report is not permission to skip the next step. If the
**Markdown** lines are not true, the step is not done: restore the files
you were not allowed to change, update any document this step left stale,
say so, and do not stamp `**Landed:**`. If a code step's code-level tests
were not written or not run, or a docs step's checks were not done, the
step is not done: do not stamp `**Landed:**`.

## Never

- Skip, merge, or reorder steps
- Several steps in one uncommitted change
- More than the current window (five commits) in this chat
- `git commit` yourself while the `commit` skill can run
- Pass a subject to commit
- Grep `git log` for a planned subject to decide if a step landed
- Stop the plan because nothing was staged (retry add + commit once)
- Commit when the index already holds files this step did not change
- In a code step, commit a markdown file that is not an architecture page
  this step updated and not a markdown document this step names
- In a docs step, touch code or tests, create or update a markdown
  document the step does not name, or record a decision the plan does not
  contain
- Commit anything from a throwaway experiment, or build it inside the repo
- Update or close issue-tracker items the step does not name
- Unstage the user's other work
- Stop the plan because a gate was already red at HEAD
- Pause to fix baseline errors that this step did not add
- Rewrite the plan while implementing, except the `**Landed:**` stamp
- Implement because a review in this chat just finished
- Create, edit, or delete a markdown document the step does not name
- Wait for the user to name, start, or confirm the next window
- Stop after the first window on Claude Code because a subagent cannot
  chain — the driver runs every later window in a worker
- As a Claude Code worker, start another chat or subagent, or delete the
  plan file
- As a Claude Code driver, implement a window a worker stopped on
- Stage or commit the plan file
- Continue the next window in this same chat
- Resume or self-fork this conversation into the next window
- Pass this chat's history, diffs, or a finished window into the next chat
- Use omp `planner` or `hand` for the chain
- Spawn the next window `isolated` on omp
- Finish a code step that changes behaviour with no code-level test for a
  sanity check and for that functionality
- Open a browser, start the app, or do a manual or UI pass
