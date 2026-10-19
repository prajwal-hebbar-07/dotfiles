# Work record, state, IDs, resume, status

## Starting a run

1. Resolve the repo: `git rev-parse --show-toplevel`. Not a git repo (or an empty directory): note `repo_state: empty`; Gate 2 settles `git init`, the remote and the initial commit. Do not create anything yet.
2. Refuse to start if the repo is mid-merge, mid-rebase, mid-cherry-pick, bisecting, or on a detached HEAD. Say which and stop.
3. Work ID: `NNN-slug`. `NNN` is one more than the highest number under `.factory/` (`001` if none); slug is 2–4 kebab-case words from the request. Claim it with `mkdir .factory/<work-id>` (no `-p` on the leaf); if it exists, take the next number.
4. Append `.factory/` to `.git/info/exclude` if it is not already listed.
5. Create the scenario home `~/.omp/factory/<repo>/<work-id>/` where `<repo>` is the basename of the repo root (or of the current directory for an empty repo).
6. Write `state.json` (below) with `stage: "gate1"`. Print: `<work-id>: started — Gate 1 requirements`.

## Layout

In the repo, never committed:

```
.factory/<work-id>/
  state.json            you write it; nothing else does
  requirements.md       Gate 1 packet (R-IDs, out of scope, assumptions, glossary) + revision log
  stack.md              Gate 2 packet + revision log
  architecture.md       Gate 3 packet (D-IDs, contracts, test plan, issue plan) + revision log
  design.md             Gate 4: Paper file and page, approved artboards + revision log
  questions.md          queued gated questions and their answers
  trace.jsonl           one JSON line per agent run (see retro.md)
  arch-review/r<N>/<agent>.md
  design-review/r<N>/factory-review-design.md
  issues/<n>/
    slices/<k>/build.md                  builder report
    slices/<k>/r<N>/<agent>.md           slice review verdicts
    tests/r<N>/<agent>.md                test-suite review verdicts
    qa/r<N>-findings.md                  builder-safe QA findings (no scenario text)
    final/r<N>/<lens>-<agent>.md         final review verdicts
    evidence.md                          PR body source
```

Outside the repo, visible only to you and `factory-qa`:

```
~/.omp/factory/<repo>/<work-id>/
  scenarios.md          holdout scenarios (Gate 1)
  qa/r<N>-report.md     full QA reports with scenario references
```

## state.json

```json
{
  "work_id": "003-todo-app",
  "request": "<the user's words, verbatim>",
  "repo": "<absolute repo root>",
  "repo_name": "<basename>",
  "base_branch": "main",
  "stage": "gate1",
  "grant": {
    "tests": ["<exact command>"],
    "build_lint_typecheck": ["<exact command>"],
    "app_launch": {"allowed": false, "command": null, "port": null},
    "network": false,
    "github_writes": false,
    "given_in": "<short description of the conversation turn>",
    "status": "not_requested"
  },
  "budget": {"factory-builder": 0},
  "push_target": {"remote": "origin", "url": null, "create_private_repo": false},
  "paper": {"file": null, "page": null},
  "issues": [
    {
      "number": 12, "title": "Auth", "branch": "12-auth",
      "requirements": ["R1", "R2"],
      "slices": [{"id": 1, "title": "sign-up", "status": "committed", "sha": "abc1234", "builder": "factory-builder-12-1"}],
      "phase": "slices", "round": 1, "pr": null, "status": "building"
    }
  ],
  "current": {"issue": 12, "slice": 2, "step": "slice-review", "round": 1},
  "waiting_on": null,
  "standins_used": []
}
```

`stage` is one of `gate1`, `gate2`, `gate3`, `gate4`, `issues`, `build`, `waiting_merge`, `rework`, `retro`, `done`. `waiting_on` names what the run is blocked on in one line (a gate answer, a queued question, a PR merge). Rewrite the whole file on every transition; it is the only resume source.

## Resolving IDs

- Work ID omitted: if exactly one run under `.factory/` has `stage` other than `done`, use it; otherwise list the unfinished runs (work ID, stage, waiting on) and ask.
- Issue omitted in `rework`: if that run has exactly one open PR, use its issue; otherwise list the open PRs and ask.
- `12` and `#12` are the same issue.

## Resume

1. Read `state.json`. Print where it stands.
2. If this conversation has not granted the run grant, show the recorded grant and stop for the human (`rules.md`, "Human interaction"); `approve` renews it. Re-apply the budget (`rules.md`).
3. If `stage` is `waiting_merge`: `gh pr view <pr> --json state,mergedAt`. Not merged: say which PR is waiting and stop. Merged: mark the issue `merged`, `git fetch`, `git switch <base>`, `git pull --ff-only`, and start the next issue (`build.md`).
4. Otherwise continue from `current`. A step that was mid-flight when the session ended has an unknown outcome: inspect its output file and the git state; rerun the step only if its output file is missing or has no valid first line.

## Status

Read-only; never spawn, run or commit. For every run under `.factory/`:

```
003-todo-app   build — issue #13 (todo list), slice 3/5, final review round 1
               issues: #12 merged, #13 building, #14 planned
               open PRs: none
               waiting on: nothing
004-csv-export waiting_merge — PR #21 (closes #20) needs your merge, then /factory resume 004-csv-export
```
