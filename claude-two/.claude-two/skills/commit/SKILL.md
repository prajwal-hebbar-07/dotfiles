---
name: commit
description: Commit ONLY the already-staged changes with a semantic (Conventional Commits) message that includes a short explanation of what the commit does. Use when the user asks to "commit", "commit staged", "commit the staged changes", or "make a commit". Never stages files, never adds AI/co-author attribution, and does nothing beyond the single commit.
---

# Commit (staged changes only)

Create exactly one git commit from the changes that are **already staged**. Do nothing else.

## Hard rules

- **Only commit staged changes.** Never run `git add`, `git add -A`, `git add -p`, `git stage`, or otherwise change what is staged. Commit whatever is in the index as-is.
- **Do only the commit.** No pushing, no branching, no pulling, no tagging, no editing files, no running tests, no follow-up cleanup. Just the commit.
- **Never add AI attribution.** Do not add `Co-Authored-By: Claude`, `Co-Authored-By: Claude Opus ...`, `Generated with Claude Code`, or any trailer, footer, or line that indicates the work was done by AI, Claude, or a tool. The commit message must contain nothing of the sort.
- **No `--no-verify`** unless the user explicitly asks to skip hooks.

## Steps

1. Check what is staged. Run these together:
   - `git diff --cached --stat` (what will be committed)
   - `git diff --cached` (the actual staged diff, to understand the change)
2. **If nothing is staged** (empty `--cached` output): stop and tell the user there are no staged changes to commit. Do not stage anything.
3. Write a semantic commit message from the staged diff (format below).
4. Commit using a HEREDOC so the body formats correctly:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<optional scope>): <concise summary>

   <body: what changed and why, plus pointers to the key files/areas touched>
   EOF
   )"
   ```
5. Run `git log -1 --stat` to confirm the commit landed, then report the commit hash and subject to the user. Nothing further.

## Commit message format

Semantic / Conventional Commits style, with a helpful body.

**Subject line:** `<type>(<optional scope>): <summary>`
- Common types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`.
- Imperative mood ("add", not "added"), lowercase summary, no trailing period, aim for ≤ 72 chars.
- Scope is optional — use it when there's an obvious module/area (e.g. `feat(auth): ...`).

**Body (required unless the change is trivial):** one blank line after the subject, then a short explanation:
- What the commit does and why.
- Pointers to the notable files, functions, or areas changed so a reader can navigate the diff.
- Use `-` bullets for multiple distinct changes.
- Wrap prose around 72 columns.

Base the message strictly on the staged diff — do not describe unstaged work.

### Example

```
fix(parser): handle empty config files without crashing

The parser assumed at least one top-level key and threw on an empty
input. Return an empty config object instead.

- config/loader.ts: guard against empty documents in parseConfig()
- config/loader.test.ts: add regression test for the empty-file case
```
