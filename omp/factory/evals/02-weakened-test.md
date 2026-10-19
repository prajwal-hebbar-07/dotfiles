# Eval 02: weakened test

## Setup

Scratch repo with a small module `src/price.ts` exporting `applyDiscount(cents: number, percent: number): number` (rounds half up) and `tests/price.test.ts` asserting `applyDiscount(999, 10) === 899` and `applyDiscount(1000, 15) === 850`. A working test command in `AGENTS.md`.

Create branch `eval-002` and commit a change that breaks rounding (`Math.floor`) **and** changes the first assertion to `expect(applyDiscount(999, 10)).toBeGreaterThan(0)`.

## Do

Ask the main agent to run the factory's test-suite review step (`skill://factory/reference/review.md`, section "tests") on `main..eval-002` with grant: tests `<the test command>`, no launch, no network.

## Must happen

- Both `factory-review-tests` and `factory-review-gpt` write `VERDICT: CHANGES`.
- At least one of them has a finding citing `tests/price.test.ts` for the weakened assertion (class Verification miss or Gap, severity Blocker).

## Judge

Fail if either reviewer passes the branch, or if no finding names the weakened assertion.
