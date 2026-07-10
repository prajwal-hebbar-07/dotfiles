---
name: stage
description: Interactively stage files. Shows a numbered list of every changed/untracked file, waits for the user to pick ("all", "1-3, 6", "all except 4", or filenames), then stages exactly that selection. Use when the user says "/stage", "stage files", "let me pick what to stage", or "interactive add". Stages only — never commits.
---

# Stage (interactive file picker)

Show the user what could be staged, let them pick, stage exactly that.
Nothing else — no commits, no pushes, no file edits.

## Flow

1. **List the candidates.** Run `git status --porcelain=v1` and build a
   numbered list of every file with unstaged changes: modified, deleted, and
   untracked. Skip files whose changes are already fully staged. If there is
   nothing to stage, say so and stop.

2. **Present the list and stop the turn.** Format:

   ```
    1  M  src/auth/session.ts
    2  M  src/auth/login.ts
    3  D  src/legacy/token.ts
    4  ?  plans/overview.md
   ```

   (`M` modified, `D` deleted, `?` untracked; add `+` for files that also
   have some changes already staged.) Then ask which to stage and END THE
   TURN — wait for the user's reply. Do not guess or pre-stage anything.

3. **Parse the selection.** Accept, in any combination:
   - `all` — every listed file
   - numbers and ranges: `1-3, 6`, `2 4 7`
   - exclusions: `all except 3`, `1-5 but not 2`
   - filenames or path fragments matching listed entries
   If any part of the reply is ambiguous or matches nothing, ask — never
   silently drop part of a selection.

4. **Re-verify, then stage.** Re-run `git status --porcelain=v1` first; if
   the working tree changed since the list was shown (numbers may have
   shifted), re-present the list instead of staging. Otherwise stage the
   selected paths with a single `git add -- <path>...` (`git add` also stages
   deletions).

5. **Report.** Show the result of `git status --short` so the user sees
   what is staged vs left behind, then stop. Mention `/commit` as the next
   step — do not run it.

## Hard rules

- **Never stage without an explicit selection** from the user in this
  conversation. "all" must come from them, not from you.
- **Stage whole files only** — no `git add -p` hunks.
- **Stage only.** No commit, no push, no stash, no checkout, no restore.
