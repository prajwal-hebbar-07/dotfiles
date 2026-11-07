# Direction

How `design` turns a brief into rules and tokens. Use named products as
structure, never as a brand clone: no logo, wordmark, exact palette or
proprietary illustration.

## Base and changes

Split the brief into a **base** (a named product, reference site, spec, or
kind of UI) and **changes** (simpler, more modern, more unique, or
anything else). Apply the changes on top of the base; anything the brief
does not mention stays with the base. A change that conflicts with the base
wins, and the design says what it dropped. If two products are named, the
first is the base. Do not blend in one the user did not name.

A reference document the user supplied (a measured spec of a site, a
screenshot set) is the base at full precision: its values become tokens
as written.

## Portraits

- **Notion** — left sidebar, quiet page, content as blocks, editing in
  place. Warm or cool neutrals, one accent, almost no boxes. Hierarchy from
  weight and space. Document density.
- **Linear** — dense, keyboard-first, the list is the product, tight type,
  dark-capable, almost no decoration.
- **Stripe** — wide margins, confident type, one restrained accent,
  documentation-grade hierarchy, little chrome.
- **Figma** — canvas in the centre, panels on the sides, compact controls.
- **Apple** — large type, few controls, one primary action, space instead
  of borders, depth used sparingly.

Any other named product gets the same kind of portrait: navigation,
density, color attitude, type, content model, and what that UI refuses.
Write it into `docs/design.md` so Paper does not reinterpret the name.

## Dials

Three numbers from 1 to 10 make a direction concrete and comparable.

| Dial | Low (1–3) | Middle (4–7) | High (8–10) |
| --- | --- | --- | --- |
| Variance | centered, symmetric, conventional | balanced, one signature move | asymmetric, bento, editorial, unexpected |
| Motion | color and opacity only | standard `motion.md` recipes | choreographed entrances, scroll and gesture work (marketing or rare screens only) |
| Density | spacing 4/8/24/32/48/64/96 | 4/8/16/24/32/48/64 | 2/4/8/12/16/24/32, 28–32px rows |

Directions in Step 2 should sit at clearly different dial settings.

## What the words mean

Every feel word in the design is written as a rule, never left as the word.

- **Simpler** — fewer controls in view, one idea per region, secondary
  chrome dropped. No second navigation.
- **More modern** — current type, spacing and radius. No heavy shadow,
  skeuomorphism or dense toolbars. Stay inside the base; no glass or
  gradients the base is not.
- **More unique** — one or two signature choices (a type pairing, a single
  accent, one layout move). Do not restyle every component.
- **Calm** — one primary action per screen, no badges or counters unless a
  requirement needs them, nothing animates unprompted.
- **Dense** — many rows visible, small controls, the keyboard is enough.
- **Friendly** — plain words, first-person copy, errors say what to do
  next.
- **Professional** — neutral language, no exclamation marks, no
  illustrations where a table will do.
- **Premium** — generous space, restrained palette, one excellent typeface,
  slow-enough motion on rare moments only.

A word not listed gets a rule written from what the user said it means. If
they have not said, it goes under `Open decisions`.

## Tokens from a direction

1. **Color.** Neutrals first (background, surface, border, muted,
   foreground), then one primary, then at most one accent, then
   destructive and success. Pick from the base's color attitude. Check
   every text pair against 4.5:1 and every control boundary against 3:1;
   adjust lightness, not hue, until it passes. Dark values are
   desaturated, lighter tonal variants, with surfaces visibly separated.
2. **Type.** One family, or one display plus one text family. A scale of
   about five sizes; body 16px (15px allowed for dense desktop), headings
   with slight negative tracking. Confirm the family is available in Paper
   (`get_font_family_info`) and on the platform; prefer the system font on
   native apps.
3. **Space.** The density dial's scale; one step everywhere.
4. **Radius and elevation.** Two or three radii; elevation only if the
   base uses depth.
5. **Motion.** The `motion.md` easing tokens and the duration for each
   kind of element the design uses; the motion dial decides how many
   moments get motion at all.
