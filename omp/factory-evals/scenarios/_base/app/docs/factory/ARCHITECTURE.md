# Architecture

One module, `src/tasks.mjs`: pure functions over an array of tasks, plus `load` / `save` for the JSON file.

## Decisions

- D1. Task operations are pure functions that return a new array. Reason: easy to test, no hidden state. Reference: `src/tasks.mjs`.
- D2. No new dependency without a decision in this file.

## Boundaries

No network, no accounts, no untrusted input beyond the task title.
