---
name: plan
description: Terminal-native planning. Researches the task in the real codebase, writes a crisp, diagram-first plan to plans/plan-<slug>.md, and opens it for review in a right-hand tmux split running nvim so the user can annotate it with inline "@me" HTML comments (resolved later by the plan-review skill). Never implements and never presents the plan only in conversation — the file is the medium. Use when the user says "/plan <task>", "$plan <task>", "plan this", "make/write a plan for X", "create a plan doc", or asks for a plan they can review in the editor.
---

# Plan (terminal-native)

Produce a reviewable plan **as a markdown file**, not as a conversational
proposal. The plan is researched against the real codebase, written to
`plans/plan-<slug>.md`, and opened in a right-hand tmux split running nvim
where the user annotates it inline. The `plan-review` skill (wired to the
`<leader>pr` keybind in nvim) resolves those annotations in later rounds.

The output of this skill is always **the plan file only** — never the
implementation.

## Writing style: crisp and visual

The reader is an experienced software developer. Optimize the plan for
scanning, not for completeness of prose:

- **Diagrams over paragraphs.** Whenever the plan involves structure, flow,
  ordering, or a before/after state, draw it as an ASCII diagram in a fenced
  code block (box-drawing characters render perfectly in the nvim split —
  never use mermaid or anything that needs a renderer). Good candidates:
  current vs. target architecture, data/control flow, dependency order of
  steps, a file-tree of what gets touched.
- **One line per step.** `path/to/file.ext:line — what changes`. No
  explanation of *how* to do standard things; the reader knows.
- **No concept explanations.** Never explain what a tool, pattern, or
  technique is. State decisions, not tutorials.
- **Terse everywhere.** Goal in 2-3 lines. Risks as one-liners. If a section
  has nothing non-obvious to say, keep it empty rather than padding it.
- Depth on demand is the `plan-detail` skill's job — the plan itself stays
  lean and the user asks when they want the reasoning behind a step.

## Flow

1. **The file is the medium.** Do not deliver the plan as a chat message or
   through any built-in planning/approval feature — the review loop lives in
   the plan file.

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

5. **Write the file**, using the template in "Plan file format" below and the
   writing style above. Anything you could not settle from research goes in
   `## Open questions` — the user answers them inline with `@me` comments.

6. **Open the review split** (only if `$TMUX` is set), passing this pane's id
   into nvim's environment as `CLAUDE_PANE` (the nvim keybind reads that
   variable regardless of which agent runs in the pane) so `<leader>pr` can
   send comments straight back:

   ```bash
   plan="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/plans/plan-<slug>.md"
   : "${TMUX_PANE:?not in tmux}"
   tmux split-window -h -t "$TMUX_PANE" \
     -e "CLAUDE_PANE=$TMUX_PANE" -e "PLAN_FILE=$plan" \
     nvim "$plan"
   ```

   Substitute the real slug. If **not** inside tmux, skip the split: report
   the file path and tell the user to open it in their editor and send
   `/plan-review <path>` after commenting.

7. **Tell the user, concisely**, how the loop works: annotate inline with
   `@me` HTML comments (`<leader>pc` inserts one), save, press `<leader>pr`
   (leader = Space) to send them back (it types `/plan-review <path>` into
   this pane), and close the pane (`:q`) once the Status line says ready.
   Mention that the `plan-detail` skill expands on any part of the plan and
   `plan-done` deletes it once implemented. Then STOP the turn — the next
   round arrives as a `/plan-review <path>` message.

## Plan file format

`plans/plan-<slug>.md`:

```markdown
<!-- plan-review guide (delete when done):
  - Leave notes for the agent as HTML comments beginning with @me, e.g. a line:
        @me: use Postgres, not Redis
    written inside an HTML comment, anywhere in the plan. In nvim, Space+pc
    inserts one under the cursor.
  - Save, then press Space+pr to send your notes back for review.
  - The agent edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - plan-detail <question> for depth; plan-done to delete when implemented.
-->

# <Plan title>

Status: draft — <YYYY-MM-DD>

## Goal
<2-3 lines: what this delivers, plus your reading of anything ambiguous>

## Shape
<the picture: ASCII diagram(s) of the flow / architecture / before-after /
touched-files tree — whatever view makes the change obvious at a glance>

## Plan
<ordered one-liners: `file:line — change`; group under short ### headings
when phases matter; a small diagram beats a paragraph for step ordering>

## Edge cases & risks
<one-liners only>

## Open questions
<anything research could not settle — the user answers these with @me comments>

## Review changelog
<!-- plan-review appends a dated round entry here each pass -->
```

## Hard rules

- **Never implement in this skill.** Output is the plan file only; the user
  triggers implementation explicitly after review.
- **Never skip research.** No plan file before the relevant code has been read.
- **Never clobber an existing plan file** without the user's say-so.
- **ASCII diagrams only** — the plan is read in a terminal nvim split;
  mermaid/graphviz blocks are unreadable there.
- Requires tmux for the split; without tmux, write the file and report the
  path — never fall back to some other editor or an in-conversation review.
