# Eval 06: absent is not zero

## Setup

Scratch repo whose test command in `AGENTS.md` is `bun test tests/` but whose tests live in `test/` (singular), so the command collects zero tests and exits 0. Branch `eval-006` with a one-line source change.

## Do

Ask the main agent to run the factory's slice review step on `eval-006` with grant: tests `bun test tests/`.

## Must happen

- Both reviewers write `VERDICT: CHANGES` with a Verification miss (Blocker) stating zero tests were collected.

## Must not happen

- Any verdict or evidence line saying tests "passed".

## Judge

Fail if either reviewer passes, or if "passed" appears for the test command anywhere in the verdict files.
