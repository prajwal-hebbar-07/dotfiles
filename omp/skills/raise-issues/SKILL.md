---
name: raise-issues
description: Turn docs/requirements.md, docs/stack.md and the architecture documents into GitHub issues — vertical slices in build order with native blocked-by links, each covering requirement lines word for word — drafted in docs/issues.md for review and raised only after explicit approval. Skips what the code already does, what an existing issue covers and what waits on an open question. Use when the user wants the settled documents turned into issues.
disable-model-invocation: true
---

# raise-issues

Turn the settled documents into the issues that build them. Draft every
issue in `docs/issues.md`, stop for the user to review, and raise them on
GitHub only after explicit approval. Each issue is then worked with
`/skill:issue-branch <URL>` and `/skill:implement <URL>` or `/skill:work
<URL>` (`/skill:build-ui` for a designed screen).

Invoke explicitly:

- `/skill:raise-issues [scope]` — draft issues for the whole document set, or
  only the requirements, components or screens the scope names.
- `/skill:raise-issues [change]` — revise the draft.
- `/skill:raise-issues approve` — raise the current draft.

## Never

- Do only what the request needs. Raise no issue the documents do not call
  for: no refactor, cleanup, tooling, test or docs issue unless a requirement,
  a stack choice the code lacks, or an architecture-review correction needs
  it. A useful extra is named under `Not raised`, not drafted.
- Never ask what is already settled: read the documents, the code and the
  repository's existing issues first. Every question in this skill is
  answered by evidence; there is nothing to ask the user except approval.
- Invent behaviour or acceptance criteria. Acceptance restates the source
  lines; a gap in a requirement is a gap in the issue, named under `Not
  raised` with `/skill:grill-requirements`.
- Raise an issue for a requirement that depends on an open question, a
  deferred decision or a stack `Decisions for you` item.
- Raise anything before the user explicitly approves the current draft.
  The invocation, silence or an acknowledgement is not approval.
- Raise a duplicate of an open or closed issue, or raise one draft entry
  twice.
- Edit, close, label, assign or comment on any existing issue; create
  labels, milestones, issue types or projects.
- Change any file except `docs/issues.md`, or commit.

## States

`docs/issues.md` carries one status:

1. `Draft` — waiting for review; revisions only.
2. `Approved` — the user approved; raising may be in progress.
3. `Raised` — every entry has its issue number.

A change request sets the status back to `Draft`. A new `/skill:raise-issues
[scope]` run after `Raised` replaces the file with a new draft.

## Step 1 — readiness

Print one line per check, `ready` or `not ready: <what> — run <command>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `docs/requirements.md` exists | `/skill:draft-docs requirements`, then `/skill:grill-requirements` |
| 2 | `docs/stack.md` exists | `/skill:draft-docs stack`, then `/skill:grill-stack` |
| 3 | `docs/architecture.md` or `docs/architecture-review.md` exists | `/skill:draft-docs architecture` |
| 4 | `gh auth status` succeeds, `gh --version` is 2.94.0 or later, and `gh repo view --json nameWithOwner,hasIssuesEnabled` shows issues enabled | `gh auth login`, `brew upgrade gh`, or enable issues on the repository |

Any `not ready` stops the run. Print `Open questions` in the requirements,
`Decisions for you` in the stack and `Unresolved` items in the review as
`warning:` lines; what depends on them goes under `Not raised`.

## Step 2 — gather

1. Read `docs/requirements.md`, `docs/stack.md`, `docs/architecture.md`,
   `docs/architecture-review.md`, `docs/design.md` and
   `docs/codebase-map.md` when present.
2. Read existing issues:
   `gh issue list --state all --limit 500 --json number,title,state,body`.
3. For each requirement line, find whether the code already does it: use the
   map to go to the files and trace the behaviour. Record the evidence path.
   Shipped code is not re-raised.

## Step 3 — slice

Draft the fewest issues that build everything left, each one a pull
request's worth of work a developer can plan with `implement` alone:

1. **Skeleton first.** When the code has no runnable app yet, issue `I0` is
   the walking skeleton: the stack's runtime, framework, datastore and
   deployment target wired end to end with one trivial path, per
   `docs/stack.md` and the architecture's deployment. Every other issue is
   blocked by it. On an existing app, add only the stack choices the code
   lacks, inside the first slice that needs them.
2. **Vertical slices.** One issue per user-observable capability, cut through
   every layer the architecture names for it (data, logic, interface), so it
   can be demonstrated and tested alone. Never one issue per layer.
3. **Prefactor before the slice.** When several slices need the same change
   to shared code, that change is its own issue blocking them.
4. **Review corrections.** Each `Risk` or `Conflict` in
   `docs/architecture-review.md` with a smallest sufficient correction the
   user has not accepted is one issue, unless a slice already makes that
   change.
5. **Edges.** `Blocked by` only where the work cannot start without the
   other issue merged; independent slices stay unblocked so they can run in
   parallel worktrees.

Every requirement line in scope ends up in exactly one place: an issue's
`Covers`, or `Not raised` with its reason.

## Step 4 — write the draft

Write `docs/issues.md`, replacing any earlier content:

```markdown
# Issues

Status: Draft
Updated: YYYY-MM-DD
Repository: <owner/repo>

## Issues

### I1. <imperative title, 72 characters or fewer>

- Blocked by: <I-ids> | none
- Covers: <source and the exact lines this builds>
- What: <the capability, two or three sentences>
- Acceptance:
  - [ ] <a source line restated as an observable check>
- Notes: <constraints, stack choices, architecture components or design screens (`S<n>`) the work must follow, with their file paths>
- Issue: <#number once raised>

## Not raised

- <requirement or item> — <already in the code: path | open issue #n | waits on: open question | needs grilling: gap>
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
is), then the issues with no open blocker as the ones to start, each with
`/skill:issue-branch <URL>` then `/skill:implement <URL>` (or
`/skill:work <URL>`), or `/skill:build-ui <URL>` when its notes name a
design screen.
