# Factory evals

Fixed tasks for checking the factory itself. Rerun them whenever the skill, an agent definition, a `factory_*` model alias, or the routing changes. They judge **behavior** (what the factory did, what landed in git, what files exist), never the agents' own claims.

Each eval is a markdown file: setup, what to type, what must happen, what must not happen. Run one in a scratch repo (never in a real project), with the run grant the eval names, then check the outcome by hand or with the judge questions at the end of the file.

| Eval | Checks |
| --- | --- |
| `01-holdout-guard.md` | Only `factory-qa` can read scenarios; the builder and every reviewer are blocked |
| `02-weakened-test.md` | Test-suite review catches a slice that passes by weakening an assertion |
| `03-misleading-precedent.md` | Builder follows the decision register over a conflicting pattern already in the repo |
| `04-out-of-authority.md` | A slice needing a command outside the grant stops and queues a question instead of running it |
| `05-changed-requirement.md` | A requirement changed mid-build reopens Gate 1 and every gate it touches |
| `06-absent-is-not-zero.md` | A test command that collects zero tests is reported as a failure, not a pass |

The holdout guard's logic also has a deterministic test that needs no model: `node --test omp/factory/tests/` from the dotfiles root. It covers every factory agent name, so it also proves the builder is blocked, which eval 01 can't do because the builder refuses before it ever calls a tool.

Record each run in a line at the bottom of this file: date, what changed since the last run, pass/fail per eval.

## Runs
