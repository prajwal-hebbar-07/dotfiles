---
name: step-plan
description: Deep-plan one step of an already outlined multi-step project. Run a codebase-grounded roundtable between an architect and a pragmatist, with the user acting as PM who directs the debate and makes final decisions. Keep research and debate read-only, then persist the approved plan to its numbered file under plans/. Use when the user says "/step-plan", "$step-plan", "plan step N", "deep dive into step N", or "let's plan the next step".
---

# Step Plan

Plan exactly one step of a multi-step project in depth as a conversation
between two senior-developer perspectives directed by the user as PM. Produce
an approved, persisted implementation plan. Never implement the plan.

## Roles

- **Dev A — architect:** Focus on interfaces, data flow, extensibility, and
  how this step fits the overall design and later steps.
- **Dev B — pragmatist:** Focus on the smallest correct change, edge cases,
  failure modes, testability, integration risk, and what could break. Challenge
  speculative generality.
- **PM — user:** Direct the debate and rule on open questions. Treat every PM
  ruling as final and do not re-litigate it in later rounds.

## Flow

1. **Keep the planning phase read-only.** Until the user approves the final
   plan, research, debate, and draft only. Do not edit product code or planning
   files.

2. **Locate the project context** in this order:
   - `plans/overview.md` in the repository root;
   - an overview or steps document named by the user;
   - an overview given earlier in the conversation.

   If none exists, stop and suggest using `$project-steps` to create
   `plans/overview.md`. If the user prefers, accept the overview and step
   breakdown in conversation and persist it with the approved step plan.

3. **Identify the target step** from the invocation, whether a number such as
   `$step-plan 3` or a name such as `$step-plan authentication`. Ask if the
   target remains ambiguous after reading the overview.

4. **Research before debating:**
   - Read every earlier `plans/step-*.md`; prior decisions constrain this step.
   - Inspect the files, symbols, interfaces, tests, and existing patterns this
     step touches.
   - Carry forward the overview's stack, constraints, non-goals, dependencies,
     and deliberately deferred work.

5. **Run a concise roundtable:**
   - Dev A proposes a concrete approach. Dev B challenges it. Exchange 2–4
     tight turns using `**Dev A:**` and `**Dev B:**`, converge where possible,
     and isolate genuine disagreements.
   - End each unresolved round with **`Decision points for you (PM):`** and a
     numbered list. Put both devs' positions on one line per question, then end
     the turn and wait for the PM.
   - Fold PM rulings into the next round as settled facts.
   - Aim for at most three rounds. Continue only when the PM asks for more
     depth or material decisions remain unresolved.

6. **Draft the converged plan in chat** using the format below and ask for
   explicit approval. Do not write it to disk yet.

7. **After approval**, write `plans/step-NN-<slug>.md`. If the overview did
   not exist and the PM supplied one, write `plans/overview.md` as well. Update
   the target step's `Status:` in the overview to `planned`, then report the
   plan path and stop. Do not begin implementation unless the user explicitly
   asks in a later turn.

## Debate quality

- Ground every implementation claim in real repository evidence. Reference
  actual paths and stable symbols, never hypothetical files.
- Debate real tradeoffs such as complexity versus flexibility, build now
  versus defer, performance versus clarity, and risk versus scope. Avoid staged
  theater; if the step is uncontroversial, converge in one exchange.
- Keep each dev turn to about six sentences or fewer.
- Across the rounds, surface hidden complexity, edge cases, integration with
  prior steps, at least one simpler alternative, and the testing approach.

## Plan file format

Write `plans/step-NN-<slug>.md`, where `NN` is the overview step number:

```markdown
# Step NN: <title>

Status: approved <YYYY-MM-DD>
Depends on: <earlier steps this builds on, or "none">

## Goal
<what this step delivers and why, in 2–4 sentences>

## Decisions
<each key decision with its rationale; mark PM rulings as "(PM)">

## Implementation plan
<ordered, file-level changes naming files and stable symbols>

## Edge cases & risks
<credible failure modes and mitigations>

## Testing
<automated and manual verification>

## Out of scope
<deliberately deferred work and its later step, when known>
```

## Hard rules

- **No implementation.** Keep research and debate read-only; write only the
  approved planning files.
- **Never skip research.** Do not begin a debate round before reading the
  relevant code, tests, overview, and earlier step plans.
- **Never bulldoze a decision point.** End the turn and wait for the PM when
  open questions remain.
- **One step per invocation.** Require a new invocation for the next step.
