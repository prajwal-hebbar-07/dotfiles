# Feature grill coverage: #<n> <title> · architecture

A category is `covered` only when architecture.md says what is decided there,
and `n/a` only with the user's own reason. `open` blocks the end of the grill.

Status: `open` → `covered` · `n/a` · `deferred`.

| # | Category | What it asks | Status | Where | Note |
| --- | --- | --- | --- | --- | --- |
| 1 | As is | Every fact the design rests on is in the code, with its source | open | | |
| 2 | Shape and fit | What it extends, what is new, why not smaller or bigger; the stop rule | open | | |
| 3 | Module changes | One responsibility each; new ones pass the deletion test; extended ones stay deep | open | | |
| 4 | Interfaces and callers | Operations added or changed; every existing caller and what it sees | open | | |
| 5 | Dependencies | Direction, no cycles, nothing reaching past an interface | open | | |
| 6 | Data and ownership | Every entity changed or new, one writer, who may write it | open | | |
| 7 | Existing rows and migration | Default, backfill, run twice, undo, without losing data | open | | |
| 8 | Lifecycles and deletion | States, transitions, cascades, what is kept and erased | open | | |
| 9 | Consistency and concurrency | Where a transaction ends, two writers, out-of-order events | open | | |
| 10 | Idempotency and retries | Doing it twice, a retry after a timeout | open | | |
| 11 | Flows for every requirement | Each `R` served, start to finish, through existing and new modules | open | | |
| 12 | Failure and error model | What breaks at each step, what is left, what the caller sees, in the app's style | open | | |
| 13 | Permissions | Where the existing check runs on every new path | open | | |
| 14 | Trust boundaries and abuse | Input checked where trust changes; each abuse case with a test | open | | |
| 15 | Background work | Jobs, schedules, duplicates, through the existing mechanism | open | | |
| 16 | Integrations | Each at a seam: adapter, failure mode, rate limit, fake for tests | open | | |
| 17 | Configuration and secrets | Where each lives, through the existing mechanism | open | | |
| 18 | Observability | What is logged per flow, through the existing logging | open | | |
| 19 | Performance at the numbers | Hot paths, indexes, today's volumes and the requirements' | open | | |
| 20 | Tests and seams | Where tests cross, the existing test style, what is faked | open | | |
| 21 | Rollout and rollback | Deploy order, a switch if any, undoing a bad release | open | | |
| 22 | Dependencies added | Each new library against what the stack and the code already do | open | | |
| 23 | Simplicity | Each new piece earns its place against what exists | open | | |

## Closing checks

| Check | Status | Round | Hashes | Result |
| --- | --- | --- | --- | --- |
| Simplicity sweep | open | | | |
| Pre-mortem | open | | | |
| Fresh-eyes check | open | | | |
| Confirm | open | | | |
