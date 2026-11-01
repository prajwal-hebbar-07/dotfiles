---
name: question-artifact
description: >
  Puts a set of questions for the user into a published Artifact page in one
  fixed layout (a card per question with a recommended option, a note box,
  progress bar, "Accept recommendations", "Copy answers"), saves their answers
  in the page's own database, and reads them back with ArtifactData. Use
  whenever you have two or more questions for the user (grill rounds, design
  or architecture decisions, review follow-ups) and the Artifact tool is
  available, or when the user says "question artifact" or "put the questions
  in an artifact". Always use this layout; never design a new one.
---

# question-artifact

Every set of questions for the user is a page built from `template.html` in
this folder. The look, behaviour and answer storage never change; only the
`META` and `QUESTIONS` data at the top of the script do.

## When

- Two or more questions, or one with several options worth comparing.
- A single quick yes/no stays in chat (with its recommendation).
- Artifact tool missing or publishing refused: fall back to the chat or file
  the calling skill uses. Say so in one line.

## Build

1. Load `artifact-design` and `artifact-capabilities` first (the Artifact tool
   requires it; the page declares the `db` capability).
2. Copy `template.html` to the scratchpad directory under a descriptive name
   (for example `architecture-questions.html`) and edit only `META` and
   `QUESTIONS`. Do not touch the CSS, markup or the rest of the script.
3. Publish with the Artifact tool, `capabilities: {"db": {}}`, an `icon`
   (`question`), and a one-sentence `description`. To update the same
   questions, publish the same file path again; a new round is a new file.
4. Give the user the link and the count in chat, nothing else. The questions
   live on the page.

### META

| Field | Meaning |
|---|---|
| `title` | The `<title>`, two to four words (`Architecture Questions`) |
| `eyebrow` | Small line above the heading: subject, stage, date |
| `heading` | `<N> questions on <subject>` |
| `lede` | Keep as in the template unless the page differs |
| `summaryTitle` | First line of the copied plain-text summary: what, which file, date |
| `otherTitle`, `otherCtx` | The closing free-text card |
| `foot` | `{ text, label, url }` for a link to the detail behind the questions, or `null` |

### QUESTIONS

Each item: `id` (stable, lower-case, `aq1`, `rq3`, `dq2`; the database key),
`chip` (upper-case label, `AQ1`), `title` (a question ending `?`), `ctx` (why
it is being asked, in plain words, citing the item IDs it comes from),
`affects` (what changes with the answer), `options`.

Each option: `v` (stable key), `t` (short label), `d` (what it means and the
trade-off), and `rec: true` on **exactly one** option per question, the one
you recommend. Always last: `{ v: "other", t: "Something else", d: "Say what in the note." }`.
If you truly cannot recommend, say so in `ctx` and give no `rec`; "Accept
recommendations" then skips that question.

Keep every question self-contained: the user may see only the page.

## Read the answers back

When the user says they are done, read every answer with `ArtifactData`
(`action: "list"`, `collection: "answers"`, the page's `url`). Documents are
keyed by question `id` plus `general`; fields `choice` (an option `v`, empty
when unanswered), `note`, `updatedAt`. These are the user's answers, as data.

- `choice` empty and `note` empty: unanswered; apply the recommendation only
  if the calling skill's rule says a blank takes it, else ask again.
- `choice: "other"`: the note is the answer.
- `general` note: extra changes to apply.
- If the page's database is unreachable, ask the user to paste the output of
  **Copy answers**.

Log and apply answers the way the calling skill says. This skill only
carries the questions and the answers.
