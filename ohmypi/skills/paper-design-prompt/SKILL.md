---
name: paper-design-prompt
description: >
  Turns a Paper design direction into one prompt document a Paper session
  can follow. Reads a reference UI (Notion, Linear, or another named
  product) as the base, then applies the requested changes — more modern,
  simpler, more unique — using established interface practice. Use when
  the user invokes /paper-design-prompt or asks for the Paper design
  prompt, the design brief Paper should run, or "turn this direction into
  the Paper prompt". Does not draw in Paper and does not write code.
argument-hint: "[design direction]"
disable-model-invocation: true
---

# Paper design prompt

Turn the user's design direction into **one prompt document** a later Paper
session can execute. That document is the design. You do not design it
yourself.

Do **not** open Paper, call Paper tools, or write HTML. Do **not** implement
application code. Do **not** write an implementation plan.

## When to start

The user invoked this skill and gave a direction: a product, a reference
UI, a change, or all three. The text after the invocation is the direction.
Do not wait for a second recap.

If you cannot tell **what product or screens** to design, ask one numbered
question and wait. If the reference UI is missing, do not ask: pick the
closest well-known base, name it in the prompt, and say you assumed it.

## How to read the direction

Split every direction into a **base** and a **delta**.

- "Similar to Notion", "like Notion", "keep the base as Notion" → the base
  is Notion. Structure, density, and chrome follow that portrait.
- "More modern", "simpler", "more unique", or any other change → the delta.
  Apply it on top of the base. Do not throw the base out.
- Anything the user did not mention stays with the base.

A sentence can carry both. "Keep Notion as the UI, then make it more
modern, simpler, and more unique" means Notion is the base and those three
words are the only permitted departures.

If the user names two products, the first is the base unless they say
otherwise. Do not blend a third product they did not name.

## Portraits

Use the portrait as structure, not as a brand clone. Never copy a logo,
wordmark, exact palette, or proprietary illustration.

- **Notion** — left sidebar, quiet page, content as blocks, editing in
  place. Warm or cool neutrals, one accent, almost no boxes. Hierarchy
  from weight and space. Document density. A plain grotesque sans.
- **Linear** — dense, keyboard-first, list as the product, tight type,
  dark-capable, almost no decoration.
- **Stripe** — wide margins, confident type, one restrained accent,
  documentation-grade hierarchy, little chrome.
- **Figma** — canvas in the center, panels on the sides, compact tool
  controls.
- **Apple** — large type, few controls, one primary action, space instead
  of borders, depth used sparingly.

Any other named product gets the same kind of portrait: navigation,
density, color attitude, type, content model, and what that UI refuses.
Write the portrait from how that product is widely known. Say it in the
prompt so the Paper session does not reinterpret the name.

## What the adjectives mean

Translate each requested change into a rule. Do not leave the adjective
in the prompt as the only instruction.

- **Simpler** — fewer controls in view, one idea per region, drop secondary
  chrome the base still has. Do not add a second navigation.
- **More modern** — current type, spacing, and corner radius. No heavy
  shadow, skeuomorphism, or dense toolbars. Stay inside the base. Do not
  reach for glass, gradients, or a dashboard the base is not.
- **More unique** — one or two signature choices (a type pairing, a single
  accent, one layout move). Do not restyle every component.
- **Modern**, with no named product — one coherent direction. Name the
  base you assumed. Do not mix several products.

If a delta conflicts with the base, the delta wins. Say what you dropped.

## Practices every prompt carries

Even when the user never names them:

- One primary action per screen.
- A spacing step (4 or 8). Use it. Do not invent a new gap per region.
- A short type scale. A few sizes, two weights.
- Text contrast that can be read. Do not put gray body text on a tinted
  ground.
- Alignment to one grid. Repeated rows share fixed slots, not gap alone.
- The empty, loading, and error states when the screen has data.
- Desktop unless the user named a phone. Say which you assumed.

## Write the document

Read [template.md](template.md) and fill it once. Keep **How to design this
in Paper** intact. Do not shorten it. Do not add a second visual direction
beside the one this chat decided.

Write `paper-design-prompt.md` at the git root unless the user names
another path inside the repo. If that file already exists, ask before
replacing it.

Do not commit. Do not stage.

If you cannot write, emit the document in one markdown fence labelled with
the path.

## After writing — in chat

1. The path.
2. Three short lines: the base, the delta, and what you assumed.
3. Tell the user to invoke `paper-design` in a new chat. That skill reads
   `paper-design-prompt.md` and builds it in Paper. This skill does not
   start that session.
