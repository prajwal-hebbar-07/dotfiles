---
name: stack-slides
description: >
  Turns docs/stack.md into a colourful slide deck published as an Artifact,
  so the user can review the tech stack in a few minutes instead of reading
  the file: the stack in one picture, each choice with why, its alternative,
  cost and way out, what is not needed, cost overall, what it assumes, what
  the models decided for the user, and what still needs them. Read-only on
  the repo. Use when the user says "/stack-slides" or wants the stack as
  slides. Claude Code only.
argument-hint: "[path/to/stack.md]"
disable-model-invocation: true
---

# stack-slides

A simpler, fun-to-read version of the stack for review. The file stays the
source; the deck is a view of it.

## Read

`docs/stack.md` (or the path given; none and none found, say so in one line
and stop), and beside it, if present: `docs/requirements.md`,
`docs/project.md`, `docs/glossary.md`, `docs/adr/`,
`docs/grill/stack-log.md`, `docs/grill/stack-questions.md`. Nothing else; no
code.

## Slides

In this order; drop a slide only when the files have nothing for it.

1. **Title**: project name, the stack in one line, status, stat chips
   (decisions, settled, ADRs, open questions).
2. **The stack in one picture**: one inline SVG of the pieces and how they
   connect (client, server, data, hosting, services), each with its `S` ID.
3. **The choices**: one slide per hard-to-reverse decision (language,
   framework, data store, hosting, auth), then the rest grouped, at most four
   per slide. Each: the choice and version, why (the `R` / `N` / `C` IDs it
   serves, in plain words), the alternative and what would make it win,
   cost, and how hard it is to leave. An ADR badge where one exists.
4. **Not needed**: each area left out, with the reason.
5. **What it costs**: monthly cost at launch and at the requirements'
   numbers, from the decisions' `Cost` lines.
6. **What it assumes**: `Assumes:` lines and `SA` items, with the reason.
7. **Decided for you**: log questions marked `Class: settled by models`, and
   those marked `Class: default` answered `yes`, each with its `T` ID and the
   answer, so the user can spot one to reopen.
8. **Needs you**: open `SQ` items and open questions in the questions file,
   counted by theme, with the file path.
9. **Next**: the tracker's **Next action**.

## Words

Simpler, never different. Keep every name, version, price, limit and date
exactly as in the file, with its source date. Cut words, never meaning; when
a plain version would lose something, use the file's words. Every decision
keeps its ID. Invent nothing; no choice, reason, cost or example that is not
in the files.

## Look

Load `artifact-design` first and follow it (and `artifact-diagramming` for
slide 2). One slide on screen at a time, next and back by arrow keys, buttons
and swipe, a slide counter and a progress bar. A bold colour per section
(each kind of item keeps its colour on every slide), big type, short lines,
ID chips as coloured badges, an emoji or icon per section heading. Works at
phone width, light and dark. Static page: no capabilities.

## Publish

1. Write the HTML to the scratchpad directory as
   `stack-slides-<project>.html`.
2. One deck per project, titled `Slides: <project> stack`. Linked, published
   earlier in this chat, or in the user's list (`action: "list"`): republish
   to the same `url`. Else new, with an `icon` (`presentation`) and a
   one-sentence `description`.
3. Reply with the link and one line: slide count, and counts of decisions,
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
compare each slide with `stack.md` and find any choice, version, price or
reason that changed, or that the deck dropped or invented. Fix what the file
supports. Claude decides when the advisor is called, so name the point. If the
advisor is off, unavailable, or declines, say so in one line and carry on. Its
answer is advice; the file wins.
