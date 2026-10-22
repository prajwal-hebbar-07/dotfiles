# 16 Quota stop mid-step: the next /skill:factory resumes at that step

Gate: a quota stop is not a failure and not a reset. The ledger has an open `start` for the review step, hours old; the next `/skill:factory` resumes that step, does not count the idle gap as running time, and does not escalate to `factory:needs-human` (SOFTWARE-FACTORY.md §5.3 budget, §5.6, §8 item 9).

## Setup

base: app

```sh setup
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.1' '{"status":"factory:review","branch":"factory/1-tasks","attempts":{}}'
git checkout -q -b factory/1-tasks
echo "// complete (R2)" >> src/tasks.mjs && git commit -qam "feat: complete a task (R2)"
SHA=$(git rev-parse --short HEAD)
T=$(printf '\t')
OLD=$(date -u -v-5H +%FT%TZ 2>/dev/null || date -u -d '5 hours ago' +%FT%TZ)
printf '%s\n' \
 "$OLD${T}1${T}build${T}plan${T}start${T}factory-planner${T}opus${T}-${T}-${T}-" \
 "$OLD${T}1${T}build${T}plan${T}done${T}factory-planner${T}opus${T}-${T}PASS${T}-" \
 "$OLD${T}1${T}build${T}implement${T}start${T}factory-builder${T}opus${T}-${T}-${T}-" \
 "$OLD${T}1${T}build${T}implement${T}done${T}factory-builder${T}opus${T}$SHA${T}PASS${T}-" \
 "$OLD${T}1${T}build${T}review${T}start${T}factory-test-review${T}opus${T}$SHA${T}-${T}-" \
 "$OLD${T}1${T}build${T}review${T}verdict${T}factory-test-review${T}opus${T}$SHA${T}quota-stop${T}account quota out at 10% reserve; session ended" >> .factory/ledger.tsv
"$EVAL_FS" set nextAction '"Resume issue #1 at step review (quota stop)."'
```

## Prompt

```prompt
/skill:factory
```

## Expected

- The router reports that issue #1 stopped at step `review` with a quota stop, and starts that step again (a new `start` row for `review`, spawning the reviewers for the head SHA).
- It does not re-run `plan` or `implement`, does not commit anything new, and does not set `factory:needs-human` because of the five hours between the rows (the clock counts only start-to-done spans).
- `factory-state budget 1` is not used as a reason to stop.

## Rubric

PASS only if the next pipeline action is the `review` step, no earlier step was repeated, and the issue was not marked needs-human for time.
FAIL if the factory restarts from plan or implement, declares the budget spent from the five-hour gap, or marks `review` done without running a reviewer.
