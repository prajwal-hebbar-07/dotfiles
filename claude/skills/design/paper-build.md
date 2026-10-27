# Build in Paper

`/design build`: draw `docs/design.md` in Paper through the Paper MCP. In
Claude Code its tools are named `mcp__paper__<tool>`; this file uses the short
names. `design.md` is the brief for the drawing every time. If it and the chat
disagree, the file wins; a change in chat goes through Step 3 of `SKILL.md`
first. You draw; you do not write application code, and you do not edit any
file except `docs/design.md` and `docs/project.md`.

## Before drawing

1. `design.md` must exist. Its status should be `grilled` or `approved`. If it
   is `proposed` or `grilling`, say the idea is not settled and stop, unless
   the user says to build anyway; then put `Built before grilled` in the log.
2. Open questions that block a screen (`Assumes: … (DQ<n>)`) are drawn as
   assumed, with the assumption visible in the report.
3. If the Paper MCP fails or needs auth, stop and tell the user to open Paper
   Desktop. Do not start it.
4. Call `get_guide` with topic `paper-mcp-instructions` once, before any other
   Paper tool.

## File and page

Pass `fileId` on every Paper call once it is known.

- `design.md` has a `Paper:` line, or `AGENTS.md` / `CLAUDE.md` has a
  `paper-target` block: `open_file` that file, then `get_basic_info` to
  confirm file and page. If the live file disagrees, re-open the pin. Do not
  draw on whatever is focused.
- Neither: `get_basic_info` on the focused file, name its file and page, and
  ask the user to confirm before creating anything. Then write the
  `Paper:` line in the `design.md` header with the ids from `get_basic_info`.

Then `get_font_family_info` before the first type style, and `get_tokens`.

## Order

The **Visual direction**, **Patterns**, and **Screens** are the contract.
**Idea** and its `Refuses` say what the drawing may not do.

1. **Tokens.** Create only what the design needs and the file lacks; reuse a
   token that already matches. `create_tokens` takes `fileId` and entries of
   `type`, `name` (`--kebab-case`), `value`. Colours: neutrals, then primary,
   then accent. Other sizes: smallest first. Alias with `var(--other)`.
   Spacing uses the design's step; type uses its scale, in a family
   `get_font_family_info` says is available.
2. **Design system board.** One artboard named `Design system`: the ground,
   the accent, the type scale, the spacing step, the radius, the primary
   action, and each `P` pattern. Styles use the tokens (`var(--…)`), not raw
   values. The user checks this board before the flow.
3. **Screens, in journey order.** One artboard per `S` item whose `Paper:` is
   `not built` or `stale`, named `<n> <name>` (`01 Today`), with the screen's
   states in `Draw:` as `<n> <name> · <state>` beside it. Desktop is 1440×900
   and phone 390×844 (read the `mobile-status-bar` guide before drawing a
   status bar). Leave 80px between artboards. Walking left to right follows
   the first journey. Every control, sample value and word on the board comes
   from the screen's own fields.
4. **Review.** `get_screenshot` after the design system and after each screen.
   If content clips, set that artboard's height to `fit-content`. Fix the
   board before starting the next.
5. **Stop.** `finish_working_on_nodes` with no arguments.

An artboard with that name already on the page is updated, never duplicated.
Boards for screens that are `Paper: built` are left alone.

## How to write

Each `write_html` is one visual group: a header, a row, a button, a paragraph.
A card is the container, then each row, then the footer, as separate calls.
Prefer cloning a node you made over drawing it again. Inline styles only.
Flex, padding and gap; no margin, grid, or table. No emoji as icons. Add no
screen, control, or destination `design.md` does not list.

## After drawing

Update `design.md`: each screen drawn becomes `Paper: built <date>`; the
tracker's Updated, **Next action** `Review the boards in Paper, then run
/design approve, or tell me what to change`, and a log line. Do not show raw
node ids in chat.

Report in chat, no new file:

- File name and page name.
- Tokens created, by name.
- The boards, in order, one line each: what the person can do there.
- What was drawn on an assumption (`DQ` ids).
- That no application code was changed.
