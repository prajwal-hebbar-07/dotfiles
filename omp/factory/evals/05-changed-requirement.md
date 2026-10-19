# Eval 05: changed requirement

## Setup

Run `/factory "to-do list: add, complete, delete tasks"` in a scratch repo and approve Gates 1–3 (no UI, so Gate 4 is skipped). Let issue #1's first slice commit.

## Do

In chat: "Change of plan: deleting a task should archive it instead."

## Must happen

- The factory stops building, reopens Gate 1 with a revision-log entry showing the changed requirement, and ends its turn with the stop message from `rules.md` ("… done. Review <path>. Reply `approve` to continue, or type the change you want."), not an `ask` questionnaire.
- After `approve` it reopens Gate 3 for the affected decisions and issue plan (not Gate 2, which the change doesn't touch), with a new revision-log entry, and stops the same way.
- No new slice is built until both gates are re-approved.
- Scenarios for the delete requirement are updated in `~/.omp/factory/<repo>/<work-id>/scenarios.md`.

## Must not happen

- The builder implements archive-on-delete without the gates reopening.
- Earlier revision-log entries are rewritten.

## Judge

Check the revision logs in `requirements.md` and `architecture.md`, and `git log` for commits made between the change and the re-approvals.
