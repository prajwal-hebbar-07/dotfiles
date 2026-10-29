# #<n> <title>: feature tracker

<One line: what the feature is.>

State lives in this file and the files beside it, not in any chat. To resume,
check out the branch and run `/feature` in a new chat.

Issue: #<n> · Branch: <branch>

## Next action

<One line: the single next thing to do.>

## Stages

| Stage | Status | File | Review | Updated |
| --- | --- | --- | --- | --- |
| Requirements | capturing | [requirements.md](requirements.md) | | |
| Architecture | not started | [architecture.md](architecture.md) | | |
| Design | not started | [design.md](design.md) | | |
| Build | not started | <branch> | | |

Requirements status moves `capturing` → `captured` → `grilling` → `grilled`
→ `approved`. Architecture and design move `not started` → `proposed` →
`grilling` → `grilled` → `approved`; design can instead be `n/a: <reason>`
when the feature has nothing a person sees. A stage is only `approved` when
the user runs its `approve` command. `/review-feature <stage>` never changes a
status; its verdict goes in the Review column and **Next action**. Build
status, written by `/implement`, moves `not started` → `in progress` →
`awaiting review` → `done` (the pull request merged).

Built from (set by `/implement` when it starts, to notice a stage changed
since): requirements <hash> · architecture <hash> · design <hash | n/a>

## Log

- <yyyy-mm-dd>: Created tracker.
