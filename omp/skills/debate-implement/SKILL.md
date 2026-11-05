---
name: debate-implement
description: >
  Builds the next GitHub issue in plan order in Oh My Pi, then has it
  reviewed and fixed, in one run. Reads docs/progress.md to pick the first
  issue not done, makes its branch, builds it test first in the ponytail
  skill's full mode (YAGNI, the smallest complete change, reuse before
  writing, no duplicated code) with Claude Opus 5.5 (medium, or high for a
  hard issue), has GPT-6.1 Sol review the branch, and fixes the findings
  until the review is approve-ready or only the user's decisions are left.
  Never pushes or opens the pull request: it hands over the branch and a
  ready PR description. No grill. Follows Claude Code's /implement and
  /review-code rules and writes the same files, plus a run log in
  docs/progress.md. Use when the user says "/skill:debate-implement".
argument-hint: "[status | fix | <issue key or #number>]"
disable-model-invocation: true
---

# debate-implement

Claude Code's `/implement` and `/review-code` in one run, with three models.
The rules are theirs: `implement-rules.md` and `review-rules.md` in this
skill's directory are those two skills, linked, with `commit-rules.md` (the
`commit` skill every commit goes through) and `principles.md` (the build
rules every issue carries). Follow them in full, except where this file says
otherwise; where they disagree, this file wins. The `ponytail` skill
(`~/.omp/agent/skills/ponytail/SKILL.md`, third-party) binds every line of
code at its `full` level.

One issue per run, as `implement-rules.md` says. The run ends with a branch
whose review is `approve-ready` (or with the findings only the user can
settle), the tests run, and a hand-off. It never pushes, opens a pull
request, merges, or starts the next issue: the user raises the PR, merges
it, and runs the skill again.

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Models

| Role | `task` agent | Model (its frontmatter) | Does |
| --- | --- | --- | --- |
| Builder | `code-builder` | `anthropic/claude-opus-5-5`, medium | Builds the issue and fixes the findings |
| Builder, hard issue | `code-builder-high` | `anthropic/claude-opus-5-5`, high | The same, for an issue the runner rates hard |
| Reviewer | `code-reviewer` | `openai-codex/gpt-6.1-sol`, medium | Reviews the branch and answers the builder's responses |

You, the session, are the **runner**: you track state, pick the issue, make
the branch, choose the builder, check its work, and hand off. You never write
code, a finding, or a response yourself.

**Hard issue.** Use `code-builder-high` when any of these hold, and say which
in the log: the issue is labelled `security`; its architecture section names
three or more modules (`M`) or two or more flows (`F`) with failure paths;
it has more than eight acceptance criteria; or `code-builder` on this issue
left a failing test after its own check, or two fix rounds without moving
the verdict. Once an issue moves to high it stays there.

Start each as a `task` with `agent` set to its name and no `model` field. If
one is missing or cannot start, or the session log shows a different model,
stop and say which; never substitute another agent or model, or do its part
yourself. A model naming itself wrongly in its reply is not that.

Every sub-agent starts blank. Paste into its task the issue body (from `gh
issue view`), the branch, the commands from the bootstrap issue, the text of
`ponytail`'s SKILL.md, and the absolute paths of the rule files it follows
(resolve this skill's directory with `realpath`). Never only a path to find.

## Never

Everything in `implement-rules.md`'s and `review-rules.md`'s **Never** holds,
and:

- No grill of the code, and no advisor: the review is the check.
- Never build a needs-decision issue: **Decision mode** of
  `implement-rules.md` is the runner's, asked in chat.
- Never mark an issue `done`: only a merged PR or a closed issue does that,
  as the tracker rules say.

## Step 1 — readiness and state

Print a checklist, one line each, `ready` or `not ready: <what and the fix>`:

| # | Check | When it fails |
| --- | --- | --- |
| 1 | `git config user.name` and `user.email` set; `gh auth status` logged in; `gh repo view` resolves the repository | Stop. Do not set identity or log in |
| 2 | `docs/issues.md` exists, `published`, with GitHub numbers | Stop: run `/skill:debate-issues` |
| 3 | No uncommitted change outside `docs/review/code/` and `docs/progress.md` | Stop and list them; the user commits or stashes |
| 4 | `ponytail` installed (`~/.omp/agent/skills/ponytail/SKILL.md`) | Stop: `npx skills add DietrichGebert/ponytail -g --skill ponytail`, then `ln -s ~/.agents/skills/ponytail ~/.omp/agent/skills/ponytail` |
| 5 | The three agents exist in `~/.omp/agent/agents/` | Stop: run `omp/link-skills` in the dotfiles |
| 6 | `docs/progress.md` in `.git/info/exclude` | Warning: add it, so the tracker never lands in a commit |

Then `implement-rules.md` Step 1 from "Read `docs/progress.md`": bring the
tracker up to date, `status`, and **Pick**, with these changes:

- Current issue **awaiting review** with no open finding the models can
  still move, argument not `fix`: stop as the rules say ("waiting for your
  PR"), giving the last review's verdict.
- Current issue **awaiting review** with open blocker or major findings, or
  argument `fix`: **Fix and re-review**.
- **Feature mode** (`docs/features/<n>-*/` for the branch's issue): as the
  rules say, then **Build** onward with the feature's files as the brief and
  its tracker in place of `progress.md`.

## The log

`docs/progress.md` gets a `## Log` section after its table (create it if
missing), one line per event, newest last, so a new run, or the user, sees
what happened to each issue:

```
- <date> <key> #<n>: picked (<why: first not done | named by user>)
- <date> <key>: branch issue/<n>-<slug> from origin/<default> @ <short sha>
- <date> <key>: built by code-builder (medium | high: <reason>), <k> commits, tests <pass | fail: what>
- <date> <key>: review <N> by code-reviewer: <verdict>, <b>/<m>/<i>/<n>
- <date> <key>: fix round <N>: <a> accepted, <r> rebutted, <q> intent, <k> commits
- <date> <key>: handed off, awaiting PR | stopped: <why>
```

Write each line when the event happens, before the next step starts, so a
stopped run leaves the log true. The table above it stays as
`implement-rules.md` defines it.

## Build

1. **Branch** (runner). `implement-rules.md` Step 2. Log it.
2. **Rate** (runner). Read the issue body (`gh issue view <n> --json
   title,body,labels,blockedBy,state`) and choose the builder by **Hard
   issue**.
3. **Build** (builder). `implement-rules.md` Steps 3, 4 and 5.1–5.2: read the
   issue and the code it touches, then each acceptance criterion test first,
   each commit through `commit-rules.md` with `now`, then run everything
   and check the diff against the issue. Ponytail's ladder before every new
   piece of code: does it need to exist, is it already in the codebase, the
   standard library, the platform or an installed dependency, can it be one
   line. Return the commits, the commands run with their results, each
   criterion with its test, and the assumptions.
4. **Check** (runner). From git and the shell, not the builder's word:
   commits exist on the branch (`git log --oneline origin/<default>..HEAD`),
   the working tree is clean outside `docs/progress.md` and
   `docs/review/code/`, no file under `docs/` changed that the issue's
   Definition of done does not name, and the issue's test command, run once
   by you, passes. A failure goes back to the builder once, as a new task with
   the list; still failing, move to `code-builder-high` (the **Hard issue**
   rule) and try once more; then stop and log why. Log the build.

## Review

1. **Review** (reviewer). `review-rules.md` Steps 1–4 and **Responses and
   disputes**, on the branch, writing `docs/review/code/<key>-review.md`.
   Skip its advisor and its Step 5 reply; return the verdict and the counts.
   Paste the issue body and the ponytail text into its task, and add to its
   checks: code the codebase already has written again, duplicated code, a
   dependency or helper added where an existing one serves, each a `major`.
   Log it.
2. `approve-ready`: **Hand-off**. Otherwise **Fix and re-review**.

## Fix and re-review

1. **Fix** (the builder that built it). `implement-rules.md` Step 6: one
   `Response:` per open finding (accepted with a commit, rebutted with
   evidence, or intent), fixes through `commit-rules.md`, then Steps 5.1–5.2
   again. Log the round.
2. **Check** (runner) as **Build** item 4.
3. **Re-review** (reviewer). As **Review**, a re-review that handles each
   `Response:` first.
4. **Again or stop.** `approve-ready`: **Hand-off**. Findings left that are
   `contested` or `intent` only: **Hand-off**, listing them for the user.
   Anything else open: back to 1. Stop with the log line `stopped: no
   progress` when a round leaves the code and the open findings unchanged,
   and after the fifth round in any case.

## Hand-off

`implement-rules.md` Step 7, with the row `awaiting review` (waiting for the
user's PR), the log line, the review's verdict and counts, the rounds it
took, the builder level used and why, and anything left for the user from
the report's **For you**. **Next:** "Raise the PR with the description
below (`/raise-pr <default>` in Claude Code, or by hand), merge it, then run
`/skill:debate-implement` for the next issue (`#<m> <title>`)." Then the
ready pull request description, as the rules give it. Do not push or create
the PR.
