---
name: ship
description: Full git shipping flow in one shot - stage ALL changes, commit with a semantic (Conventional Commits) message, then pull with a merge (never rebase) and push. Stops on merge conflicts instead of guessing; never adds AI attribution, never force-pushes. Use when the user says "/ship", "ship it", "stage everything, commit and push", or "commit and push everything".
---

# Ship (stage all → commit → pull/merge → push)

Do the whole shipping flow in one invocation: stage everything, make one
semantic commit, bring the branch up to date with a merge pull, push.

## Flow

1. **Check state.** Run together:
   - `git status --porcelain` — what's changed
   - `git branch --show-current` and `git rev-parse --abbrev-ref @{upstream}`

   If there are no changes at all AND no unpushed commits, say the branch is
   already in sync and stop. If there is nothing to commit but unpushed
   commits exist, skip to step 4.

2. **Stage everything.** `git add -A`. Then read what got staged:
   - `git diff --cached --stat` and `git diff --cached`

3. **Commit** with a semantic message written from the staged diff:

   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<optional scope>): <concise summary>

   <body: what changed and why, plus pointers to the key files/areas touched>
   EOF
   )"
   ```

   Message rules (same as the commit skill):
   - Conventional Commits subject: imperative mood, lowercase, no trailing
     period, ≤ 72 chars; types like feat/fix/refactor/docs/chore/etc.
   - Body (unless trivial): what and why, `-` bullets for distinct changes,
     pointers to notable files, prose wrapped ~72 columns.
   - **Never add AI attribution** — no `Co-Authored-By: Claude`, no
     "Generated with" lines, nothing indicating AI involvement.
   - **No `--no-verify`** unless the user explicitly asks to skip hooks.

4. **Pull with merge.** If there is no upstream, ask before creating one
   (`git push -u origin <branch>`) and finish there if the user agrees.
   Otherwise `git fetch` then `git pull --no-rebase` — always a merge,
   regardless of `pull.rebase` config.

5. **On merge conflicts: stop.** Do not resolve, do not abort, do not
   commit. Report the conflicted files (`git diff --name-only
   --diff-filter=U`) and wait for the user's instructions.

6. **Push.** Plain `git push` — no `--force`, no `--force-with-lease`,
   unless the user explicitly asks.

7. **Report.** The commit hash and subject, what came in from the pull
   (including a merge commit if one was created), and confirmation that
   local and remote are in sync.

## Hard rules

- **Stage everything, exactly once, at step 2** — no second `git add` later
  to sweep in files that appeared mid-flow.
- **One commit per invocation.**
- **Merge, never rebase. Never force-push. Never auto-resolve conflicts.**
- **Never add AI attribution to the commit message.**
- Ship only the **current branch**.
