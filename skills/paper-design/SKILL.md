---
name: paper-design
description: >
  Builds the Paper design from paper-design-prompt.md at the git root.
  Always that file. Creates the design tokens and a design-system artboard
  first, then the screens in order, so the flow can be reviewed in Paper
  before anyone changes application code. Use when the user invokes
  /paper-design or says to design this in Paper from the prompt, build the
  Paper design, or implement the paper-design-prompt. Does not write code
  and does not rewrite the prompt.
argument-hint: "(always paper-design-prompt.md)"
disable-model-invocation: true
---

# Paper design

Build the design in Paper from **one file**: `paper-design-prompt.md` at
the git root. That file is the brief every time. A path in the message does
not switch it. An attached copy does not switch it. If the file and the
chat disagree, the file wins.

You design. You do not implement the product.

## Never

- Read a different brief, or write a second `paper-design-prompt.md`.
- Edit `paper-design-prompt.md`.
- Invent a visual direction the brief does not state.
- Write or edit application code, tests, or docs. Implementation is a later
  session, after the user has reviewed this design.
- Start Paper Desktop (`open -a` or otherwise). If the Paper MCP is down
  or needs auth, stop and tell the user to open Paper Desktop.
- `git add` or commit. Nothing from this skill belongs in git.
- Show raw node ids in the chat.
- Skip the design system and start on a screen.
- Add a feature the brief puts out of scope.

## Read first

1. `paper-design-prompt.md` at the git root, the whole file. If it is
   missing, stop. Tell the user to run `paper-design-prompt` in this repo.
   Do not design from memory.
2. A `paper-target` block in `AGENTS.md` or `CLAUDE.md`, if one exists.
3. The Paper guide, once: `get_guide` with topic `paper-mcp-instructions`,
   before any other Paper tool.

## File and page

Pass `fileId` on every Paper call after it is known.

- A `paper-target` block → `open_file` that file and page, then confirm
  with `get_basic_info`. If the live file disagrees, re-open the pin. Do
  not draw on whatever is focused.
- No pin → `get_basic_info` on the focused file. Name the file and page
  and ask before creating anything. Do not guess.

Then `get_font_family_info` before the first type style, and `get_tokens`.

## Order

The brief's **Design rules** and **Screens** are the contract. **Reference**
and **Changes** say what the UI may and may not do.

1. **Tokens.** Create only what the brief needs and the file does not
   already have. Reuse a token that already matches. `create_tokens` needs
   `fileId` and entries of `type`, `name` (`--kebab-case`), `value`.
   Colors: neutrals, then primary, then accent. Other sizes: smallest
   first. Alias with `var(--other-token)`. Spacing uses the brief's step.
   Type sizes and weights are the brief's scale, in a family
   `get_font_family_info` says is available.
2. **Design system artboard.** One artboard named `Design system`. Show
   the ground, the accent, the type scale, the spacing step, the radius,
   and the primary action. Styles use the tokens (`var(--…)`), not raw
   values repeated by hand. This is the board the user checks before the
   flow.
3. **Screens, in the brief's order.** One artboard per screen, named with
   the brief's number and name (`01 Today`). Desktop is 1440×900 unless
   the brief names a phone (390×844; read the `mobile-status-bar` guide
   before drawing a status bar). Leave 80px between artboards. Walking
   the artboards left to right is the flow.
4. **Review.** `get_screenshot` after the design system and after each
   screen. If content clips, set that artboard's height to `fit-content`.
   Fix the board you just made before starting the next one.
5. **Stop.** `finish_working_on_nodes` with no arguments.

If an artboard with that name is already on the page, update it. Do not
create a second copy.

## How to write

Each `write_html` is one visual group: a header, one row, a button, a
paragraph. A card is the container, then each row, then the footer, as
separate calls. Prefer cloning a node you already made over drawing it
again.

Inline styles only. Flex, padding, and gap. No margin, no grid, no table.
No emoji as icons. Sample names and data come from the brief. Do not add
a screen, a control, or a destination the brief does not list.

## Report

Chat only. Do not write a markdown file.

- File name and page name.
- Tokens you created, by name.
- The flow, in screen order: one sentence each for what the person can do
  there, taken from the brief.
- That application code was not changed. The user reviews this design,
  then updates the implementation in a later session.
