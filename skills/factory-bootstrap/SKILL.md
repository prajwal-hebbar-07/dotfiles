---
name: factory-bootstrap
description: >
  Issue #0 of the software factory: builds the walking skeleton, CI, check
  scripts, floor guard, boundary checker, test harness, seed, launch/doctor,
  the verify-<app> skill, and branch protection, then plants one fault per
  gate to prove each check goes red. On an existing repo it detects what is
  there and adds only what is missing. Use when the factory builds issue #0
  (through factory-build like any issue) or the user asks to bootstrap the
  project.
disable-model-invocation: true
---

# factory-bootstrap

Design: `SOFTWARE-FACTORY.md` §4.7. Every later issue assumes what this issue
creates. It is built through the normal `factory-build` pipeline (plan, tests
first, review, QA, the "Raise PR?" ask); this skill is the issue's content,
not a separate pipeline. The planner, builder, and reviewers read this skill
and `references/checklist.md`; the checklist rows are the issue's acceptance
criteria, each with its proof.

## Never

- Mark a gate done that has not been seen red on a planted fault.
- Lower a threshold, skip a check, or add a suppression to get green.
- Commit `.env`, real secrets, or the planted faults.
- Add a dependency STACK.md does not name.
- Apply branch protection from inside the build (step 8).

## Steps

1. **Detect first** (addyosmani `constraint-driven-development`, step 1:
   never ask what you can read). Read, do not guess:

   | What | Where |
   | --- | --- |
   | language, stack | manifests, STACK.md |
   | test runner, E2E runner | dev dependencies, `test` scripts, spec files |
   | linters, formatter | their config files |
   | coverage today | existing `coverage/`, or one run of the suite |
   | CI | `.github/workflows/` |
   | agent harness | `AGENTS.md`, `.claude/` |

   Put two lines of findings in the plan. New repo: nothing exists, build the
   lot. **Existing repo:** mark each row of `references/checklist.md` `have`
   (proof run now), `partial`, or `missing`; the issue adds only `partial` and
   `missing`. The repo's own lint config and conventions stay.
2. **New repo: walking skeleton** (Cockburn): one trivial feature through every
   layer (one screen, one API call, one stored row; or the CLI/library
   equivalent from ARCHITECTURE.md). Domain-free; later issues replace it.
   Existing repo: no skeleton; one existing path stands in for it.
3. **Checks.** Write `check:fast` / `check:task` / `check:full` as real scripts
   mirroring CONSTRAINTS.md (the file is the source; scripts must not drift).
   Each exits 0 on the skeleton. On an existing repo, coverage and mutation
   start as **ratchets at today's measured value** (tolerance 0.5%), recorded
   under "Measured, not yet enforced".
4. **Floor guard**, built to `references/floor-guard.md`; wired into
   `check:fast` (working diff) and `check:full` / CI (diff to the merge base).
5. **Boundary checker** (dependency-cruiser or import-linter, per STACK.md)
   with the module rules from ARCHITECTURE.md.
6. **CI** in `.github/workflows/`: runs `check:full` on `pull_request` and on
   `push` to `main` and `factory/**`; `actions/checkout` with `fetch-depth: 0`
   (the guards diff against the merge base). Unit runner with lcov; E2E runner
   with one test over the skeleton (each later issue adds its own, §5.8).
7. **Runtime pieces:**
   - `seed`: idempotent, works from an empty data directory.
   - `.env.example`: fake values, one comment per variable; `.env`
     git-ignored (Twelve-Factor).
   - `launch`: returns only when the app is usable (migrations and seed done).
     `doctor`: read-only; process, port, version, data reachable.
   - **`verify-<app>` skill** at `.omp/skills/verify-<app>/`, per pstack
     `create-verification-skill`:
     - Interview the repo, not the user: surface, run, drive, observe,
       isolate. If the checkout does not start, fix that first.
     - `SKILL.md` with frontmatter (`name: verify-<app>`, a description naming
       app, surface, and when to use it) and sections **Launch** (exact
       command, ready = usable, from an empty data dir, teardown),
       **Doctor**, **Drive** (real selectors/commands from this repo, stable
       handles; existing harness first, else browser for web, tmux/PTY for CLI,
       HTTP for services), **Evidence** (real user path, capture action and
       resulting state, verify side effects), **Cleanup** (kill only what you
       started; never delete evidence), **Helpers** (executable, invocation
       shown). Reuse `launch` / `doctor`, do not duplicate them.
     - `features/README.md` plus one file per top 3-5 user-facing features
       (Sub-features, How to get to it, Driving it, Gotchas).
     - Run its instructions end to end once: launch, doctor, drive one
       feature, capture evidence, clean up, confirm the evidence survived. A
       skill never run is a draft.
8. **Branch protection on `main`** is a repo-settings change outside the diff,
   so the build does not apply it. Write the payload to
   `docs/factory/branch-protection.json` (required checks = the CI job names,
   `strict: true`, PRs required, no force pushes, no deletions) and say so in
   the PR body. After the user merges the #0 PR (the check names now exist on
   `main`), the main session asks once ("Apply branch protection to main?"),
   runs `gh api -X PUT repos/{owner}/{repo}/branches/main/protection --input
   docs/factory/branch-protection.json`, and proves it with
   `gh api repos/{owner}/{repo}/branches/main/protection`. On 403 or a plan
   limit (private repo, free plan): log it in the ledger and tell the user;
   do not fake it.
9. **Planted faults**, last step before review: one fault per gate, in the
   working tree or a throwaway branch, never committed: a `.skip` and an
   `eslint-disable` / `# noqa` (floor guard exits 1), an illegal import
   (boundary checker fails), a fake secret of a real format (gitleaks fails;
   output redacted). Run the gate for each, show the red exit and message,
   remove the fault, show green. A check that does not fail on its planted
   fault is not a gate: fix it. Save the transcript to
   `qa-evidence/0/<sha>/planted-faults.txt`.
10. **Prove the table.** Walk `references/checklist.md`; run each proof and
    put its output in the PR body. The CI row needs a green run on the
    `factory/*` push (the pre-PR step watches it).

## Existing repo

- CI exists: add the missing triggers and `fetch-depth: 0`; do not replace it.
- A check that is red today becomes an Exceptions row (owner, expiry), never a
  silenced check; tell the user in the PR body.
- Dimensions that need a URL (axe, Lighthouse) are dropped for a CLI or
  library; say so in CONSTRAINTS.md rather than invent a check that cannot run.
