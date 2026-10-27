# <project>: project tracker

<One line: what the app is.>

State lives in this file and the files it links, not in any chat. To resume,
run `/requirements` in a new chat.

## Next action

<One line: the single next thing to do.>

## Stages

| Stage | Status | File | Updated |
| --- | --- | --- | --- |
| Requirements | not started | [requirements.md](requirements.md) | |
| Tech stack | not started | [stack.md](stack.md) | |
| Architecture | not started | [architecture.md](architecture.md) | |
| Design | not started | [design.md](design.md) | |

Requirements status moves `not started` → `capturing` → `captured` →
`grilling` → `grilled` → `approved`. Tech stack status moves `not started` →
`proposed` → `grilling` → `grilled` → `approved`. Architecture and design
status move the same way as the tech stack's. A stage is only `approved` when the user
runs its `approve` command. A review (`/review-<stage>`) never changes a status;
its report is in `docs/review/<stage>-review.md` and its verdict only moves
**Next action**.

## Log

- <yyyy-mm-dd>: Created tracker.
