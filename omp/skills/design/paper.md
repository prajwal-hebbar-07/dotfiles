# Drawing in Paper

How `design` draws through the Paper MCP. Tool names below are short; in
OMP they are the mounted `paper` MCP tools. `docs/design.md` is the brief
for every drawing; if it and the chat disagree, update the document first.

## Before drawing

1. If Paper does not answer or says Paper Desktop is not running, stop
   drawing and tell the user to open it. Never start it. Writing
   `docs/design.md` may continue.
2. Call `get_guide` with topic `paper-mcp-instructions` once per session,
   before any other Paper tool. Read `mobile-status-bar` before drawing a
   phone status bar.
3. Call `get_font_family_info` before the first type style, and
   `get_tokens` to reuse tokens that already match.

## Pin the file and page

Pass `fileId` on every call and `pageId` on every page-scoped call; the
focused file can change while you work.

- `docs/design.md` has a `Paper:` line: `open_file` that file, then
  `get_basic_info` to confirm the file and page names match.
- No `Paper:` line: `get_basic_info` on the focused file, name its file
  and page to the user, and ask them to confirm before creating anything.
  Then write the `Paper:` line.

## Order

1. **Tokens.** `create_tokens` only what the design needs and the file
   lacks. Names in `--kebab-case`, matching `docs/design.md`. Colors as
   neutrals, primary, accent, status; sizes smallest first. Alias with
   `var(--other)`.
2. **Design system board** (after `pick`, or when the tokens change). One
   artboard named `Design system`: the color roles with their names, the
   type scale, the spacing step, radii, the primary and secondary button
   in every state (rest, hover, pressed, focus, disabled), an input in
   rest, focus and error, and each `P` pattern. Labels are allowed on this
   board only.
3. **Screens in journey order.** One artboard per screen named
   `S<n> <name>`, and one per state named `S<n> <name> · <state>` to its
   right. Each is a whole screen at the platform size; `fit-content` may
   only make it taller. 80px between artboards; reading left to right
   follows the first journey. Direction boards are named
   `Direction · <name>`, side by side, before any screen.

A board that shows the product shows only what the person would see: no
notes, arrows or annotations. Every word, control and value on it comes
from `docs/design.md`; a gap is reported, not invented.

## How to write

- One `write_html` per visual group: a header, a row, a card shell, then
  its rows. Clone with `duplicate_nodes` and adjust with `update_styles`
  and `set_text_content` instead of redrawing repeats.
- Inline styles that reference tokens (`var(--…)`); flex, padding and gap;
  no margins, grid or tables. Font sizes in px, letter-spacing in em,
  line-height in px.
- Repeated rows use fixed-width slots (`flex-shrink: 0`) for icons,
  avatars and trailing actions.
- SVG icons from one family, never emoji.
- An artboard that already exists with that name is updated, never
  duplicated. Boards for screens marked `built` stay untouched unless the
  screen is `stale`.

## Check and finish

- `get_screenshot` after the design system board and after each screen:
  look for clipping, content touching an edge, misaligned rows, low
  contrast, and stray annotations. Fix before the next board.
- Mark each drawn screen `Paper: built YYYY-MM-DD` in `docs/design.md`.
- Call `finish_working_on_nodes` when done. Never show node ids in chat.
