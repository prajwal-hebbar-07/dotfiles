---
name: plan-review
description: Resolve the inline review comments left in a plan Markdown document and maintain a dated review log inside it. Reads the whole plan, finds every `@me` HTML-comment annotation, edits the plan to satisfy each one, strips the resolved markers, and records what was done in a Review log section. Use when the user says "/plan-review", "review my plan comments", "resolve the notes in the plan", or hands over a plan file with comments to address. Only edits the plan document — never implements the change.
---

# Plan Review (resolve comments → update plan → log the round)

Take a plan document that has review comments in it, address every comment by
editing the plan, and keep a running Review log of what changed and when. Edit
only the plan file — never implement the underlying change.

## Comment convention

Reviewers annotate the plan with inline HTML comments whose body starts with
`@me` (case-insensitive), so they stay invisible in rendered Markdown:

```markdown
The retry loop runs at most 3 times. <!-- @me: make this configurable and say where -->
```

An `@me` marker may sit inline next to the text it refers to, or on its own line
above/below a section. Treat each `@me` comment as one review request.

## Context and scope

The user usually **selects the block of the plan** where the review applies and
hands it over as context, so you know exactly where the change lands:

- **With a selection:** treat that block as the anchor. Resolve the `@me`
  comment(s) in or attached to it and make the edit there. Still read the whole
  plan first so the change stays consistent with the rest of the document.
- **Without a selection:** use the whole document as context — scan the entire
  plan for `@me` comments and resolve every one.

## Hard rules

- **Only edit the plan document.** No code changes, no new files, no branches,
  commits, installs, or test runs. The single file you write is the plan.
- **Address every `@me` comment.** Never silently drop one. Resolve it, or — if
  it needs a decision you can't make — leave a clear `<!-- @me: ... -->` note
  asking the question and record it as unresolved in the Review log.
- **Ground factual updates in the real repo.** When a comment asks for a
  correction or more detail, research the actual code; never guess.
- **Preserve structure.** Keep the plan's existing sections and untouched
  content intact. Change only what the comments require.
- **Never implement.** Resolving a comment means updating the plan text, not
  writing the code it describes.

## Steps

1. **Work from the referenced plan.** The user hands over the plan document as
   context (usually with a selection), so use it directly — no need to hunt for
   it. Read the whole document. Only if no plan was referenced, fall back to the
   most recently modified `plans/plan-*.md`.
2. **Collect the comments in scope** (see Context and scope). With a selection,
   that's the `@me` comment(s) in the selected block; otherwise every `@me`
   comment in the plan. For each, note its location and what it asks. If there
   are none, report that there are no open comments and stop.
3. **Resolve each comment.** Edit the relevant section to satisfy it —
   clarify, correct, expand, adjust the approach, update or add a diagram,
   etc. Do fresh repo research where a comment needs grounding.
4. **Strip resolved markers.** Remove the `@me` HTML comments you addressed so
   the plan reads clean. Leave only markers you deliberately could not resolve.
5. **Update the Review log** (format below): add a new dated round summarizing
   each comment and what you did about it.
6. **Report** how many comments were resolved, which round you added, anything
   left unresolved and why, and the plan file path.

## Review log format

Keep a `## Review log` section at the end of the plan. Add one round per run,
newest at the bottom, so the history reads top-to-bottom in order:

```markdown
## Review log

### <YYYY-MM-DD> — round <N>
- <comment paraphrase> → <what changed and where in the plan>
- <comment paraphrase> → <what changed and where>
- UNRESOLVED: <comment paraphrase> → <why, or what decision is needed>
```

If the plan has no Review log yet, create the section on the first run and start
at round 1. Never rewrite or renumber earlier rounds — only append.
