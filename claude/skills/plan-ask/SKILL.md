---
name: plan-ask
description: Discuss and answer questions about a plan Markdown document — explain the reasoning behind a decision, weigh alternatives and tradeoffs, surface risks and gaps — in a back-and-forth conversation. Reads the plan (and the real repo when a question needs grounding) and answers in the conversation; read-only, never edits the plan or implements. Use when the user says "/plan-ask", "ask about the plan", "what are you thinking here", "why did you choose X in the plan", or wants to talk through a plan.
---

# Plan Ask (talk through a plan)

Answer questions about a plan and think out loud with the user, one question at
a time, so you can have a real back-and-forth. Explain the reasoning behind the
plan's decisions, lay out alternatives and tradeoffs, and flag risks or gaps.
Read-only — this skill discusses the plan, it does not change it.

## Context and scope

The user usually **selects the part of the plan** their question is about and
hands it over as context:

- **With a selection:** answer about that block — it is the focus of the
  question. Still read the whole plan so your answer fits the larger design.
- **Without a selection:** the question is about the whole document; use all of
  it as context.

## Hard rules

- **Read-only.** Do not edit the plan, write code, or implement anything. The
  output is your answer in the conversation.
- **Ground answers in reality.** Base them on what the plan actually says and,
  when the question turns on feasibility, correctness, or fit, on real repo
  research — actual paths and symbols. Never guess or invent.
- **Share your actual thinking.** Give the reasoning, the tradeoff, and your
  recommendation directly; don't hedge or hide behind a list of options.
- **Keep it a dialogue.** Answer the question that was asked, then stop — ready
  for the next one. Don't force closure or dump everything at once.
- **Route changes elsewhere.** If the exchange settles on a concrete change,
  say so and suggest capturing it (an `@me` note or a `/plan-review` pass)
  rather than editing the plan here.

## Steps

1. **Work from the referenced plan.** The user hands over the plan document as
   context (usually with a selection), so use it directly — no need to hunt for
   it. Read the whole document. Only if no plan was referenced, fall back to the
   most recently modified `plans/plan-*.md`.
2. **Set the scope** from the selection (see Context and scope).
3. **Understand the question.** Research the plan, and the real code when the
   question turns on how the plan fits the codebase or whether it will work.
4. **Answer directly.** Explain the thinking behind the relevant decision, give
   the alternatives and their tradeoffs, cite the plan sections and real code
   paths, and call out risks or gaps as you see them.
5. **Invite the follow-up** and carry the thread's context into the next
   question, so the discussion builds instead of restarting.
