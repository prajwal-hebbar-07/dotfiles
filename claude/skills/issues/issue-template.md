# Issue file

One file per issue, `docs/issues/<key>.md`. Line 1 is the title; the rest is
the body published to GitHub. The body is read by an implementer who has not
seen the chat, the other issues, or any document, and who must not need to
ask anything. So everything the issue depends on is **copied in, word for
word**, with its ID and its source; a bare "see architecture.md" or "per M2"
is never enough. Omit a section that has nothing in it, except Acceptance
criteria, Tests, Out of scope and Definition of done.

Cite stack decisions as `stack S3` and screens as `screen S3`: both documents
use `S`.

````markdown
# <Verb phrase in glossary terms, 70 characters or fewer>

## Summary

<Two to four sentences from the person's side: what they can do after this
issue that they could not before, and why it comes now.>

## When this is done you can

<The demo, in steps: "Open X, do Y, see Z." The check that this slice is
complete end to end.>

## Requirements

<Each live `R`, `N`, `C` this issue serves, pasted from requirements.md with
its ID, its `Said:` line, and its `Accept:` lines. Then the `X` (out of scope)
items that sit next to it.>

## What to build

<The behaviour, in order of the person's journey. Name the flows below. Say
what this issue builds and what it leaves for another issue (by key).>

### Flows

<Each `F` this issue builds, pasted in full: serves, trigger, steps, failure at
each step, what the caller sees, transaction boundary, retry and duplicate
behaviour, permissions, what is recorded, cost at the numbers.>

## Architecture to follow

<Pasted in full, each under its ID. Only what this issue touches.>

- **Shape and deployment units** relevant here.
- **Modules** (`M`): responsibility, interface, depends on, owns, serves, seam.
- **Entities** (`E`): meaning, fields, relations, lifecycle, invariants,
  retention, size, owner.
- **Concerns** (`K`) that bind this code: permissions, errors, configuration,
  observability, consistency, background work, migrations.
- **Abuse cases** (`B`): asset, actor, boundary, mitigation, verification.
- **Decisions** (ADRs): the text of each that this issue must respect.

## Stack to use

<Each `stack S` decision this issue relies on, pasted: choice and version,
the facts that matter (limits, support, licence) with their source and date,
and the exit note if the choice binds this code. Say how to run and test it
here, from the bootstrap issue.>

## Design

<Only for an issue with UI. Pasted in full:>

- **Idea and feel rules** that apply to this screen.
- **Journeys** (`J`) this issue builds, with their failure steps.
- **Screens** (`screen S`): purpose, primary action, seen first, reached from,
  goes to, shows, controls, and **every state** (default, empty, loading,
  error, denied) with its words.
- **Patterns** (`P`) used, and the **visual direction** tokens and rules.
- **Paper**: file, page, and the board names to match (for example `03 Today`
  and `03 Today · empty`). The boards are the reference for layout; this text
  is the reference for behaviour and words. Where they differ, say which wins:
  the text.

## Glossary

<Each domain term used above, with its one-line meaning and `_Avoid_` words.>

## Acceptance criteria

- [ ] **R3 · AC1.** Given <state>, when <action>, then <result>.
      False if: <the observation that would prove it wrong>.
- [ ] **F2 · failure at step 3.** Given …, when …, then <what the caller sees>.
      False if: ….

## Tests required

<Level by level, naming the seam from the architecture where tests cross.>

- Unit: <which behaviour>
- Integration: <which seam, what is faked, what is real>
- End to end: <which journey, for an issue with UI>
- Abuse case `B2`: <the verification the architecture names>
- Non-functional `N2`: <the check and the number it must meet>
- How to run them: <the commands from the bootstrap issue>

## Out of scope

- <Adjacent behaviour this issue must not add, each with the key of the issue
  that owns it, or the `X` item that forbids it.>

## Assumptions

<Each open question (`AQ`, `DQ`, `SQ`, `Q`) or accepted unknown (`A`, `AA`,
`DA`, `SA`) that touches this issue: the question, the value to assume, and
the ID. Build to the assumed value. If it turns out wrong, the fix is a new
issue, not a question here.>

## Blocked by

- #<number> `<key>`: <what it provides that this needs>

## Starting points

<Only when the repository already has code: the existing modules, files and
tests this change extends or must not break, as of commit <sha>. For a new
codebase write nothing here: layout is the implementer's unless the
architecture fixes it.>

## Definition of done

- Every acceptance criterion is checked and its test passes.
- The required tests exist and pass on the stack's own test tooling, and add
  no failures elsewhere.
- Nothing from **Out of scope** was built.
- Docs that describe behaviour this issue changed are updated in the same PR.
- The PR says `Closes #<number>` and lists any assumption it relied on.

## Sources

Copied from these versions; if a document has changed since, the document
wins and this issue is stale.

- requirements.md @ <hash> · stack.md @ <hash> · architecture.md @ <hash> · design.md @ <hash>
- Items: <every ID this issue cites, with its heading>
````
