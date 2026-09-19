---
name: paper-target
description: >
  Pins which Paper (paper.design) file and page this repository's design work
  reads from. Resolves them through the Paper MCP, writes a marked block into
  AGENTS.md / CLAUDE.md, then stages only those files and runs the commit
  skill. Also shows or clears the pin. Use when the user says "use this Paper
  file", "set the Paper target", "point Paper at <file>", "the design lives
  in <file>", "which Paper file are we using", "clear the Paper target", or
  invokes /paper-target or /skill:paper-target.
argument-hint: "[file=<name|id|url>] [page=<name|id>] [show|clear] [memory file path]"
---

# paper-target

Pin one Paper file and page into agent memory so later sessions do not follow
whatever Paper has focused. That is the whole skill.

Three modes: **set** (default), **show**, **clear**.

## Never

- Guess a file id or page id. Every id comes from `list_files`, `open_file`,
  or `get_basic_info`.
- Call any Paper tool except `list_files`, `open_file`, `get_basic_info`.
  Forbidden: `write_html`, `update_styles`, `create_page`, `create_file`,
  `create_artboard`, `delete_nodes`, `set_tokens`, `get_screenshot`, comments,
  export, and every other Paper tool.
- Start, open, or restart Paper Desktop (`open -a`, etc.). If the MCP is down
  or needs auth, STOP and tell the user to open Paper Desktop / authenticate.
- Reconstruct an id from a URL you did not successfully `open_file`.
- Edit any line of a memory file outside the marked block.
- Edit product code, run builds, start a server, or drive the browser.
- `git add` anything except the memory files this skill just changed.
- `git commit` yourself. After a real write, run the **commit** skill.
- Pass a subject into commit. Commit writes the message from the staged diff.
- Pick among zero or several name matches. List them with ids and ask.

If asked to do any of those, refuse.

## Modes

| Mode | When | Writes? | Commit? |
|---|---|---|---|
| **set** | pin / "use this file" / no `show` or `clear` | yes, after confirm | yes, if files actually changed |
| **show** | `show`, or "which Paper file are we using" | no | no |
| **clear** | `clear` | yes, delete the block | yes, if something was deleted |

An explicit `file=` / `page=` in this message is a **set**, not a show.

## Memory files

- Default: every agent memory file that already exists at the **git root**
  (`AGENTS.md`, `CLAUDE.md`). Update all of them so hosts do not disagree.
- Explicit path in the skill argument wins only if it is inside the repo.
  Refuse paths outside the repo. Do not invent `packages/foo/AGENTS.md`.
  Default is the git root, not a package.
- If none exist: create `AGENTS.md` and write the block there. Also create
  `CLAUDE.md` whose entire content is `@AGENTS.md` — pointer only, no second
  copy of the block.
- If `CLAUDE.md` already exists as a real file, write the same block into it
  (set and clear both files together so they stay twins).

## Step 0 — Paper MCP

If `list_files` / `open_file` / `get_basic_info` fail, or the server needs
auth: STOP. Tell the user to open Paper Desktop (and authenticate if needed).
Do not start it. Do not guess ids.

Always pass `fileId` on every Paper call after it is known. Never rely on
"whatever is focused" after that.

## Step 1 — resolve the file (set only)

- **Id, `/file/<id>` path, or https URL** → `open_file({ fileId })`. Use the
  id the tool returns. If open fails, STOP.
- **Name** → `list_files`, match **exact** name after lowercasing (not
  substring). Exactly one match → open it. Zero or several → list candidates
  with ids and ask. Never pick. `list_files` is open + recent, not the whole
  team; no match is not "use the focused file".
- **Nothing given** → `get_basic_info` on the focused file, then **ask**
  "pin this file (name + id)?" Do not write until the user confirms.

Then `get_basic_info({ fileId })`. That payload is the source of truth for
the file name and the `pages` list.

## Step 2 — resolve the page (set only)

`open_file({ pageId })` does **not** switch page if the file is already open.
Do not trust the focused page. Read `pages` from `get_basic_info({ fileId })`.

- **Page id, or a URL that carries one** → confirm with
  `get_basic_info({ fileId, pageId })`. If that call fails, STOP. Do not keep
  an unseen id.
- **Page name** → case-insensitive **exact** match on `pages`. One match →
  use that `pageId`. Zero or several → list them and ask.
- **No page given** → tell the user the focused page (name + id) and **ask**
  before pinning. Do not write until they confirm.

`pageId: UNKNOWN` only if this MCP returns no `pages` list (old server) and
you still saw the page via `get_basic_info`. Never invent a page id.

Confirm the pin with `get_basic_info({ fileId, pageId })` before writing.
Live file name and page name in the block must come from that call.

## Step 3 — write the block (set only)

Idempotent: if the markers exist, replace what is between them. If a file
has more than one marker pair, collapse to a single block. Otherwise append
the whole block at the end.

Do not touch any other line.

```markdown
<!-- paper-target:start -->
## Paper design target

Design work in this repo reads from one Paper file and page. Before any Paper
MCP read, call `open_file` with these, then confirm with `get_basic_info`.

- File: `<file name>` — fileId `<id>`
- Page: `<page name>` — pageId `<id | UNKNOWN>`
- Confirmed: `<YYYY-MM-DD>` via `get_basic_info`

Pass `fileId` on every Paper tool call. If `get_basic_info` reports a
different file or page, re-open the target — do not read the focused one.
An explicit `file=` / `page=` in the user's message overrides this block;
a stale block is fixed by re-running `paper-target`, never by silently
using another file.
<!-- paper-target:end -->
```

If the new block equals the old block, do not rewrite. That is a no-op.

## Step 4 — verify (set only)

Re-read each memory file: exactly one marked block. Re-run
`get_basic_info({ fileId, pageId })` and check it matches what was written.
If not, STOP. Do not commit a bad pin.

## `show`

Read the block from **every** memory file (not the first hit). Run
`get_basic_info({ fileId, pageId })` (or without `pageId` if the block says
`UNKNOWN`). Report the block, the live file/page, and whether they agree.
Change nothing. Do not stage. Do not run commit.

Answer "which Paper file are we using" this way, not from memory.

## `clear`

Delete the marked block **and** its markers, nothing else, in every memory
file that has them. If more than one pair exists, delete all of them.

If `CLAUDE.md` was created by this skill as a bare `@AGENTS.md` pointer and
`AGENTS.md` now has no other content, say so and let the user decide about
the files. Do not delete those files yourself.

## Step 5 — stage this skill's files, then commit

Run this step only after **set** or **clear** actually changed a memory
file. Skip it for `show`, for a no-op set, and when you stopped before a
write.

1. `git add` **only** the memory files this skill created or changed
   (`AGENTS.md`, `CLAUDE.md`, or the explicit path). Leave every other dirty
   file alone. Do not stage unrelated edits that already sat in those files
   outside the marked block — if you only touched the block, adding the
   file is correct.
2. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself. Do not draft the message.
3. If commit reports nothing staged: you failed to add. Add those files and
   run commit **once** more. Then stop if it is still empty.
4. If identity is missing or a pre-commit hook fails: STOP. Relay that.
   Do not retry with `--no-verify`.

## Report

At most a short block:

- mode (set / show / clear)
- file name + fileId, page name + pageId
- which memory file(s) changed (or that nothing changed)
- commit SHA if commit ran; or that commit was skipped (show / no-op)
- that new sessions pick the pin up from memory; this session already has it
