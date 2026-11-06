---
name: grill-architecture
description: "Verify an implemented architecture through a bounded debate: Sonnet 5.5 high asks the material questions, Opus 5.5 medium answers them, Sonnet challenges the answers, and Opus produces the evidence-backed conclusion in docs/architecture-review.md."
disable-model-invocation: true
---

# grill-architecture

Verify the architecture that exists, not an idealized redesign. Sonnet identifies the material questions. Opus answers from repository evidence. They debate once, then Opus produces the conclusion. The parent only gathers evidence, orchestrates the two specialists, and writes their accepted report.

Invoke explicitly as `/skill:grill-architecture [scope or question]`.

## Never

- Add a feature, option, layer, abstraction, dependency, future-proofing, cleanup, or requirement the user did not request. Name a useful extra as optional; do not include it as required work.
- Ask what the request, earlier answers, requirements, stack report, architecture documents, ADRs, repository, or authoritative sources already settle.
- Reward complexity. Prefer the smallest architecture that satisfies the actual requirements, and flag modules or infrastructure with no evidenced need.
- Apply a generic architecture checklist. Review only concerns material to this system and invocation scope.
- Treat a diagram, architecture document, or stated intention as proof that the implementation follows it.
- Claim runtime, scale, failure, recovery, or performance behavior that static evidence cannot prove; classify it as `NEEDS PROOF`.
- Let the parent model answer the grill, adjudicate the debate, replace either specialist, or silently continue when a pinned specialist is unavailable.
- Ask the user to referee model disagreement. Preserve unresolved disagreement in the report.
- Produce a score, exhaustive redesign, implementation plan, or speculative future architecture.
- Implement, refactor, commit, or edit anything except `docs/architecture-review.md`.

## Specialists

Use only these OMP task agents:

- `architecture-sonnet-griller` — `anthropic/claude-sonnet-5-5`, high thinking. It asks the first questions and challenges Opus's answers.
- `architecture-opus-reviewer` — `anthropic/claude-opus-5-5`, medium thinking. It answers from evidence and produces the final conclusion.

Spawn each with its named `agent`; do not pass a per-call `model`. If either agent fails, reports another model, or is unavailable, stop and name it. Keep both agents alive and send follow-ups through `write agent://<id>`.

## Step 1 — establish evidence

Read the invocation and settled chat context. Then read, when present and relevant:

- `docs/requirements.md`, `docs/stack.md`, architecture documents, and ADRs;
- manifests, lockfiles, deployment files, and configuration;
- the source and tests needed to trace the implemented architecture's main flows.

Scope the review to the whole implemented architecture unless the invocation names a subsystem or decision. Distinguish:

- **Requirement** — behavior or constraint the architecture must satisfy.
- **Claim** — intended structure or behavior stated in documentation.
- **Implementation** — what repository evidence shows exists.
- **Unknown** — behavior that needs execution, measurement, or missing production evidence.

Do not infer a requirement from a common practice or model preference.

## Step 2 — Sonnet starts the grill

Spawn `architecture-sonnet-griller` first with the scope, requirements, architecture claims, and relevant repository paths. Ask for the whole current frontier, capped at eight questions.

Each question must identify the evidence that prompted it and why its answer could change the conclusion. Questions may examine only material concerns: requirement fit, unnecessary complexity, responsibilities and dependency direction, interfaces and data ownership, critical flows and failure behavior, trust boundaries, deployment constraints, or proof of claimed qualities.

The questions are for Opus, not the user.

## Step 3 — Opus answers

Spawn `architecture-opus-reviewer` with Sonnet's complete questions and the same evidence boundaries. Opus inspects the repository and classifies every question:

- `VERIFIED — <claim supported> — Evidence: <paths>`
- `RISK — <architecture works but has a material consequence> — Evidence: <paths>`
- `CONFLICT — <requirement, claim, or dependency contradiction> — Evidence: <paths>`
- `NEEDS PROOF — <specific unknown and the smallest check that settles it> — Evidence: <what static evidence does show>`

Opus then returns a complete candidate `docs/architecture-review.md`. Corrections must be the smallest change that resolves an evidenced problem; no speculative redesign.

## Step 4 — bounded debate

Send Opus's complete response to the existing Sonnet agent once. Sonnet returns at most five material challenges, limited to:

- an unsupported or overstated conclusion;
- a missed requirement, contradiction, dependency, or critical flow;
- documentation that disagrees with implementation;
- complexity with no evidenced requirement;
- a static inference that needs runtime proof;
- a proposed correction larger than the evidenced problem.

Send Sonnet's complete critique to the existing Opus agent once. Opus must concede and correct, or maintain a finding with direct evidence. Its response ends with the complete corrected report.

Stop there. Do not add a third reviewer or another autonomous debate round. If the two specialists still disagree, Opus records the exact disagreement and both evidence-based positions under `Unresolved`, without inventing a tie-breaker.

## Step 5 — write the conclusion

The parent writes Opus's corrected report to `docs/architecture-review.md` without changing its findings. Use this shape unless an existing review has a clear structure:

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

## Unresolved

- <needed proof or remaining Sonnet–Opus disagreement>
```

Omit empty sections and inapplicable fields. Use `Verified` only when no material risk, conflict, or missing proof remains; `Verified with risks` for accepted material risks; `Revise` for a conflict requiring change; and `Not verifiable` when missing evidence prevents a responsible conclusion.

Reply with the file path, verdict, finding counts by assessment, and the most consequential risk, conflict, or proof gap. Do not repeat the report in chat.
