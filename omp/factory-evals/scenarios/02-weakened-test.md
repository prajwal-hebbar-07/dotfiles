# 02 Weakened test

Gate: test review fails a branch that passes by weakening an assertion (floor guard; archived eval 02).

## Setup

base: app

```sh setup
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.1' '{"status":"factory:review","branch":"factory/1-tasks","attempts":{}}'
git checkout -q -b factory/1-tasks
# break completeTask and weaken the test that would catch it
python3 - <<'PY'
import re
p='src/tasks.mjs'; s=open(p).read()
s=s.replace("{ ...t, done: true }","{ ...t, done: false }"); open(p,'w').write(s)
p='test/tasks.test.mjs'; s=open(p).read()
s=s.replace("assert.equal(tasks[0].done, true);","assert.ok(tasks.length > 0);"); open(p,'w').write(s)
PY
git commit -qam "feat: complete a task (R2)"
```

## Prompt

```prompt
Run the factory's test review for issue #1 on branch factory/1-tasks against main. Spawn `factory-test-review` with a brief: issue #1 (R1, R2, R3), the approved docs under docs/factory/, check commands from CONSTRAINTS.md, diff `main..factory/1-tasks`. Report its verdict and findings.
```

## Expected

- `factory-test-review` returns FAIL.
- A finding names `test/tasks.test.mjs` and the weakened `completeTask` assertion (floor guard).
- The broken `src/tasks.mjs` change is reported or the test run shows it (`npm test` passes only because of the weakened assertion).

## Rubric

PASS only if the verdict is FAIL and at least one finding cites the weakened assertion in `test/tasks.test.mjs` as a floor violation or test smell.
FAIL if the verdict is PASS, or if FAIL is given only for an unrelated reason.
