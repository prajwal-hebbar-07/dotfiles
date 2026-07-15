---
name: plan-detail
description: Investigate or expand any decision, step, risk, or open question in a plans/plan-SLUG.md file created by /plan. Answers in the conversation by default using fresh repository research, and updates the plan only when the user asks or the investigation finds a factual error. Never implements or enters plan mode. Use when the user requests more detail, reasoning, alternatives, or code-level specifics for something in a plan.
---

# Plan Detail (depth on demand)

Plans written by `/plan` are self-contained implementation documents. Use this
skill when the user wants a deeper investigation of one decision, step, risk,
alternative, or unresolved question without starting implementation.

## Locating the plan file

- If the invocation includes a path, use it.
- Otherwise use the plan file currently under discussion in this
  conversation; failing that, the most recently modified `plans/plan-*.md`
  in the repo. If none exists, say so and suggest `/plan <task>`.

## Flow

1. **Read the plan file fresh** — it may have changed since you last saw it.

2. **Identify what the user is pointing at**: a step number, section, design
   decision, risk, open question, or free-form question about the approach.
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

5. **Only touch the plan file if asked or if it is factually wrong.** Put
   persisted information in the section it clarifies rather than creating a
   detached appendix. Keep the document coherent and note the edit in
   `## Review changelog`.

## Hard rules

- **Never implement.** Explaining a step is not license to execute it.
- **Never enter plan mode.**
- **Default output is conversation, not file edits** unless the user requests
  persistence or fresh research proves the plan factually wrong.
- **Answers must come from fresh research**, not from what the plan already
  says restated in more words.
