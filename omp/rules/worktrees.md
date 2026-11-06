---
alwaysApply: true
---
Git worktrees live inside the repository they belong to, under
`.worktrees/` at the main checkout's root — never beside the repository
(`../<repo>-<branch>`) or anywhere else. From a linked worktree, still use the
main checkout's `.worktrees/`; never nest one worktree inside another.

Before the first `git worktree add`, make git ignore the directory so it never
shows as untracked or gets staged as an embedded repository:

```sh
root=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
common=$(git rev-parse --path-format=absolute --git-common-dir)
mkdir -p "$common/info"
grep -qxF '.worktrees/' "$common/info/exclude" || echo '.worktrees/' >> "$common/info/exclude"
git worktree add "$root/.worktrees/<branch>" -b <branch>
```

Name the directory after the branch, with `/` replaced by `-`. For a bare
repository, ask where the worktree should go.
