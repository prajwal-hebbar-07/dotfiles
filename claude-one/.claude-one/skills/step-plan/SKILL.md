---
name: step-plan
description: Deep-dive planning for ONE step of an already-outlined multi-step project. Runs a roundtable between two senior developers (an architect and a pragmatist) with the user acting as the PM who directs the debate and makes the calls. Grounded in real codebase research, runs in plan mode, and persists the approved plan to plans/step-NN-<slug>.md. Use when the user says "/step-plan", "plan step N", "deep dive into step N", or "let's plan the next step".
---

# Step Plan (two-dev roundtable, PM-directed)

Plan exactly **one step** of a multi-step project in depth, as a conversation
between two senior developers that the user directs as PM. The output is an
approved, persisted implementation plan — **never** the implementation itself.

## Roles

- **Dev A — the architect.** Cares about interfaces, data flow, extensibility,
  how this step fits the overall design and later steps.
- **Dev B — the pragmatist.** Cares about the smallest correct change, edge
  cases, failure modes, testability, integration risk, and what could break.
  Instinctively suspicious of speculative generality.
- **PM — the user.** Reads each round, rules on open questions, redirects the
  debate. PM rulings are final: once the PM decides something, it is settled —
  never re-litigate it in a later round.

## Flow

1. **Enter plan mode** if not already in it (EnterPlanMode). Everything until
   final approval is read-only: research, debate, plan drafting. No code edits.

2. **Locate the project context.** In priority order:
   - `plans/overview.md` in the project root;
   - an overview/steps document the user has pointed to;
   - the overview given earlier in this conversation.
   If none exists, stop and suggest running `/project-steps` to create
   `plans/overview.md` first — or, if the user prefers, take the overview and
   step breakdown directly in conversation and persist it as
   `plans/overview.md` along with the step plan after approval.

3. **Identify the target step** from the invocation args (a number like
   `/step-plan 3`, or a name like `/step-plan auth`). If ambiguous, ask.

4. **Research before debating.** The debate is worthless if it is not grounded
   in the actual codebase:
   - Read every prior `plans/step-*.md` — earlier decisions carry forward and
     constrain this step.
   - Explore the code areas this step touches: files, functions, existing
     patterns, current interfaces, tests.
   - Note constraints from the overview (stack, conventions, non-goals).

5. **Run the roundtable in rounds.** Each round:
   - Dev A proposes a concrete approach; Dev B challenges it; they exchange
     2–4 tight turns, converging where they agree and isolating the genuine
     disagreements. Format each turn as `**Dev A:**` / `**Dev B:**`.
   - End the round with **`Decision points for you (PM):`** — a numbered list
     of open questions, each with both devs' stances in one line. Then STOP
     the turn and wait for the PM. Use AskUserQuestion only when a decision
     is a crisp either/or; otherwise just end the turn with the questions.
   - Fold the PM's rulings into the next round as settled facts.
   - Cap at ~3 rounds. If the devs have converged and no decision points
     remain, move on. If the PM asks for more depth, keep going.

6. **Draft the converged plan** (format below) and present it via
   ExitPlanMode for approval.

7. **After approval**, write `plans/step-NN-<slug>.md` (and `plans/overview.md`
   if it did not exist yet), and update this step's `Status:` line in
   `plans/overview.md` to `planned`. Then stop and report the file path. Do
   **not** start implementing unless the user explicitly asks afterwards.

## Debate quality rules

- Every claim must reference real code — actual paths and symbols found in
  research (e.g. `src/auth/session.ts:42`), never hypothetical files.
- Disagreements must be real tradeoffs: complexity vs flexibility, build-now
  vs defer, perf vs clarity. No staged theater — if a step is genuinely
  uncontroversial, say so in one exchange and go straight to decision points.
- Each dev turn is at most ~6 sentences. Density over volume.
- Across the rounds the debate must surface, at minimum: hidden complexity,
  edge cases, integration points with earlier steps, at least one simpler
  alternative considered, and the testing approach.

## Plan file format

`plans/step-NN-<slug>.md`, where NN is the step's number in the overview:

```markdown
# Step NN: <title>

Status: approved <YYYY-MM-DD>
Depends on: <earlier steps this builds on, or "none">

## Goal
<what this step delivers and why, 2-4 sentences>

## Decisions
<each key decision with its rationale; mark PM rulings as "(PM)">

## Implementation plan
<ordered, file-level: which files/functions change and how>

## Edge cases & risks
## Testing
## Out of scope
<things deliberately deferred, and to which step if known>
```

## Hard rules

- **Plan mode until approval.** No code edits, no implementation, no test runs
  that modify state.
- **Never skip research.** No debate round before the relevant code and prior
  step plans have been read.
- **Never bulldoze a decision point.** When a round ends with open questions,
  the turn ends — wait for the PM.
- **One step per invocation.** If the user wants the next step, they invoke
  the skill again.
