---
name: draft-docs
description: Write docs/requirements.md, docs/stack.md, or docs/architecture.md only from what the user stated in the invocation and chat, in the shape the matching grill skill reads. Use when the user wants a starting document to grill afterwards.
disable-model-invocation: true
---

# draft-docs

Turn what the user has told you into the starting document for a grill skill.
Record their statements; do not research, judge, or complete them. The grill
skills find the gaps afterwards.

Invoke explicitly as `/skill:draft-docs <requirements|stack|architecture> [what you want recorded]`.

| Kind | File | Grill afterwards |
| --- | --- | --- |
| `requirements` | `docs/requirements.md` | `/skill:grill-requirements` |
| `stack` | `docs/stack.md` | `/skill:grill-stack` |
| `architecture` | `docs/architecture.md` | `/skill:grill-architecture` |

The architecture draft goes to `docs/architecture.md`, not
`docs/architecture-review.md`: the review is the grill's own output, and the
grill reads this draft as the architecture claim to verify.

## Never

- Do only what the request needs. Add no requirement, technology, component,
  flow, constraint, or exclusion the user did not state. A useful extra is
  named in the reply, not written.
- Never ask what is already settled. Read the invocation, this chat, and the
  existing target file first.
- Research the repository or the web, or validate, rank, or recommend a
  choice. That is the grill's job.
- Resolve an ambiguity or fill a gap with common practice. Record it as open.
- Grill the user. Ask only when Step 1 says to.
- Write any file other than the one target document, run a grill, or commit.

## Step 1 — pick the document

The kind is the first word of the invocation. Accept obvious variants
(`reqs`, `tech stack`, `arch`). Without a kind, infer it only when every
statement belongs to one document; otherwise ask once which document to
write.

The content is the rest of the invocation plus anything the user stated
earlier in this chat for this document. If there is nothing to record, say
so and stop.

## Step 2 — sort the statements

Sort each statement into the target shape (Step 3). Keep the user's wording,
numbers, and force words such as “must,” “only,” “never,” and “always.”
Rephrase only to make one statement per line; never sharpen, soften, or
quantify it.

- A statement that belongs to another document kind is left out and named in
  the reply, so the user can draft that document next.
- A vague, conflicting, or half-made decision goes under the shape's open
  section, worded as the question it leaves.

If the target file exists, keep its structure and everything the new
statements do not touch. A new statement that contradicts an existing line
replaces it; list each replacement in the reply.

## Step 3 — write the document

Create `docs/` only if needed. Omit empty sections and fields. Add no IDs,
dates, scores, or acceptance criteria the user did not give.

### `requirements` → `docs/requirements.md`

```markdown
# Requirements

## Goal

<what the user is trying to achieve>

## Requirements

- <observable required behavior>

## Constraints

- <explicit limit, dependency, platform, or quality constraint>

## Out of scope

- <explicit exclusion>

## Open questions

- <ambiguity or undecided point the user left>
```

### `stack` → `docs/stack.md`

```markdown
# Technology stack

## Context

- <requirements and constraints the user gave for the stack>

## Choices

### <area>: <technology and version only when the user gave it>

- Origin: User-chosen | Fixed constraint
- Serves: <the need the user named for it>

## Decisions for you

- <area left undecided or choice the user was unsure about>
```

`Origin` is `Fixed constraint` only when the user said the choice is forced
(employer, platform, existing system); otherwise `User-chosen`. Leave
`Checked`, `Assessment`, `Evidence`, `Risks`, `Alternative`, `Suggestion`,
and `Exit` out: `grill-stack` fills them from its research.

### `architecture` → `docs/architecture.md`

```markdown
# Architecture

## Overview

<the system's shape in the user's words>

## Components

### <component>

- Responsibility: <what it does>
- Depends on: <other components or external systems>
- Owns: <data or state it owns>

## Flows

- <critical flow, step by step as described>

## Deployment

- <where and how each part runs>

## Open questions

- <ambiguity or undecided point the user left>
```

## Step 4 — reply

Reply with the file path, the number of entries per section, every replaced
line, statements left out because they belong to another document, and the
grill command to run next. Do not repeat the document in chat.
