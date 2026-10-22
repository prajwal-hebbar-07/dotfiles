# Bootstrap checklist (issue #0): deliverables and proofs

Source: `SOFTWARE-FACTORY.md` §4.7. These rows are issue #0's acceptance
criteria. On an existing repo, mark each row `have` / `partial` / `missing`
after detecting; run the proof for `have` rows too.

| # | Deliverable | Proof |
| --- | --- | --- |
| 1 | `CONSTRAINTS.md` and `check:fast` / `check:task` / `check:full` scripts that mirror it | each exits 0 on the skeleton |
| 2 | CDD floor guard, diff-scoped (`floor-guard.md`) | exits 1 on a planted `.skip`; exits 1 on a planted suppression; exits 0 on the clean tree |
| 3 | Boundary checker with the ARCHITECTURE.md module rules | fails on a planted illegal import |
| 4 | CI on `pull_request` and on `push` to `main` and `factory/**`, `fetch-depth: 0` | green run on the `factory/*` push |
| 5 | Unit runner with lcov; E2E runner with one test over the skeleton | both green locally and in CI |
| 6 | Idempotent `seed` that works from an empty data directory | running it twice gives the same state |
| 7 | `.env.example` (fake values, one comment per variable); `.env` git-ignored | gitleaks clean; fails on a planted fake secret |
| 8 | `launch` and a read-only `doctor` (process, port, version, data reachable) | doctor green after launch, red after teardown |
| 9 | `verify-<app>` skill (pstack `create-verification-skill`) with a seeded feature map | its own end-to-end run: launch, doctor, drive one feature, evidence kept after cleanup |
| 10 | Branch protection on `main` with the required checks (applied after the #0 merge, SKILL step 8) | `gh api repos/{owner}/{repo}/branches/main/protection` lists the required checks |
| 11 | Planted-fault run: one fault per gate (`.skip`, `eslint-disable`, illegal import, fake secret) | each check red on its fault, green after removal; transcript in `qa-evidence/0/<sha>/` |

Existing repo extras:

| Deliverable | Proof |
| --- | --- |
| Coverage and mutation recorded as ratchets at today's values | CONSTRAINTS.md "Measured, not yet enforced" holds the numbers; a drop fails `check:full` |
| Repo's own lint/format config kept | `check:fast` calls it; diff touches no rule |
