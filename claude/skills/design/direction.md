# Direction

How `/design` turns a feel into rules. Use portraits as structure, never as a
brand clone: no logo, wordmark, exact palette, or proprietary illustration.

## Base and changes

Split the brief into a **base** (a named product or kind of UI) and
**changes** (more modern, simpler, more unique, or anything else). Apply the
changes on top of the base; do not throw the base out. Anything the brief
does not mention stays with the base. A change that conflicts with the base
wins, and the design says what it dropped. If two products are named, the
first is the base. Do not blend one the user did not name.

## Portraits

- **Notion** — left sidebar, quiet page, content as blocks, editing in
  place. Warm or cool neutrals, one accent, almost no boxes. Hierarchy from
  weight and space. Document density.
- **Linear** — dense, keyboard-first, the list is the product, tight type,
  dark-capable, almost no decoration.
- **Stripe** — wide margins, confident type, one restrained accent,
  documentation-grade hierarchy, little chrome.
- **Figma** — canvas in the centre, panels on the sides, compact controls.
- **Apple** — large type, few controls, one primary action, space instead of
  borders, depth used sparingly.

Any other named product gets the same kind of portrait: navigation, density,
colour attitude, type, content model, and what that UI refuses. Write it from
how the product is widely known, and put it in the design so Paper does not
reinterpret the name.

## What the words mean

Every feel word in the design is written as a rule, never left as the word.

- **Simpler** — fewer controls in view, one idea per region, secondary chrome
  dropped. No second navigation.
- **More modern** — current type, spacing and radius. No heavy shadow,
  skeuomorphism, or dense toolbars. Stay inside the base; no glass or
  gradients the base is not.
- **More unique** — one or two signature choices (a type pairing, a single
  accent, one layout move). Do not restyle every component.
- **Calm** — one primary action per screen, no badges or counters unless a
  requirement needs them, nothing animates unprompted.
- **Dense** — many rows visible, small controls, the keyboard is enough.
- **Friendly** — plain words, first-person copy, errors say what to do next.
- **Professional** — neutral language, no exclamation marks, no illustrations
  where a table will do.

A word not listed gets a rule written from what the user said it means. If
they have not said, it is a `DQ`.

## Practices every design carries

- One primary action per screen.
- A spacing step (4 or 8), used everywhere.
- A short type scale: a few sizes, two weights.
- Text that can be read: no grey body text on a tinted ground.
- Alignment to one grid; repeated rows share fixed slots.
- The empty, loading, and error states wherever a screen shows data.
- Desktop unless the user named a phone; say which was assumed.
- Words from the glossary for domain things.
