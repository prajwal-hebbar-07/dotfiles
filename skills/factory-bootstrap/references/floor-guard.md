# Floor guard: spec

The script issue #0 writes into the app repo. It enforces the always-on
floor of CONSTRAINTS.md (SOFTWARE-FACTORY.md §4.5) from the diff alone.
Modelled on the reference in addyosmani `constraint-driven-development`
(`references/floor-guard.md`); written fresh in the app's own stack.

## Placement

- Path: `scripts/floor-guard` (or `.sh`/`.py`/`.mjs`), in the language the
  stack already has. Bash + git, Python 3 stdlib, or Node with no packages.
  No new dependency.
- Wired into `check:fast` (staged + unstaged diff against `HEAD`) and
  `check:full` / CI (diff against the merge base).
- CONSTRAINTS.md names it as the `Checked by` command for the floor rows.

## Interface

```
floor-guard [--base <ref>] [--staged]
```

- Default base: `origin/main` merge base (`git merge-base HEAD origin/main`);
  `--staged` checks `git diff --cached`. In CI use `fetch-depth: 0`.
- Looks only at **added** lines and at the file/lockfile/CONSTRAINTS changes in
  the diff. Never scans whole files, so old debt does not fail a new change.
- Output: one line per violation, `RULE path:line text`, then a summary.
  A secret's value is never printed; only the rule and location.
- Exit codes: **0** clean; **1** at least one violation; **2** could not run
  (not a git repo, base ref missing, shallow clone with no merge base). Never
  exit 0 when it could not run.

## Checks

| # | Rule | Detected in the diff |
| --- | --- | --- |
| 1 | no new suppressions | added lines matching `@ts-ignore`, `@ts-expect-error` without a reason, `eslint-disable`, `# noqa`, `# type: ignore`, `istanbul ignore`, `Stryker disable`, `nosemgrep`, `gitleaks:allow`, `//nolint`, `#[allow(`, plus the stack's equivalents |
| 2 | no stubs or silent failure | added `throw new Error("Not implemented")`, `NotImplementedError`, `unimplemented!()`, `todo!()`, `pass  # TODO`, empty `catch {}` / `except: pass`, bare `TODO` where code should be |
| 3 | no skipped or deleted tests without a reason | added `.skip`, `xit`, `xdescribe`, `it.todo`, `@pytest.mark.skip`, `t.Skip(`, `#[ignore]` with no reason string; deleted test files or removed `test(`/`it(` lines, unless the commit message (or `--reason-file`) states a reason |
| 4 | no secrets | gitleaks over the diff's commits when installed (`gitleaks detect --redact --no-banner --log-opts <base>..HEAD`); fallback regexes for private-key headers, `AKIA[0-9A-Z]{16}`, `ghp_…`, `sk-…`, `password\s*=\s*['"]` in added lines; `.env` newly tracked |
| 5 | no new runtime dependency unnamed in STACK.md or the issue's plan | lockfile/manifest diff: added runtime (non-dev) packages, compared with names listed in `docs/factory/STACK.md` and the plan file passed as `--allow-deps <file>` (one name per line). Dev dependencies are reported as a notice, not a violation |
| 6 | CONSTRAINTS.md never weakened | diff of `CONSTRAINTS.md` against base: a number made less strict (coverage down, budget up, mutation target down), a `check:*` or `Checked by` command removed, a floor line removed, a new Exceptions row without owner and expiry |

Rule 6 may flag a legitimate tightening as clean; it flags only loosening.

## Required behaviour

- Same result run twice on the same diff (no state, no network).
- Paths under `docs/`, `*.md` prose, and the guard's own pattern table are
  excluded from rules 1–3 so the guard does not flag itself.
- Single-file overrides are not supported: a line that needs an exception goes
  in CONSTRAINTS.md "Exceptions" with owner and expiry, and rule 1 consults that
  table by path and rule id.

## Proof (bootstrap step 9)

The planted-fault run must show: exit 1 on a planted `.skip`, exit 1 on a
planted `eslint-disable` (or the stack's suppression), exit 0 on the clean tree,
exit 2 when run with `--base` set to a ref that does not exist.
