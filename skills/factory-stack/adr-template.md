---
status: "proposed | accepted | deprecated | superseded by ADR-NNNN"
date: YYYY-MM-DD
---

# <Short title: the problem solved and the solution found>

Format: MADR 4 (adr.github.io/madr). File: `docs/factory/adr/NNNN-<slug>.md`,
numbered by scanning the folder for the highest number and adding one
(mattpocock `domain-modeling` ADR-FORMAT). Write an ADR only when all three
hold: hard to reverse, surprising without context, and a real trade-off. An
ADR can be a few lines; drop optional sections that add nothing. Keep
Confirmation always.

## Context and Problem Statement

<Two or three sentences: the context, the question, and the R numbers or
constraints that force it.>

## Decision Drivers

* <driver: a quality, concern, or constraint>

## Considered Options

* <option 1>
* <option 2>

## Decision Outcome

Chosen option: "<option>", because <justification tied to a driver>.

### Consequences

* Good, because <...>
* Bad, because <...>

### Confirmation

<The check that enforces this decision later, so it is checked and not only
recorded. Name the command or rule, and where it runs: for example a
dependency-cruiser rule `no-orm-in-domain` in `check:full`, a Semgrep rule,
a lockfile check in `check:task`, a test, or a review item for
`factory-spec-review`. If no automated check is possible, say what the
reviewer must look at.>

## Pros and Cons of the Options

### <option 1>

* Good, because <...>
* Bad, because <...>

### <option 2>

* Good, because <...>
* Bad, because <...>
