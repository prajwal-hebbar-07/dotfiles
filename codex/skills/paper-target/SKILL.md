---
name: paper-target
description: >
  Pins the one Paper file and page a project looks at, so that several sessions
  or several open Paper tabs cannot pull design work onto the wrong file. Resolves
  them through the Paper MCP and writes a marked block into the repository's
  AGENTS.md / CLAUDE.md, which every Paper skill reads. Also shows or clears the
  pin. Never draws, never commits. Use when the user says "$paper-target", "use
  this Paper file", "which Paper file are we using", or "clear the Paper target".
---

# paper-target

Invoke as `$paper-target [file=<name|id|url>] [page=<name|id>] [show | clear]`.
Discover the available Paper MCP tools in Codex; this file uses their short names
regardless of the server prefix.

Paper has one focused file and page, shared by every session on the machine, and
it changes whenever the user or another session moves. A tool call without ids
acts on whatever is focused at that moment. This skill records which file and
page this repository uses, and the block it writes tells every later session to
pass those ids and never to follow the focus.

| Argument | Mode | Writes |
| --- | --- | --- |
| `file=`, `page=`, or nothing | **set** | the block, after the user confirms anything they did not name |
| `show` | **show** | nothing |
| `clear` | **clear** | removes the block |

## Never

- Guess or reconstruct an id. Every id comes from `list_resources`, `open_file`
  or `get_basic_info`.
- Call any other Paper tool except `get_guide`. This skill reads Paper and never
  draws.
- Start Paper Desktop. If the MCP is down, stop and tell the user to open it.
- Pin whatever is focused without the user saying so. When several files are
  open, the focused one may belong to another session.
- Pick among zero or several name matches. List them with ids and ask.
- Pin a divider: an item in `pages` of type `divider` has no canvas.
- Edit any line outside the marked block, or a file outside the git root.
- Stage, commit or push. Say the file is uncommitted, and let the user run
  `$commit`.

## Step 1 — state

```sh
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
date +%F
git branch --show-current
```

The memory files are `AGENTS.md` and `CLAUDE.md` at the root, each that exists:

- Neither exists: **set** creates `AGENTS.md` with only the block.
- `CLAUDE.md` is a symlink to `AGENTS.md`, or holds nothing but `@AGENTS.md`: it
  gets no block of its own.
- Otherwise each gets the same block, so the two never disagree.

Call `get_guide` once with topic `paper-mcp-instructions` before any other Paper
tool (**clear** needs no Paper tool). If it fails, stop and tell the user to open
Paper Desktop.

## Step 2 — set: the file

`list_resources` says which files are open tabs (`open`) and which is in the
foreground (`active`). Pass a higher `limit` until `truncated` is absent before
saying a name does not exist.

- **Id or URL:** use it.
- **Name:** match type `file` exactly, ignoring case. One match: use it. Zero or
  several: list them with ids, and ask.
- **Nothing given:** list the open files with their ids, marking the active one,
  and ask which. Recommend the one whose name matches the repository's, else the
  active one, and say why. Do not write until the user answers.

Then `get_basic_info({ fileId })`. Only if that fails because the file is not
open, call `open_file({ fileId })` and try again; it can bring a tab forward for
every session, so never call it for a file that is already open.

## Step 3 — set: the page

Read `pages` from `get_basic_info({ fileId })`. Do not trust the active page, and
do not use `open_file`'s `pageId` to choose one: it does nothing to an open file.

- **Id:** it must be in `pages` as type `page`.
- **Name:** match type `page` exactly, ignoring case. One match: use it. Zero or
  several: list them with ids, and ask.
- **Nothing given:** list the pages with their ids, marking the active one, and
  ask which, with your recommendation.

Then `get_basic_info({ fileId, pageId })`. The names in the block come from this
call, not from the argument.

## Step 4 — set: write the block

If the markers exist, replace what is between them, collapsing more than one pair
into one. Otherwise append the block at the end of the file. If only the date would
change, leave the block as it is.

```markdown
<!-- paper-target:start -->
## Paper design target

Design work in this repository uses one Paper file and page, whatever Paper has
focused.

- File: `<file name>` — fileId `<id>`
- Page: `<page name>` — pageId `<id>`
- Confirmed: `<YYYY-MM-DD>`

Before reading or drawing, call `get_basic_info` with both ids and check the names
match. Pass `fileId` on every Paper tool call and `pageId` on every page-scoped
one; never omit them to use the focused file or page, which another session can
change while you work. Call `open_file` only when the file is not already open. A
name that differs, or a file or page that is gone, is a stop: tell the user to run
`paper-target` again, and do not use another file. A file or page the user names
in their message wins for that message. A feature may draw on a page of its own in
this file; its `design.md` `Paper:` line names that page.
<!-- paper-target:end -->
```

Re-read each file: exactly one pair of markers, and the ids are the ones
`get_basic_info` returned.

## show

Read the block from every memory file. They must agree. Call `get_basic_info` with
its ids. Report the pin, the live names, and whether they match, and name the file
and page currently focused if they differ, since that is what a call without ids
would have used. No block: say so, and that `$paper-target` sets one. Change
nothing.

## clear

Delete the block and its markers, and nothing else, in every memory file that has
them. A file this leaves empty stays for the user to decide about.

## Reply

At most five lines: the mode; the file and page with their ids; which memory files
changed, or that nothing did; and after a write: "Uncommitted. `/implement` and
`$qa` stop on a dirty `AGENTS.md`, and other branches and worktrees do not see the
pin until it is committed and merged, so run `$commit`."
