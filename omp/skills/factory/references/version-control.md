# Factory version control and checkpoint history

Every factory work item leaves a navigable git history: one branch per work item, small self-contained commits at each meaningful interval, and tags at accepted gates. The user must be able to inspect any point, revert a single change, branch from a checkpoint, or cherry-pick one feature into another line of work.

## Standing authority

The user has granted a standing `checkpoint_commit` permission for factory work items. Within the current work item it covers only:

- Creating and switching to the work branch from the recorded base.
- Staging explicitly listed, factory-owned paths.
- Creating new commits on the work branch.
- Creating local tags under `factory/<work-id>/`.

It does not cover, and each still needs explicit permission: `git init`, push, merge or cherry-pick into any other branch, rebase, amend, squash, reset, force operations, deleting branches or tags, stash, checkout of files over local changes, rewriting history, or committing changes the factory did not make.

## Intake: establish the branch

1. Confirm the target is a git repository. If not, ask once whether to run `git init` (and an initial commit of existing files, which needs separate approval because those files are the user's). Without a repository, record `version_control: none` and the resulting rollback limitation.
2. Stop and ask if the repository is mid-merge, mid-rebase, mid-cherry-pick, bisecting, or on a detached HEAD.
3. Record base branch, base SHA (`git rev-parse HEAD`), and the pre-existing dirty paths (`git status --porcelain`). Pre-existing dirty paths belong to the user and are never staged by the factory.
4. Create the work branch `factory/<work-id>` from the current HEAD (`git switch -c factory/<work-id>`). Uncommitted user changes travel with the switch untouched; tell the user the active branch changed. Reuse an existing repository branch-naming convention when one exists.
5. Detect the commit-message convention from recent `git log --oneline -n 30` and follow it. Default to Conventional Commits.
6. Inspect commit hooks (`.git/hooks/`, `core.hooksPath`, husky, lefthook, pre-commit, lint-staged config) without running them. If a hook runs builds, linters, tests, or other checks, that is runtime verification: ask once per work item whether to commit with hooks running or with `--no-verify`. Never pass `--no-verify` without that explicit answer. If the user allows neither, record that checkpoint commits are blocked and why, and keep a patch artifact per checkpoint instead.

## When to commit

Commit at every interval where the tree is in a coherent, explainable state. At minimum:

| Interval | Commit content |
| --- | --- |
| Work record created | `.factory/<work-id>/` only |
| Each human gate decision (approve, request changes, reject, waiver, permission change) | Updated work record only |
| Each completed implementation task inside a batch | That task's production code with its tests |
| Documentation change that stands alone | Docs only |
| Each review-feedback revision | The revision's code/test/doc changes |
| Batch packet prepared for code review | Work record pointing at the review head SHA |
| Before any risky operation (large refactor, generated code, migration authoring) | Current coherent state first |

Prefer more small commits over fewer large ones, but never commit a half-edited file or a state that mixes two unrelated concerns. A commit is a checkpoint, not a claim of verification: do not write "tested", "verified", or "passing" in a message unless authorized checks actually passed for that exact content.

## Commit shape for cherry-picking

- One concern per commit. Feature code and its unit tests travel together; unrelated refactors, formatting, docs, and factory records are separate commits.
- Never mix `.factory/` record changes into code commits, so feature commits cherry-pick cleanly into repositories or branches without the record.
- Each commit should compile/read coherently on top of its parent as far as can be judged from source; note known dependencies on earlier commits in the body.
- Stage explicit paths only: `git add -- <path>...`. Never `git add -A`, `git add .`, or `git commit -a`. Check `git diff --cached --stat` before committing; unstage anything not owned by the factory.
- Never commit secrets, credentials, `.env` files, large binaries, or build output. Respect `.gitignore`; do not edit it without permission.

### Message format

```
<type>(<scope>): <imperative summary, ≤72 chars>

<why this change exists; notable decisions; dependencies on earlier commits>

Factory-Work: <work-id>
Factory-Batch: <B1|none>
Factory-Reqs: <R1, R2|none>
Factory-Stage: <requirements_review|...|accepted>
```

Trailers make history queryable: `git log --grep='Factory-Work: <work-id>'`, `git log --grep='Factory-Reqs:.*R2'`, or `git log --format='%h %s%n%(trailers)'`.

## Tags

Lightweight, local, never moved or deleted without permission:

- `factory/<work-id>/base`: the recorded base SHA.
- `factory/<work-id>/b<N>-review-r<rev>`: the head presented for batch code review revision `<rev>`.
- `factory/<work-id>/b<N>-accepted`: the head the user accepted for batch `<N>`.
- `factory/<work-id>/accepted`: integration-accepted head.

If a tag name already exists, append a suffix rather than moving it.

## Concurrency

Workers never run mutating git commands (`add`, `commit`, `switch`, `tag`, `stash`, `reset`, …). They report their changed files. The main agent, as sole integration owner, inspects the output, then stages and commits each worker's slice as its own commit after the slice settles. This avoids index races and keeps one commit per independent slice. With isolated worktrees, commit inside the isolated branch only if the apply flow preserves those commits; otherwise commit after applying.

## Review identity

A code-review revision is identified by the base SHA and the review head SHA (plus its tag). The diff shown to the user is `git diff <base>..<head>` together with the commit list `git log --oneline <base>..<head>`. Uncommitted factory changes at review time are a defect: commit them first. Any later change produces new commits and a new review revision; never amend or rebase a reviewed commit.

## Integration

Merging into the base branch is a separate `merge_push` permission. Recommend `git merge --no-ff factory/<work-id>` so the whole feature is one merge commit: revertible as a unit with `git revert -m 1 <merge-sha>` and its commits still individually cherry-pickable. Squash merges destroy the per-step history; offer them only if the user asks. Keep the work branch and tags after merge unless the user asks to delete them.

## Using the history (only on user request)

All of these are non-destructive and preserve existing commits. Run them only when the user asks; anything that touches another branch needs `merge_push` permission.

| Goal | Command |
| --- | --- |
| See feature history | `git log --oneline --decorate factory/<work-id>` or `git log --grep='Factory-Work: <work-id>'` |
| See what a checkpoint changed | `git show <sha>` |
| Compare two checkpoints | `git diff <sha-a>..<sha-b>` |
| Undo one commit, keeping history | `git revert <sha>` |
| Undo a merged feature | `git revert -m 1 <merge-sha>` |
| Start new work from a checkpoint | `git switch -c <new-branch> <sha-or-tag>` |
| Look at an old state without changing branches | `git worktree add ../<dir> <sha-or-tag>` |
| Take one feature onto another branch | On the target branch: `git cherry-pick <sha>` or a range `git cherry-pick <first>^..<last>` |
| Take a feature's commits without the factory record | Cherry-pick the code/doc commits only; record commits are separate by construction |

Never use `git reset --hard`, `git checkout -- <path>`, `git clean`, or force-push to "go back". Going back means a new branch from the checkpoint or a revert commit. If the user explicitly asks for a destructive operation, state exactly what will be lost first.

## Recording

Append every commit to the work record's checkpoint log: short SHA, subject, stage, batch, and requirement IDs. Because the record is committed in its own follow-up commit, the log entry for a code commit appears in the next record commit; do not amend to fold it in.
