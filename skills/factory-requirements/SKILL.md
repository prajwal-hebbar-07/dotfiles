---
name: factory-requirements
description: >
  Factory stages 1-3: interviews the user one question at a time, writes
  docs/factory/REQUIREMENTS.md (numbered R requirements with Given / When /
  Then, out of scope, tech choices, boundaries), grills it with a pre-mortem
  round, and runs the approval gate (builder check on). Also handles a
  requirement change after issues exist. Use when /skill:factory routes to
  the requirements stage, or when invoked as /skill:factory-requirements.
argument-hint: "[idea | change: <what changes>]"
disable-model-invocation: true
---

# factory-requirements

Stages 1-3 of the software factory. Design: `SOFTWARE-FACTORY.md` §4.1-§4.3,
§4.8. Run from the target repo root. State tool:
`F=~/.omp/agent/skills/factory/scripts/factory-state`. Document layout:
`template.md` beside this file.

## Never

- Ask more than one interview question per message.
- Ask a question without a guess attached.
- Ask the user something the repo, or a `scout`, can answer.
- Treat "whatever you think", "sounds good", "sure" as a yes (addyosmani
  `interview-me`). Re-ask with two concrete options.
- Invoke tools or start the next stage in the turn the user confirms the
  playback, other than writing the draft.
- Edit `REQUIREMENTS.md` after its gate is stamped without
  `$F reopen requirements` first. The guard blocks it.
- Renumber or reuse an `R` number.
- Write code, a stack, or an architecture here.

## Entry

1. `$F init` when `.factory/state.json` is missing (app mode). Then
   `$F set stage '"requirements"'`.
2. If `$F verify` prints any `REOPEN` line, stop: tell the user which gate
   was edited after approval and ask whether to reopen it. Do not continue.
3. If `docs/factory/REQUIREMENTS.md` exists and its gate is stamped
   (`$F get gates.requirements`) and the arguments do not start with
   `change:`, say it is already approved and point to `/skill:factory`.
   With `change:`, go to **Change** below.

## 1. Interview

Base: addyosmani `interview-me`, unchanged.

- **Existing repo** (any tracked source files): spawn one `scout` first. It
  maps stack, modules, tests, docs, and existing `AGENTS.md` rules. Never ask
  what it answered. Skip for an empty repo.
- **Hypothesis first.** One sentence plus a confidence number (0-100%); below
  70%, add what is missing on the same line.

  ```
  HYPOTHESIS: <what you think they want>
  CONFIDENCE: ~30% (missing: who it is for, what success looks like)
  ```

- **One question at a time, a guess on every question:**

  ```
  Q: <one focused question>
  GUESS: <your answer and why>
  ```

  Occasionally guess in a direction you expect pushback on. Wait for the
  answer before the next question.
- **Want vs should-want.** On "scalable", "clean", "modern", "the standard
  way", ask: "If you didn't have to justify this to anyone, what would you
  actually want?"
- **Two additions, each needed later:**
  1. Ask which tech choices the user wants to make and which to leave to the
     factory (language, framework, data store, hosting, other). Superpowers
     `brainstorming`, "How it gets made". The stack stage grills only the
     kept ones.
  2. Pin acceptance as numbered `R1`, `R2`, ... each with Given / When / Then
     (github/spec-kit `spec-template.md`). Issues cite the numbers; QA writes
     scenarios from them.
- **Stop** when you can predict the answers to the next three questions. If
  several rounds do not raise confidence, say so and ask to step back.
- **Playback.** Write it back and get an explicit yes:

  ```
  Outcome:      <one line>
  User:         <who benefits>
  Why now:      <what changed>
  Success:      <how we know it worked>
  Constraint:   <the binding limit>
  Out of scope: <what is not being built>
  ```

  Out of scope is never skipped. Fold corrections in and restate until yes.

## 2. Draft

On the yes, write `docs/factory/REQUIREMENTS.md` from `template.md`. Sections,
in order: Problem, Solution, User Stories, Requirements, Non-functional
requirements, Out of Scope, Tech choices, Open Questions, Boundaries
(Always / Ask first / Never; addyosmani `spec-driven-development`). Use
mattpocock `to-spec` wording rules: user's side, glossary words, no file
paths or code. Every criterion is checkable without asking anyone; include
failure and edge paths.

## 3. Grill

`read skill://factory-grill`. Run the full frontier first, then the
**pre-mortem round** (`factory-grill` round `pre-mortem`): a `@slow` agent
proposes likely causes of failure from R1..Rn (a failure path with no
criterion, an abuse case, a permission gap, a partial failure in an
integration). Each answer becomes a new requirement, an Out of Scope line, or
an accepted risk (addyosmani `idea-refine` `frameworks.md` "Pre-mortem"; BMAD
`methods.csv` "Pre-mortem Analysis"). Fold every answer into the document.
Struck scope goes to `docs/factory/out-of-scope/<concept>.md`.

## 4. Gate

`read skill://factory-gate` and run it with: gate `requirements`, doc
`docs/factory/REQUIREMENTS.md`, builder check **ON**, extra files: any
`out-of-scope/` notes. It stamps and commits on approval.

## 5. Stop

After approval: `$F stop S1 "Run /skill:factory to start the stack stage"`.
End the turn with the line the tool prints (*Stop S1. Start a new omp session
in this repo and run `/skill:factory`.*).

## Change (requirement change after issues exist, §4.8)

Used for "Change of plan: ...". Stop any building first.

1. `$F reopen requirements`; edit `REQUIREMENTS.md` (new numbers for added
   requirements; a removed one stays as `R7 (removed)`).
2. Find every citation of each added, changed, or removed number:
   `gh issue list --state all --search "R7 in:body" --json number,title,state`
   and the same with `gh pr list --state all --search ...`. Also grep
   `docs/factory/` for the number.
3. Put a **what changed** header at the top for the gate: each added /
   changed / removed `R`, then every issue and PR citing it with what will
   happen (not started: body rewritten; in progress: requeued; PR open: "Act
   on" item on the same branch; merged: follow-up issue; removed `R`: closed
   "not planned"). Approving the document approves that list.
4. Grill only what the change touches (add the pre-mortem round when it adds
   requirements), then run the gate as in step 4 (builder check on).
5. Say whether STACK.md or ARCHITECTURE.md is touched; reopen them only if so
   (`$F reopen stack|architecture`). Updating the issues is the router's next
   action: `$F stop S1 "Apply the approved requirement change to issues: <R numbers>"`.

Sources: addyosmani `interview-me`, `spec-driven-development`, `idea-refine`;
mattpocock `to-spec`, `grilling`; superpowers `brainstorming`; github
spec-kit; BMAD (all §13 of the design).
