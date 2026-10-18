# Paper design prompt: <product in a few words>

Design this in Paper. This document is the brief. Follow it. Do not invent
a second visual direction. Do not implement application code.

## Product

<What is being designed, for whom, in one short paragraph. No component
tree.>

## Reference

- **Base:** <named product, or the assumed base>
- **Portrait:** <navigation, density, color attitude, type, content model,
  what this UI refuses>
- **Keep:** <what stays from the base>
- **Do not copy:** logo, wordmark, exact palette, proprietary illustration

## Changes

Only these departures from the base. Each line is a rule, not an adjective.

- **Simpler:** <the rule, or "not requested">
- **More modern:** <the rule, or "not requested">
- **More unique:** <the one or two signature choices, or "not requested">
- **Dropped from the base:** <what the delta removed, or "nothing">

## Design rules

- **Device:** desktop or the device the user named
- **Ground:** <neutral from the base>
- **Accent:** <one accent. Where it is allowed>
- **Type:** a grotesque or the face the base implies. Pick the closest
  family `get_font_family_info` returns. Sizes: <three or four>. Weights:
  <two>.
- **Space:** <4 or 8> point step
- **Radius:** <matches the base, or the modern delta>
- **Chrome:** <how much border, shadow, and navigation>
- **Primary action:** <the one action on the main screen>

## Screens

<Ordered list. One line each: the screen name and what the person can do
there. Include empty, loading, or error only when that screen has data.>

1. <screen> — <what is true on it>

## How to design this in Paper

1. Read the Paper guide once: `get_guide` with topic
   `paper-mcp-instructions`. If the repo has a `paper-target` block, open
   that file and page before any other Paper read. Pass `fileId` on every
   call.
2. Call `get_basic_info`, then `get_font_family_info` before the first
   type style. Prefer a family that call lists.
3. The palette, type scale, spacing, and direction above are the brief.
   Do not generate a second one.
4. Each `write_html` adds about one visual group. Prefer `duplicate_nodes`
   with `update_styles` and `set_text_content` when that is faster.
5. After a meaningful change, `get_screenshot` and look. If content clips,
   set height to `fit-content`. Do not guess a taller fixed height.
6. Repeated rows: fixed-width slots for icons and trailing actions
   (`flexShrink: 0`). Gap alone will not align columns.
7. When the screens above exist, call `finish_working_on_nodes`.
8. Do not show raw node ids. Do not export code into the repo. Do not
   write application source.
