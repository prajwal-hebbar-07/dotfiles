---
name: plan
description: Research the repository and produce a concise, senior-engineer-ready implementation plan as a Markdown document in the project's plans/ directory, with technical diagrams where they clarify the design. Acts like a planning agent — investigates real code, weighs the approach, and writes the plan — but never implements it. Use when the user says "plan this", "make a plan", "write an implementation plan", "/plan", or describes a task they want planned before coding.
---

# Plan (research → implementation plan document)

Turn a task description into a clear implementation plan a senior engineer can
execute without re-deriving the context. Research the real codebase first,
settle on an approach, then write a focused Markdown plan into `plans/`. Plan
only — never implement the change.

## Hard rules

- **Research is read-only.** The only file you write is the plan document under
  `plans/`. No code edits, no branches, commits, installs, or test runs.
- **Ground everything in the real repo.** Reference actual paths, symbols, and
  existing patterns. Never invent files or APIs that aren't there.
- **Be concise and specific.** A senior engineer should learn what to build and
  how — not wade through filler. Cut any section that doesn't apply.
- **Diagrams only when they clarify.** Add a diagram for non-trivial
  architecture, data flow, sequences, or state. Skip them for simple changes.
- **Plan, don't build.** Do not start implementing unless the user explicitly
  asks in a later turn.

## Process (mirror a planning agent)

1. **Understand the task.** Restate the goal, scope, and success criteria from
   the user's description, and note constraints. Ask at most a few clarifying
   questions — only for decisions that genuinely fork the design. Otherwise
   proceed and record your assumptions in the plan.
2. **Research the codebase.** Inspect the stack, conventions, entry points, and
   the specific files, symbols, and tests the task touches. Learn how similar
   things are already done so the plan fits existing patterns rather than
   fighting them.
3. **Decide the approach.** Choose one concrete approach and the smallest
   correct change that fits the codebase. When there is a real tradeoff, name
   the alternative you rejected and why.
4. **Write the plan** to `plans/plan-<slug>.md` using the format below, where
   `<slug>` is a short kebab-case name derived from the task. Create `plans/`
   if it does not exist.
5. **Report** the plan path and a 2–3 line summary of the approach.

## Locating plans/

Write to `plans/` at the repository root — find it with
`git rev-parse --show-toplevel`. Create the directory if missing. Outside a git
repo, use `plans/` under the current working directory.

## Plan document format

Write `plans/plan-<slug>.md`. Keep it tight; drop sections that don't apply.

```markdown
# <Task title>

Status: draft <YYYY-MM-DD>

## Goal
<what we're building and why, in 2-4 sentences>

## Context
<current state: the relevant files, modules, and behavior this touches, with
paths — what exists today that the change builds on or replaces>

## Approach
<the chosen approach and the key decisions behind it; note rejected
alternatives when a tradeoff mattered>

## Diagrams
<Mermaid diagram(s) when they clarify architecture, data flow, sequence, or
state; omit if not helpful>

## Implementation plan
<ordered, file-level steps naming the files and stable symbols to add or
change and what each step does — concrete enough to execute>

## Edge cases & risks
<credible failure modes, tricky states, and how the plan handles them>

## Testing
<how to verify: automated tests to add or adjust, plus any manual checks>

## Out of scope / open questions
<deliberately deferred work and anything still needing a decision>
```

## Diagram guidance

Use Mermaid fenced blocks (` ```mermaid `). Pick the type that fits and keep it
small and labeled — a diagram should cut reading time, not add ceremony:

- `flowchart` — architecture, control flow, or data flow
- `sequenceDiagram` — request/response or multi-component interactions
- `stateDiagram-v2` — state machines and lifecycles
- `erDiagram` — data models and relationships
