---
name: ship
description: Full git shipping flow in one shot - stage ALL changes, commit with a semantic (Conventional Commits) message, then pull with a merge (never rebase) and push. Stop on merge conflicts instead of guessing; never add AI attribution or force-push. Use when the user says "/ship", "ship it", "stage everything, commit and push", or "commit and push everything".
---

# Ship (stage all → commit → pull/merge → push)

Do the whole shipping flow in one invocation: stage everything, make one
semantic commit, bring the branch up to date with a merge pull, and push.

## Flow

1. **Check state.** Run together:
   - `git status --porcelain` — what's changed
   - `git branch --show-current` and `git rev-parse --abbrev-ref @{upstream}`

   If there are no changes at all AND no unpushed commits, say the branch is
   already in sync and stop. If there is nothing to commit but unpushed
   commits exist, skip to step 4.

2. **Stage everything.** Run `git add -A`. Then read what got staged:
   - `git diff --cached --stat` and `git diff --cached`

3. **Commit** with a semantic message written from the staged diff:

   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<optional scope>): <concise summary>

   <body: what changed and why, plus pointers to the key files/areas touched>
   EOF
   )"
   ```

   Follow these message rules:
   - Use a Conventional Commits subject in imperative mood, lowercase, with
     no trailing period and at most 72 characters. Use types such as
     `feat`, `fix`, `refactor`, `docs`, or `chore`.
   - Include a body unless the change is trivial. Explain what changed and
     why, use `-` bullets for distinct changes, point to notable files or
     areas, and wrap prose at about 72 columns.
   - **Never add AI attribution.** Do not add assistant `Co-Authored-By`
     trailers, "Generated with" lines, or anything indicating AI involvement.
   - **Do not use `--no-verify`** unless the user explicitly asks to skip
     hooks.

4. **Pull with merge.** If there is no upstream, ask before creating one with
   `git push -u origin <branch>`, then finish there if the user agrees.
   Otherwise, run `git fetch`, then `git pull --no-rebase`. Always merge,
   regardless of the `pull.rebase` configuration.

5. **Stop on merge conflicts.** Do not resolve, abort, or commit. Report the
   conflicted files from `git diff --name-only --diff-filter=U` and wait for
   the user's instructions.

6. **Push.** Run plain `git push`. Do not use `--force` or
   `--force-with-lease` unless the user explicitly asks.

7. **Report.** Give the commit hash and subject, describe what came in from
   the pull (including a merge commit if one was created), and confirm that
   local and remote are in sync.

## Hard rules

- **Stage everything exactly once, at step 2.** Do not run a second `git add`
  later to sweep in files that appeared mid-flow.
- **Create one commit per invocation.**
- **Merge, never rebase. Never force-push. Never auto-resolve conflicts.**
- **Never add AI attribution to the commit message.**
- Ship only the **current branch**.
