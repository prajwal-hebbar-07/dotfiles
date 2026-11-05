---
name: debate-architecture
description: >
  Takes the architecture from an approved stack to ready-to-approve in Oh My
  Pi: proposes it, grills it, has it reviewed and fixes the review, with
  models answering first, between three models only. Claude Opus 5.5 at
  medium effort proposes, drafts each round, folds answers in and responds to
  the review; Claude Opus 5.5 at high effort designs the structurally
  different alternative shape, challenges every item and answers or sorts
  every question before the user sees it; GPT-6.1 Sol runs the cold
  fresh-eyes check and reviews the grilled architecture until it is
  approve-ready. Questions only the user can answer go to
  docs/grill/architecture-questions.md, best-practice answers go there
  pre-filled for a skim, and what the models proved from the documents, the
  repo or a source is folded in and listed. Replaces Claude Code's
  /architecture, /grill-architecture and /review-architecture, and writes the
  same files. Use when the user says "/skill:debate-architecture".
argument-hint: "[change text | status | approve]"
disable-model-invocation: true
---

# debate-architecture

`/skill:debate-requirements`, for the architecture, with its own three
models. The loop, the classes, the debate round, the review and the
questions file are those of `debate-rules.md` (that skill, linked). The
stage rules are Claude Code's
`/architecture`, `/grill-architecture` and `/review-architecture`:
`architecture-rules.md`, `grill-rules.md` and `review-rules.md`, with their
templates (`architecture-template.md`, `vocabulary.md`,
`architecture-log-template.md`, `architecture-coverage-template.md`,
`probes.md`). Follow them in full, except where this file or `debate-rules.md`
says otherwise; where the two disagree, this file wins. Every model uses the
words in `vocabulary.md` exactly (module, interface, depth, seam, adapter).

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Models

Three models, and only these three. `debate-rules.md`'s four roles map onto
them; no other agent or model runs any part of this skill.

| Role here | `task` agent | Model (its frontmatter) | Takes `debate-rules.md`'s |
| --- | --- | --- | --- |
| Architect | `arch-architect` | `anthropic/claude-opus-5-5`, medium | drafter: proposes, drafts each round, replies to objections, folds answers in, responds to the review |
| Answerer | `arch-answerer` | `anthropic/claude-opus-5-5`, high | challenger: designs the alternative shape, challenges every item and question, answers or sorts it with evidence, adds what was missed |
| Reviewer | `arch-reviewer` | `openai-codex/gpt-6.1-sol`, medium | reviewer, and the fresh-eyes check |

There is no tiebreaker. `debate-rules.md`'s **Round** items 4 (Tiebreak) and
5 (Answer) are skipped: a block still disputed after the architect's one
reply is `user`, with both positions and their evidence under **Known**. The
fresh-eyes check is the reviewer's, started cold with only the four paths
below. The chat reply's `(<l> by Luna)` is left out. The same rules on
starting each agent hold: if one is missing or cannot start, or its result
names a different model, stop and say which.

## Names

Read `debate-rules.md` with these substitutions:

| In `debate-rules.md` | Here |
| --- | --- |
| `requirements.md` (the document) | `docs/architecture.md` |
| `capture-rules.md` | `architecture-rules.md` |
| **Capture** | **Propose** (below) |
| questions `G<N>.<k>` | `D<N>.<k>`, grill-architecture's own |
| debate blocks `D<N>.<k>` | `P<N>.<k>`, so they never clash with the questions |
| `requirements-log.md`, `-questions.md`, `-coverage.md`, `-debate.md` | `docs/grill/architecture-log.md`, `architecture-questions.md`, `architecture-coverage.md`, `architecture-debate.md` |
| `log-template.md`, `coverage-template.md` | `architecture-log-template.md`, `architecture-coverage-template.md` |
| `docs/review/requirements-review.md` | `docs/review/architecture-review.md` |
| the ID check's IDs | items `grep -oE '^### [MEFKB][0-9]+'`, and `grep -oE '\*\*A[QA][0-9]+\*\*'` |
| grill Step 5 items 1–4 | grill Step 5 items 1–7 (simplicity sweep and pre-mortem included) |
| the tracker row | the Architecture row |
| `/skill:debate-requirements` | `/skill:debate-architecture` |

The fresh-eyes check gets the paths of `requirements.md`, `stack.md`,
`architecture.md` and `glossary.md`, and counts only while all three hashes
match (grill Step 5 item 8).

## Never

Everything in `debate-rules.md`'s **Never**, and in the `Never` lists of the
three stage rule files, holds, with these changes:

- Never settle, and never pre-fill: the lock of the **Shape**, of who owns
  which data, of the consistency model or of the permission model (and any
  item that would get an ADR); anything that costs money each month;
  changing a `Fixed by` item; a requirement gap or a stack gap.
- A model never sets `State: settled`. Only the answer to a lock question
  does, as grill Step 2 says; a pre-filled lock left blank is the user's
  `yes`.
- Never edit `requirements.md` or `stack.md`. A gap is logged as grill Step 2
  says and goes to the user as a **Needs you** question that names the
  change to make with `/skill:debate-requirements <change>` or
  `/skill:debate-stack <change>`.
- Never state a fact about the chosen technology (a limit, an isolation
  level, a delivery guarantee) without its source and the date checked. In
  **Round** item 6, a `settle` on a fact passes only when you `read` the
  source and it says so today.
- Never leave a `Depends on` cycle or an entity with two owners standing as
  settled: it is a question in the next round.

## Step 1 — state

Run Step 1 of `architecture-rules.md`, then read the files Step 1 of
`grill-rules.md` reads. Then:

| State / argument | Do |
| --- | --- |
| No `requirements.md` or `stack.md`, or either `Status:` is not `grilled` or `approved` | Stop: run `/skill:debate-requirements` or `/skill:debate-stack` first |
| `status` | As `debate-rules.md` says, with the architecture status lines of `architecture-rules.md` and `grill-rules.md`. Change nothing |
| `approve` | Only when `Status: grilled` and the last review is `approve-ready` on the current hashes; otherwise say what is missing. Then `architecture-rules.md`'s approve, with **Next action** `Architecture approved; run /skill:debate-design` |
| No `architecture.md` | **Propose**, then **Next** |
| A hash recorded in `architecture.md` differs from the current one | **Earlier stage moved**, then **Next** |
| The user's message holds a change | Architect: `architecture-rules.md` Step 3. Run the ID check. Then **Next** |
| `proposed` | Start the grill as grill Step 1 does with no log, then **Next** |
| `grilling` | **Ingest**, then **Next** |
| `grilled` | Reply with the counts and `Review docs/architecture.md, then /skill:debate-architecture approve` |

**Next** is `debate-rules.md`'s list, in the same run.

## Propose

The first architecture is a debate too.

1. **Two shapes, in parallel.**
   - Architect: `architecture-rules.md` Step 2 items 1 and 3–11 on candidate
     A, the simplest shape that meets every `R`, `N` and `C` on the chosen
     stack.
   - Answerer, started with only the paths of `requirements.md`,
     `stack.md`, `glossary.md` and `vocabulary.md`: candidate B, structurally
     different (a different number of deployable units or a different place
     for the data), not a renaming, as Step 2 item 2's sub-agent would. It
     writes B to `architecture-debate.md` under `## Proposal · <date>`.
2. **Pick** (architect). Compare A and B as Step 2 item 2 says, pick one,
   write the other as `Alternative shape` with why it loses and what would
   force it, then write `docs/architecture.md` (Step 2 item 12, `Status:
   proposed`, both hashes).
3. **Counter** (answerer). For the shape and each `M`, `E`, `F`, `K`, `B`
   item, append `### <ID> <name>` and `Answerer: agree` or `Answerer:
   object — <reason and evidence>` under the proposal. Object for a
   pass-through module (deletion test), an interface that leaves out what a
   caller must know, an entity with two owners or none, a flow that skips a
   failure, a `Depends on` cycle, a part no number asks for, a fact that is
   wrong or unsourced, or a shape choice B beats on a stated number.
4. **Reply** (architect). Under each objection: `Architect: concede` (apply
   it to `architecture.md`, diagrams and traceability included) or
   `Architect: rebut — <evidence>`. A rebutted objection becomes an `AQ` with
   both positions and their evidence; nobody argues twice.
5. **Check** (runner). `read` every fact's source; a fact the source does
   not say today goes back to the architect to fix or remove. Check the
   `Depends on` graph has no cycle and every entity one owner. Run the ID
   check.

Set the Architecture row to `proposed` as Step 2 item 12 says, then start the
grill (no pause: a change the user wants comes in their answers or as
`/skill:debate-architecture <change>`).

## Earlier stage moved

Architect: `architecture-rules.md` Step 1's check of each item against the
changed requirements or stack. Each item it lists becomes a `user` question
in the next round ("F2 rests on S3, now changed to …: keep, change, or
drop?"), debated like any other. Once they are all answered, the architect
records the new hashes in `architecture.md`.

## Round, Review, Questions file, End

As `debate-rules.md` says, with these stage rules:

- The round's frontier is grill-architecture Step 4 items 1–10, and its
  closing rounds the simplicity sweep, pre-mortem and fresh-eyes check, in
  that order. The confirm round is grill-architecture's own wording, after
  the review is `approve-ready`.
- A `default` here is the simplest design that still serves every
  requirement, as grill-architecture's **Recommended** is, worded so a blank
  accepts it.
- **Fold** also rebuilds the diagrams and the traceability table, checks for
  cycles, adds settled terms to `glossary.md`, and writes the ADRs grill
  Step 2 calls for.
- **Respond** is `architecture-rules.md`'s **Respond to a review**.
- **End** sets `Status: grilled` as grill-architecture Step 5 says, with
  **Next action** `Review docs/architecture.md, then run
  /skill:debate-architecture approve`, and names the ADRs written.

The chat reply ends with `Slides of the architecture: /architecture-slides in
Claude Code.` in place of the requirements slides line.
