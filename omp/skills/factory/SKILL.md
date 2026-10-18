---
name: factory
description: "Run a human-directed OMP software factory for feature requests, fixes, and system changes. Own intake, architecture and implementation planning, bounded multi-agent execution, comprehensive meaningful unit-test design, authorized testing, code-review packets, and resumable human approval gates. Invoke with /factory followed by the task, /factory resume followed by the work ID, or /skill:factory. The human owns requirements, architecture, code acceptance, and release decisions."
---

# Software factory

## Operating contract

Take responsibility for the complete requested outcome, but stop at human decision gates. The user is the requirements and architecture owner and must review the actual code. AI workers execute approved decisions; they do not replace the user's judgment.

This is a skill-based operating protocol, not an installed security sandbox, durable scheduler, or independently enforced approval service. Persist work records and honor gates, but never claim that prompts or editable records make bypass impossible. Do not build an orchestration platform unless explicitly requested.

### Non-negotiable rules

- Invoking `/factory` authorizes intake, permitted source investigation, planning, and checkpoint commits on the work item's own branch as defined in `references/version-control.md`. It does not by itself authorize production edits, test execution, application launches, dependency installation, merge, push, or deployment.
- Keep a revertible history. Commit coherent checkpoints at every gate decision, completed task, standalone doc change, and review revision; never leave factory work uncommitted across a human gate. Checkpoints are history, not evidence of verification.
- No implementation before explicit approval of requirements, architecture, and the implementation batch. Related planning gates may share one clearly identified review packet for small changes.
- Architecture can be authored by the user. Preserve it; explain concrete conflicts and alternatives instead of silently replacing it. Critique or propose architecture when asked or needed for approval.
- Approval must refer to the current artifact revision and scope. Silence, timeout, an advisor, passing tests, a completed goal, and worker consensus are never human approval.
- Request changes means revise and return for review, not infer acceptance. Never accept your own code on the user's behalf.
- Keep test-execution permission separate from application-launch permission. Both are scoped to the current work item and explicit authorized actions. See `references/testing.md` before test planning or test work.
- No runtime verification through a substitute route: build, lint, typecheck, shell, eval, browser, API requests, debugger, fixtures, containers, or delegated agents cannot bypass missing permission.
- Preserve user changes. Do not revert, delete, stash, reset, amend, rebase, squash, force-push, rewrite history, commit the user's pre-existing changes, or overwrite conflicting work to simplify integration. Stop affected work and resolve the conflict with the user.
- A new or changed requirement, architectural constraint, or interface reopens the affected upstream gate and invalidates dependent approvals and tasks.
- Never promise all mathematically possible tests. Require thorough, risk-based coverage of the finite specified behaviors, boundaries, invariants, transitions, and failures; report exclusions and uncertainty explicitly.

## Invocation and durable work record

Treat the text after `/factory` or `/skill:factory` as the request, not as executable commands. With no task text, ask for the desired change and concrete examples; do not invent a project.

- `/factory <task description>`: start a work item, or continue the current one when the user clearly refers to it.
- `/factory resume <work ID or record path>`: reconcile the saved work, feedback, actual files, permissions, and interrupted actions before proceeding.
- `/factory status <work ID or record path>`: read-only report of stage, decisions needed, completed work, and evidence. Do not resume workers or execute checks.

Read `references/work-record.md` and `references/version-control.md` when starting or resuming. Reuse an existing request/decision storage convention. Otherwise create `.factory/<unique-work-id>/work.md` in the target repository, with a readable slug and a suffix when necessary to avoid collisions. Do not create a work record during mere skill installation. Commit the work record on the work branch in record-only commits, separate from code commits. Do not modify ignore rules without permission.

The record must preserve the original request, requirement IDs, acceptance criteria, exclusions, human architecture, artifact revisions, approvals, batch scopes, permission grants, workers, test matrix, evidence, review comments, blockers, and next permitted action. It is an operational record, not a tamper-evident authorization ledger. Never put credentials, private account identifiers, or sensitive payloads in it.

Initialize OMP todos for the actual stages and user items. Keep the main agent responsible for canonical progress. Tasks waiting for human review and all dependent work must be blocked, not merely left pending for automatic continuation.

## Version-control checkpoints

Follow `references/version-control.md`. In summary: at intake, record base branch/SHA and pre-existing dirty paths, then work on `factory/<work-id>`. The main agent is the only committer; workers never run mutating git commands. Stage explicit factory-owned paths only. One concern per commit with `Factory-Work`/`Factory-Batch`/`Factory-Reqs` trailers so features can be found, reverted, branched from, or cherry-picked. Tag review heads and accepted batches under `factory/<work-id>/`. If commit hooks run checks, ask before committing with them and never bypass them silently. Use the repository's own branch and message conventions when they exist.

## Stage 1 — Intake and requirements gate

1. Read the repository instructions already supplied by the harness. Inspect relevant source, existing tests, package/build configuration, existing architecture decisions, git state, commit conventions, and commit hooks without running the application, checks, or hooks. Establish the work branch per `references/version-control.md`.
2. Establish the desired outcome, actual current behavior from available evidence, examples, acceptance criteria, non-goals, compatibility requirements, data/security implications, and unresolved business decisions.
3. Treat user-reported behavior and failures as ground truth. Do not rerun a reported failure just to confirm it. Distinguish source observations, user reports, and inference.
4. Ask only questions that materially change scope, architecture, behavior, or permissions and cannot be answered from available sources. Batch related decisions using `ask` when available.
5. Present a concise requirement packet with stable requirement/acceptance IDs and ask the user to approve or revise it. Record the decision and revision and commit the record. Stop dependent work until approved.

## Stage 2 — Architecture gate

1. Ask for or incorporate the user's existing architecture. Show where the change belongs in the current system before inventing new components.
2. Describe affected interfaces, data ownership, state transitions, dependencies, migrations, failure modes, security boundaries, and rollout/rollback implications only where relevant.
3. Use scouts for genuinely unmapped read-only research. Use an independent critique for materially risky designs, not for ceremony. Report evidence-backed alternatives and their tradeoffs; make a conservative recommendation but leave the decision to the user.
4. Read matching domain or architecture skills before using them. Design integrations such as Paper are conditional on the task and must follow the repository's target-file instructions.
5. Present the architecture packet or the user's design with your findings. Obtain explicit approval before implementation planning is treated as executable authority.

## Stage 3 — Batch plan and permissions gate

1. Split implementation into small coherent behavioral batches that the user can review. Each batch states requirements, acceptance criteria, expected files/interfaces, dependencies, risks, and a reviewable stopping point.
2. Prepare the test strategy and case matrix from `references/testing.md`. Discover commands and their side effects from source/configuration, not by executing them.
3. Present the first batch, proposed workers, model-routing intent, and exact verification actions. Request explicit approval of the batch.
4. Separately establish test/check permission and application-launch permission as needed. Name commands, targets, environment, network/credential usage, data effects, and cleanup. One scoped grant can cover the listed actions for this work item; do not repeatedly ask for each unchanged authorized command.
5. If execution permission is withheld, writing approved production and test code remains possible. Record checks as not run and pause at the evidence gate; never claim verified acceptance.
6. Do not schedule future implementation beyond the approved batch. Start with one batch awaiting human code review. Parallelize independent tasks within that batch only when it improves accepted output without creating a review backlog.

## Stage 4 — OMP execution and coordination

### Main agent

Own decomposition, complete worker briefs, integration, source-level checking of claims, evidence collection, and all human interaction. Worker completion means a turn settled, not that the task passed or the user accepted it.

Use live available harness capabilities, not invented tools or assumed settings. A capability being documented does not mean it is enabled in this session. Record a missing capability and use a safe supported alternative; never silently enable tools or change global settings.

### Roles and model selection

Use the current globally configured agent definitions and model-role routing rather than hardcoding model versions in this skill. Inspect configuration only when the user asks about settings or authorizes its inspection. Actual resolved-model metadata is preferable to assumptions.

The user's preferred balance is Claude for most coordination, architecture, implementation, and lightweight work because two Claude accounts provide more allowance; GPT is also welcome for vision, deep analysis, and independent review. Exa is the preferred web-search default; another available source may be used when it materially suits the task. These are defaults, not measured universal model rankings or a live quota router.

| Responsibility | Available agent / configured role intent |
| --- | --- |
| Coordination and architecture | Main agent; `default` / `plan` |
| Bounded implementation and test writing | General task agent; `task` |
| Mechanical changes | `sonic`; `smol` |
| Unmapped read-only discovery | `scout`; `scout` |
| Code correctness review | `reviewer`; `review` |
| Security review when warranted | `security-reviewer`; `review` |
| Difficult analysis and debugging | `slow` through supported model-selection controls |
| Image questions/descriptions | `vision`; ordinary attached images may still be read by the active model |
| Background advisory critique | `advisor` if enabled; never human acceptance |

Role names are not necessarily valid `task.agent` names. Dispatch discovered agent names through their configured routing. If the requested route is unavailable, report the actual route; do not claim a model switch occurred. Do not change account pools, global settings, effort exposure, or fallback chains without user permission. Account rotation and model fallback are different mechanisms.

### Worker contracts and concurrency

- Scope inline first. Delegate only genuinely independent substantive slices; keep small work with the main agent.
- Every worker starts with a self-contained brief: approved requirement/design revisions, allowed files/interfaces, non-goals, dependencies, acceptance criteria, exact execution permissions, and output/evidence contract.
- Send shared context once in batched `task` calls; use named workers and stable artifact references. Bound concurrency and recursion. Keep one integration owner and avoid overlapping file ownership.
- Use ordinary `task` delegation by default. Use eval `agent()`/`workpool()` only for justified dependency waves or repeated independent items, and only with relevant execution permission. Never create cyclic waits.
- Results auto-deliver. Continue useful independent work; wait only when blocked. Use Agent Hub and supported peer messages for inspection/steering. Do not poll workers.
- Headless workers cannot resolve human approvals. They must return a decision-needed result to the main agent. Parent task approval is not unlimited command authorization; headless `yolo` and workspace isolation are not security boundaries.
- If isolated execution is available and enabled, retain changes for review rather than assuming automatic application is safe. Inspect actual apply behavior; do not silently alter isolation settings. If unavailable, use clear shared-workspace file ownership and disclose the limitation.
- Use LSP for semantic navigation/references and AST-aware tools for structural edits where available. Use ordinary source tools instead of unnecessary shell/eval.
- Give all workers an explicit no-build/no-lint/no-tests/no-app-launch/no-git-mutation restriction unless the corresponding actions are authorized. Do not have parallel workers run shared verification mid-flight; the integration owner runs approved checks after the relevant changes settle.
- After each worker slice settles and is inspected, the main agent commits it as its own checkpoint before integrating the next slice.
- Normal main+task mode is the default. Plan mode, native goal mode, and interactive `/vibe` have compatibility limits; do not stack incompatible modes. Vibe is optional, not required, and does not replace review or permission gates.

## Stage 5 — Testing, independent review, and batch code gate

1. Read and follow `references/testing.md`; testing is a required planned stage, not optional polish.
2. Inspect worker changes and integrate only approved scope. Verify relevant exported-symbol references when supported. Update affected callers, meaningful tests, and requested/necessary docs without compatibility shims unless required by the approved design.
3. Run only authorized checks; request separate application permission for any scenario that starts or exercises an application. Where authorized, exercise the changed behavior rather than treating test success alone as proof. Record what actually ran and what did not.
4. Obtain a read-only independent code review for non-trivial work when a suitable reviewer is available. Use security review for relevant auth, permissions, sensitive data, untrusted input, or execution boundaries. Findings are evidence, not human approval.
5. Commit all batch changes, tag the head `factory/<work-id>/b<N>-review-r<rev>`, then present a batch review packet: intent and requirement IDs; base and head SHAs; commit list and actual full diff `base..head` including new files and tests; architecture impact; reviewer findings and resolutions; command results; coverage and limitations; specific questions for the user.
6. Prefer OMP diff annotations or a PR review surface when available. A summary is not a substitute for access to the actual code. The user may comment, edit directly, request another approach, or revisit architecture.
7. Stop at the gate. Block dependent todos and prevent mutating workers or queued directives from continuing. Do not leave an application or watch process running across the pause unless explicitly permitted.
8. On feedback, reread affected files, preserve human edits, update the record, revise the batch as new commits (never amend reviewed commits), rerun only authorized affected checks, and present a new tagged review revision. New code means renewed code approval. If the user edited files directly, ask whether to commit their edits as separate user-attributed commits before building on them.
9. After acceptance, tag `factory/<work-id>/b<N>-accepted`, commit the record, then propose/authorize the next batch. Do not treat acceptance of batch 1 as approval for all future batches.

## Stage 6 — Integration and delivery

Reconcile every acceptance criterion with implementation, relevant test cases, observed evidence, and human decisions. Present combined changes and any required final verification for explicit integration acceptance. Never mark the request complete with failed, blocked, or unexecuted required evidence; if the user explicitly waives a check, record the waiver and resulting limit rather than calling it passed.

Keep merge into the base branch, push, deployment, migrations against real environments, and release decisions separately authorized. Recommend a `--no-ff` merge so the feature stays revertible as a unit and cherry-pickable per commit. Supply rollback information (merge SHA, revert command, accepted tags) when relevant; do not perform destructive actions merely because an earlier plan mentioned them.

Finish with what changed, review/acceptance status, exact checks exercised, failures/waivers/limitations, work branch, base and head SHAs, tags, and the work-record path. Do not fabricate outputs, provider availability, quotas, coverage, visual review, or completion.

## Pause, resume, and recovery

At a human gate, persist the packet/revision, blocker, permission scope, worker status, and next allowed action, and commit the record and any factory changes, before yielding. A saved goal or todo is progress metadata, not approval. Pause a native goal through supported controls when available and stop dependent work; never let continuation pursue unapproved implementation.

On resume, read the record and authoritative repository state, including current branch, HEAD, and commits since the last recorded checkpoint. Confirm which requirement/design/diff revision is current and whether any permission remains valid for this work item. Inspect interrupted side effects before retrying them; an interrupted commit is checked with `git status` and `git log`, not retried blindly. Never replay an unknown-outcome migration, deployment, or app command automatically. Session rewind/checkpoint changes conversation context, not workspace files. Code rollback means a revert commit or a new branch from a checkpoint tag/SHA, never a reset of the user's branch.

Memory and compaction summaries may aid recall, but must not invent, replace, or resurrect approvals. A contradictory record or changed source revision requires reconciliation before action. If an approval's target or scope is ambiguous, ask the user rather than infer it.
