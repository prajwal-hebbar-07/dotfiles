---
name: debate-issues
description: >
  Turns the approved requirements, stack, architecture and design into GitHub
  issues in Oh My Pi, after first checking that everything the plan needs is
  ready: issue 0 bootstraps the app, then one vertical slice per journey,
  each self-contained (every item it needs copied in word for word, with
  acceptance criteria, tests, out of scope and the build rules), published
  under an epic with sub-issue and blocked-by links, so the user picks an
  issue and builds it. Claude Opus 5.5 plans and writes the issues; GPT-6.1
  Sol challenges the cut and reads each issue cold as its implementer. Runs
  straight through to GitHub with no approval step, like Claude Code's
  /issues, and writes the same files. Use when the user says
  "/skill:debate-issues".
argument-hint: "[status | sync | qa | change text]"
disable-model-invocation: true
---

# debate-issues

Claude Code's `/issues`, with two models checking each other before anything
reaches GitHub. The rules are that skill's: `issues-rules.md` in this skill's
directory is it, linked, with its templates and rules (`issues-template.md`,
`issue-template.md`, `slicing.md`, `principles.md`). Follow them in full,
except where this file says otherwise; where the two disagree, this file
wins. Like `/issues`, it never stops to ask the user: judgment calls follow
the rules (the simplest design that serves a number, YAGNI), are recorded,
and are reported at the end.

The issues it publishes are the ones Claude Code's `/implement` builds, one
at a time, from `docs/progress.md`; a later document change reaches them
through `sync`, and `/qa` findings through `qa`.

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Models

Two models, and only these two. You, the session, are the **runner**: you
start them, run the checks, and publish with `gh`. You never cut, write or
fix an issue yourself.

| Role | `task` agent | Model (its frontmatter) | Does |
| --- | --- | --- | --- |
| Planner | `issues-planner` | `anthropic/claude-opus-5-5`, medium | Inventory, cut, assumptions, the plan and every issue file; replies once to each objection; fixes every gap; changes and syncs |
| Checker | `issues-checker` | `openai-codex/gpt-6.1-sol`, medium | Challenges the cut; the fresh-reader check, each batch a new task given only issue files |

Start each as a `task` with `agent` set to its name and no `model` field. If
one is missing or cannot start, or the session log shows a different model,
stop and say which; never substitute another agent or model, or do its part
yourself. A model naming itself wrongly in its reply is not that.

Every sub-agent starts blank. Give it the repo root, the absolute paths of
the rule files it needs (resolve this skill's directory with `realpath`), the
files it reads and writes, and its step.

## Never

Everything in `issues-rules.md`'s **Never** holds, with these changes:

- Its Advisor section does not apply: the checker's challenge and the fresh
  reader take its place.
- Never publish while a Step 3 check of `issues-rules.md` fails, or while the
  fresh reader has gaps the planner has not answered (fixed, or recorded as
  an open point).
- Never edit an issue on GitHub that lacks the `issues:key=` marker.

## Step 1 — readiness

Every run starts here. Run Step 1 of `issues-rules.md` (hashes and reads),
then check, and print the result as a checklist, one line each, `ready`,
`not ready: <what and the command that fixes it>`, or `warning: <what>`:

| # | Check | When it fails |
| --- | --- | --- |
| 1 | `requirements.md`, `stack.md` and `architecture.md` exist and are `approved` | Stop. Name the stage and its `/skill:debate-<stage> approve` (or the skill, if not yet `grilled`) |
| 2 | `design.md` is `approved` with every screen `Paper: built`, or the requirements have no screens | Stop, as above. No screens: warning, and the plan's header says `Built without design.md` |
| 3 | None of the four has an open question or gap in its log | Stop, as above |
| 4 | Nothing is stale: the hashes each later document records for the earlier ones match the files | Stop: name the stage to re-check |
| 5 | The two agents exist in `~/.omp/agent/agents/` | Stop: run `omp/link-skills` in the dotfiles |
| 6 | `gh auth status` logged in; `gh repo view` resolves a GitHub repository; `gh --version` 2.94.0 or later | Not ready for publishing only: the plan is written and stays `planned`; say what to fix and that running the skill again publishes |
| 7 | The `ponytail` skill is installed (`~/.omp/agent/skills/ponytail`) | Warning: the YAGNI sweep runs without its ladder |

With any stop, change nothing else. Then by argument and state, as
`issues-rules.md` Step 1 says (`status`, `sync`, `qa`, a change, an
interrupted run, a new plan), with one more: `issues.md` at `Status:
planning` is a plan the debate did not finish. Go back to **Plan** at the
first item `docs/issues-debate.md` and the issue files show is not done;
never publish from it.

One file beyond `issues-rules.md`'s: `docs/issues-debate.md`, the models'
notes (objections, replies, fresh-reader gaps), append only, never read by
the user.

## Plan

`issues-rules.md` Step 2, as a debate:

1. **Cut** (planner). Step 2 items 1–4: inventory, cut, cover and sweep
   (with ponytail's ladder when installed), assume. Write the cut to
   `docs/issues.md` (`Status: planning`): the issue table with keys,
   titles, Sources, `Blocked by`, waves, UI and Sec; the Coverage table; the
   Assumed and Open points sections. No issue files yet.
2. **Challenge** (checker). Read the four documents, the glossary, the ADRs,
   `slicing.md`, `principles.md` and the plan. Append to
   `docs/issues-debate.md` under `## Cut · <date>` one block per objection:
   `### C<k> <key or item>`, `Checker: object — <reason and evidence>`.
   Object for a horizontal slice, a missing dependency or one only for
   tidiness, a live item with no issue or an issue with no item, an issue or
   part of one no number asks for, an issue too big for one pull request, an
   assumption that is not the simplest value, a wave that breaks an edge.
   Nothing to object to: write `Checker: no objection`.
3. **Reply** (planner). Under each block: `Planner: concede` (apply it to the
   plan) or `Planner: rebut — <evidence from the documents>`. One reply;
   nobody argues twice. A rebutted objection is listed under **Open points**
   in `issues.md` with both positions, and in the final reply.
4. **Write** (planner). Step 2 item 5: one file per issue, every cited item
   pasted word for word, `principles.md` pasted unchanged.
5. **Fresh reader** (checker). Batches of up to five issues, each batch a
   new task given only those issue files (no documents, no plan, no chat),
   asking `slicing.md`'s Self-sufficiency item 7 question. Batches run in
   parallel.
6. **Fix** (planner). Each gap is fixed by pasting the missing text from the
   documents, or recorded as an open point when the documents do not answer
   it. Every issue with a fix goes through item 5 once more, as a new task;
   gaps still left are open points.
7. **Record** (planner). Step 2 item 8: `Status: planned`, the four hashes,
   the Issues row and a log line.

## Check and publish

- **Check** (runner). `issues-rules.md` Step 3, from the files. A failure
  goes back to the planner with the list; then check again.
- **Publish** (runner). `issues-rules.md` Step 4, with the `gh` commands it
  gives, in wave order, recording each number in `issues.md` and
  `docs/progress.md` after each create. Readiness check 6 not ready: stop
  before it, as the check says. Create one issue per command, never in a
  loop or script, and immediately before each `gh issue create` search for
  its marker (`gh issue list --state all --search "issues:key=<key>" --json
  number,body`); found, record that number and do not create. After any
  failed call, re-run Step 4.3's scan before anything else. In Step 4.8's
  verify, a key carried by two issues, or a marker issue the plan does not
  have, is a mismatch: comment on the extra one naming the one in the plan,
  close nothing, and list it in the reply as `duplicate #<n> of #<m>: close
  it`.

## Change, sync, qa

`issues-rules.md` Steps 5, 6 and 8, with the planner writing every file,
the fresh reader (item 5 above) on every issue they write or rewrite, and
the runner running Step 3's checks and every `gh` call.

## Reply

`issues-rules.md` Step 7, with the readiness checklist's warnings, the
objections the planner rebutted, and **Next action** `Start with issue #<n>
(bootstrap): run /implement in Claude Code`. The files are uncommitted.
