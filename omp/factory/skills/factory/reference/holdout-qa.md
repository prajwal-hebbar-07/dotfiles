# Holdout QA

Runs after the test-suite review passes and before the final review, once per round. Only `factory-qa` reads the scenarios.

## Prompt

```
Work ID: <id>. Issue #<n>. Round: <N>. Repo: <root>. Branch: <branch>.
Scenarios: ~/.omp/factory/<repo>/<id>/scenarios.md — run every scenario for R<…> (this issue) and every scenario of issues already merged in this run (regression): S<…>.
Approved design: .factory/<id>/design.md (UI only).
Run grant: <verbatim>.
Write two files:
  1. ~/.omp/factory/<repo>/<id>/qa/r<N>-report.md   (full report)
  2. .factory/<id>/issues/<n>/qa/r<N>-findings.md    (builder-safe findings)
```

## What factory-qa does

1. Read `AGENTS.md`. If the grant allows launch, start the dev server on the granted port with the twins configured, in the background. Without launch permission, run only what the grant covers and mark every scenario that needed the running app as `NOT RUN (no launch grant)`.
2. For each scenario: follow the steps as that user would, with the `browser` tool for UI and `bash` (curl against localhost) for APIs. Record what happened.
3. Per scenario: `PASS`, `FAIL`, or `NOT RUN (<reason>)`. Evidence for every FAIL: screenshot path, console errors, uncaught page errors, failing network calls (status and URL), and the visible difference from the approved artboard. A 200 response with a blank page is a FAIL.
4. Stop the dev server and close the browser.

## Report (`r<N>-report.md`, outside the repo)

```markdown
RESULT: PASS | FAIL
ROUND: <N> · RAN: <count> · PASSED: <count> · FAILED: <count> · NOT RUN: <count>
## S1 — PASS | FAIL | NOT RUN
<observations, evidence paths>
```

`RESULT: PASS` only when every scenario passed; any NOT RUN means `FAIL` unless the human waived it.

## Builder-safe findings (`r<N>-findings.md`, in the repo)

```markdown
RESULT: PASS | FAIL
## Q1 [Blocker] <route, screen or endpoint>
Observed: <what the app did>
Expected: <the behavior the requirement R<n> promises, in the requirement's words>
Evidence: <console error, status code, screenshot path under .factory/>
```

Never copy scenario steps, scenario IDs, or wording that exists only in the scenarios. Describe the observed failure and cite the requirement.

## Loop

`RESULT: FAIL` → route each finding to the slice that owns the code (`build.md`, "Fixes from later steps"), then rerun **every** scenario in scope. Max 3 rounds; then queue the remaining failures for the human. `RESULT: PASS` → final review.

Satisfaction scoring (fraction of trajectories that satisfy the user) only for features whose behavior is produced by an LLM; everything else is pass/fail.
