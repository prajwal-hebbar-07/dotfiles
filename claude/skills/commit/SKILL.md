---
name: commit
description: Commit ONLY the already-staged changes with a semantic (Conventional Commits) message that explains the change in a few bullets, then bring the branch up to date with a merge pull (never rebase) and push. Use when the user says "commit", "commit and push", "commit the staged changes", or "commit staged". Never stages files itself and never adds AI/co-author attribution.
---

# Commit (staged changes only → pull --no-rebase → push)

Commit whatever is **already staged**, then update the branch with a merge
pull and push. Never stage anything, never rebase, never add AI attribution.

## Hard rules

- **Only commit staged changes.** Never run `git add`, `git add -A`,
  `git add -p`, `git stage`, or otherwise change what is staged. Commit the
  index exactly as it is.
- **One commit per invocation.**
- **Require a Git identity.** If `user.name` or `user.email` is not configured,
  do not commit, pull, or push — stop and tell the user to set them.
- **Merge, never rebase.** Always pull with `--no-rebase`, regardless of any
  `pull.rebase` config.
- **Never force-push.** Plain `git push` only, unless the user explicitly asks.
- **Never auto-resolve conflicts.** On a merge conflict, stop and report.
- **Never add AI attribution.** No `Co-Authored-By: Claude`, no "Generated with
  Claude Code", no trailer, footer, or line indicating AI, Claude, or a tool
  was involved. The message must contain nothing of the sort.
- **No `--no-verify`** unless the user explicitly asks to skip hooks.

## Steps

1. **Check what is staged.** Run together:
   - `git diff --cached --stat` (what will be committed)
   - `git diff --cached` (the actual staged diff, to understand the change)
2. **If nothing is staged** (empty `--cached` output): stop and tell the user
   there is nothing staged to commit. Do not stage anything, do not pull or push.
3. **Check the Git identity.** Read `git config user.name` and
   `git config user.email`. If either is empty, **do not commit, pull, or
   push** — stop and tell the user to configure them, for example:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```
   Use `--global` for an account-wide identity, or drop it to set only this repo.
4. **Write a semantic commit message** from the staged diff (format below).
5. **Commit** using a HEREDOC so the body formats correctly:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<optional scope>): <concise summary>

   - <bullet explaining a distinct change>
   - <bullet explaining another change>
   - <optional third bullet>
   EOF
   )"
   ```
6. **Pull with merge.** Check for an upstream with
   `git rev-parse --abbrev-ref @{upstream}`.
   - If there is no upstream, ask before creating one; if approved,
     `git push -u origin <branch>` and finish there.
   - Otherwise `git fetch` then `git pull --no-rebase`.
7. **On merge conflicts: stop.** Do not resolve, do not abort, do not commit.
   Report the conflicted files (`git diff --name-only --diff-filter=U`) and wait
   for instructions.
8. **Push.** Plain `git push`.
9. **Report** the commit hash and subject, anything the pull brought in
   (including a merge commit if one was created), and that local and remote are
   in sync.

## Commit message format

Semantic / Conventional Commits, with a short explanatory body.

**Subject line:** `<type>(<optional scope>): <summary>`
- Common types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`,
  `build`, `ci`, `style`.
- Imperative mood ("add", not "added"), lowercase summary, no trailing period,
  aim for ≤ 72 chars. Scope is optional — use it when there's an obvious area.

**Body:** one blank line after the subject, then two or three `-` bullets that
explain what the commit does and why, with pointers to the notable files or
areas so a reader can navigate the diff. Wrap prose around 72 columns. Base the
message strictly on the staged diff — never describe unstaged work.

### Example

```
fix(parser): handle empty config files without crashing

- guard against empty documents in parseConfig() (config/loader.ts)
- return an empty config object instead of throwing on missing keys
- add a regression test for the empty-file case (config/loader.test.ts)
```
