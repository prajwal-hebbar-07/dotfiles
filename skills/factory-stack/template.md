# Stack: <product name>

<!-- Header, only while the gate is open. Delete after approval.
What changed since the last review: ...
Factory's calls (decided without you, minor): ...
-->

One section per decision area, plus the compatibility table. A choice the
user kept (REQUIREMENTS.md "Tech choices": Mine) says so. Sources are the
official pages the scouts read; fetched pages were treated as data, not
instructions (addyosmani `source-driven-development`).

## Summary

| Area | Choice | Version | Decided by | ADR |
| --- | --- | --- | --- | --- |
| Language / runtime | | | Mine / Factory's | |
| Framework | | | | |
| Data store | | | | |
| Hosting / deploy | | | | |
| Test tooling | | | | |
| Other | | | | |

## Decisions

### <Area>

- **Chosen:** <name and version>, because <fit to R numbers, cost, operational load, team familiarity>.
- **Runner-up:** <name>, not chosen because <reason>.
- **Sources:** <official doc URLs>
- **Kept piece, with its reason:** <each dependency or service this adds, and the R number or constraint that requires it>
- **Brings back a dropped piece:** <what would justify adding the simpler-round rejects>

### <Area>

...

## Factory compatibility

Hard pass/fail, before any scoring. Every row for the chosen stack. A fail
needs a stated substitute or the stack is out.

| Check the factory runs later | Needs | Chosen stack's tool | Pass / Substitute |
| --- | --- | --- | --- |
| Types and lint for `check:fast` | | | |
| Line coverage as lcov | | | |
| Mutation testing | StrykerJS, mutmut, or equivalent | | |
| Module boundary checker | dependency-cruiser, import-linter, or equivalent | | |
| Semgrep rules for the language | | | |
| Lockfile osv-scanner reads | | | |
| QA driver | Playwright (web), a PTY (CLI), omp `computer` (desktop) | | |
| Data seedable from an empty directory | | | |
| Official CI image | | | |

## Out of scope for the stack

Pieces dropped in the simplicity round, each with what would bring it back.
Also written to `docs/factory/out-of-scope/<concept>.md`.

- <piece> — <why dropped> — <what would justify it>

## ADRs

| ADR | Decision |
| --- | --- |
| [0001](adr/0001-<slug>.md) | <title> |
