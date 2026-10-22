# Per-issue pipeline detail

Read once per build session. `FS` and `board` as in SKILL.md. `<repo>` is the
basename of the repo root. `N` = issue number, `<s>` = step name.

## Brief

App mode: issue number + body; paths to `docs/factory/*` at the sha stamped in
`FS get gates`; the `check:*` commands from CONSTRAINTS.md; the plan (builder
and reviewers). Feature-mode briefs are the feature factory's, not this file.

## Resume

1. `FS ledger open` lists starts with no done. For each, read the branch and
   `git status`.
2. Uncommitted changes from the interrupted step stay if that step's test now
   passes; otherwise `git stash push -m wip/<N>/<s>`, restart the step from the
   brief.
3. Re-check the last `done` claim once. Never create a second commit, PR or
   comment: look for the branch at the expected sha, `read pr://<n>`, and the
   hidden `<!-- factory:step=<s> -->` marker first.
4. Helper returned nothing: check branch + ledger without reviving it; respawn
   once with the same brief. Same tool error twice: retry once on the step's
   fallback model, then `factory:needs-human`. Two retries at most per step.

## Steps

**1-2 Plan and scenarios.** Spawn `factory-planner` and `factory-qa-author` in
one `task` batch. The author gets the issue and REQUIREMENTS.md only and
writes `~/.omp/factory/<repo>/holdout/N/`. The plan must have: at most 5
commits, each S or M; seams; test level per acceptance criterion; the ponytail
rung per step; `sec:boundary` boundaries touched; `data-paper-id` per UI
element. A dependency, module, abstraction or option ARCHITECTURE.md lacks
arrives as a question; the simpler option is the recommended answer.

**3-4 Design (UI issues).** `factory-designer` draws only this issue's screens
from `paper-design-prompt.md`. `factory-design-review` scores out of 10; FAIL on
any severity 3-4 finding. Feed findings back to the designer; after 3 cycles
set needs-human. Keyboard/focus/screen-reader go to step 10.

**5 Code.** `git switch -c factory/N-<slug>` (whole-app: off the wave branch).
Spawn `factory-builder` with brief + plan. Statuses: DONE, DONE_WITH_CONCERNS
(read the concerns; Act on or record), NEEDS_CONTEXT / BLOCKED (questionnaire).
Commits go through `commit`.

**6 Reviews.** One `task` batch: bundled `reviewer`, `factory-spec-review`,
`factory-test-review`, all given the diff and brief. Verdict vocab: reviewer
`overall_correctness` + P0-P3; spec APPROVE / REQUEST CHANGES; test PASS /
FAIL. Pass = reviewer has no P0-P1, spec APPROVE, test PASS. Synthesise per
SKILL.md; fix cycle returns to step 5 and re-runs only invalidated reviewers
(by patch-id). Max 3 cycles.

**7 Security (only `sec:boundary`).** `security_scan` needs
`async.enabled: false`, so it runs in its own process from the repo root:

```sh
printf 'async:\n  enabled: false\n' > "$TMPDIR/factory-sec.yml"
omp -p --config "$TMPDIR/factory-sec.yml" \
  "Run security_scan with target_kind ref_diff against main...HEAD; knowledge_base_paths: docs/factory/ARCHITECTURE.md"
```

Then `read security://scans` for the result. Verdict PASS / PASS+NOTES / FAIL.
If the scan fails to run or ends `partial`, fall back to the bundled
`security-reviewer` agent on the diff and ledger `--model security-reviewer`.
A quota stop during the scan: it reruns after the reset. Never `--force` or
change settings files.

**8 QA.** `factory-qa` follows the repo's `verify-<app>` skill, starts its own
instance (own port and data directory), never holds production credentials,
and writes `qa-evidence/N/<sha>/`. It may read the holdout scenarios. Per
scenario PASS / FAIL / BLOCKED; BLOCKED is a question, never a pass. Never
paste holdout text into any other agent's brief; a FAIL tells the builder the
failing behaviour and evidence path, not the scenario file.

**9 QA review.** `factory-qa-review` reads evidence + acceptance criteria.
FAIL when a covered requirement has no test or runtime evidence.

**10 UI review.** `factory-ui-review`: same-size viewport from Paper
`get_node_info`, Paper `export` file moved into `qa-evidence/N/<sha>/`, style
diff (blocking), pixel diff, vision judge, per Paper state. Paper Desktop not
running = BLOCKED.

**11 GO / NO-GO and 12 PR.** As SKILL.md. After CI: run `FS ledger verdict
--step go --result GO --sha <head>`. If the user answers No at the gate, the
reason becomes an Act on item and the loop restarts at step 5; the new head
needs new verdicts for whatever it invalidates. After `pr_create`:
`board status N factory:pr-ready`, `FS ledger done --step pr --evidence <url>`.

## Parallel frontier

Only when `FS get parallelOk` is true. One `task` batch, one item per frontier
issue, each `isolated: true`, each running steps 5-6 only (children never
spawn). The main session runs the other steps. Each child's commit is
cherry-picked onto the parent's current branch; if the merge fails (no git
identity) the change is a `.patch` in the session dir: stop and fix identity.

## Whole-app waves

Wave = the frontier at one moment. Wave branch `factory/<epic>-w<k>`: wave 1
off main, wave k+1 off wave k's tip. Each issue branch `factory/N-<slug>`
bases on its wave branch and is merged into it with a plain merge before the
pre-PR checks. Per wave: finish every wave issue, run GO / NO-GO on the wave
branch, ask once "Raise PR for <wave branch>?" listing each issue's
Verification, open one PR (base main for wave 1, else wave k-1's branch), then
one `FS stop S5` for the wave.
