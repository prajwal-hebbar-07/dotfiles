---
name: paper-target
description: >
  Pin which Paper (paper.design) file and page this repository's design work
  reads from, by resolving them through the Paper Desktop MCP server and writing
  a marked block into the repo's agent memory file (AGENTS.md / CLAUDE.md) so
  every later session and every Paper skill targets them without being told
  again. Also shows or clears the current target. Use when the user says "use
  this Paper file", "set the Paper target", "point Paper at <file>", "the design
  lives in <file>, page <name>", "which Paper file are we using", or invokes
  /paper-target.
argument-hint: "[file=<name|id|url>] [page=<name|id>] [show|clear] [memory file path]"
---

# Paper target: pin the file and page in agent memory

One resolution, written once, read by every session afterwards. This is the only
place the resolution procedure lives — `paper-design` and `paper-implement`
consume the block, and every parallel `paper-implement` instance consumes the
same one, so they cannot drift onto different files.

## Why this works

`AGENTS.md` / `CLAUDE.md` at the repo root are loaded into the agent's context
at the start of every session. A target written there is already in context when
the user says "implement the hero from Paper", so the skill opens the right file
and page instead of using whatever Paper happens to have focused. The file ids
are stable; a re-run is only needed when the design moves to another file or
page.

## Hard rules

- **Never guess an id.** Every id in the block comes from `list_files`,
  `open_file`, or `get_basic_info`. No memory, no reconstruction from a URL you
  did not see.
- **Never invent a page id.** The MCP cannot enumerate pages. If the page id is
  not knowable, record the page *name* and write `pageId: UNKNOWN` — the
  consuming skills then confirm the page by name via `get_basic_info`.
- **Only the marked block.** Rewrite between the markers; never reformat,
  reorder, or touch a single other line of the memory file.
- **Paper stays read-only.** `list_files`, `open_file`, `get_basic_info` only.
  Never `write_html`, `update_styles`, `create_page`, or any mutation.
- **No code edits, no builds, no dev servers, no browsers.**

## Steps

### 1. Resolve the file

- **Id, `/file/<id>` path, or https URL** → `open_file({ fileId })` directly.
- **Name** → `list_files`, match case-insensitively. Exactly one match → open
  it. Zero or several → list the candidates with their ids and ask. Never pick.
- **Nothing given** → `get_basic_info` on the active file and confirm with the
  user that the file it reports is the one to pin, before writing anything.

### 2. Resolve the page

- **Page id, or a URL that carries one** → `open_file({ fileId, pageId })`.
- **Page name only** → open the file, then read `get_basic_info`. If the page it
  reports matches, record the name and `pageId: UNKNOWN`. If it does not match,
  ask the user to switch to that page in Paper Desktop and say when done, then
  re-run `get_basic_info`. Do not pin a page you never saw.
- **No page given** → record whatever `get_basic_info` reports, and say so.

### 3. Pick the memory file

- Update **every** agent memory file that already exists at the repo root
  (`AGENTS.md`, `CLAUDE.md`), so hosts do not disagree. An explicit path in the
  skill argument overrides this.
- If none exists, create `AGENTS.md`. Claude Code reads `CLAUDE.md`, so also
  create a `CLAUDE.md` whose entire content is `@AGENTS.md` — one source of
  truth, both hosts.
- Repo root = the git root. In a monorepo, if the design work belongs to one
  package, write to that package's memory file and say which one you chose.

### 4. Write the block

Idempotent: if the markers exist, replace what is between them; otherwise append
the whole block at the end of the file.

```markdown
<!-- paper-target:start -->
## Paper design target

Design work in this repo reads from one Paper file and page. Before any Paper
MCP read, call `open_file` with these, then confirm with `get_basic_info`.

- File: `<file name>` — fileId `<id>`
- Page: `<page name>` — pageId `<id | UNKNOWN>`
- Confirmed: `<YYYY-MM-DD>` via `get_basic_info`

Pass `fileId` on every Paper tool call. If `get_basic_info` reports a different
file or page, re-open the target — do not read the focused one. An explicit
`file=` / `page=` in the user's message overrides this block; a stale block is
fixed by re-running `paper-target`, never by silently using another file.
<!-- paper-target:end -->
```

### 5. Verify and report

Re-read the written file to confirm exactly one marked block, and re-run
`get_basic_info` to confirm the live target matches what was written. Report:
file name + id, page name + id, which memory file(s) changed, and that new
sessions pick it up automatically while the current session already has it.

## `show`

Read the block from the memory file, run `get_basic_info`, and report both plus
whether they agree. Change nothing. Answer "which Paper file are we using" this
way rather than from memory.

## `clear`

Delete the block and its markers, nothing else. If `CLAUDE.md` was created as a
bare `@AGENTS.md` pointer by this skill and `AGENTS.md` now has no other
content, say so and let the user decide about the files themselves.
