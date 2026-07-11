---
name: plan-detail
description: Expand on any part of a plans/plan-<slug>.md file created by the plan skill — the plans are deliberately crisp, so this is how the user pulls the reasoning, alternatives, or code-level specifics behind a step when they want them. Answers in the conversation by default, grounded in fresh research; only writes into the plan file if the user asks to persist it. Never implements. Use when the user says "/plan-detail <question>", "$plan-detail <question>", "more detail on step N", "why does the plan do X", "explain that part of the plan", or asks a question about something in a plan file.
---

# Plan Detail (depth on demand)

Plans written by the `plan` skill are deliberately crisp — one-liners and
diagrams, no explanations. This skill is the pressure valve: the user points
at a part of the plan and gets the depth that was intentionally left out.

## Locating the plan file

- If the invocation includes a path, use it.
- Otherwise use the plan file currently under discussion in this
  conversation; failing that, the most recently modified `plans/plan-*.md`
  in the repo. If none exists, say so and suggest the `plan` skill.

## Flow

1. **Read the plan file fresh** — it may have changed since you last saw it.

2. **Identify what the user is pointing at**: a step number, a section, a
   diagram, a risk line, or a free-form question about the plan's approach.
   If the reference is ambiguous, pick the most likely target and say which
   one you answered.

3. **Research before answering.** Read the actual code, configs, or history
   the question touches — the answer must be grounded the same way the plan
   was, not reconstructed from memory. If the plan's claim turns out to be
   wrong or stale, say so plainly.

4. **Answer in the conversation.** Give the reasoning, trade-offs,
   alternatives considered, code-level specifics, or failure modes — real
   depth, but still written for an experienced developer: no tutorials, no
   padding. Reference real paths and symbols (`src/auth/session.ts:42`).

5. **Only touch the plan file if asked.** If the user says to persist the
   detail (or the answer reveals the plan itself needs correcting), edit the
   plan minimally: fix the affected line(s), or add a short `### <topic>`
   under a `## Details` section at the end — never bloat the main sections.
   Note the edit in `## Review changelog`.

## Hard rules

- **Never implement.** Explaining a step is not license to execute it.
- **Default output is conversation, not file edits** — the plan stays crisp
  unless the user explicitly wants the detail persisted.
- **Answers must come from fresh research**, not from what the plan already
  says restated in more words.
