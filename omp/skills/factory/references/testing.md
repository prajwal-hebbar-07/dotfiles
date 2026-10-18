# Factory testing protocol

Read this before test planning, writing tests, assigning a testing worker, or executing checks. Testing is part of delivering the requested behavior, but runtime permission is not implied by invoking the skill or approving code.

## What comprehensive means

The user wants broad, meaningful unit-test coverage, not a token happy-path test. Derive a finite case matrix from the approved contract and the system's real behavior. Enumerate all distinct specified outcomes and manageable finite states where practical; use equivalence classes, boundary analysis, or existing deterministic property-based tools for larger input spaces.

Never claim "every possible test" or complete coverage of an arbitrary system. Explain unbounded input spaces, unavailable environments, omitted behaviors, and residual risks. Do not add irrelevant cases, duplicate assertions, or new product behavior merely to grow the suite.

For an existing system, inspect the test inventory before proposing new tests. Cover all requirements in the approved scope and affected existing behavior. If the user explicitly requests a whole-system test audit, inventory its subsystems and contracts and plan reviewable test batches. Do not silently limit that request to changed files, or silently expand a feature request into rewriting every test in the repository.

## Permission model

Separate source work from execution:

| Action | Required authority |
| --- | --- |
| Inspect existing tests/configuration and propose cases | Intake/source-inspection scope |
| Write or update unit tests without executing them | Approved implementation/test-writing batch |
| Run a unit suite, collect tests, measure coverage, lint, typecheck, build, benchmark, or run a diagnostic script | Explicit current-work authorization for the stated check |
| Launch or exercise an app, dev/preview server, watcher, container, browser-based app check, or real app API | Separate explicit application-execution authorization |
| Install test tools/dependencies, download fixtures/models, provision infrastructure | Explicit setup authorization |
| Access shared/live data or external services | Explicit target and side-effect authorization, plus application permission where applicable |

A direct user request to "write and run unit tests for this module" grants that unit-test scope. It does not authorize launching its application or running unrelated suites. A previous work item's permission, general autonomy, architecture approval, or a worker prompt is not a new grant.

Before requesting a grant, discover the actual commands and lifecycle from package scripts, test configuration, fixtures, and documentation. Do not run discovery commands that execute imports/plugins, collect tests, or start fixtures without permission. A command called "test" can still start a backend or container; classify its actual effects, not its name.

Present the scope plainly: checks and targets; commands; expected environment; application processes if any; network, credential, and data access; cleanup; excluded actions. Use distinct test and app permission questions/options where both are needed. No timeout/recommended answer may count as approval. With no interactive UI, return a permission-needed result to the main agent and wait.

Once the user grants a scoped verification plan, execute its unchanged commands as needed within that work item without asking repeatedly. Changed targets, new commands with materially different effects, new services, or live-data use require a new grant. Revocation stops work safely. Never bypass a denied command using eval, another agent, a build, browser automation, or a seemingly harmless API call.

## Build the case matrix before writing

For each requirement and affected invariant, evaluate the following dimensions. Include only applicable cases, but record a reason when a material dimension is excluded.

| Dimension | Cases to consider |
| --- | --- |
| Normal behavior | Representative valid inputs and each distinct output/branch promised by the contract |
| Boundaries and partitions | Minimum/maximum, just below/at/above limits, zero/one/many, empty/missing/null only where the API distinguishes them, numeric precision or overflow where relevant |
| Invalid inputs | Malformed types/formats, unsupported values, conflicting parameters, invalid combinations, domain-invalid states |
| State transitions | Each allowed transition; rejected transitions; repeated operations and idempotency only where specified; ordering/precedence |
| Errors and recovery | Declared error classes/results; dependency failure; partial operation failure; cleanup/rollback invariants; retry/cancellation/timeout behavior only if part of the contract |
| Side effects | Exact required persisted changes or emitted actions, and absence of forbidden side effects on failure |
| Access and isolation | Authentication/authorization, owner/tenant boundaries, sensitive-data exposure, and untrusted input when relevant |
| Time and concurrency | Expiry/time boundaries, ordering, duplicate delivery, races or concurrent updates only for systems that expose those behaviors |
| Compatibility | Public contract, serialization, migration boundaries, supported historical inputs, affected existing consumers |
| Cross-component behavior | Interactions that cannot be proven by isolated units; identify these as integration/system checks, not unit tests |

Each case records: stable case ID; requirement/invariant; setup and input; observable expected result; test type; file/test name; dependencies; permission needs; and status. Keep the matrix in the work record or a linked test-plan artifact.

Prefer the repository's existing language, runner, fixtures, assertions, and test locations. Do not introduce a parallel test convention or new framework unless genuinely required and approved.

## Writing strong unit tests

- Assert public behavior, domain invariants, errors, boundaries, or meaningful state transitions. Each permanent test must catch a plausible consumer-visible regression.
- Test results and prohibited effects precisely. A weak "does not throw", truthy result, nonempty response, length increase, or generic status alone is insufficient when the contract specifies more.
- Do not test source text, copied constants, wiring, mocks echoing their own setup, private call order, incidental wording, or implementation details instead of behavior. Existing tests of incidental wording/implementation should be removed rather than re-pinned, while preserving required behavior coverage.
- Use parameterized cases for real equivalence classes; avoid duplicate rows that exercise the same path without a distinct invariant or boundary.
- Use mocks/fakes at real external boundaries to make a unit deterministic, not to mock away the behavior being tested. Avoid real network, live credentials, shared databases, sleeps, or environment-dependent assertions.
- Isolate state, use temporary resources, restore mutated globals/time/environment, fix random seeds where relevant, and clean up fixtures. New tests must be full-suite-safe and order-independent.
- Use fake time or controlled scheduling for temporal behavior. Do not add flaky stress loops or performance thresholds to a unit suite. Benchmarks require their own explicit authorization.
- Property-based/metamorphic tests are useful only with meaningful domain invariants and existing/approved tooling; they are not a substitute for clear examples and boundary cases.
- For a bug, preserve a regression test that fails under the old behavior and passes with the fix when feasible. Respect user-reported failures as evidence; do not rerun solely to confirm their report. Demonstrating failure on an old revision needs an authorized, non-destructive environment; do not revert the user's workspace.
- Keep test-writing and implementation tasks in the approved batch with clear file ownership. Do not run parallel shared suites mid-edit. The integration owner gathers results after changes settle.

## Execution and evidence

When authorized:

1. Run the focused tests for the changed behavior using the discovered project command. Record actual command, source revision, permission reference, result, and useful output.
2. Run the affected regression scope and broader suite only to the extent authorized. Do not mistake collection, skipped tests, or a filtered suite for running everything.
3. Distinguish a failed assertion from environment/setup failures. Investigate permitted source first; do not silently install missing tools or start services to force a result.
4. Resolve failures without suppressing exceptions, skipping meaningful tests, weakening assertions, or changing expected behavior merely to make the suite green. If the requirement legitimately changes, reopen its gate and update affected tests after approval.
5. Exercise the actual changed surface when that execution has been explicitly authorized. A UI requires observing the UI; an API requires the actual response/side effect; a CLI requires its real output/state. Unit tests alone do not prove the running integration works.
6. Before an app smoke check, obtain application permission if not already granted. Name the launch/action/stop steps and use non-production data. Do not assume test permission covers a server, even if it runs in a fixture. Avoid starting a service if a permitted existing instance can be used safely.
7. Clean up only the processes/resources created for the authorized check. Do not stop a user's existing service. Never leave a watcher, container, or server alive across a human-review pause without explicit permission.
8. If coverage measurement was authorized, report actual relevant uncovered behaviors and the measured scope. Do not manufacture percentages, infer coverage from the number of tests, or use a percentage as proof of correctness.

If testing is not authorized, finish approved source/test writing and record `not_run: permission not granted`. If an authorized check cannot run, record the actual blocker. Neither state is a pass. Ask for a missing permission when it becomes necessary, then wait rather than repeatedly prompting or executing alternatives.

## Required testing report at code review

Include:

- Requirement/invariant-to-case mapping and which meaningful gaps were filled.
- New/updated/deleted test locations and the reasons for material changes.
- Checks actually executed, their scope, results, and log/artifact references.
- Failed, skipped, blocked, and not-run cases with reasons.
- Actual-surface evidence when separately authorized, or the explicit lack of it.
- Relevant residual risks and any human-approved exclusions/waivers.

Never describe all tests as passing unless the exact claimed scope ran successfully. A green unit suite, AI reviewer, judge model, or coverage report cannot approve the code; the user still reviews the actual production and test diff.
