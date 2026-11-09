---
name: raise-issues
description: Turn the settled documents into GitHub issues — the requirements and stack in the blueprint's chunk order, an approved design, a feature spec, or a UI review's gaps — as vertical slices with native blocked-by links, each covering its source lines word for word, drafted for review and raised only after explicit approval. Skips what the code already does, what an existing issue covers and what waits on a deferred decision. Use when the user wants the settled documents turned into issues.
disable-model-invocation: true
---

# raise-issues

Turn the settled documents into the issues that build them. Draft every
issue, stop for the user to review, and raise them on GitHub only after
explicit approval. Then stop: nothing is implemented here. Each issue is
later worked with `/skill:issue-branch <URL>`, the user's architecture for
it, and `/skill:implement <URL>` or `/skill:work <URL>`.

Invoke explicitly:

- `/skill:raise-issues [scope]` — draft issues for the whole document set,
  or only the requirements, chunks or screens the scope names.
- `/skill:raise-issues docs/ui-review.md [items]` — draft issues for the
  gaps a UI review found.
- `/skill:raise-issues [change]` — revise the draft.
- `/skill:raise-issues approve` — raise the current draft.

`feature` runs this skill with its spec as the source and
`docs/features/<slug>/issues.md` as the draft; everywhere below, the draft
is that file in place of `docs/issues.md`.

## Never

- Do only what the request needs. Raise no issue the source does not call
  for: no refactor, cleanup, tooling, test or docs issue unless a
  requirement, a stack choice the code lacks, a blueprint setup step or a
  UI review finding needs it. A useful extra is named under `Not raised`,
  not drafted.
- Never ask what is already settled: read the documents, the code and the
  repository's existing issues first. Every question in this skill is
  answered by evidence; there is nothing to ask the user except approval.
- Invent behaviour or acceptance criteria. Acceptance restates the source
  lines; a gap in a requirement is a gap in the issue, named under `Not
  raised` with `/skill:grill-requirements`.
- Decide the architecture of an issue. The user gives it when the issue is
  implemented; notes name only what the documents already settle.
- Raise an issue for a requirement that depends on a deferred decision or a
  stack `Decisions for you` item.
- Raise anything before the user explicitly approves the current draft.
  The invocation, silence or an acknowledgement is not approval.
- Raise a duplicate of an open or closed issue, or raise one draft entry
  twice.
- Edit, close, label, assign or comment on any existing issue; create
  labels, milestones, issue types or projects.
- Change any file except the draft, or commit.

## States

The draft carries one status:

1. `Draft` — waiting for review; revisions only.
2. `Approved` — the user approved; raising may be in progress.
3. `Raised` — every entry has its issue number.

A change request sets the status back to `Draft`. A new run with a scope or
source after `Raised` replaces the file with a new draft.

## Step 1 — readiness

Print one line per check, `ready` or `not ready: <what> — run <command>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `docs/requirements.md` exists, or the feature spec is `Settled` | `/skill:grill-requirements`, or `/skill:feature` |
| 2 | `docs/stack.md` exists | `/skill:grill-stack` |
| 3 | For a new app's documents: `docs/blueprint.html` exists | `/skill:blueprint` |
| 4 | When the requirements or spec in scope have a user interface: `docs/design.md` is `Approved` for those screens | `/skill:design` |
| 5 | For a UI review source: `docs/ui-review.md` exists | `/skill:review-ui` |
| 6 | `gh auth status` succeeds, `gh --version` is 2.94.0 or later, and `gh repo view --json nameWithOwner,hasIssuesEnabled` shows issues enabled | `gh auth login`, `brew upgrade gh`, or enable issues on the repository |

Any `not ready` stops the run; when the user says to skip check 4, record
that in the draft's header. Print `Open questions` in the requirements,
`Decisions for you` in the stack and the blueprint's `Gaps` as `warning:`
lines; what depends on them goes under `Not raised`.

## Step 2 — gather

1. Read `docs/requirements.md`, `docs/stack.md`, `docs/blueprint.html`,
   `docs/design.md`, `docs/codebase-map.md`, the feature spec and
   `docs/ui-review.md` when present and in scope.
2. Read existing issues:
   `gh issue list --state all --limit 500 --json number,title,state,body`.
3. For each source line, find whether the code already does it: use the
   map to go to the files and trace the behaviour. Record the evidence
   path. Shipped code is not re-raised.

## Step 3 — slice

Draft the fewest issues that build everything left, each one a pull
request's worth of work a developer can plan with `implement` alone:

1. **Blueprint order.** The blueprint's chunks and their `Issue candidates`
   are the starting cut and the build order; follow them unless the rules
   below or the code say otherwise, and say where the draft departs.
2. **Skeleton first.** When the code has no runnable app yet, issue `I0` is
   the blueprint's `C0`: its setup steps (manual ones listed as a
   checklist for the user) and the walking skeleton. Every other issue is
   blocked by it. On an existing app, add only the stack choices the code
   lacks, inside the first slice that needs them.
3. **Vertical slices.** One issue per user-observable capability, cut
   through data, logic and interface, so it can be demonstrated and tested
   alone. Never one issue per layer. A slice with a screen names its
   `S<n>` and Paper boards from `docs/design.md`.
4. **Prefactor before the slice.** When several slices need the same change
   to shared code, that change is its own issue blocking them.
5. **UI review gaps.** From `docs/ui-review.md`: one issue per screen
   marked `Missing` or `Partial` in its coverage, and one per screen
   grouping that screen's `Broken` and `Off` findings. `Covers` quotes the
   finding numbers; acceptance restates each finding's fix.
6. **Edges.** `Blocked by` only where the work cannot start without the
   other issue merged; independent slices stay unblocked so they can run in
   parallel worktrees.

Every source line in scope (requirement, spec line or review finding) ends
up in exactly one place: an issue's `Covers`, or `Not raised` with its
reason.

## Step 4 — write the draft

Write `docs/issues.md`, replacing any earlier content:

```markdown
# Issues

Status: Draft
Updated: YYYY-MM-DD
Repository: <owner/repo>
Source: <documents | feature spec path | docs/ui-review.md>

## Issues

### I1. <imperative title, 72 characters or fewer>

- Blocked by: <I-ids> | none
- Covers: <source and the exact lines or finding numbers this builds>
- What: <the capability, two or three sentences>
- Acceptance:
  - [ ] <a source line restated as an observable check>
- Notes: <blueprint chunk, stack choices, design screens (`S<n>`, Paper board names) and setup steps the work must follow>
- Issue: <#number once raised>

## Not raised

- <requirement or item> — <already in the code: path | open issue #n | waits on: deferred decision | needs grilling: gap>
```

Order the issues so every blocker comes before what it blocks. Reply with
the path, the issue count, the number of blocked-by edges, the count under
`Not raised` by reason, and ask the user to approve or request changes. Do
not repeat the draft in chat. Stop.

## Step 5 — raise

On explicit approval, re-run Step 2's issue list; if an issue now duplicates
an entry, mark that entry `Not raised` with the number and say so. Set
`Status: Approved`, then for each entry in order, skipping any that already
has an `Issue:` number:

```sh
gh issue create --title '<title>' --body-file - [--blocked-by <numbers>] <<'BODY'
<body>
BODY
```

The body is the entry's `What`, `Acceptance` checklist, `Covers` as a
`Source` section and `Notes`, followed by the marker
`<!-- raise-issues:<Updated date>:<I-id> -->`. Before creating, search the
issue list from this run for that marker; if it is there, record that
number instead of creating a second issue. After each creation, write the
number into the entry's `Issue:` line at once, so an interrupted run resumes
without duplicates. Map each `Blocked by` I-id to its recorded number.

If a create fails, stop: report the error, the issues raised so far and the
command to resume (`/skill:raise-issues approve`). When every entry has a
number, set `Status: Raised`.

Reply with one line per issue (`#number title`, and `blocked by #n` when it
is), then the issues with no open blocker as the ones to start. For each,
the next steps are `/skill:issue-branch <URL>`, then the user's
architecture for it given to `/skill:implement <URL>` (or `/skill:work
<URL>`). Stop; start none of them.
