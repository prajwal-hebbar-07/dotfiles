---
name: grill-architecture
description: "Verify an implemented architecture in bounded rounds with Sonnet/Opus, or an authorised GPT 6.1-terra griller and GPT 6.1-sol reviewer fallback pair. Write the evidence-backed conclusion in docs/architecture-review.md. Low-impact unknowns become assumptions; only high-impact questions only the user can answer go to docs/architecture-questions.md, then grill again until nothing is left for the user."
disable-model-invocation: true
---

# grill-architecture

Verify the architecture that exists, not an idealized redesign, in rounds. In each round Sonnet identifies the material questions, Opus answers from repository evidence, they debate once, low-impact unknowns become recorded assumptions, and only high-impact questions (the impact gate in Step 5) go into `docs/architecture-questions.md`. After the user answers, Opus applies the answers, the parent updates `docs/architecture-review.md`, and the next round grills the updated review. Rounds repeat until one ends with nothing left for the user. The parent only gathers evidence, orchestrates the two specialists, and writes their accepted report.

Invoke explicitly as `/skill:grill-architecture [scope or question]`.

## Never

- Add a feature, option, layer, abstraction, dependency, future-proofing, cleanup, or requirement the user did not request. Name a useful extra as optional; do not include it as required work.
- Ask what the request, earlier answers, `docs/architecture-questions.md`, requirements, stack report, architecture documents, ADRs, repository, or authoritative sources already settle.
- Reward complexity. Prefer the smallest architecture that satisfies the actual requirements, and flag modules or infrastructure with no evidenced need.
- Apply a generic architecture checklist. Review only concerns material to this system and invocation scope.
- Treat a diagram, architecture document, or stated intention as proof that the implementation follows it.
- Claim runtime, scale, failure, recovery, or performance behavior that static evidence cannot prove; classify it as `NEEDS PROOF`.
- Let the parent model answer the grill, adjudicate the debate, replace either specialist outside the authorised pairs below, or silently continue when a pinned specialist is unavailable.
- Ask the user to referee model disagreement. Preserve unresolved disagreement in the report. Ask the user only what passes the Step 5 impact gate; record anything else as an assumption.
- Produce a score, exhaustive redesign, implementation plan, or speculative future architecture.
- Implement, refactor, commit, or edit anything except `docs/architecture-review.md` and `docs/architecture-questions.md`.

## Specialists

Use only these OMP task agents, in one of these pairs:

Primary pair:

- `architecture-sonnet-griller` — `anthropic/claude-sonnet-5-5`, high thinking. It asks the first questions and challenges the reviewer's answers.
- `architecture-opus-reviewer` — `anthropic/claude-opus-5-5`, medium thinking. It answers from evidence and produces the final conclusion.

Authorised fallback pair:

- `architecture-terra-griller` — `openai-codex/gpt-6.1-terra`, high thinking. It performs the griller's questions and bounded critique.
- `architecture-sol-reviewer` — `openai-codex/gpt-6.1-sol`, high thinking. It performs the evidence-based answers, rebuttal and final review.

Start with the primary pair unless the user requests the fallback pair. If either primary specialist fails (including a rate limit or quota error), is unavailable, or reports a model other than its pin, name the failure and switch both roles to the fallback pair. Restart the unfinished round from `docs/architecture-review.md`, the current repository evidence and any answered `docs/architecture-questions.md`; preserve settled user answers, but do not treat an unchecked candidate as accepted. Do not mix pairs or accept further results from the superseded pair. If either fallback specialist fails, reports another model, or is unavailable, stop and name it. No other fallback is authorised.

Spawn each specialist with its named `agent`; do not pass a per-call `model`. Each agent file pins its model; require the specialist to report its actual model identity before substantive work. Throughout the steps below, “Sonnet” means the active griller (Sonnet or Terra), and “Opus” means the active reviewer (Opus or Sol). Keep the selected pair for the rest of the run.

Keep both agents alive across rounds and send follow-ups through `write agent://<id>`. If either is no longer running, for example because the user answered in a new session, spawn a fresh one from the selected pair: `docs/architecture-review.md` and `docs/architecture-questions.md` carry the state.

## Step 1 — establish evidence

Read the invocation and settled chat context. Then read, when present and relevant:

- `docs/requirements.md`, `docs/stack.md`, `docs/architecture.md`, `docs/architecture-questions.md`, other architecture documents, and ADRs; every answered question in the questions file is a settled user answer, and `defer` is an explicit deferral;
- manifests, lockfiles, deployment files, and configuration;
- the source and tests needed to trace the implemented architecture's main flows.

Scope the review to the whole implemented architecture unless the invocation names a subsystem or decision. Distinguish:

- **Requirement** — behavior or constraint the architecture must satisfy.
- **Claim** — intended structure or behavior stated in documentation.
- **Implementation** — what repository evidence shows exists.
- **Unknown** — behavior that needs execution, measurement, or missing production evidence.

Do not infer a requirement from a common practice or model preference.

## Step 2 — Sonnet starts the grill

Spawn the griller from the selected pair (`architecture-sonnet-griller` or `architecture-terra-griller`) first with the scope, requirements, architecture claims, relevant repository paths, and the paths `docs/architecture-review.md` and `docs/architecture-questions.md` when they exist. Ask for the whole current frontier, capped at eight questions.

Each question must identify the evidence that prompted it and why its answer could change the conclusion. Questions may examine only material concerns: requirement fit, unnecessary complexity, responsibilities and dependency direction, interfaces and data ownership, critical flows and failure behavior, trust boundaries, deployment constraints, or proof of claimed qualities.

The questions are for Opus, not the user.

## Step 3 — Opus answers

Spawn the reviewer from the selected pair (`architecture-opus-reviewer` or `architecture-sol-reviewer`) with Sonnet's complete questions and the same evidence boundaries. Opus inspects the repository and classifies every question:

- `VERIFIED — <claim supported> — Evidence: <paths>`
- `RISK — <architecture works but has a material consequence> — Evidence: <paths>`
- `CONFLICT — <requirement, claim, or dependency contradiction> — Evidence: <paths>`
- `NEEDS PROOF — <specific unknown and the smallest check that settles it> — Evidence: <what static evidence does show>`

Opus then returns a complete candidate `docs/architecture-review.md`. Corrections must be the smallest change that resolves an evidenced problem; no speculative redesign.

## Step 4 — bounded debate

Send Opus's complete response to the existing Sonnet agent once. Sonnet returns at most five material challenges, limited to:

- an unsupported or overstated conclusion, including a user answer applied with a meaning other than the user's wording;
- a user question that fails the Step 5 impact gate, or an assumption that passes it;
- a missed requirement, contradiction, dependency, or critical flow;
- documentation that disagrees with implementation;
- complexity with no evidenced requirement;
- a static inference that needs runtime proof;
- a proposed correction larger than the evidenced problem.

Send Sonnet's complete critique to the existing Opus agent once. Opus must concede and correct, or maintain a finding with direct evidence. Its response lists any user questions that pass the Step 5 impact gate, each with its impact and recommendation, and ends with the complete corrected report.

Stop there. Do not add a third reviewer or another debate exchange in this round. If the two specialists still disagree, Opus records the exact disagreement and both evidence-based positions under `Unresolved`, without inventing a tie-breaker.

## Step 5 — write the round's user questions to a file

A user question is allowed only for:

- a fact the conclusion needs that the repository and sources cannot show, such as production load, the deployment target, or an external system's behavior;
- the intent behind structure flagged as having no evidenced requirement;
- whether the user accepts a material risk.

### Impact gate

Even then, ask only when the answer could change the verdict, or the assessment or correction of a finding about one of:

1. stored data: integrity, loss, or a migration;
2. security, trust boundaries, privacy, or compliance;
3. money: hosting, licences, or metered services;
4. availability of a critical flow;
5. a correction that is large — a rewrite, a migration, or a change across several modules.

Everything else becomes an assumption: Opus takes the most conservative reading the evidence supports, records it under `Assumptions` with a one-line reason, and notes any finding that depends on it. Unjustified structure that is cheap to remove stays a `Risk` with removal as the smallest correction, without asking why it exists; a minor risk stays a `Risk` with its recommendation, without asking whether the user accepts it.

Never ask the user to settle a Sonnet–Opus disagreement or a `NEEDS PROOF` item that needs measurement; both stay under `Unresolved`. If no question passes the gate, go to Step 7.

Otherwise write the questions to `docs/architecture-questions.md` instead of asking in chat. Before writing, test each against the impact gate once more and move any that fail it to the assumptions. Clear the file first and write only this round's questions, numbered from Q1: earlier answers already live in `docs/architecture-review.md`, which Step 6 updated before this round began. Use this shape:

```markdown
# Architecture questions

Write your answer on the `Answer:` line under each question, then say they are answered. `yes` accepts the recommendation; `defer` leaves it under `Unresolved`. To correct an assumption, write the change under it.

## Round <N>

### Q1. <the question in plain language>

- Why you: <the gate item it touches and how the answer could change the conclusion>
- Finding: <the finding it affects>
- Evidence: <what the repository shows and why it cannot settle this>
- Recommendation: <Opus's recommendation and its main trade-off>
- Choices: <concise options, worded so `yes` accepts the recommendation when possible>

Answer:

## Assumptions made this round (no answer needed)

- <assumption> — <one-line reason>
```

Omit the assumptions section when there are none.

Reply with the file path, the round number, and the number of questions, then wait.

## Step 6 — apply the answers and grill again

When the user says the questions are answered, read the file. An empty `Answer:` is unanswered: name those questions in chat and wait, unless the user says to defer them. Then:

1. Send the exact answers, and any correction written under an assumption, to the existing Opus agent. It applies them to its corrected report and returns the complete updated report: a stated fact or intent becomes evidence cited as the user's answer, a corrected assumption is replaced by the user's answer, an accepted risk is recorded as accepted, and a deferral stays under `Unresolved`. An answer with two materially different meanings is not applied; it stays a user question for the next round.
2. The parent writes the updated report to `docs/architecture-review.md`, so the file always holds every settled answer.
3. Start the next round at Step 2 with the updated review and the answered questions file as the baseline. Sonnet drafts the fresh frontier: questions the answers unlocked, consequences of the answers for the findings and verdict, gaps the updated review exposes, and anything left unresolved in item 1. Steps 3 and 4 run in full, and Step 5 replaces the file with the next round's questions.

Every settled answer, and every deferral under `Unresolved`, lives in `docs/architecture-review.md`; that is what lets the next round clear the questions file.

## Step 7 — close the grill

The grill closes when a round's Step 4 leaves no question allowed by Step 5. The parent writes Opus's corrected report from that round to `docs/architecture-review.md` without changing its findings. Use this shape unless an existing review has a clear structure:

```markdown
# Architecture review

Reviewed: YYYY-MM-DD
Scope: <reviewed system or subsystem>

## Conclusion

- Verdict: Verified | Verified with risks | Revise | Not verifiable
- <brief evidence-backed conclusion>

## Architecture observed

- <implemented responsibilities, dependencies, and critical flows needed to understand the verdict>

## Findings

### <finding>

- Assessment: Verified | Risk | Conflict | Needs proof
- Evidence: <paths and concrete observations>
- Consequence: <material effect>
- Smallest sufficient correction: <only for a risk or conflict>

## Assumptions

- <low-impact unknown, the conservative reading taken, and the findings that depend on it>

## Unresolved

- <needed proof, remaining Sonnet–Opus disagreement, or a user question deferred in docs/architecture-questions.md>
```

Omit empty sections and inapplicable fields. Use `Verified` only when no material risk, conflict, or missing proof remains; `Verified with risks` for accepted material risks; `Revise` for a conflict requiring change; and `Not verifiable` when missing evidence prevents a responsible conclusion.

Reply with the file path, the number of rounds, verdict, finding counts by assessment, the number of assumptions, and the most consequential risk, conflict, or proof gap. Do not repeat the report in chat.
