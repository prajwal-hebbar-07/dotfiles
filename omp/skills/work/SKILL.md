---
name: work
description: The implement workflow without the codebase map. Turn a GitHub issue, a requested change or a supplied plan into a plan in docs/implementation-plan.md that follows the architecture already in place, wait for explicit approval, implement the smallest complete change, and update only the documents that already exist. Use when the repository should not carry an AI navigation map.
disable-model-invocation: true
---

# work

`implement`, without `docs/codebase-map.md`. Read `skill://implement` and
run it in full — issue or request intake, the architecture in place, plan
in `docs/implementation-plan.md`, explicit approval, smallest complete
change, updates to existing documents, verification — with the changes
below. Where this file and `implement` disagree, this file wins.

Invoke explicitly as `/skill:work [issue URL | request | plan]`.

## Changes to implement

- Never create, read or edit `docs/codebase-map.md` or `docs/codebase-map/`,
  and never add the codebase-map pointer to `AGENTS.md`, `CLAUDE.md` or any
  other context file. Skip every part of `implement` that touches the map:
  the `Reuse first` check in its YAGNI rules (search the repository
  instead), item 2 of Step 1, the map update in Step 4, and Step 5.
  Navigate from the architecture documents and the code.
- Documentation is only `implement`'s rule for existing documents: update
  every document already in the repository that the change makes
  inaccurate, and create none.
- Reply as `implement` Step 6 does, without map updates.
