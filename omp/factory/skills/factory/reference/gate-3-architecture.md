# Gate 3: architecture, decision register, issue plan (human approves)

You decide; you do not interview. Decisions are written for the approved stack.

## Decide, per layer

| Layer | Decide |
| --- | --- |
| Data | Schema ownership, ID strategy, money and time types, migration approach |
| Module | Layering (e.g. handler → service → repository), transaction ownership, fakeable seams |
| Function design | Pure core with side effects at the edges or not; functions vs classes; how dependencies are passed; async model; signatures and invariants of key functions |
| Error model | Exceptions vs Result types; where validation happens; error codes |
| Testing | Test layers; real database vs fakes; what must be proven end to end |
| Security and ops | Authn/authz model, secrets handling, logging and tracing |
| Not decided here | Formatting, naming case, import order: these go into linter/formatter config |

For each decision that is expensive to reverse (new ownership boundary, public interface, data model, cross-cutting pattern): if an existing ADR or repo precedent answers it, follow it. Otherwise sketch two genuinely different designs and compare: owner and interface, constraints met, depth, blast radius, migration and reversal cost, how it is verified, and what disappears if the module is deleted. Pick the smallest design that meets the constraints.

## Write `architecture.md`

```markdown
# Architecture — <work-id>

## Decision register
| ID | Decision | Why | Reference code | Enforced by |
| D1 | <decision> | <one line> | <repo path, or named external exemplar> | <ast-grep rule / lint rule / architecture test / review checklist / not enforceable> |
Rejected alternatives (expensive decisions only): D3 — <alternative> — <why not>

## Interface contracts
<signatures, request/response shapes, invariants>

## Test plan
<per requirement: layer, what proves it>

## Issue plan
| Issue | Module or feature | Requirements | Slices (each < ~400 changed lines, working end to end) | Depends on |
| 1 | Auth | R1, R2 | 1 sign-up · 2 sign-in · 3 sign-out | — |

## Revision log
```

Issue plan rules: an issue is a complete module or feature, never a commit. One issue for a single feature; one per build phase for a whole application. Slices are vertical (each commit works on its own). Order issues by dependency. The first issue also carries Slice 0 (`build.md`). Every requirement maps to exactly one issue.

Each "Enforced by" check records the decision ID it enforces, so a changed decision flags its checks.

## Architecture review

Spawn `factory-review-arch` and `factory-review-gpt` in one message (parallel), each with:

```
Step: architecture. Round: <N>.
Read: .factory/<work-id>/requirements.md, stack.md, architecture.md; prior round files under .factory/<work-id>/arch-review/r<N-1>/ if N > 1 (your own only).
Checklist: skill://factory/reference/review.md, section "architecture".
Write exactly one file: .factory/<work-id>/arch-review/r<N>/<your agent name>.md
```

GPT rate-limited (the spawn fails with a rate-limit or quota error): spawn `factory-review-standin` with the same prompt instead, record it in `state.json.standins_used`, and flag it in the packet.

Pass needs every reviewer's `VERDICT: PASS`. Otherwise revise `architecture.md`, append a revision-log entry, and run the next round. Max 3 rounds; after that, present the packet with the open findings marked as disagreements. Never average or drop a reviewer's finding.

## Present

`architecture.md` holds the decision register (decision — why — reference — enforcement), rejected alternatives in one line each, contracts, test plan, the issue plan, and any reviewer disagreement. Stop for the human (`rules.md`, "Human interaction"), pointing at it. Approving the packet also approves creating the issues on GitHub.

## Exit

`approve` → `stage: "gate4"` (UI work) or `"issues"` (no UI). Any other reply → change, re-review, append a revision-log entry, show the delta, stop again. A decision the approved stack cannot meet → reopen that choice in Gate 2.
