# 10 Builder killed mid-step: resume

Gate: the next `/skill:factory` resumes at the open ledger step, keeps or stashes the interrupted work, and never repeats finished steps (SOFTWARE-FACTORY.md §5.6 resume protocol).

## Setup

base: app

```sh setup
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.1' '{"status":"factory:building","branch":"factory/1-tasks","attempts":{}}'
git checkout -q -b factory/1-tasks
T=$(printf '\t')
NOW=$(date -u +%FT%TZ)
printf '%s\n' \
 "$NOW${T}1${T}build${T}plan${T}start${T}factory-planner${T}opus${T}-${T}-${T}-" \
 "$NOW${T}1${T}build${T}plan${T}done${T}factory-planner${T}opus${T}-${T}PASS${T}-" \
 "$NOW${T}1${T}build${T}tests${T}start${T}factory-builder${T}opus${T}-${T}-${T}-" \
 "$NOW${T}1${T}build${T}tests${T}done${T}factory-builder${T}opus${T}$(git rev-parse --short HEAD)${T}PASS${T}-" \
 "$NOW${T}1${T}build${T}implement${T}start${T}factory-builder${T}opus${T}-${T}-${T}-" >> .factory/ledger.tsv
"$EVAL_FS" set nextAction '"Resume issue #1 at step implement."'
# the builder was killed halfway: an uncommitted half-edit that breaks the suite
printf '\nexport function archiveTask(tasks, id) {\n  return tasks.map((t) => (t.id === id ? { ...t, archivedAt:\n' >> src/tasks.mjs
```

## Prompt

```prompt
/skill:factory
```

## Expected

- The router reads state.json and the ledger, finds the open `start` for step `implement` (issue 1) and reports it as interrupted work.
- It does not re-run `plan` or `tests` (no new start rows for them), does not restart requirements, and does not recommit finished steps.
- The half-written, syntax-broken edit is not kept as-is: it is stashed (to `wip/1/implement` or a stash) and `implement` restarts clean from the brief, or it is completed and `npm test` passes.
- A new `start` row for `implement` appears; no `done` row before its own check passes.

## Rubric

PASS only if the first pipeline action is the `implement` step, earlier done steps are not repeated, and the broken working-tree change is either stashed or finished with passing `npm test`.
FAIL if the factory starts from the planner, ignores the open row, commits the broken file, or marks `implement` done without a passing check.
