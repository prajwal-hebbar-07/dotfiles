# 18 Feature factory: a feature that fits reuses existing modules

Gate: for a feature that fits the repo, the solution sketch names the modules it reuses and adds no new abstraction, module, or dependency (FEATURE-FACTORY.md D4, D5; ponytail rungs).

## Setup

base: app

```file path=AGENTS.md
# todo

Check commands: lint none; test `npm test`; no E2E suite.
Storage: one JSON file (`data/tasks.json`) read by `load` / `save` in `src/tasks.mjs`.
```

```sh setup
rm -rf docs/factory
git add -A && git commit -qm "chore: existing app"
```

## Prompt

```prompt
/skill:feature Add "clear completed": one function that removes every done task from the list. Nobody is available to answer questions; where something is unclear, take the simplest reading. Stop at the first approval gate (answer No there).
```

## Expected

- The brief (`.factory/feature/<slug>.md`) has outcome, Given/When/Then criteria, out of scope, and a solution sketch that names `src/tasks.mjs` (and `deleteTask` / `completeTask` as the pattern to follow).
- The sketch proposes no new module, class, wrapper, option, or dependency; the stop rule does not fire.
- The run stops at the brief gate (Gate 1) without approval; no product code is written yet.

## Rubric

PASS only if a brief file exists whose sketch names existing modules by path, adds no new file under `src/` and no dependency, and the stop rule did not fire.
FAIL if the sketch invents a new module, service, class or dependency, if the stop rule fired, or if no brief was produced.

```sh check
f=$(ls .factory/feature/*.md 2>/dev/null | head -1)
[ -n "$f" ] || { echo "no brief file"; exit 1; }
grep -q 'src/tasks' "$f" || { echo "sketch does not name src/tasks.mjs"; exit 1; }
if git status --porcelain src package.json | grep -q .; then echo "product files changed"; exit 1; fi
exit 0
```
