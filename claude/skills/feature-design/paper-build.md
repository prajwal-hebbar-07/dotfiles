# Build in Paper

`/feature-design build`: draw the feature's `design.md` in Paper through the
Paper MCP. In Claude Code its tools are named `mcp__paper__<tool>`; this file
uses the short names. `design.md` is the brief for the drawing every time. If
it and the chat disagree, the file wins; a change in chat goes through Step 3
of `SKILL.md` first. You draw; you do not write application code, and you do
not edit any file except the feature's `design.md` and `tracker.md`.

The feature lives inside an app that already has a look. The boards show the
feature in that look: the existing screen it changes, as it is today, beside
the feature's screens, drawn with the app's own tokens and components. No new
design system.

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
  confirm it. If the app's screens are already drawn there, read the boards
  the `EU` items cite (`get_tree_summary`, `get_jsx`, `get_computed_styles`)
  before drawing, and match them.
- Neither: `get_basic_info` on the focused file, name it, and ask the user to
  confirm before creating anything.
- Draw on a page of its own named `#<n> <title>`: `create_page` when the file
  has none by that name. Write the `Paper:` line in the `design.md` header
  with the ids.

Then `get_font_family_info` before the first type style, and `get_tokens`.

## Order

The **Existing UI**, **Visual**, **Patterns** and **Screens** are the
contract. **Idea** and its `Follows` and `Refuses` say what the drawing may
not do.

1. **Tokens.** The app's tokens, by the names its code uses (the `EU` token
   items, read from its CSS variables, theme or config). Reuse a Paper token
   that already matches; create only what the file lacks, with the code's
   value. A token in **Visual**'s `New` line is created only with its `DQ`
   noted in the report.
2. **Today.** For each existing screen a feature screen changes (`Change:
   changes EU<n>`), one artboard named `<n> <name> · today`, drawn from its
   code: the layout, the components and the words as they are. It is the
   reference the change is judged against. Keep it to what the code shows;
   mark anything inferred `(from code)` in the report.
3. **Feature patterns.** Only if the design has a `P` item: one artboard named
   `Feature patterns` with each new pattern, in the app's tokens.
4. **Screens, in journey order.** One artboard per `S` item whose `Paper:` is
   `not built` or `stale`, named `<n> <name>` (`01 Export orders`), placed
   right of its `· today` board when it changes one, with the screen's states
   in `Draw:` as `<n> <name> · <state>` beside it. The platform size from the
   design (desktop 1440×900, phone 390×844; read the `mobile-status-bar` guide
   before drawing a status bar). Leave 80px between artboards. Every control,
   sample value and word comes from the screen's own fields; every part of
   the screen the feature does not change matches the `· today` board.
5. **Review.** `get_screenshot` after each board. If content clips, set that
   artboard's height to `fit-content`. Compare each changed screen with its
   `· today` board: only what the design's `Change:` line names may differ.
   Fix the board before starting the next.
6. **Stop.** `finish_working_on_nodes` with no arguments.

An artboard with that name already on the page is updated, never duplicated.
Boards for screens that are `Paper: built` are left alone.

## How to write

Each `write_html` is one visual group: a header, a row, a button, a paragraph.
A card is the container, then each row, then the footer, as separate calls.
Prefer cloning a node you made, or an existing board's node, over drawing it
again. Inline styles only, with the app's tokens (`var(--…)`). Flex, padding
and gap; no margin, grid, or table. No emoji as icons. Add no screen, control,
or destination `design.md` does not list.

## After drawing

Update `design.md`: each screen drawn becomes `Paper: built <date>`; the
tracker's Design row Updated, **Next action** `Review the boards in Paper,
then run /feature-design approve, or tell me what to change`, and a log line.
Do not show raw node ids in chat.

Report in chat, no new file:

- File name and page name.
- Tokens reused and created, by name.
- The boards, in order, one line each: what the person can do there, and for
  a changed screen what differs from `· today`.
- What was drawn on an assumption (`DQ` ids) or inferred from code.
- That no application code was changed.
