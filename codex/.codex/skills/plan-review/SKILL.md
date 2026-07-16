---
name: plan-review
description: Resolve the user's inline "@me" HTML comments in a plans/plan-SLUG.md file created by the plan skill. Edit the plan to satisfy each comment, strip the markers, record a dated round in the Review changelog, and rewrite the file in place for the nvim or Plan Visualizer review workflow. Never implements. Use when invoked with a plan file path or when the user asks to review comments or notes left in a plan.
---

# Plan Review (resolve @me comments)

One review round on a plan file written by the `plan` skill: read the user's
inline `@me` comments, apply them, and rewrite the file cleanly. The caller may
be an interactive pane, nvim, or Plan Visualizer's headless Claude runner; the
file is the shared review medium in every case.

Never implement anything in this skill. Its only output is an updated plan
file plus a short report.

## Locating the plan file

- **With an argument** (the usual case — nvim's `<leader>pr` sends
  `/plan-review /abs/path/to/plans/plan-<slug>.md`): use that path.
- **Without an argument**: use the plan file currently under discussion in
  this conversation; failing that, the most recently modified
  `plans/plan-*.md` in the repo. If neither exists, say so and suggest
  running the `plan` skill to create one.

## Review round

1. **Read the file fresh from disk** — it has changed since you last saw it;
   never trust a stale copy from context.

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
   read, read it before answering. Preserve the plan as a self-contained
   engineering document: update the context, design, change inventory,
   implementation sequence, verification, rollout, risks, and open questions
   wherever the resolution has consequences. If a comment asks for analysis
   beyond the plan's implementation scope, answer briefly in place and mention
   the `plan-detail` skill for deeper follow-up.

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

7. **Write the file back.** nvim autoreloads on CursorHold. Plan Visualizer
   reloads after its Claude process exits; when review was invoked elsewhere,
   its Reload control reads the latest file.

8. **Return a brief report:** how many comments were resolved, one line each
   (same content as the changelog round). Do not rely on the report being
   visible: a headless caller may surface only completion or failure. Then
   STOP and wait for the next round, or for the user to explicitly ask to
   implement.

## Hard rules

- **Never implement.** Even if every comment is resolved and the plan is
  ready, implementation starts only when the user explicitly asks.
- **The file is the review medium** — never move the review into chat.
- **No `@me` markers left behind**, and every resolution recorded in the
  changelog.
- **Always re-read the file from disk** before resolving — the user edited it
  after you last wrote it.
- **Preserve independent readability.** A reviewer should understand the
  revised plan without access to the conversation or review comments.
- **Preserve ordinary engineering Markdown.** Do not introduce visualization
  prompts, renderer metadata, or machine-specific formatting contracts.
