---
name: factory-architecture
description: >
  Factory stage 5: designs two structurally different architectures, has two
  models attack the chosen one, writes docs/factory/ARCHITECTURE.md (modules,
  interfaces, data model, test seams, error handling, threat model),
  GLOSSARY.md, CONSTRAINTS.md (quality bar and check scripts), ADRs and
  diagrams, gets a UI design brief from factory-design-director when there is
  a UI, then runs the approval gate. Use when /skill:factory routes to the
  architecture stage, or when invoked as /skill:factory-architecture.
disable-model-invocation: true
---

# factory-architecture

Stage 5 of the software factory. Design: `SOFTWARE-FACTORY.md` §4.5, §4.2,
§4.3, §5.8. Run from the target repo root. State tool:
`F=~/.omp/agent/skills/factory/scripts/factory-state`. Sidecars beside this
file: `template.md` (ARCHITECTURE.md), `constraints-template.md`,
`glossary-template.md`; ADRs use `skill://factory-stack/adr-template.md`.

## Never

- Add a module, layer, service, or abstraction with no `R` number or
  constraint behind it.
- Let a reviewer agent edit files; reviewers are read-only and return findings.
- Show the user the document with an unfixed "Act on" finding.
- Skip the threat model, or leave an abuse case without a mitigation, a
  verification, and an ASVS 5.0.0 id.
- Run the builder check here. The two-model review replaces it.
- Edit any of the four stamped docs after the gate without `$F reopen architecture`.
- Draw Paper screens. `factory-design-director` writes the brief only.

## Entry

1. `$F verify requirements stack`. Any `REOPEN` line or missing stamp: stop and
   say which gate comes first.
2. `$F set stage '"architecture"'`.
3. `read` REQUIREMENTS.md and STACK.md in full, plus `docs/factory/adr/` and
   `docs/factory/out-of-scope/`. Existing repo: one `scout` for the current
   module structure, seams, and test layout.

## 1. Two candidates

Use pstack `architect`: design it twice, whole shapes, not point fixes.

- **Candidate A (you, `@default`):** the simplest design that meets every `R`.
  Walk the ponytail ladder for each piece: not needed, already in the
  codebase, standard library or platform, an installed dependency, then the
  minimum new code.
- **Candidate B:** one `task` (`model: "@slow"`) given REQUIREMENTS.md,
  STACK.md, and the grounding notes, told to propose a structurally
  different design (different module boundaries or data ownership, not
  different names). Prefer, between viable designs, the one hiding more
  behind a smaller interface.

Pick one and write down what the other lost on. Show neither candidate to the
user yet.

## 2. Draft the documents

From the chosen candidate, write under `docs/factory/`:

- `ARCHITECTURE.md` from `template.md`: Overview, Modules, Interfaces, Data
  model, Seams for tests, Error handling, Configuration, UI direction, Threat
  model, Decisions, Out of scope. Every piece cites its `R` numbers. Seams
  follow mattpocock `to-spec`: existing seams over new, highest seam, as few
  as possible.
- `GLOSSARY.md` (started in the requirements grill) from
  `glossary-template.md` (mattpocock `domain-modeling`). Draft entries for the
  terms the design adds and for fuzzy or overloaded terms left in
  REQUIREMENTS.md; one word per concept, the rest under `_Avoid_`. No
  implementation details. Drafts are proposals: each new or changed term is a
  question in the §5 grill (`factory-grill` Language).
- ADRs for hard-to-reverse structural choices (module style, event versus
  call, data ownership) per `skill://factory-stack/adr-template.md`, each
  with a **Confirmation** line naming its enforcing check.
- `CONSTRAINTS.md` from `constraints-template.md`: the floor, numbered
  dimensions each naming its command, ratchets, `check:fast` / `check:task` /
  `check:full`, the published-standards table, and test levels (§5.8). Fill
  the commands from STACK.md's compatibility table. Defaults are
  addyosmani `constraint-driven-development` (CDD).
- **Threat model** inside ARCHITECTURE.md: assets; actors with authority
  needed and denied; data flows marking where trust changes; assumptions to
  test; abuse cases each with mitigation, verification, and the
  `v5.0.0-<id>` ASVS requirement (magnus919 `secure-software-engineering`
  lightweight threat model). Start from the pre-mortem answers in
  REQUIREMENTS.md. Propose ASVS Level 1, or Level 2 with user accounts,
  personal data, or payments; the user decides at the gate.
- **Diagrams:** `read skill://arc-design` and run it for one overview plus
  one diagram per module; reference the files in the document.

## 3. UI direction (only when REQUIREMENTS.md has a UI)

1. Run the `paper-target` skill to pin the Paper file and page (ask the user
   which file if none is pinned).
2. Spawn `factory-design-director` (`task`, `agent: factory-design-director`)
   with: REQUIREMENTS.md path, the glossary, the Paper file name, any
   reference product the user named, and the output path
   `paper-design-prompt.md` at the repo root. It runs `paper-design-prompt`
   and returns the path in its final json block. Answer its `questions` from
   the approved docs or relay them through `ask`.
3. Summarise the brief in ARCHITECTURE.md "UI direction". The brief file is
   committed with this gate; drawing happens per issue.

## 4. Adversarial review (pstack `interrogate`)

Before the user sees anything. Spawn two read-only reviewers in one `task`
batch, `agent: reviewer`, one with `model: "@review"` and one with
`model: "@default"`. Give each the intent (one paragraph), the document set,
and these angles: unmet or contradicted `R`, a missing failure path, a module
boundary that lets agents break the structure, an unmentioned seam, a threat
model gap, unrequested complexity, and CONSTRAINTS that cannot be run.
Findings in the contract's json block. Merge duplicates, noting which model
raised each (two models independently is the strongest signal), then sort:

- **Act on:** blocks a real PR (wrong, missing, or unsafe). Fix it now.
- **Consider:** legitimate, you are unsure it outweighs its cost. Keep as a
  known trade-off; the gate header lists it.
- **Noted:** valid, not actionable now. **Dismissed:** wrong or missing
  context, with a one-line reason.

You are the lead reviewer, not an aggregator. Re-run a reviewer only if you
changed a module boundary while fixing.

## 5. Grill

`read skill://factory-grill`. Run the frontier, then the **simplicity round**
(`factory-grill` round `simplicity`): every module, layer, abstraction,
config option, and piece of infrastructure the draft adds is asked "does it
need to exist, does something already there do it", with the simpler option
recommended. Keeping the larger option needs an `R` number or a constraint.
Dropped pieces go to `docs/factory/out-of-scope/<concept>.md`.

Fold CDD's four questions into the same round, each with a default so "I
don't know" still works (addyosmani CDD): (1) which dimensions beyond the
floor are enforced; (2) on a mid-task failure, block or warn (default: block
the floor, warn the rest for two weeks); (3) target numbers, or measure and
hold today's value (default: measure and hold, ratchets); (4) the slowest
check tolerated at task end (default 90 seconds). Also settle the ASVS
level. Measure today's coverage and bundle size once for the ratchets.

## 6. Gate

`read skill://factory-gate`; run it with gate `architecture`, doc
`docs/factory/ARCHITECTURE.md`, builder check **OFF**, extra files to stage
and commit with it: `CONSTRAINTS.md`, `GLOSSARY.md`, `adr/*.md`,
`out-of-scope/*.md`, `paper-design-prompt.md` (when a UI exists), and the
diagram files. Only ARCHITECTURE.md is stamped and walked section by
section; the header lists the others and the "Consider" trade-offs.

## 7. Stop

After approval: `$F stop S3 "Run /skill:factory to create the issues"`. End
the turn with the line the tool prints.

Sources: pstack `architect`, `interrogate`; mattpocock `domain-modeling`,
`to-spec`; addyosmani `constraint-driven-development`; magnus919
`secure-software-engineering`; DietrichGebert ponytail; OWASP ASVS 5.0.0
(§13 of the design).
