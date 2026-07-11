---
name: plan-review
description: Resolve the user's inline "@me" HTML comments in a plans/plan-<slug>.md file created by /plan — edit the plan to satisfy each comment, strip the markers, record a dated round in the Review changelog, and rewrite the file in place (the nvim split autoreloads it). Never enters plan mode, never implements. Use when invoked with a plan file path (the nvim <leader>pr keybind sends "/plan-review /abs/path"), or when the user says "/plan-review", "check my comments on the plan", or "I left notes in the plan".
---

# Plan Review (resolve @me comments)

One review round on a plan file written by `/plan`: read the user's inline
`@me` comments, apply them, and rewrite the file cleanly. The nvim split the
user is commenting in autoreloads the rewrite, so the loop never leaves the
terminal.

Never implement anything in this skill, and never enter plan mode. Its only
output is an updated plan file plus a short report.

## Locating the plan file

- **With an argument** (the usual case — nvim's `<leader>pr` sends
  `/plan-review /abs/path/to/plans/plan-<slug>.md`): use that path.
- **Without an argument**: use the plan file currently under discussion in
  this conversation; failing that, the most recently modified
  `plans/plan-*.md` in the repo. If neither exists, say so and suggest
  `/plan <task>` to create one.

## Review round

1. **Read the file fresh** with the Read tool — it has changed since you last
   saw it; never trust a stale copy from context.

2. **Find every comment.** Comments are HTML comments whose content begins
   with `@me` — single- or multi-line:

   ```markdown
   <!-- @me: we don't have Redis here, use the existing sessions table -->
   ```

   If there are **no** `@me` comments, do not rewrite the body. Update the
   `Status:` line to `ready to implement — <YYYY-MM-DD>`, remove the top
   guide comment if still present, report that the plan reads clean, and stop.

3. **Resolve each comment** by editing the relevant plan content to satisfy
   it — change the approach, split a step, add a constraint, answer a
   question, move an Open questions item into the plan as a decision, etc.
   Treat each `@me` note as a directive from the user (the PM), not a
   suggestion to weigh. If a comment is genuinely ambiguous, make the smallest
   reasonable interpretation and note the assumption in the changelog rather
   than stalling the loop. If a comment requires looking at code you have not
   read, read it before answering.

4. **Remove the `@me` markers** you resolved — the rewritten plan must be
   clean, with no leftover comment markers.

5. **Update the `Status:` line** to `reviewed (round N) — <YYYY-MM-DD>`.

6. **Append a dated round to `## Review changelog`**, one bullet per comment:

   ```markdown
   ### Round N — <YYYY-MM-DD>
   - Step 3: dropped Redis; session store is now the existing sessions table.
   - Step 5: split into 5a (migration) and 5b (backfill) per your note.
   - Open question 2: assumed staging only, as your note implied — flag if wrong.
   ```

7. **Write the file back** (Edit/Write). nvim has `autoread` on and runs
   `checktime` on CursorHold, so the split reloads on its own — the user does
   not need to do anything.

8. **Report briefly** in the Claude pane: how many comments were resolved,
   one line each (same content as the changelog round). Then STOP and wait
   for the next round, or for the user to explicitly ask to implement.

## Hard rules

- **Never implement.** Even if every comment is resolved and the plan is
  ready, implementation starts only when the user explicitly asks.
- **Never enter plan mode.** The file is the review medium.
- **No `@me` markers left behind**, and every resolution recorded in the
  changelog.
- **Always re-read the file from disk** before resolving — the user edited it
  after you last wrote it.
