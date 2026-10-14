---
name: follow-plan-with-review
description: >
  Review-gated twin of follow-implementation-plan. Implements the next
  unfinished step of an implementation plan, then stops with the change
  uncommitted so the user can review it. For a code step, writes the code
  and code-level tests for the behaviour it changes and runs them, and
  updates the existing architecture pages it makes stale and any markdown
  document the step names. For a docs step, creates or updates the
  markdown documents the step names (running any throwaway experiment
  outside the repo) and touches no code. When the user says to commit,
  stages that step's files, commits through the commit skill (no
  subject), stamps Landed:<sha>, implements the next step in the same
  window, and stops for review again. A window is at most five commits
  per chat; when it is done, hands the user a prompt for a new chat with
  empty history. Use only when the user asks to implement the plan with
  review ("implement the plan step by step", "stop after each step", "let
  me review each commit") or invokes /follow-plan-with-review, and when a
  step from this skill is waiting for review and the user says to commit
  it or asks for changes. A plain implement ask goes to
  follow-implementation-plan. Do not use when the user asks to review,
  write, update, or look at the plan.
argument-hint: "[path to plan file or directory]"
---

# Follow plan with review

The review-gated twin of `follow-implementation-plan`. Same plan file,
same steps, same rules for code and docs steps — but nothing is committed
until the user has reviewed it, and nothing starts a window except the
user.

Follow **every step exactly**, in order. The plan is the contract. Each
chat implements one window only: at most five commits.

**The user reviews every step before it is committed.** Implement one
step, run its checks, then **stop** with the change uncommitted and
unstaged and report it. Commit only when the user says so. Then implement
the next step and stop again. See **Review stop**.

When a window is done, give the user the prompt for a new chat (see
**Next window**). Do not start that chat or a subagent yourself.

## This skill wins over the plan's protocol

Plan files are written for `follow-implementation-plan`. Their **How this
file is followed**, **How to follow this plan**, and step **Prompt** text
say to commit as soon as **Done when** passes, to take the next step
without waiting, and to start the next window in a new chat
automatically. Under this skill, ignore those lines: stop for review
before every commit, and hand the user the next-window prompt instead of
starting a chat. Every other instruction in the plan still applies.

## This turn must be an implement ask

This skill runs only when **this message** asks to implement, execute,
follow the plan as code, do the next step, or names
`/follow-plan-with-review` — or when a step this skill implemented in
this chat is waiting for review and this message answers that review (see
**Review stop**).

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
not `git add` the deletion) and hand the user the prompt for the next file
(see **Next window**). Do not merge them into `plan.md` while
implementing.

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
  sections. Everything else (one step at a time, review stop, staging,
  commit, stamp, next window, report) is the same.

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

If the next step's work is already in the working tree, uncommitted (an
earlier chat implemented it and stopped for review), do not implement it
again. Run its checks and stop for review (see **Review stop**).

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

## Review stop

When **Done when** passes, **stop**. Do not `git add`. Do not run the
commit skill. Emit the step report (below) with status `Step N
implemented — waiting for your review`, then end your turn. The user
reviews the uncommitted change.

The user's next message decides:

- **Go-ahead** — "commit", "looks good", "lgtm", "next", "continue", or
  the like: run **Stage, commit, stamp** for this step. If the word
  "commit" also loaded the commit skill, stage this step's files first
  (step 1 below); the commit skill does not stage. Then take the next
  unfinished step **in this window**, implement it, and stop for review
  again. If this was the window's last step, go to **Next window**.
- **Changes** — the user asks for something different in this step: make
  the change within this step's scope, re-run this step's tests or
  checks, and stop for review again with an updated report. If the change
  would alter a later step or a locked decision, **stop and ask**. Do not
  edit the plan.
- **Stop** — the user says to stop or leave it: do nothing more. The
  change stays uncommitted. The next implement ask picks it up for review.
- Anything else: answer it, then ask whether to commit. Do not commit.

A go-ahead covers only the step under review. Never commit a step the
user has not seen. Never implement the next step before this one is
committed.

## Stage, commit, stamp

Run this only after the user's go-ahead. The step is not finished until
its commit exists and `**Landed:**` is on the step. Do not stop because
commit could not run.

1. Code step: `git add` the code and tests this step created or changed,
   any existing `docs/architecture` pages it updated, and any markdown
   document this step names. Docs step: `git add` only the markdown
   documents this step created or updated. Edits the user made to this
   step's files during review are part of the step. Leave unrelated dirty
   files unstaged. Do not stage a markdown file this step does not name. Do not
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
   files (per step 1) and run commit **once** more. If it is still empty
   after that, stop and relay.
6. If identity is missing or a pre-commit hook fails: **stop**. Relay that.
   Do not start the next step. Do not `--no-verify`.
7. When commit returns a SHA, write `**Landed:** \`<sha>\`` on this step
   in the plan file (next to the step heading, not in git). Do any
   issue-tracker update the step names. Say in one line which SHA landed,
   then take the **next** unfinished step **in this window** and stop for
   review after it.
8. When every step in this window has `**Landed:**`, go to **Next
   window**. Do not delete `plan.md` between windows. On an older `NN.md`
   plan, delete that finished file instead (do not `git add` the
   deletion). If the plan directory is empty after that deletion, remove
   it.

## Next window

After the current window's last commit:

- If no unfinished window remains: delete `plan.md` if it is still there.
  Do not `git add` the deletion. If the plan directory is empty, remove
  it. Stop. The plan is done.
- If a later window remains: **stop** and give the user this prompt to
  paste into a **new chat with empty history**. Do not continue the next
  window in this chat; its context already holds this window's work. Do
  not start the new chat, a Task, or a subagent yourself: a subagent
  cannot stop for the user's review.

```
Follow the implementation plan with review. This message is an implement
ask. Read the follow-plan-with-review skill and implement the next window
of docs/implementation-plan/plan.md, stopping after each step for my
review.
```

On an older `NN.md` plan, name the plan directory instead of `plan.md`.

## Report

When a step stops for review, after a change round, or when it is
blocked, emit one report in this shape.
Do not write `docs/reports/`. Chat only.

```
<one-line status: Step N implemented — waiting for your review | commit blocked | stopped — <reason>>

**Step N** — <concern> — not committed (`<file count>` files changed)

| Done when | State |
| --- | --- |
| <outcome from the plan, verbatim> | <what is true now, in this tree> |

**Changed**
- <what this step actually did — outcomes or existing paths only>

**Not this step's**
- <dirty paths this step did not change and will not stage, or `none`>

**Markdown**
- code step: architecture pages updated: <paths, or `none — nothing this step describes was stale`>; other markdown created or updated: <paths this step names, or `none`>
- docs step: documents created or updated: <paths>; no code touched

**Verification**
- code step: code-level tests: <command and result, including the sanity check and the functionality check>; Gate vs parent: <unchanged error set → met | this step added N | could not run>
- docs step: consistency checks: <what was searched or compared, and the result>; experiment: <what ran, where outside the repo, kept or deleted | none>
- issue tracker: <items updated | none>
- manual / UI: left to the user

**Next**
Waiting for your review. Say commit to commit step N and start step N+1 — <concern>.
Or (last step of the window): say commit to commit step N; then paste the next-window prompt into a new chat.
Or (last step of the plan): say commit to commit step N; the plan is then done.
Or: stopped — <identity | hook | mixed index | markdown outside the step's rules | this step added failures | experiment could not run>.
```

Keep only the lines for this step's kind. Unknown cells say "unknown". No
"your call". A report is not a go-ahead; only the user's reply is. If the
**Markdown** lines are not true, the step is not done: restore the files
you were not allowed to change, update any document this step left stale,
say so, and do not stamp `**Landed:**`. If a code step's code-level tests
were not written or not run, or a docs step's checks were not done, the
step is not done: do not stop for review; finish it first.

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
- Stage or commit a step before the user's go-ahead
- Treat one go-ahead as approval for any later step
- Implement the next step while the current one is uncommitted
- Start the next window yourself in a new chat, Task, or subagent
- Stage or commit the plan file
- Continue the next window in this same chat
- Resume or self-fork this conversation into the next window
- Pass this chat's history, diffs, or a finished window into the next chat
- Finish a code step that changes behaviour with no code-level test for a
  sanity check and for that functionality
- Open a browser, start the app, or do a manual or UI pass
