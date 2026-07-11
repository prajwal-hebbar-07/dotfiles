---
name: plan
description: Terminal-native planning that replaces plan mode entirely. Researches the task in the real codebase, writes the plan to plans/plan-<slug>.md, and opens it for review in a right-hand tmux split running nvim so the user can annotate it with inline "@me" HTML comments (resolved later by /plan-review). Runs in whatever permission mode is active — never enters plan mode. Use when the user says "/plan <task>", "plan this", "make/write a plan for X", "create a plan doc", or asks for a plan they can review in the editor.
---

# Plan (terminal-native, no plan mode)

Produce a reviewable plan **as a markdown file**, not as a plan-mode session.
The plan is researched against the real codebase, written to
`plans/plan-<slug>.md`, and opened in a right-hand tmux split running nvim
where the user annotates it inline. `/plan-review` (its own skill, wired to
the `<leader>pr` keybind in nvim) resolves those annotations in later rounds.

The output of this skill is always **the plan file only** — never the
implementation, and never a plan-mode session.

## Flow

1. **Never enter plan mode.** Do not call EnterPlanMode, and do not present
   the plan via ExitPlanMode. This skill exists specifically because the
   review loop lives in the plan file, not in plan mode. Work in whatever
   permission mode is active.

2. **Understand the task.** Take it from the invocation args
   (`/plan add oauth refresh`) or from the conversation. Ask only if the task
   is genuinely ambiguous — otherwise state your interpretation in the plan's
   Goal section and let the user correct it with a comment.

3. **Research before writing.** A plan not grounded in the actual codebase is
   worthless. Explore the files, functions, existing patterns, and tests the
   task touches. Every file or symbol the plan references must actually exist
   (e.g. `src/auth/session.ts:42`) — never hypothetical paths. Also check
   `plans/` for related plan files (`overview.md`, `step-*.md`,
   other `plan-*.md`) whose decisions constrain this one.

4. **Choose the file path.** Repo root is
   `git rev-parse --show-toplevel 2>/dev/null || pwd`. The file is
   `<root>/plans/plan-<slug>.md`, where `<slug>` is a short kebab-case slug of
   the task (e.g. `plan-oauth-refresh.md`). Create `plans/` if it does not
   exist. If the file already exists, do **not** silently overwrite it — pick
   a new slug or ask whether to replace it (existing comments would be lost).

5. **Write the file** with the Write tool, using the template in
   "Plan file format" below. Anything you could not settle from research goes
   in `## Open questions` — the user answers them inline with `@me` comments.

6. **Open the review split** (only if `$TMUX` is set), passing Claude's own
   pane id into nvim's environment so the `<leader>pr` keybind can send
   comments straight back:

   ```bash
   plan="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/plans/plan-<slug>.md"
   : "${TMUX_PANE:?not in tmux}"
   tmux split-window -h -t "$TMUX_PANE" \
     -e "CLAUDE_PANE=$TMUX_PANE" -e "PLAN_FILE=$plan" \
     nvim "$plan"
   ```

   Substitute the real slug. If **not** inside tmux, skip the split: report
   the file path and tell the user to open it in their editor and run
   `/plan-review <path>` after commenting.

7. **Tell the user, concisely**, how the loop works: annotate inline with
   `@me` HTML comments (`<leader>pc` inserts one), save, press `<leader>pr`
   (leader = Space) to send them back, and close the pane (`:q`) once the
   Status line says ready. Then STOP the turn — the next round arrives as a
   `/plan-review <path>` invocation.

## Plan file format

`plans/plan-<slug>.md`:

```markdown
<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g. a line:
        @me: use Postgres, not Redis
    written inside an HTML comment, anywhere in the plan. In nvim, Space+pc
    inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
-->

# <Plan title>

Status: draft — <YYYY-MM-DD>

## Goal
<what this delivers and why, plus your interpretation of anything ambiguous>

## Plan
<ordered, file-level: which files/functions change and how; reference real
paths and symbols found during research>

## Edge cases & risks

## Open questions
<anything research could not settle — the user answers these with @me comments>

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
```

## Hard rules

- **No plan mode, ever.** Not on entry, not for presenting the result.
- **Never implement in this skill.** Output is the plan file only; the user
  triggers implementation explicitly after review.
- **Never skip research.** No plan file before the relevant code has been read.
- **Never clobber an existing plan file** without the user's say-so.
- Requires tmux for the split; without tmux, write the file and report the
  path — never fall back to some other editor or an in-conversation review.
