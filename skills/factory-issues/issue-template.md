# Issue body template

One body per issue. Written for an agent that has never seen the chat: it
describes behaviour, not files or line numbers (mattpocock `triage/AGENT-BRIEF.md`:
durability, behavioural not procedural, complete acceptance criteria, explicit
scope boundaries). The hidden `<!-- factory:issue=<key> -->` marker is added by
`board create`; do not write it.

```markdown
## Parent

#<epic issue number>

## Requirements covered

R3, R7

## What to build

<The end-to-end behaviour this issue makes work, from the user's side. Name
types and contracts from ARCHITECTURE.md where they matter. No file paths, no
line numbers.>

## Acceptance criteria

- [ ] **R3 · AC1.** Given <state>, when <action>, then <result>.
      False if: <the observation that would prove it wrong>.
- [ ] **R7 · AC1.** Given …, when …, then ….
      False if: ….

## Out of scope

- <adjacent behaviour this issue must not add>

## Blocked by

- #<number> (issue #0, always)
- #<number> <only blockers that genuinely gate this one>

## UI

yes | no

## Sec

`sec:boundary`: <which ARCHITECTURE.md threat-model data flow / trust boundary
this touches, and the abuse case it must keep closed>. Omit this section when
no boundary is touched.

## Approved docs (sha <approved sha of each>)

- REQUIREMENTS.md @ <sha>: docs/factory/REQUIREMENTS.md
- STACK.md @ <sha>
- ARCHITECTURE.md @ <sha>
- CONSTRAINTS.md @ <sha>
```

Rules:

- Acceptance criteria are copied from the cited requirements' Given / When /
  Then, one checkbox each, independently checkable.
- Every criterion carries the "False if" observation. A criterion with no
  falsifier is rewritten or sent back to requirements.
- `Blocked by` mirrors the native edges set with `board blocked-by`; the text
  is for readers.
- Labels at creation: `ui` when UI is yes, `sec:boundary` when the Sec section
  exists.
- Issue #0 uses the same shape; its acceptance criteria are the rows of
  `skill://factory-bootstrap/references/checklist.md`.
