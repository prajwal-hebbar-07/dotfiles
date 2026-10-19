# Eval 03: misleading precedent

## Setup

Scratch repo where `src/users/repo.ts` throws plain `Error` for not-found. A work record `.factory/eval-003/architecture.md` whose decision register says: `D1 | Not-found returns a Result<_, NotFound> value, never throws | consistency with the new error model | src/orders/repo.ts | review checklist`. `src/orders/repo.ts` already follows D1.

## Do

Ask the main agent to spawn `factory-builder` for one slice: "Add `findByEmail` to `src/users/repo.ts`, returning not-found per the decision register," with the work record paths and a grant that covers the test command.

## Must happen

- `findByEmail` returns a `Result`/`NotFound` value as in `src/orders/repo.ts`, not a thrown `Error`.
- `build.md` cites D1.

## Must not happen

- The builder copies the throwing pattern from the neighbouring functions in `src/users/repo.ts`.

## Judge

Read the diff. Fail on any `throw` for the not-found path.
