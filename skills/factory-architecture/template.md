# Architecture: <product name>

<!-- Header, only while the gate is open. Delete after approval.
What changed since the last review: ...
Factory's calls (decided without you, minor): ...
Known trade-offs (reviewer "Consider" items): <each: the finding, which reviewer raised it, the trade-off>
-->

Names follow `GLOSSARY.md`. Every module, interface, and piece below cites
the `R` numbers that need it (`R4, R5`); a piece with no `R` number and no
constraint behind it was cut in the simplicity round. Quality bar and
commands: `CONSTRAINTS.md`. Decisions that are hard to reverse: `adr/`.

## Overview

<One paragraph: the shape of the system in plain words, and why this shape
(the chosen candidate and what the other candidate lost on).>

Diagram: `docs/architecture/diagrams/overview.html` (made with `arc-design`).

## Modules

One block per module. Allowed dependencies are enforced by the boundary
checker in `CONSTRAINTS.md`.

### <module>

- **Responsibility:** <one sentence, in glossary words>
- **Serves:** <R numbers>
- **Depends on:** <modules it may import; nothing else>
- **Never depends on:** <the forbidden direction that matters>
- **Diagram:** `docs/architecture/diagrams/<module>.html`

## Interfaces

For each seam between modules, and each outside contract (HTTP API, CLI,
event, file format): the signature or shape, who calls it, and the error
cases. HTTP APIs return errors as RFC 9457 Problem Details.

### <module>.<interface>

- **Shape:** <types and signatures, no bodies>
- **Callers:** <modules>
- **Errors:** <each error case and what the caller sees>

## Data model

Entities and fields in glossary words, their relationships, what is stored
where, and what is derived. Migrations: <how schema changes ship>. Seed
data: <how a fresh checkout gets it, from an empty directory>.

## Seams for tests

Where tests attach, highest seam first (mattpocock `to-spec`: prefer
existing seams, fewest seams). Each seam names the level it is tested at
(unit, integration, end-to-end; see `CONSTRAINTS.md` Test levels).

| Seam | Modules it crosses | Level | Real or mocked |
| --- | --- | --- | --- |
| | | | Real seeded store; mock only outside services |

## Error handling

- **Validation:** <where input is validated; every trust boundary in the threat model validates>
- **Failure paths:** <what happens on partial failure, retry, timeout, and data-loss risk>
- **Reporting:** <what the user sees; what is logged; no secrets or personal data in logs>

## Configuration

Twelve-Factor config in environment variables. `.env.example` is committed
with every variable, `.env` is ignored. Variables: <name: purpose>.

## UI direction

Include only when the product has a UI; otherwise write "No UI."

- **Design brief:** `paper-design-prompt.md` (written by `factory-design-director`, approved with this document).
- **Paper file:** <pinned by `paper-target`>
- **Direction in one line:** <base product, delta>
- **Accessibility:** WCAG 2.2 AA, unless REQUIREMENTS.md says higher.

## Threat model

Lightweight, adapted from magnus919 `secure-software-engineering`
(`templates/lightweight-threat-model.md`). The pre-mortem in REQUIREMENTS.md
says what must not happen; this says where it is stopped. Each verification
becomes a test the code reviewers expect.

**ASVS level:** <1 | 2>, decided at this gate. Level 2 when there are user
accounts, personal data, or payments. Standard: OWASP ASVS 5.0.0.

### Assets

| Asset | Harm if compromised | Where it lives or flows | Owner |
| --- | --- | --- | --- |

### Actors and authority

| Actor or workload | Trust basis | Authority it needs | Authority it is denied |
| --- | --- | --- | --- |

### Data flows and trust boundaries

Each flow, and where trust changes (client to server, server to store,
server to outside provider, build system). A boundary here is a module
interface that gets the `sec:boundary` label on its issues.

| Flow | From -> to | Trust changes? | What crosses |
| --- | --- | --- | --- |

### Assumptions to test

| Assumption | Why it matters | Evidence or test | Status |
| --- | --- | --- | --- |
| | | | open / verified |

### Abuse cases

One row per abuse case. Every row has a mitigation, a verification a test or
scan can run, and the ASVS requirement it meets as `v5.0.0-<chapter.section.requirement>`.

| ID | Abuse case | Preconditions | Mitigation | Verification | ASVS | Residual risk |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | | | | | v5.0.0- | |

## Decisions

| ADR | Decision | Confirmation |
| --- | --- | --- |
| [0001](adr/0001-<slug>.md) | | <the check that enforces it> |

## Out of scope

Pieces dropped in the simplicity round, with what would bring each back.
Also written to `docs/factory/out-of-scope/<concept>.md`.

- <piece> — <why dropped> — <what would justify it>
