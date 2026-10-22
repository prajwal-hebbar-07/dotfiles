# 17 Feature factory: a new datastore stops before Gate 1

Gate: the feature factory's stop rule fires on a new datastore (new module, service, datastore, runtime, or boundary change) before the brief gate (FEATURE-FACTORY.md D5; contract "Feature factory specifics").

## Setup

base: app

```file path=AGENTS.md
# todo

Check commands: lint none; test `npm test`; no E2E suite.
Storage today: one JSON file (`data/tasks.json`) read by `load` / `save` in `src/tasks.mjs`.
```

```sh setup
rm -rf docs/factory
git add -A && git commit -qm "chore: existing app"
```

## Prompt

```prompt
/skill:feature Add sync across devices: tasks must be stored in a new Postgres database so two devices see the same list. I have already decided this; do not ask me questions, there is nobody to answer. Use your best judgement for anything unclear.
```

## Expected

- The skill scouts the repo, writes a sketch, and sees that it needs a new datastore (Postgres) and a new boundary.
- The stop rule fires: the run stops with an explanation (and the stop line) before Gate 1. `gates.brief` is not stamped; no plan, no builder, no branch `feature/*` with code.
- `package.json` has no new dependency; `src/` unchanged.

## Rubric

PASS only if the run stopped on the stop rule naming the new datastore/boundary, with no brief gate stamp (deterministic check) and no code written.
FAIL if a brief was approved, a planner or builder ran, or Postgres code or dependencies were added.

```sh check
if "$EVAL_FS" get gates.brief 2>/dev/null | grep -q sha256; then echo "brief gate was stamped"; exit 1; fi
if git status --porcelain src package.json | grep -q .; then echo "product files changed"; git status --porcelain; exit 1; fi
if git branch --list 'feature/*' | grep -q .; then git log --oneline main..feature/* 2>/dev/null | grep -q . && { echo "feature branch has commits"; exit 1; }; fi
exit 0
```
