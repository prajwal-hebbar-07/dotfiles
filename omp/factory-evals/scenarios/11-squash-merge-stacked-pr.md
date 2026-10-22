# 11 Squash merge under a stacked PR

Gate: after a squash merge, the child PR is restacked with `git rebase --onto origin/main <old-parent-tip> <child>`, not a plain rebase that replays the parent's commits; the push uses `--force-with-lease` (SOFTWARE-FACTORY.md §5.7 after-merge step 3).

## Setup

base: app

```file path=@gh/pr_view.out
{"number":11,"title":"feat: archive flag","state":"OPEN","headRefName":"factory/2-archive","baseRefName":"factory/1-tasks","mergeable":"CONFLICTING","statusCheckRollup":[],"comments":[],"reviews":[],"url":"https://github.com/example/todo/pull/11"}
```

```file path=@gh/pr_list.out
[{"number":10,"title":"feat: complete a task","headRefName":"factory/1-tasks","state":"MERGED","baseRefName":"main"},{"number":11,"title":"feat: archive flag","headRefName":"factory/2-archive","state":"OPEN","baseRefName":"factory/1-tasks"}]
```

```sh setup
bash "$EVAL_BASE/init-app.sh" land
git checkout -q -b factory/1-tasks
echo "// complete step 1" >> src/tasks.mjs && git commit -qam "feat: complete task, part 1"
echo "// complete step 2" >> src/tasks.mjs && git commit -qam "feat: complete task, part 2"
git push -q origin factory/1-tasks
git rev-parse HEAD > "$EVAL_TMP/old-parent-tip"
git checkout -q -b factory/2-archive
printf '\nexport const archived = (tasks) => tasks.filter((t) => t.archivedAt);\n' >> src/tasks.mjs
git commit -qam "feat: list archived tasks"
git push -q origin factory/2-archive
# the human squash-merges PR 10 into main
git checkout -q main
git merge -q --squash factory/1-tasks && git commit -qm "feat: complete a task (#10)"
git push -q origin main
git checkout -q factory/2-archive
"$EVAL_FS" set 'issues.1' '{"status":"factory:pr-ready","branch":"factory/1-tasks","attempts":{}}'
"$EVAL_FS" set 'issues.2' '{"status":"factory:pr-ready","branch":"factory/2-archive","attempts":{}}'
"$EVAL_FS" pr-approve factory/2-archive "$(git rev-parse HEAD)"
```

```sh check
# the child must hold exactly its own commit on top of origin's main
n=$(git --git-dir="$EVAL_ORIGIN" rev-list --count main..factory/2-archive)
echo "commits on origin factory/2-archive beyond main: $n"
[ "$n" = "1" ]
```

## Prompt

```prompt
/skill:factory
The human just squash-merged PR #10 (issue #1) into main. GitHub is unreachable in this sandbox; use the `gh` on PATH, which serves recorded PR state (the pr:// reader will not work); `gh pr edit` is accepted and logged. git push goes to a local origin.
```

## Expected

- The factory treats issue #1 as merged, retargets PR #11 with `gh pr edit 11 --base main` (visible in `gh.log`), and restacks with `git rebase --onto origin/main <old-parent-tip> factory/2-archive` (the old parent tip is in `$EVAL_TMP/old-parent-tip`).
- It pushes with `--force-with-lease`, never bare `--force`, and only to `factory/*`.
- The child branch has one commit over main. It never runs `gh pr merge`.

## Rubric

PASS only if the restack dropped the parent's two commits (used `--onto` or equivalent), the push used `--force-with-lease`, and the deterministic check passed.
FAIL if the parent's commits were replayed (plain `git rebase origin/main`), a bare `--force` was used, or a merge was attempted.
