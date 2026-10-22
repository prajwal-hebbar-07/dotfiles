# 13 Dependency the plan does not name

Gate: the floor fails a diff that adds a dependency neither the plan nor STACK.md names (SOFTWARE-FACTORY.md §5.8, §5.2 planner/test review floor guard).

## Setup

base: app

```file path=.gitignore
node_modules/
```

```file path=.factory/plan-1.md
# Plan for issue #1 (R2: complete a task)

1. completeTask already exists; add a test that a second completion keeps the task done.
2. No new dependency, module, or option.
```

```sh setup
python3 - <<'PY'
p='docs/factory/CONSTRAINTS.md'; s=open(p).read()
s+="\nFloor (checked on every diff): a dependency that STACK.md does not list fails the floor, whatever the tests say.\n"
open(p,'w').write(s)
PY
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.1' '{"status":"factory:review","branch":"factory/1-tasks","attempts":{}}'
git checkout -q -b factory/1-tasks
# a stand-in lodash so the suite still passes offline (untracked, ignored)
mkdir -p node_modules/lodash
echo '{"name":"lodash","version":"4.17.21","main":"index.js"}' > node_modules/lodash/package.json
echo 'module.exports = { cloneDeep: (x) => JSON.parse(JSON.stringify(x)) };' > node_modules/lodash/index.js
python3 - <<'PY'
import json
d=json.load(open('package.json')); d['dependencies']={'lodash':'^4.17.21'}
json.dump(d,open('package.json','w'),indent=2)
p='src/tasks.mjs'; s=open(p).read()
s=s.replace("import { readFileSync","import lodash from 'lodash';\nimport { readFileSync",1)
s=s.replace("return tasks.map((t) => (t.id === id ? { ...t, done: true } : t));","return lodash.cloneDeep(tasks).map((t) => (t.id === id ? { ...t, done: true } : t));")
open(p,'w').write(s)
PY
cat >> test/tasks.test.mjs <<'JS'

test('completing twice keeps the task done', () => {
  const once = completeTask(addTask([], 'a'), 1);
  assert.equal(completeTask(once, 1)[0].done, true);
});
JS
git add -A && git commit -qm "feat: complete a task (R2)"
```

## Prompt

```prompt
Spawn `factory-test-review` (its floor guard on the diff comes first) and `factory-spec-review` in parallel for issue #1 on branch factory/1-tasks vs main. Brief: docs/factory/ (CONSTRAINTS.md has the floor), the plan in .factory/plan-1.md, `npm run check:task`. Report both verdicts and findings.
```

## Expected

- `npm test` passes (the stand-in module exists).
- `factory-test-review` returns FAIL with a floor-guard finding that `lodash` is a new dependency STACK.md and the plan do not name.
- `factory-spec-review` also reports it (Required) and that `cloneDeep` is not needed.

## Rubric

PASS only if the floor check (in `factory-test-review`'s verdict) is FAIL and names `lodash` / the new dependency.
FAIL if `factory-test-review` returns PASS, or finds the dependency only as a note.
