---
name: debate-stack
description: >
  Takes the tech stack from approved requirements to ready-to-approve in Oh My
  Pi: proposes it, grills it, has it reviewed and fixes the review, with
  models answering first. Claude Haiku 5.5 proposes, drafts each round, folds
  answers in and responds to the review; Claude Sonnet 5.5 argues the
  alternatives and challenges every question and fact; GPT-6 Luna takes what
  is still open or disputed; Claude Opus 5.5 reviews the grilled stack until
  it is approve-ready. Questions only the user can answer go to
  docs/grill/stack-questions.md, best-practice answers go there pre-filled
  for a skim, and facts the models proved from a source are folded in and
  listed. Replaces Claude Code's /stack, /grill-stack and /review-stack, and
  writes the same files. Use when the user says "/skill:debate-stack".
argument-hint: "[change text | status | approve]"
disable-model-invocation: true
---

# debate-stack

`/skill:debate-requirements`, for the stack. The loop, the models, the
classes, the debate round, the review and the questions file are those of
`debate-rules.md` (that skill, linked). The stage rules are Claude Code's
`/stack`, `/grill-stack` and `/review-stack`: `stack-rules.md`,
`grill-rules.md` and `review-rules.md`, with their templates (`areas.md`,
`stack-template.md`, `stack-log-template.md`, `stack-coverage-template.md`,
`probes.md`). Follow them in full, except where this file or `debate-rules.md`
says otherwise; where the two disagree, this file wins.

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Names

Read `debate-rules.md` with these substitutions:

| In `debate-rules.md` | Here |
| --- | --- |
| `requirements.md` (the document) | `docs/stack.md` |
| `capture-rules.md` | `stack-rules.md` |
| **Capture** | **Propose** (below) |
| questions `G<N>.<k>` | `T<N>.<k>` |
| `requirements-log.md`, `-questions.md`, `-coverage.md`, `-debate.md` | `docs/grill/stack-log.md`, `stack-questions.md`, `stack-coverage.md`, `stack-debate.md` |
| `log-template.md`, `coverage-template.md` | `stack-log-template.md`, `stack-coverage-template.md` |
| `docs/review/requirements-review.md` | `docs/review/stack-review.md` |
| the ID check's IDs | decisions `grep -oE '^### S[0-9]+'`, and `grep -oE '\*\*S[QA][0-9]+\*\*'` |
| grill Step 5 items 1–4 | grill Step 5 items 1–6 (simplicity sweep and pre-mortem included) |
| the tracker row | the Tech stack row |
| `/skill:debate-requirements` | `/skill:debate-stack` |

The fresh-eyes check gets the paths of `requirements.md`, `stack.md` and
`glossary.md`, and counts only while both hashes match (grill Step 5 item 7).

## Never

Everything in `debate-rules.md`'s **Never**, and in the `Never` lists of the
three stage rule files, holds, with these changes:

- Never settle, and never pre-fill: the lock of a hard-to-reverse decision
  (language, framework, data store, hosting, auth, or any that would get an
  ADR); budget, price, or anything that costs money each month; which
  accounts, skills or hosting the user already has; changing a `Fixed by`
  choice; a requirement gap.
- A model never sets `State: settled`. Only the answer to a lock question
  does, as grill Step 2 says; a pre-filled lock left blank is the user's
  `yes`.
- Never edit `requirements.md`. A requirement gap is logged as grill Step 2
  says and goes to the user as a **Needs you** question that names the
  change to make with `/skill:debate-requirements <change>`.
- Never state a version, price, limit, licence or support date without its
  source and the date checked. In **Round** item 6, a `settle` on a fact
  passes only when you `read` the source and it says so today.

## Step 1 — state

Run Step 1 of `stack-rules.md`, then read the files Step 1 of
`grill-rules.md` reads. Then:

| State / argument | Do |
| --- | --- |
| No `requirements.md`, or its `Status:` is not `grilled` or `approved` | Stop: run `/skill:debate-requirements` first |
| `status` | As `debate-rules.md` says, with the stack status lines of `stack-rules.md` and `grill-rules.md`. Change nothing |
| `approve` | Only when `Status: grilled` and the last review is `approve-ready` on the current hashes; otherwise say what is missing. Then `stack-rules.md`'s approve, with **Next action** `Run /skill:debate-architecture` |
| No `stack.md` | **Propose**, then **Next** |
| The requirements hash in `stack.md` differs from the current one | **Requirements moved**, then **Next** |
| The user's message holds a change | Drafter: `stack-rules.md` Step 3. Run the ID check. Then **Next** |
| `proposed` | Start the grill as grill Step 1 does with no log, then **Next** |
| `grilling` | **Ingest**, then **Next** |
| `grilled` | Reply with the counts and `Review docs/stack.md, then /skill:debate-stack approve` |

**Next** is `debate-rules.md`'s list, in the same run.

## Propose

The first stack is a debate too.

1. **Propose** (drafter). `stack-rules.md` Step 2 items 1–3, 5 and 6, and
   item 4 without its own sub-agent: write `docs/stack.md` with `Status:
   proposed`, every fact with its source and date checked.
2. **Counter** (challenger). For each decision, append to `stack-debate.md`
   under `## Proposal · <date>`: `### S<n> <area>`, then `Challenger: agree`
   or `Challenger: object — <reason and evidence>`. Object when no `R`, `N`
   or `C` forces it, the platform or a piece already chosen does the job, a
   fact is wrong or unsourced, or the alternative is a strawman. For each
   hard-to-reverse decision, argue for the alternative from the requirements
   and the facts alone, as `stack-rules.md` Step 2 item 4's sub-agent would.
3. **Reply** (drafter). Under each objection: `Drafter: concede` (apply it
   to `stack.md` as `stack-rules.md` Step 2 would have written it) or
   `Drafter: rebut — <evidence>`. Write the strongest counter into the
   decision's `Alternative`.
4. **Tiebreak** (tiebreaker). Under each rebutted objection: `Ruling: keep |
   switch | user — <evidence>`. The drafter applies a `switch`; a `user`
   ruling becomes an `SQ` with both choices and their evidence.
5. **Check** (runner). `read` every fact's source; a fact the source does
   not say today is reported to the drafter to fix or remove. Run the ID
   check.

Set the Tech stack row to `proposed` as `stack-rules.md` Step 2 says, then
start the grill (no pause: a change the user wants comes in their answers or
as `/skill:debate-stack <change>`).

## Requirements moved

Drafter: `stack-rules.md` Step 1's check of each decision against the
changed requirements. Each decision it lists becomes a `user` question in the
next round ("S3 rests on R2, now changed to …: keep, change, or drop?"),
debated like any other. Once they are all answered, the drafter records the
new requirements hash in `stack.md`.

## Round, Review, Questions file, End

As `debate-rules.md` says, with these stage rules:

- The round's frontier is grill-stack Step 4 items 1–9, and its closing
  rounds the simplicity sweep, pre-mortem and fresh-eyes check, in that
  order. The confirm round is grill-stack's own wording, after the review is
  `approve-ready`.
- A `default` here is the simplest option that meets the requirements, as
  grill-stack's **Recommended** is, worded so a blank accepts it.
- **Fold** also writes the ADRs grill Step 2 calls for.
- **Respond** is `stack-rules.md`'s **Respond to a review**.
- **End** sets `Status: grilled` as grill-stack Step 5 says, with **Next
  action** `Review docs/stack.md, then run /skill:debate-stack approve`, and
  names the ADRs written.

The chat reply ends with `Slides of the stack: /stack-slides in Claude Code.`
in place of the requirements slides line.
