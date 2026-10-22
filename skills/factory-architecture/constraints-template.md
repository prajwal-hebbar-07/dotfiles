# Constraints

Format and defaults: addyosmani `constraint-driven-development`. Every
number has a stated reason. Every dimension names the command that produces
its verdict; a number with no command is an aspiration, not a constraint.
This file is canonical: the `check:*` scripts mirror it, and if they drift
this file wins. It is committed with ARCHITECTURE.md and, like any approved
doc, changes only by reopening the gate.

Last reviewed: <YYYY-MM-DD>. ASVS level: <1|2> (from ARCHITECTURE.md).

## Floor (always enforced)

- No new suppression comments: `@ts-ignore`, `eslint-disable`, `# noqa`,
  `# type: ignore`, `istanbul ignore`, `Stryker disable`, `nosemgrep`,
  `gitleaks:allow`.
- No stubs (`throw new Error("Not implemented")`, `TODO` standing in for
  code) and no empty `catch {}`.
- No skipped or deleted tests without a reason in the commit message.
- No secrets in source.
- No new runtime dependency that STACK.md or the issue's plan does not name
  (checked on the lockfile diff).
- This file is never weakened to make a change pass: a threshold lowered, a
  severity dropped, a check moved out of `check:fast`, a new Exceptions row.

## Dimensions

Scoped to the diff where the tool allows it. Defaults are CDD's; change a
number only with a reason in the Why column.

| # | Dimension | Rule | Command | Why this number | Runs at |
| --- | --- | --- | --- | --- | --- |
| D1 | Lint and format | zero errors, the language's recommended preset, no custom rules | `<cmd>` | existing repo keeps its config | `check:fast` |
| D2 | Types | zero errors | `<cmd>` | | `check:fast` |
| D3 | Secrets | no findings | `gitleaks detect --redact --no-banner` over the branch's commits | `--redact` keeps the value out of transcripts | `check:fast`, CI |
| D4 | Changed-line coverage | >= 80% | `<test cmd + lcov>` intersected with `git diff` | high enough to force a test, low enough to allow a config line | `check:task`, CI |
| D5 | Mutation score | >= 60% on changed files | `<stryker / mutmut cmd>` | typical for a never-mutated suite; raise toward 80% as it matures | `check:task`, CI |
| D6 | Module boundaries | zero violations of ARCHITECTURE.md's allowed dependencies | `<depcruise / import-linter cmd>` | keeps module structure from eroding issue by issue | `check:task` |
| D7 | New code findings | zero new Semgrep findings | `semgrep scan --baseline-commit <merge-base> --config <language rules> --config p/owasp-top-ten --config p/cwe-top-25` | new findings only, so an old repo is not blocked | `check:full` |
| D8 | Dependency audit | nothing at high or above | `osv-scanner scan source -r .` (when a lockfile changes) | below high is mostly noise | `check:full` |
| D9 | Accessibility (UI only) | zero critical or serious violations, WCAG 2.2 AA | `<axe command>` on every QA state | | QA, CI |
| D10 | Bundle budget (web only) | <bytes> per entry | `<size-limit cmd>` | | `check:full` |

Drop a row the product cannot run (no URL for a CLI: no D9). Say so here
rather than leaving a check that cannot run. At least one dimension must be
external (D3, D7, D8, D9: a tool another party's rules drive), not only the
project's own tests.

## Ratchets

Where no target number exists, today's value must not fall (tolerance 0.5%).
Update the value when it improves; a drop is a finding.

| Metric | Today | Direction | Command |
| --- | --- | --- | --- |
| Project line coverage | <measured, or "n/a: new repo"> | must not fall | |
| Bundle size (main) | | must not grow | |

## Scripts

Mirror the dimensions. Defined in the app's own task runner by issue #0.

| Script | Runs | Budget |
| --- | --- | --- |
| `check:fast` | after each edit: D1, D2, D3, the floor on the diff, related unit tests | seconds |
| `check:task` | when the builder thinks it is done: `check:fast`, D4, D5, D6, all unit and integration tests, each new or changed E2E test three times (flaky is failing) | under 90 s at task end unless the grill set another |
| `check:full` | in CI and before the PR ask: `check:task`, D7, D8, D9, D10, the whole E2E suite | CI |

## Published standards

One per area, only ones a tool can check.

| Area | Standard | How it is enforced | When |
| --- | --- | --- | --- |
| Code style | The language's official or de-facto formatter and linter, recommended preset (PEP 8 via Ruff; `gofmt` + `go vet`; `rustfmt` + Clippy; Prettier + typescript-eslint `recommended`; ktlint) | `check:fast` | always; an existing repo keeps its own config |
| Security requirements | OWASP ASVS 5.0.0, level above | abuse cases cite IDs (`v5.0.0-1.2.5`); security scan and spec review check them | always |
| Common vulnerabilities | OWASP Top 10:2025, 2025 CWE Top 25 | Semgrep `p/owasp-top-ten`, `p/cwe-top-25`, new findings only | `check:full` |
| Accessibility | WCAG 2.2 AA | axe-core on every QA state; keyboard, focus, screen reader in UI review | apps with a UI |
| API errors | RFC 9457 Problem Details | spec review; one test per error path | HTTP APIs |
| Config | Twelve-Factor config in env vars; `.env.example` committed, `.env` ignored | gitleaks; issue #0 checklist | always |
| Commits | Conventional Commits 1.0 | the `commit` skill | always |
| Versions | SemVer 2.0.0 | release step | a library or an API others call |

Delete rows that do not apply (no HTTP API, no UI, not a library) and say
why in one line under the table.

## Test levels

The suite is set up once by issue #0 and grows with every issue. Each
acceptance criterion is proved at the lowest level that can prove it.

| Level | Written when | Runs in |
| --- | --- | --- |
| Unit | every branch, loop, parser, calculation, or rule | `check:fast` (related tests), `check:task` |
| Integration | every seam in ARCHITECTURE.md that crosses the database, an HTTP call, a queue, or the file system; real seeded store, mock only outside services | `check:task`, `check:full` |
| End-to-end | each acceptance criterion a user can see: one committed test per Given / When / Then, in the repo's E2E runner | `check:full`, CI |
| Regression | before any bug fix: a test that fails on the bug, then the fix | stays in the suite |

The committed E2E tests are the regression suite. Flaky is failing: a test
is never retried until it passes and never skipped without a reason.

## Exceptions

A rule is waived only here, with an owner and an expiry (default 90 days,
never over a year).

| ID | Rule | Path | Reason | Owner | Expires |
| --- | --- | --- | --- | --- | --- |
