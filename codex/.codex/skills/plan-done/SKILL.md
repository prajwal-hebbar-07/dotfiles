---
name: plan-done
description: Retire a plans/plan-<slug>.md file created by the plan skill once its plan has actually been implemented — verify the work landed (working tree or git history), then delete the plan file and clean up an empty plans/ dir. Refuses to delete unimplemented plans without explicit confirmation. Use when the user says "/plan-done", "$plan-done", "the plan is implemented, delete it", "clean up the plan file", or "remove the plan, it's done".
---

# Plan Done (delete an implemented plan)

Delete a plan file whose work has shipped. The plan is a working document,
not documentation — once implemented it is noise in `plans/`.

## Locating the plan file

- If the invocation includes a path, use it.
- Otherwise use the plan file currently under discussion in this
  conversation; failing that, the most recently modified `plans/plan-*.md`
  in the repo. If none exists, say so — nothing to do.

## Flow

1. **Read the plan file** and pull out its concrete claims: files it says
   change, symbols it says get added or removed, verification steps.

2. **Verify the plan actually landed.** Spot-check a few of those claims
   against reality — the working tree, `git log`, a grep for a symbol the
   plan removes or adds. This is a sanity check, not a full audit; two or
   three confirmations are enough.

   - **Implemented** → proceed.
   - **Not (or partially) implemented** → do not delete. Report what's
     missing and ask whether to delete anyway; only proceed on an explicit
     yes.

3. **Delete the file.** `git rm` if tracked (leave the deletion uncommitted
   for the `ship` skill), plain `rm` if not. If the file has unsaved `@me`
   comments, mention they existed — they die with the file.

4. **Clean up.** If `plans/` is now empty, remove the directory too. If a
   tmux/nvim split still has the file open, tell the user to close it
   (`:q`) — do not kill panes yourself.

5. **Report**: what was verified, what was deleted, and (if tracked) that
   the deletion is staged for the next ship.

## Hard rules

- **Never delete an unimplemented plan without an explicit yes** from the
  user in this conversation.
- **One plan file per invocation** — no bulk-deleting `plans/` unless the
  user explicitly asks for a sweep.
- **Never commit or push** — deletion stays in the working tree for the
  `ship` skill.
