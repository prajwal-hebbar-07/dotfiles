# Factory work record

Use this format for the operational record of each real factory request. Follow a repository's established work-item convention where one exists; otherwise use `.factory/<unique-work-id>/work.md`. Keep large diffs, command logs, and images in referenced artifacts rather than repeatedly pasting them into the record.

This is a readable record maintained by the assistant, not a signed approval ledger or runtime policy engine. Only actual user decisions authorize progress. Do not claim that file contents alone prove who approved a change.

## Required sections

### Identity and current state

Record the work ID, title, target repository, original request, current stage, current batch, current requirement/design/plan revisions, base branch and base SHA, work branch, pre-existing dirty paths at intake, current review head SHA and tag, and next permitted action. Record the date of actual events rather than manufacturing timestamps.

Use these stage names consistently:

- `requirements_review`
- `architecture_review`
- `batch_plan_review`
- `implementing`
- `testing`
- `code_review`
- `integration_review`
- `accepted`
- `blocked`
- `cancelled`

The stage is a status, not authority. `accepted` requires the specified outcome, human integration acceptance, and all required evidence or explicit scoped waivers. Code approval does not imply merge/deployment permission.

### Requirements and acceptance

Preserve the original request and later clarifications. Assign stable requirement IDs and acceptance-criterion IDs. Capture observable behavior, examples, exclusions, compatibility constraints, and user-provided architecture or domain facts. Distinguish user reports, source observations, and inference. Do not silently rewrite an approved requirement in place: increment its revision and record the change.

### Architecture and decisions

Record the human-authored design or the approved proposal, the revision, affected interfaces and data, constraints, rejected alternatives where material, and reasons for the decision. Link existing architecture records instead of creating a competing source of truth.

### Batches and tasks

For every batch record:

- Batch ID and approved scope; requirement/acceptance IDs.
- Plan revision, file/interface ownership, dependencies, and non-goals.
- Worker names, briefs, expected role/model, and actual resolved model when observed.
- Execution-attempt state and output/artifact references.
- Test-case IDs, verification scope, open findings, human feedback, and next step.

One completed worker turn is not evidence that a batch is accepted. Start with at most one batch awaiting user code review. Block all work that depends on an unapproved gate, including native todos that would otherwise auto-advance.

### Permission grants

Track permissions as separate entries with category, explicit user authorization reference, work/batch scope, approved actions/commands, target/environment, side effects, and status. Allowed statuses are `not_requested`, `requested`, `granted`, `denied`, `revoked`, and `expired`.

Categories:

- `implementation`: production/test/config/doc edits within the approved batch.
- `test_execution`: named unit/integration/check commands and their boundaries.
- `application_execution`: launching or exercising apps, servers, previews, browsers against an app, containers, watchers, or app APIs; include ownership and shutdown.
- `setup_execution`: installs, downloads, environment preparation, and their effects.
- `checkpoint_commit`: standing grant for every factory work item, limited to the work branch, factory-owned paths, new commits, and `factory/<work-id>/` tags as defined in `version-control.md`. Record hook decisions here.
- `merge_push`: exact merge, cherry-pick, push, or other actions touching branches other than the work branch.
- `release`: exact deployment/migration/release target and rollback procedure.

Except for the standing `checkpoint_commit` grant, categories describe the requested authority; they are not automatic grants. An explicit request such as "run the unit suite" can grant its named test scope, but not an application launch or deployment. If a suite launches an application, obtain that permission before starting it. A grant does not carry to a different work item, environment, or materially different command. A resumed session may use a still-valid grant for the same work item only after reconciling scope and actual side effects.

### Test matrix and evidence

Follow `testing.md`. For each planned case link requirement/invariant, scenario, public expected behavior, test location/name, and status. Use `planned`, `written`, `passed`, `failed`, `not_run`, or `blocked`. A written or collected test is not a passing test.

For actual executions capture command, target/environment, authorization reference, relevant source revision, outcome/exit status when available, meaningful output/log reference, and limitations. Keep user-reported failures clearly attributed rather than inventing local reproduction evidence. Coverage percentages require an authorized measured report.

### Append-only decision history

Append each human approval, request for changes, rejection, scope revision, permission decision, or waiver with its actual conversation/PR reference where available. Record:

- Gate and batch/work scope.
- Requirement/design/plan/code revision being decided.
- Actual human decision and conditions.
- What the decision permits and does not permit.
- Earlier decisions superseded by this event.

Do not fill in an approver name or approval message that was not observed. Timeout/cancellation is not approval. Preserve rejected decisions and feedback instead of deleting them.

### Checkpoint log

Append one row per commit or tag: short SHA or tag name, subject, stage, batch, and requirement IDs. Record-only commits need not log themselves. Never rewrite earlier rows; a reverted commit gets a new row for the revert.

### Review packet identity

A code review must identify the actual reviewed contents, not just a moving branch name. Identify each review revision by base SHA, review head SHA, and its `factory/<work-id>/b<N>-review-r<rev>` tag; the diff is `base..head`. Commit all factory changes before presenting the packet. If version control is unavailable, record a content fingerprint of the reviewed file set when supported; otherwise state the exact snapshot/artifact and the identity limitation. Never label a mutable or incomplete diff as immutable proof.

Any subsequent code/test change requires a new code-review revision. Requirement/design changes also invalidate dependent approvals. A new worker must not apply a previously approved patch to changed files without reconciling the new base.

### Blockers, interruptions, and handoff

Record the blocker, pending human question, blocked dependent tasks, worker/process state, and precise next permitted action. When an action was interrupted, record its outcome as unknown until inspected. Do not automatically rerun it. Do not claim a session checkpoint restores files or a compaction summary authorizes work.

## Resume procedure

1. Read the record, linked approved artifacts, and new human feedback.
2. Locate the target repository and inspect affected files without starting applications or checks.
3. Reconcile current branch, HEAD, and working tree with the last recorded checkpoint and reviewed revision; preserve intervening human changes and commits.
4. Reconcile goals/todos and workers with the record. Do not wake a mutating worker while a gate is blocked.
5. Recheck the scope and validity of each execution grant; inspect unknown side effects before any retry.
6. Reopen stale approvals, show material drift, and ask only unresolved decisions.
7. Continue from the next permitted action, not from an optimistic worker summary.

## Status response

Report work ID, stage/current batch, latest actual human decision, implementation/test status, missing evidence, blockers, and next permitted action. Status is read-only. Do not dispatch workers, run commands, or mark acceptance merely because the user requested status.
