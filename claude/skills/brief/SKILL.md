---
name: brief
description: >
  Turns a Markdown document (a stack, architecture, design, feature or
  requirements doc) plus everything it relates to into one visually appealing
  Artifact page that briefs the user: what it is, what is decided, what they
  must decide, risks, and what to do next. Use when the user says "/brief
  <path>", "brief me on this doc", "summarise this doc as an artifact" or
  points at a .md file and wants to understand it before deciding. Read-only
  on the repo. Claude Code only.
argument-hint: <path/to/doc.md>
---

# brief

Read a document and its surroundings, then publish a page the user can skim
in two minutes and act on. The page is for a decision-maker: plain words, the
document's own IDs, no filler.

## Input

`/brief <path>`. No path: use the document named in the chat; none, say so in
one line and stop.

## Read

1. The document itself, whole.
2. Everything it relates to, and only that: files it links, IDs it cites
   (`R3`, `D2`, `Q4`...) resolved to their source, and sibling docs in the
   same `docs/` folder it depends on or is checked against (answer logs,
   requirements, project tracker). Follow links one level; stop there.
3. Nothing outside the repo's documents. Do not read code to fill gaps.

## Page content

Order is fixed; drop a section only if the documents have nothing for it.

1. **Hero**: document title, one-sentence "what this is", status, and 3 to 4
   stat chips (for example decisions made, open questions, risks).
2. **TL;DR**: 3 to 5 lines. What it says and why it matters.
3. **Needs your decision**: the open questions and choices, each a card with
   its ID, the options in one line each, the trade-off, and a **recommended**
   option marked. No recommendation possible: say so and give the trade-offs.
   Put these first after the TL;DR, they are why the user is here.
4. **Decided**: each decision with its ID and the reason, one line.
5. **How it fits together**: one inline SVG diagram of the real structure
   (components, flow, or how this doc relates to its neighbours). Load
   `artifact-diagramming`. Skip if a picture adds nothing.
6. **Risks and gaps**: what could go wrong or is missing, severity-marked.
7. **Next**: the concrete next step and which skill or command does it.

Facts come from the documents, with their IDs. Mark anything inferred as
"inferred". Never invent a decision, option or reason.

## Look

Make it fun to read: a bold hero, colour-coded sections and badges
(decide / decided / risk), generous spacing, short lines, icons or emoji
sparingly, subtle section reveals. Works at phone width, light and dark.
Load `artifact-design` first and follow it. Static page: no capabilities.

## Publish

1. Load `artifact-design` (and `artifact-diagramming` if there is a diagram).
2. Write the HTML to the scratchpad directory as `brief-<doc-name>.html`.
3. One brief artifact per document, found by title (`Brief: <doc title>`),
   whether linked, published earlier in this chat or in the user's list
   (`action: "list"`). Found: read it and republish to the same `url`. Not
   found: new, with `icon` (`summary`) and a one-sentence `description`.
4. Reply with the link and one line: counts of decisions needed, decided,
   risks. Nothing else; the page is the brief.

Artifact tool missing or publishing refused: give the same sections in chat,
as short as possible, and say so in one line.

## Never

- Edit, create or delete any repo file. The page is the only output.
- Do only what the request needs. No extra sections, interactivity, database
  or options; a useful extra is named in one line, not built.
- Ask what is already settled. Read the documents and chat first; an answer
  already given is final. Two or more genuine questions go in a question
  artifact (`question-artifact`).
- Restate the whole document. Brief it: decisions, risks, next step.
- Present an inference as the document's word.
