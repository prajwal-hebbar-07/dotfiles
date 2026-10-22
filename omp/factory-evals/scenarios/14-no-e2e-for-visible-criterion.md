# 14 User-visible criterion without a committed E2E test

Gate: test review fails when a user-visible acceptance criterion has no committed E2E test that ran, even if unit tests pass (SOFTWARE-FACTORY.md §5.8 tests table, §5.2 test review).

## Setup

base: app

```file path=e2e/add.e2e.mjs
// R1 end-to-end test (exists, passes)
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { addTask } from '../src/tasks.mjs';

test('e2e R1: adding "buy milk" shows one open task', () => {
  assert.deepEqual(addTask([], 'buy milk').map((t) => t.title), ['buy milk']);
});
```

```file path=public/index.html
<!doctype html>
<html><body>
<ul id="list"></ul>
<button id="clear-completed">Clear completed</button>
</body></html>
```

```sh setup
python3 - <<'PY'
import json
d=json.load(open('package.json')); d['scripts']['e2e']='node --test e2e/'
json.dump(d,open('package.json','w'),indent=2)
p='docs/factory/REQUIREMENTS.md'; s=open(p).read()
s=s.replace("\nOut of scope","- R5 (user-visible). Clear completed. Given two done tasks and one open task, when I click \"Clear completed\", then only the open task is listed.\n\nOut of scope")
open(p,'w').write(s)
p='docs/factory/CONSTRAINTS.md'; s=open(p).read()
s+="\n- `e2e`: `npm run e2e` (committed tests under `e2e/`). Each user-visible acceptance criterion has one committed E2E test that ran, and each seam has an integration test.\n"
open(p,'w').write(s)
PY
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.5' '{"status":"factory:review","branch":"factory/5-clear","attempts":{}}'
git checkout -q -b factory/5-clear
cat >> src/tasks.mjs <<'JS'

export function clearCompleted(tasks) {
  return tasks.filter((t) => !t.done);
}
JS
cat >> test/tasks.test.mjs <<'JS'

test('clearCompleted keeps only open tasks', () => {
  const tasks = [{ id: 1, title: 'a', done: true }, { id: 2, title: 'b', done: false }];
  assert.deepEqual(clearCompleted(tasks), [{ id: 2, title: 'b', done: false }]);
});
JS
sed -i.bak "s/import { addTask, completeTask, deleteTask }/import { addTask, completeTask, deleteTask, clearCompleted }/" test/tasks.test.mjs && rm test/tasks.test.mjs.bak
git add -A && git commit -qm "feat: clear completed tasks (R5)"
```

## Prompt

```prompt
Spawn `factory-test-review` for issue #5 (acceptance criterion R5: "Given two done tasks and one open task, when I click Clear completed, then only the open task is listed"; R5 is marked user-visible), branch factory/5-clear vs main. Brief: docs/factory/ (CONSTRAINTS.md names the `e2e` command), `npm run check:task`. Report its verdict and findings.
```

## Expected

- `npm test` passes; the unit test for `clearCompleted` exists.
- `factory-test-review` returns FAIL: the criteria-to-test map shows R5 has only a unit test and no committed E2E test under `e2e/`.

## Rubric

PASS only if the verdict is FAIL and a finding states that R5 (user-visible) lacks a committed E2E test.
FAIL if PASS, or if FAIL is for an unrelated reason only.
