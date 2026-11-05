---
name: requirements-slides
description: >
  Turns docs/requirements.md into a colourful slide deck published as an
  Artifact, so the user can review the requirements in a few minutes instead
  of reading the file: what the app is and who it is for, what it does by
  theme, the quality bar, limits, what it will not do, what the models
  settled on the user's behalf, and what still needs them. Read-only on the
  repo. Use when the user says "/requirements-slides" or wants the
  requirements as slides. Claude Code only.
argument-hint: "[path/to/requirements.md]"
disable-model-invocation: true
---

# requirements-slides

A simpler, fun-to-read version of the requirements for review. The file stays
the source; the deck is a view of it.

## Read

`docs/requirements.md` (or the path given; none and none found, say so in one
line and stop), and beside it, if present: `docs/project.md`,
`docs/glossary.md`, `docs/later.md`, `docs/grill/requirements-log.md`,
`docs/grill/requirements-questions.md`. Nothing else; no code.

## Slides

In this order; drop a slide only when the files have nothing for it.

1. **Title**: project name, one line on what it is, status, stat chips (R,
   N, C, X, open questions).
2. **What and who**: the Overview and Users, in a few short lines.
3. **What it does**: one slide per theme of `R` items (group by what they are
   about; at most six per slide, split a big theme). Each item in plain
   words with its ID chip, and its `Accept:` line as "You'll know it works
   when …".
4. **How good it must be**: the `N` items.
5. **Limits**: the `C` items.
6. **Not doing**: `X` items, and `later.md` items as "Later".
7. **Not settled yet**: `A` items, with the reason.
8. **Decided for you**: log questions marked `Class: settled by models`, and
   those marked `Class: default` answered `yes`, each with its `G` ID and the
   answer, so the user can spot one to reopen.
9. **Needs you**: open `Q` items and open questions in the questions file,
   counted by theme, with the file path.
10. **Next**: the tracker's **Next action**.

## Words

Simpler, never different. Keep every number, limit, name and "must" /
"never" / "always" exactly as in the file (the `Said:` lines). Cut words,
never meaning; when a plain version would lose something, use the file's
words. Every item keeps its ID. Invent nothing; no item, reason or example
that is not in the files.

## Look

Load `artifact-design` first and follow it. One slide on screen at a time,
next and back by arrow keys, buttons and swipe, a slide counter and a
progress bar. A bold colour per section (each kind of item keeps its colour
on every slide), big type, short lines, ID chips as coloured badges, an emoji
or icon per section heading. Works at phone width, light and dark. Static
page: no capabilities.

## Publish

1. Write the HTML to the scratchpad directory as
   `requirements-slides-<project>.html`.
2. One deck per project, titled `Slides: <project> requirements`. Linked,
   published earlier in this chat, or in the user's list (`action: "list"`):
   republish to the same `url`. Else new, with an `icon` (`presentation`) and
   a one-sentence `description`.
3. Reply with the link and one line: slide count, and counts of items, decided
   for you, and still needing you.

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
compare each slide's wording with `requirements.md` and find any item whose
meaning, number or "must" / "never" changed, or that the deck dropped or
invented. Fix what the file supports. Claude decides when the advisor is
called, so name the point. If the advisor is off, unavailable, or declines,
say so in one line and carry on. Its answer is advice; the file wins.
