# Issues, branches, Slice 0, slices

## Create the issues

After Gate 3 (and Gate 4) approval, create one GitHub issue per issue-plan row, in dependency order:

```bash
gh issue create --title "<module or feature>" --body-file <tmpfile>
```

Issue body (short; never scenarios, never factory metadata):

```markdown
<one-paragraph purpose>

**Requirements:** R1, R2
**Acceptance criteria**
- R1: <trigger → outcome; how it is checked>
**Slices**
1. <slice> 2. <slice>
**Out of scope**
- <item>
Depends on #<n>
```

Record each issue number in `state.json`. `stage: "build"`.

## Start an issue

1. Tree clean except `.factory/`? If not, stop and ask.
2. `git fetch`, `git switch <base>`, `git pull --ff-only`.
3. `gh issue develop <n> --base <base> --checkout --name <n>-<slug>` (links branch and issue).
4. First issue of the run only: before the first slice, have the builder attempt to read `~/.omp/factory/<repo>/<work-id>/scenarios.md` (prompt: "Try to read this path and report exactly what happened"). The read must be blocked by the holdout guard. Not blocked → stop the run and tell the human the guard is not loaded (`omp plugin link` of the factory plugin).

## Slice 0 (first issue only)

Built and reviewed like any slice. It:

- writes or completes `AGENTS.md` with the repo commands every agent reads: fresh-checkout setup, dev server with a given port, tests, build, lint, type-check. In an existing repo, add only what is missing;
- turns every enforceable decision in the register into a check (ast-grep rule, lint rule, architecture test, or narrow verifier), each naming its decision ID, and shows each check failing once on a deliberately broken input before it counts (then removes the broken input);
- builds the twins chosen at Gate 2.

An issue whose slices introduce an external service no earlier issue used builds that service's twin in its first slice.

## The slice loop

For slice `k` of issue `n`:

1. Spawn a **fresh** builder named `factory-builder-<n>-<k>` (agent `factory-builder`):

```
Work ID: <id>. Issue #<n>: <title>. Slice <k>: <title>.
Repo: <root>. Branch: <branch> (already checked out). Base: <base>.
Read: AGENTS.md; .factory/<id>/requirements.md (R<…> only); .factory/<id>/architecture.md (decision register, contracts, test plan); .factory/<id>/design.md (UI only).
Slice scope: <what this slice delivers, its acceptance criteria>.
Run grant: <verbatim>.
Write exactly one factory file: .factory/<id>/issues/<n>/slices/<k>/build.md
```

2. Read the first line of `build.md`. `STATUS: BLOCKED` → read the reason; a gated decision missing from the register → queue it (`rules.md`) and move to the next independent slice; anything else → ask the human.
3. `STATUS: READY` → slice review round 1 (`review.md`, step "slice"): spawn `factory-review-slice` and `factory-review-gpt` in one message.
4. Any `VERDICT: CHANGES` → resume the **same** builder by name (`write agent://factory-builder-<n>-<k>`): "Round <N> reviews are in .factory/<id>/issues/<n>/slices/<k>/r<N>/. Address every CHANGES finding, update build.md for round <N+1>." Then the next review round. Max 3 rounds; after that, queue the open findings as a question and move on to independent work.
5. All PASS → you commit the slice: stage the paths `build.md` lists under "Files", one commit, message per `rules.md`. Record the SHA in `state.json`.

When all slices are committed: test-suite review, then holdout QA, then final review (`review.md`, `holdout-qa.md`), then `delivery.md`.

## Fixes from later steps

A finding from test-suite review, QA or final review goes back to the slice that owns the code: resume a fresh builder named `factory-builder-<n>-<k>-fix<m>` with the findings file path (QA: the builder-safe findings file only). After its slice review passes, commit with `git commit --fixup=<slice-sha>`. Autosquash happens just before the first push (`rules.md`).
