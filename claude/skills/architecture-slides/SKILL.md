---
name: architecture-slides
description: >
  Turns docs/architecture.md into a colourful slide deck published as an
  Artifact, so the user can review the architecture in a few minutes instead
  of reading the file: the shape and the alternative it beat, the module map,
  each module, the data, the main flows with what happens when they fail,
  the cross-cutting concerns, the threats, what the models decided for the
  user, and what still needs them. Read-only on the repo. Use when the user
  says "/architecture-slides" or wants the architecture as slides. Claude
  Code only.
argument-hint: "[path/to/architecture.md]"
disable-model-invocation: true
---

# architecture-slides

A simpler, fun-to-read version of the architecture for review. The file stays
the source; the deck is a view of it.

## Read

`docs/architecture.md` (or the path given; none and none found, say so in one
line and stop), and beside it, if present: `docs/requirements.md`,
`docs/stack.md`, `docs/project.md`, `docs/glossary.md`, `docs/adr/`,
`docs/grill/architecture-log.md`, `docs/grill/architecture-questions.md`.
Nothing else; no code.

## Slides

In this order; drop a slide only when the files have nothing for it.

1. **Title**: project name, the shape in one line, status, stat chips
   (modules, entities, flows, threats, ADRs, open questions).
2. **The shape**: the chosen shape, and the alternative shape with why it
   lost and what would force it.
3. **The module map**: one inline SVG of the modules and their `Depends on`
   arrows, each with its `M` ID.
4. **The modules**: at most three per slide. Each: its one responsibility,
   its interface in a line, the data it owns, and the `R` / `N` it serves.
5. **The data**: the `E` items, each with its owner, lifecycle and what is
   kept for how long.
6. **The flows**: one slide per main flow: the steps as a small sequence,
   then what fails at each step and what the user sees.
7. **Across the app**: the `K` items, one line each.
8. **Threats**: the `B` items: the abuse, what stops it, and the check that
   shows it holds.
9. **Decided for you**: log questions marked `Class: settled by models`, and
   those marked `Class: default` answered `yes`, each with its `D` ID and the
   answer, so the user can spot one to reopen.
10. **Needs you**: open `AQ` items and open questions in the questions file,
    counted by theme, with the file path.
11. **Next**: the tracker's **Next action**.

## Words

Simpler, never different. Use the file's words for module, interface, seam,
adapter and depth, and the glossary's terms for the data. Keep every name,
number, limit and guarantee exactly as in the file. Cut words, never meaning;
when a plain version would lose something, use the file's words. Every item
keeps its ID. Invent nothing; no module, flow, failure or example that is not
in the files.

## Look

Load `artifact-design` first and follow it (and `artifact-diagramming` for
slides 3 and 6). One slide on screen at a time, next and back by arrow keys,
buttons and swipe, a slide counter and a progress bar. A bold colour per
section (each kind of item keeps its colour on every slide), big type, short
lines, ID chips as coloured badges, an emoji or icon per section heading.
Works at phone width, light and dark. Static page: no capabilities.

## Publish

1. Write the HTML to the scratchpad directory as
   `architecture-slides-<project>.html`.
2. One deck per project, titled `Slides: <project> architecture`. Linked,
   published earlier in this chat, or in the user's list (`action: "list"`):
   republish to the same `url`. Else new, with an `icon` (`presentation`) and
   a one-sentence `description`.
3. Reply with the link and one line: slide count, and counts of items,
   decided for you, and still needing you.

Artifact tool missing or publishing refused: say so in one line and stop.

## Never

- Create, edit or delete any repo file. The deck is the only output.
- Do only what the request needs: no extra slides, notes, export or
  interactivity beyond navigation. A useful extra is named, not built.
- Ask what is already settled. Read the files first; two or more genuine
  questions go in a question artifact (`question-artifact`).
- Present a simplification as a change, or an inference as the file's word.

## Advisor

If an advisor is on (`/advisor`), consult it once, before publishing: ask it to
compare each slide with `architecture.md` and find any module, owner, flow,
failure or guarantee that changed, or that the deck dropped or invented. Fix
what the file supports. Claude decides when the advisor is called, so name
the point. If the advisor is off, unavailable, or declines, say so in one line
and carry on. Its answer is advice; the file wins.
