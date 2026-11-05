---
name: debate-implement
description: >
  Builds the next GitHub issue in plan order in Oh My Pi, one issue per run.
  Reads docs/progress.md to pick the first issue not done, makes its branch,
  and builds it test first in the ponytail skill's full mode (YAGNI, the
  smallest complete change, reuse before writing, no duplicated code) with
  Claude Opus 5.5 (medium, or high for a hard issue), then checks the
  commits, the tests and the map itself.
  Each issue also leaves docs/codebase.md, a map of the repository (what is
  where, modules, data, tests, commands, where to change what) linked from
  AGENTS.md, so the next model finds its way without reading everything.
  Never pushes or opens the pull request: it hands over the branch and a
  ready PR description. No grill. Follows Claude Code's /implement rules
  and writes the same files, plus a run log in docs/progress.md. Use when
  the user says "/skill:debate-implement".
argument-hint: "[status | <issue key or #number>]"
disable-model-invocation: true
---

# debate-implement

Claude Code's `/implement`, with two levels of one model.
The rules are its: `implement-rules.md` in this skill's directory is that
skill, linked, with `commit-rules.md` (the `commit` skill every commit goes
through) and `principles.md` (the build
rules every issue carries). Follow them in full, except where this file says
otherwise; where they disagree, this file wins. The `ponytail` skill
(`~/.omp/agent/skills/ponytail/SKILL.md`, third-party) binds every line of
code at its `full` level.

One issue per run, as `implement-rules.md` says. The run ends with a branch
that passed the runner's check, the tests run, and a hand-off. It never pushes, opens a pull
request, merges, or starts the next issue: the user raises the PR, merges
it, and runs the skill again.

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Models

| Role | `task` agent | Model (its frontmatter) | Does |
| --- | --- | --- | --- |
| Builder | `code-builder` | `anthropic/claude-opus-5-5`, medium | Builds the issue |
| Builder, hard issue | `code-builder-high` | `anthropic/claude-opus-5-5`, high | The same, for an issue the runner rates hard |

You, the session, are the **runner**: you track state, pick the issue, make
the branch, choose the builder, check its work, and hand off. You never write
code yourself.

**Hard issue.** Use `code-builder-high` when any of these hold, and say which
in the log: the issue is labelled `security`; its architecture section names
three or more modules (`M`) or two or more flows (`F`) with failure paths;
it has more than eight acceptance criteria; or `code-builder` on this issue
left a failing test after its own check. Once an issue moves to high it stays there.

Start each as a `task` with `agent` set to its name and no `model` field. If
one is missing or cannot start, or the session log shows a different model,
stop and say which; never substitute another agent or model, or do its part
yourself. A model naming itself wrongly in its reply is not that.

Every sub-agent starts blank. Paste into its task the issue body (from `gh
issue view`), the branch, the commands from the bootstrap issue, the text of
`ponytail`'s SKILL.md, and the absolute paths of the rule files it follows
(resolve this skill's directory with `realpath`). Never only a path to find.

## Never

Everything in `implement-rules.md`'s **Never** holds, and:

- No grill and no advisor: the runner's check in **Build** is the check.
- Nothing about code review: no review step, no review report, no fixing of
  findings. `implement-rules.md`'s Step 6, its `fix` argument, its review
  reports and its hand-off lines about `/review-code` do not apply; its
  tracker state `awaiting review` means only "waiting for the user's PR".
- Never build a needs-decision issue: **Decision mode** of
  `implement-rules.md` is the runner's, asked in chat.
- Never mark an issue `done`: only a merged PR or a closed issue does that,
  as the tracker rules say.
- Never let the codebase map say what the code does not: every path in it
  exists on the branch, and nothing in it is planned or remembered.

## Step 1 — readiness and state

Print a checklist, one line each, `ready` or `not ready: <what and the fix>`:

| # | Check | When it fails |
| --- | --- | --- |
| 1 | `git config user.name` and `user.email` set; `gh auth status` logged in; `gh repo view` resolves the repository | Stop. Do not set identity or log in |
| 2 | `docs/issues.md` exists, `published`, with GitHub numbers | Stop: run `/skill:debate-issues` |
| 3 | No uncommitted change outside `docs/progress.md` | Stop and list them; the user commits or stashes |
| 4 | `ponytail` installed (`~/.omp/agent/skills/ponytail/SKILL.md`) | Stop: `npx skills add DietrichGebert/ponytail -g --skill ponytail`, then `ln -s ~/.agents/skills/ponytail ~/.omp/agent/skills/ponytail` |
| 5 | The two agents exist in `~/.omp/agent/agents/` | Stop: run `omp/link-skills` in the dotfiles |
| 6 | `docs/progress.md` in `.git/info/exclude` | Warning: add it, so the tracker never lands in a commit |

Then `implement-rules.md` Step 1 from "Read `docs/progress.md`": bring the
tracker up to date, `status`, and **Pick**, with these changes:

- Current issue **awaiting review**: stop with "`<key>` is on `<branch>`,
  <k> commits, waiting for your PR; raise it, merge it, then run
  `/skill:debate-implement`", and its URL if an open pull request exists.
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
- <date> <key>: handed off, awaiting PR | stopped: <why>
```

Write each line when the event happens, before the next step starts, so a
stopped run leaves the log true. The table above it stays as
`implement-rules.md` defines it.

## The codebase map

Every issue leaves `docs/codebase.md` describing the repository as its
branch has it, from `codebase-template.md` in this skill's directory: what
the app is (with links to the stage documents), how to run and test it, the
layout, the modules and the files that hold them, where each entity is
stored and who writes it, where the tests are, the conventions the code
shows, and where to go to change what. It is how a model, or a person,
finds their way around without reading the whole tree. It points to the
stage documents and never copies them, and lists directories, patterns and
the files worth naming, so it stays short.

So that every agent reads it first, `AGENTS.md` at the repository root
carries this block (and `CLAUDE.md` too, if that file exists and is not a
link to `AGENTS.md`; with neither file, create `AGENTS.md` holding only the
block). Add it once; leave the rest of the file as it is:

```
<!-- codebase-map:start -->
## Codebase map

Before reading or changing code here, read
[docs/codebase.md](docs/codebase.md): what each directory and file holds,
the modules, the data, the tests and the commands. Keep it true when you
add, move or delete a file.
<!-- codebase-map:end -->
```

These two files are the exceptions to `implement-rules.md`'s rule against
editing `docs/` and files the issue does not name.

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
   Last, the **codebase map**: create `docs/codebase.md` from the template if
   it is missing (the bootstrap issue, or a repository that predates this
   skill: map what exists), else update every section the branch's changes
   touch, from `git diff origin/<default>...HEAD` and the files as they are;
   add the block to `AGENTS.md` if it is missing. One commit through
   `commit-rules.md`: `docs: update codebase map for #<n>`.
4. **Check** (runner). From git and the shell, not the builder's word:
   commits exist on the branch (`git log --oneline origin/<default>..HEAD`),
   each with a subject of 72 characters or fewer and a blank second line
   (`git log --format='%s%n%b%x00' origin/<default>..HEAD`; a malformed one
   is reported in the hand-off, since nothing may be amended),
   the working tree is clean outside `docs/progress.md`, no file under `docs/` changed that the issue's
   Definition of done does not name (`docs/codebase.md` aside), and the
   issue's test command, run once by you, passes. The map: `docs/codebase.md`
   exists and was touched on the branch, every path it names in backticks
   exists (`test -e`), every file the branch added or moved is under a path
   it names, and the `codebase-map` block is in `AGENTS.md`. A failure goes
   back to the builder once, as a new task with the list; still failing,
   move to `code-builder-high` (the **Hard issue** rule) and try once more;
   then stop and log why. Log the build.

## Hand-off

`implement-rules.md` Step 7, without its review lines, with the row
`awaiting review` (waiting for the user's PR), the log line, and the builder
level used and why. **Next:** "Raise the PR with the description
below (`/raise-pr <default>` in Claude Code, or by hand), merge it, then run
`/skill:debate-implement` for the next issue (`#<m> <title>`)." Then the
ready pull request description, as the rules give it. Do not push or create
the PR.
