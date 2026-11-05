---
name: debate-qa
description: >
  QA for the merged app in Oh My Pi, with no manual checks: audits every
  promise built so far against its tests, runs every unit, integration,
  regression and journey test the project has (twice, for flakes), then
  writes the tests that are missing or too weak to fail, on its own QA
  branch, test code only, and proves each new test can fail. A new test that
  fails on the current code has found a defect: it is reported, not fixed,
  for /skill:debate-issues qa and /skill:debate-implement. GPT-6.1 Sol
  audits and re-audits; Claude Opus 5.5 writes the tests. Never pushes or
  opens the PR. Follows Claude Code's /qa rules and writes the same report.
  Use when the user says "/skill:debate-qa".
argument-hint: "[status | <focus text>]"
disable-model-invocation: true
---

# debate-qa

Claude Code's `/qa`, plus the tests it finds missing. The audit rules are
that skill's: `qa-rules.md` in this skill's directory is it, linked, with
`commit-rules.md` (the `commit` skill every commit goes through). Follow them
in full, except where this file says otherwise; where they disagree, this
file wins. The `ponytail` skill (`~/.omp/agent/skills/ponytail/SKILL.md`,
third-party) binds every test written, at its `full` level.

`/skill:debate-implement` builds each issue with the tests its criteria
name; what it left out, or what only shows once issues meet, is this skill's
to write: tests for the journeys that cross issues, the failure paths, the
assumptions, the regressions, and every promise whose test is missing or
cannot fail. It writes tests only. A defect in the code goes back through an
issue, so every code change still lands as one reviewed issue per PR.

Nothing is checked by hand. A promise only a person can judge (how a screen
looks) is listed under **Not judged** and left. Anything a test can reach
through the project's own test commands, including ones that start a local
server or a headless browser for the run, is tested.

One QA branch per run. The run ends with a branch of test commits, the
report, and a hand-off. It never pushes, opens a pull request or merges: the
user raises the PR and merges it, and runs the skill again.

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Models

| Role | `task` agent | Model (its frontmatter) | Does |
| --- | --- | --- | --- |
| Auditor | `qa-auditor` | `openai-codex/gpt-6.1-sol`, medium | The matrix, the runs, the findings; the re-audit of the QA branch |
| Tester | `qa-tester` | `anthropic/claude-opus-5-5`, medium | Writes the tests on the QA branch, proves each can fail, commits them |

You, the session, are the **runner**: you check readiness, make the branch,
hand rows to the tester, check its work, and hand off. You never write a
test, a finding or a matrix row yourself.

Start each as a `task` with `agent` set to its name and no `model` field. If
one is missing or cannot start, or the session log shows a different model,
stop and say which; never substitute another agent or model, or do its part
yourself. A model naming itself wrongly in its reply is not that. Paste into
each task the rows or findings it works on, the commands from the bootstrap
issue, the text of `ponytail`'s SKILL.md, and the absolute paths of the rule
files it follows (resolve this skill's directory with `realpath`).

## Never

Everything in `qa-rules.md`'s **Never** holds, with these changes:

- The project's own test commands may start what they start themselves (a
  local server, a headless browser) for the run, on a free port; whatever a
  command starts, it or the runner stops by the pid recorded. Nothing else
  is started, and nothing is opened for a person to look at.
- The tester edits and creates test files, test fixtures and test helpers
  only, on the QA branch, and commits them. It never changes application
  code, configuration the app runs with, or a document. A test that needs
  the app changed to be testable (no seam to reach it) is a finding with
  route `issue`, not a change.
- Never commit a test that fails on the current code, skip or weaken a test
  to make the suite pass, or delete an existing test. A wrong existing test
  is a finding.
- No advisor: the re-audit is the check.
- Route `manual` is not used: a check no test can make is under **Not
  judged**, and is not a finding.

## Step 1 — readiness and state

Print a checklist, one line each, `ready` or `not ready: <what and the fix>`:

| # | Check | When it fails |
| --- | --- | --- |
| 1 | `git config user.name` and `user.email` set; `gh auth status` logged in; `gh repo view` resolves the repository | Stop. Do not set identity or log in |
| 2 | `docs/issues.md` exists, `published`, with GitHub numbers, and at least one issue `done` | Stop: nothing is built yet; run `/skill:debate-implement` |
| 3 | On the default branch, `HEAD` equal to `origin/<default>` after `git fetch origin`, no uncommitted change outside `docs/review/`, `docs/progress.md` and `docs/project.md` | Stop and say which; the user switches, pulls or commits |
| 4 | No earlier QA branch (`qa/*`) with commits not in `origin/<default>` | Stop: name it; the user raises its PR and merges it, or deletes it |
| 5 | `ponytail` installed (`~/.omp/agent/skills/ponytail/SKILL.md`) | Stop: `npx skills add DietrichGebert/ponytail -g --skill ponytail`, then `ln -s ~/.agents/skills/ponytail ~/.omp/agent/skills/ponytail` |
| 6 | The two agents exist in `~/.omp/agent/agents/` | Stop: run `omp/link-skills` in the dotfiles |
| 7 | The bootstrap issue records a test command | Stop: there is nothing to run; the bootstrap issue or the stack needs one |

Then `qa-rules.md` Step 1 from "Add a `QA` row" (`status`, a repeat on the
same sha by the same model, a re-run, a focus, the built-so-far set).

## Audit

1. **Audit** (auditor). `qa-rules.md` Steps 2–4 on the default branch:
   the matrix, the cross-cutting checks, every test command twice, lint,
   type check, build and audit if the bootstrap issue names them, the
   findings with routes, and the report. Add to its checks:
   - **Regression.** Every merged fix (a `fix:` commit on the default
     branch, a closed issue labelled `qa`, an accepted `Fixes CR`/`QA`
     finding) has a test that would fail if that fix were reverted; one
     without is `missing`.
   - **Kinds.** Each matrix row names the kind of test that covers it, or
     should: `unit` (one module through its interface), `integration` (two
     or more modules, or a module and its real store, through the seams the
     architecture gives), `journey` (a `J` end to end across the issues
     that build it), `regression` (above).
   Skip its advisor and its Step 5 reply; return the verdict, the counts,
   and the list of findings with route `issue` that are a missing or weak
   test (the **test list**), each with its row, kind and the code it
   guards.
2. Test list empty: **Hand-off**.

## Write the tests

1. **Branch** (runner). `git switch -c qa/<N>-tests origin/<default>`,
   where `<N>` is this QA's number. The only branch switch this skill makes.
2. **Write** (tester). For each row in the test list, in matrix order:
   - write the test at the kind the row names, through the seam the
     architecture gives, reusing the project's test setup, helpers and
     fixtures before adding any;
   - assert the promise's own words and numbers, quoting its ID in the
     test's name;
   - run it on the current code: it passes. Then break the code it guards
     in the working tree (the smallest change that breaks the promise), run
     it and see it fail, and restore the code;
   - a test that fails on the current code has found a defect: leave it out
     of every commit and return it, with its output and the promise it
     breaks;
   - commit through `commit-rules.md` with `now`, staging test files by
     path, one row or a few closely related rows per commit, the message
     naming the finding (`covers QA4`).
   Return, per row: the test (`file` and name), the command run with its
   result, the break that made it fail, or the defect found.
3. **Check** (runner). From git and the shell: `git diff
   origin/<default>...HEAD --name-only` lists test files only (the
   project's test paths, its fixtures and helpers); each commit's subject
   is 72 characters or fewer with a blank second line (a malformed one is
   reported in the hand-off, since nothing may be amended); `git status` is clean
   outside `docs/`; every test command, run once by you on the branch,
   passes. A file outside the test paths, or a failing run, goes back to
   the tester as a new task with the list; still wrong, stop, and name the
   commits and files at fault in the hand-off, so the user can drop them
   before raising the PR.
4. **Re-audit** (auditor). `qa-rules.md` as a re-run on the QA branch's
   head: every test command twice, the matrix rows of the test list
   re-judged by reading the new tests (each `covered` only if the test
   would fail if the promise broke), and each defect the tester found
   written as a finding with route `issue`, its failing test pasted as the
   reproduction. A row still `weak` or `missing` goes back to item 2 once,
   as a new tester task; still not covered, it stays a finding.

## Hand-off

Update `project.md` as `qa-rules.md` says. Reply in at most twenty lines:

- the verdict and counts, on the default branch and on the QA branch;
- the matrix in one line per kind: covered, weak, missing, not yet built,
  not judged;
- the tests written, by kind, and the commits on `qa/<N>-tests`;
- the defects the new tests found, one line each with the finding ID, the
  promise and the failing test;
- the commands run twice and any flake;
- what is under **Not judged**;
- **Next:** "Raise the PR for `qa/<N>-tests` (`/raise-pr <default>` in
  Claude Code, or by hand) and merge it. Then file the defects and the
  findings that need code with `/skill:debate-issues qa`, and build them one
  at a time with `/skill:debate-implement`. Run `/skill:debate-qa` again
  after they merge."

Then a ready pull request description in a fenced block: title `QA <N>:
tests for <the kinds written>`, a summary, the rows covered with their
tests, how each test was seen to fail, and the commands run. Do not push or
create the PR. With no tests written, there is no branch and no PR: say so.
