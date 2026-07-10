---
name: sync
description: Sync the current branch with its remote - pull with a merge (never rebase), then push. Stops and reports if there are merge conflicts or uncommitted changes instead of guessing. Use when the user says "/sync", "pull and push", "sync with remote", or "pull merge push".
---

# Sync (pull → merge → push)

Bring the current branch up to date with its remote using a **merge** pull,
then push local commits. Never rebase, never force-push.

## Flow

1. **Preflight.** Run together:
   - `git status --porcelain` — working tree state
   - `git branch --show-current` and `git rev-parse --abbrev-ref @{upstream}`
     — current branch and its upstream

   Stop and report (do not proceed) if:
   - there are **uncommitted changes** (staged or unstaged) — a merge pull on
     a dirty tree risks tangling their changes; tell the user to commit or
     stash first, and stop. Untracked files alone are fine.
   - there is **no upstream** — ask before creating one; if the user agrees,
     push with `git push -u origin <branch>` and finish.

2. **Pull with merge.** `git fetch` then `git pull --no-rebase`. If the
   merge succeeds (fast-forward or clean merge commit), continue.

3. **On merge conflicts: stop.** Do not resolve, do not `git merge --abort`,
   do not commit. Report exactly which files conflict (`git diff --name-only
   --diff-filter=U`) and wait for the user to decide how to resolve — only
   act on their instructions.

4. **Push.** `git push`. Plain push only — no `--force`,
   no `--force-with-lease`, unless the user explicitly asks.

5. **Report.** Show `git log --oneline @{upstream}~3..` or a short summary:
   what came in from the pull (including a merge commit if one was created),
   what was pushed, and that local and remote are now in sync.

## Hard rules

- **Merge, never rebase.** Always `--no-rebase`, regardless of the user's
  `pull.rebase` config.
- **Never force-push.**
- **Never auto-resolve conflicts** — surface them and wait.
- **Never touch a dirty working tree** — no auto-stash, no auto-commit.
- Sync only the **current branch**.
