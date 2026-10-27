# Architecture grill coverage: <project>

A category is `covered` only when `architecture.md` says what is decided
there, and `n/a` only with the user's own reason. `open` blocks the end of
the grill.

Status: `open` → `covered` · `n/a` · `deferred`.

| # | Category | What it asks | Status | Where | Note |
| --- | --- | --- | --- | --- | --- |
| 1 | Overall shape | Deployable units, where the data lives, why not a simpler or bigger shape | open | | |
| 2 | Module boundaries | One responsibility each; nothing is a pass-through | open | | |
| 3 | Module interfaces | Operations, invariants, order, error modes a caller must know | open | | |
| 4 | Dependencies | Direction, no cycles, nothing reaching past an interface | open | | |
| 5 | Data model and ownership | Every entity, one owner, who may write it | open | | |
| 6 | Entity lifecycles and deletion | States, transitions, cascades, what is kept and erased | open | | |
| 7 | Identifiers and uniqueness | What identifies each thing, duplicates, merges | open | | |
| 8 | Consistency and transactions | Where a transaction ends, what may be seen half-done | open | | |
| 9 | Concurrency and ordering | Two writers, two requests, out-of-order events | open | | |
| 10 | Idempotency and retries | Doing it twice, a retry after a timeout | open | | |
| 11 | Flows for every requirement | Each `R` served by a flow or module, start to finish | open | | |
| 12 | Failure and partial failure | What breaks at each step and what state is left | open | | |
| 13 | Error model | What callers and users see for each kind of failure | open | | |
| 14 | Authentication and authorization | Who they are, what they may do, where it is checked | open | | |
| 15 | Trust boundaries and input checks | Where trust changes, what is validated there | open | | |
| 16 | Abuse cases | Each with a mitigation and a test that shows it holds | open | | |
| 17 | Privacy and retention in the design | Personal data, how long, erasure, export | open | | |
| 18 | Background work and schedules | Jobs, retries, duplicates, what runs when the app is down | open | | |
| 19 | External integrations | Each at a seam: adapter, failure mode, rate limit, fake for tests | open | | |
| 20 | Configuration, secrets, environments | Where each lives, how it reaches the module | open | | |
| 21 | Observability | What is logged or traced per flow, how a failure is found | open | | |
| 22 | Performance at the numbers | Hot paths, indexes, caching, limits | open | | |
| 23 | Test seams and strategy | Where tests cross, what is faked, what runs end to end | open | | |
| 24 | Migrations, rollout, rollback | Schema and release changes without losing data | open | | |
| 25 | Fit with the stack | Each module and flow can be built on the chosen stack | open | | |
| 26 | Simplicity | Each module, layer and seam earns its place | open | | |

## Closing checks

| Check | Status | Round | Hashes (architecture / stack / requirements) | Result |
| --- | --- | --- | --- | --- |
| Simplicity sweep | open | | | |
| Pre-mortem | open | | | |
| Fresh-eyes check | open | | | |
| Confirm | open | | | |
