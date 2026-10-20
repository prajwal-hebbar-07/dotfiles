# Agent Factory: research and implementation guide (11 gaps)

**Research date:** 20 October 2026  
**Scope:** The 11 items in the screenshot, **in its exact order**. The `R#` identifiers below are the user's stage labels, not a priority ranking.  
**Intended environment:** Oh My Pi (OMP) as an execution harness, GitHub Issues / Projects v2, a UI designed in **Paper.design**, and a gated spec → tickets → build → QA → review → PR → merge workflow.

> **Evidence key:** **Verified** means the linked upstream README, skill definition, or vendor documentation describes that capability. **Compose** means the necessary components are real but integrating them into this specific factory is your own engineering work. **Custom** means no existing skill/tool reviewed here delivers that requirement end-to-end. A named skill is **not** proof that its code has run or that it supports every host.

## Executive recommendation

Do **not** install every skills pack and force the entire factory to use them simultaneously. Make **OMP the runtime**; choose **one implementation method** (Superpowers for guarded serial tasks, or Matt Pocock's `implement-spec` for ticket-graph parallelism); use **real scripts and CI checks** for truth; add **pstack verification / PR lifecycle playbooks** where useful. Skills tell agents *what procedure to follow*; tests, browsers, GitHub and CI are the systems that actually establish outcomes.

| Research order | Stage | Recommendation | Confidence / work type |
|---:|---|---|---|
| 1 | R11 New-project setup | Custom `walking-skeleton` gate + Addy Osmani's CI / constraints / Git skills | **Compose** — missing project-specific bootstrap |
| 2 | R1 QA | pstack `create-verification-skill` + real Playwright / OMP browser + Superpowers verification | **Compose** — test fixtures and evidence still need wiring |
| 3 | R2 Builder | Superpowers `subagent-driven-development` **or** Matt `implement-spec`; explicit blocked-state handoff | **Compose** — choose one orchestration owner |
| 4 | R12 After the PR | Superpowers `receiving-code-review` + pstack Babysit + lifecycle automation | **Compose** — post-merge is project-specific |
| 5 | R5 + R6 Reviews | OMP `/review` + Matt's spec/standards review + runtime mutation / test review | **Verified tools, custom policy** |
| 6 | R7 UI parity | Paper MCP + pstack visual-parity playbook + Playwright screenshot diff | **Compose** — access and stable rendering needed |
| 7 | R3 In-stage recovery | OMP advisor / `WATCHDOG.md` / `session_stop` + Superpowers debugging | **Compose** — continuation rules are custom |
| 8 | R9 Security | Semgrep + Gitleaks + OMP `security_scan` where authenticated | **Verified tools, custom per-issue gate** |
| 9 | R8 Issues / board | `gh project item-edit` + GitHub sub-issue and dependency REST APIs | **Verified API, custom synchronization** |
| 10 | R4 Tech stack | Addy `source-driven-development` / `documentation-and-adrs` + pstack `architect` | **Custom decision matrix** |
| 11 | R10 Evals | pstack blinded `eval` playbook + Promptfoo coding-agent / skill evals | **Compose** — no access to archived 6 scenarios |

---

## 1. R11 — New-project setup (new)

**Problem.** All subsequent issues and QA passes assume runnable project commands, the expected `factory/**` CI path filter, a `check:full` script, a test harness, a boundary checker, sample data and `.env.example`. A blank repository has none of these.

### Skills / resources, ranked

1. **Addy Osmani — [`ci-cd-and-automation`](https://github.com/addyosmani/agent-skills/blob/main/skills/ci-cd-and-automation/SKILL.md)** — **Verified.** For CI quality gates, build/deploy feedback loops and automation patterns. **It is guidance, not a project generator.**
2. **Addy Osmani — [`constraint-driven-development`](https://github.com/addyosmani/agent-skills/blob/main/skills/constraint-driven-development/SKILL.md)** — **Verified.** Establish explicit quality thresholds and `CONSTRAINTS.md`; keep agents from disabling checks to manufacture a pass.
3. **Addy Osmani — [`git-workflow-and-versioning`](https://github.com/addyosmani/agent-skills/blob/main/skills/git-workflow-and-versioning/SKILL.md)** — **Verified.** Atomic commits, short-lived branches and recoverable changes.
4. **pstack — [`create-verification-skill`](https://github.com/backnotprop/pstack/blob/main/skills/create-verification-skill/SKILL.md)** — **Verified.** Generates a project-specific drive/verify workflow once the project has a runnable surface.
5. **Matt Pocock — [new-project setup gap discussion, issue #967](https://github.com/mattpocock/skills/issues/967)** — useful **background, not a packaged solution you should assume exists**. It describes this exact omission and proposes a `walking-skeleton` skill. Matt's [`setup-matt-pocock-skills`](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/SKILL.md) sets up skill/tracker conventions; it does **not** necessarily scaffold the app.

### Recommended design: create your own `/factory-bootstrap`

A deterministic bootstrapping script/template must create or verify:

- A minimal app/service that starts and responds; README with start/build/test commands and pinned toolchain/runtime versions.
- `package.json` (or an equivalent task runner) implementing `lint`, `typecheck`, `test`, `test:e2e`, `check:full` and a fixture seeding command. Don't create empty success scripts.
- CI workflow covering **PRs and pushes**, including changes under `factory/**`; required checks must execute or report correctly when path filters skip jobs.
- A boundary checker for forbidden package imports, dependency direction, public/private API boundaries and unauthorized file areas. Make it deterministic (lint rule/script), not just an LLM opinion.
- `.env.example` with names and documentation only; a separately managed real secret store; no committed credentials.
- Seed data, a local demo account or auth bypass **restricted to test environments**, and mock/stub endpoints for unavailable external services.
- A runnable browser or API verification harness, artifact/evidence folder, teardown and clean-state procedure.
- `CONSTRAINTS.md`, `AGENTS.md`, architecture/decision record path, definition of done, CI required-check names.

**Acceptance test:** In a brand-new repository, clone to a clean environment, install, seed, run, then run `check:full` and at least one real end-to-end scenario. Introduce a deliberate failing test, a forbidden import and an invalid secret; each must make the appropriate check fail. Prove the `factory/**` trigger with a test PR.

**Choice:** **Custom skill + scripts**, informed by Addy's three skills. Do this first; downstream automation without a runnable baseline yields fake green reports.

---

## 2. R1 — QA

**Problem.** “Run tests” is underspecified. QA must actually boot the app, create or seed accounts/data, manage secrets and dependencies, exercise user journeys, capture evidence and clean up.

### Skills / tools, ranked

1. **pstack — [`create-verification-skill`](https://github.com/backnotprop/pstack/blob/main/skills/create-verification-skill/SKILL.md)** — **Best fit / Verified.** Interviews the repo and writes a project-local launch → doctor → drive → evidence → cleanup skill plus a feature map. Use [`maintain-verification-skill`](https://github.com/backnotprop/pstack/tree/main/skills/maintain-verification-skill) when app behavior changes.
2. **Superpowers — [`verification-before-completion`](https://github.com/obra/superpowers/blob/main/skills/verification-before-completion/SKILL.md)** — **Verified.** An agent cannot claim pass/fixed/done without freshly running the relevant check and reading its output.
3. **Addy — [`browser-testing-with-devtools`](https://github.com/addyosmani/agent-skills/blob/main/skills/browser-testing-with-devtools/SKILL.md)** — **Verified**, depends on configured Chrome DevTools MCP; useful for DOM, console, network and performance evidence.
4. **[Playwright Test](https://playwright.dev/docs/intro)** and [screenshot assertions](https://playwright.dev/docs/test-snapshots) — **Verified deterministic runner**, not merely a planning skill.
5. **OMP** — [scriptable browser](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/browser.md) and [computer use](https://github.com/can1357/oh-my-pi/blob/main/docs/computer-use.md) where enabled. Prefer browser-level DOM evidence for web apps; reserve desktop interactions for native surfaces.

### Recommended R1 QA protocol

1. Check repo revision, environment and seeded fixture version (`doctor`).
2. Start app and required infrastructure in an isolated run; ensure readiness on the expected port/version.
3. Inject credentials from protected runtime configuration, not the agent prompt; prefer disposable test credentials.
4. Exercise smoke, integration, E2E and negative paths for the issue's acceptance criteria. Verify user-visible behavior and data persistence, not just rendered text.
5. Capture exit codes, logs, failed HTTP/network requests, screenshot/video/trace, affected route and git SHA.
6. Clean up servers, temporary files, seeded entities and ports **without deleting the proof bundle**.
7. Emit a structured `PASS | FAIL | BLOCKED` artifact. Missing prerequisites are `BLOCKED`, **not** pass.

**Acceptance test:** Start from a clean checkout; QA seeds data, logs in using a test mechanism, completes one successful journey, detects a deliberate regression, emits usable evidence and leaves no stray process.

**Choice:** pstack-generated verification skill owns the instructions; Playwright/browser and `check:full` own the truth. Avoid overlapping browser drivers unless they verify different concerns.

---

## 3. R2 — Builder

**Problem.** This is the largest under-specified gap. Implementation must be bounded, reviewable, and able to escalate before wasting a fixed three-attempt retry budget.

### Compare orchestration candidates

| Candidate | How it works | Best when | Limitation |
|---|---|---|---|
| **[Superpowers subagent-driven development](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md)** | Fresh implementer per task, verification, spec review and code-quality review; escalates `BLOCKED` / `NEEDS_CONTEXT` | A tightly controlled implementation loop | Serializes conflicting implementation tasks; requires you to connect it to issue graph |
| **[Matt `implement`](https://github.com/mattpocock/skills/blob/main/skills/engineering/implement/SKILL.md)** | Takes one settled ticket/spec, performs TDD, typecheck, review and commit | One ticket per fresh agent session | Not a whole-board dispatcher |
| **[Matt `implement-spec`](https://github.com/mattpocock/skills/blob/main/skills/engineering/implement-spec/SKILL.md)** | Runs independent tickets in worktrees according to blocking edges and merges on integration branch | Many independent ready tickets in a verified task DAG | Needs an issue tracker, subagents and worktree/merge support |
| **[pstack Orchestrate](https://github.com/backnotprop/pstack/blob/main/skills/poteto-mode/playbooks/orchestrate.md)** | Long-lived coordinator delegates substantial multi-phase / multi-PR programs | Multi-day project ownership | Too heavy for a single issue; not the default builder |
| **[Addy incremental implementation](https://github.com/addyosmani/agent-skills/blob/main/skills/incremental-implementation/SKILL.md)** | Small, testable, rollback-friendly vertical slices | Working in controlled increments | A methodology, not a ticket scheduler |

### Recommended builder contract

`READY → CLAIMED → WORKTREE_CREATED → BASELINE_CHECKED → IMPLEMENTING → VERIFYING → REVIEWING → PR_READY`, with explicit `BLOCKED`, `FAILED`, `ESCALATED` transitions. Save status and identifiers in a durable issue/PR record; do not trust ephemeral chat history.

- **Input:** ticket/spec, approved architecture and Paper frame reference where relevant, acceptance criteria, dependency list, permitted paths, base SHA.
- **Before coding:** lock ticket ownership; create branch/worktree; verify starting revision, tests and accessible dependencies; flag contradictory requirements.
- **During work:** enforce targeted TDD, small vertical slices, typechecking and bounded changes; run reviewer on real diffs.
- **Troubleshooting:** each attempt must introduce a **new hypothesis and new evidence**. On repeated identical failure, missing credentials, missing external service, unclear specs, potential security regression or changed architecture: **stop immediately** and escalate rather than consuming all retries.
- **Retry budget:** set `max_attempts = 3` across substantive repair iterations, including context recovery. A 4th attempt requires explicit external decision.
- **Output:** commit hash, changed files, test commands with outcomes, evidence paths, unsolved risks, reviewer findings, PR URL (if authorized).

**Choice:** For a starter factory, choose Superpowers' bounded loop for **individual tickets**. Introduce Matt's `implement-spec` only after DAG metadata and merge safety are solid. Never let both systems independently dispatch the same ticket.

---

## 4. R12 — After the PR (new)

**Problem.** A PR is not the end of work: review comments must reach the builder; after merge, issues unblock, branch stacks may need rebasing and documentation/tests may require refresh.

### Skills / tools

1. **Superpowers — [`receiving-code-review`](https://github.com/obra/superpowers/blob/main/skills/receiving-code-review/SKILL.md)** — evaluate feedback technically before accepting/fixing it, verify changes.
2. **pstack — [Babysit playbook](https://github.com/backnotprop/pstack/blob/main/skills/poteto-mode/playbooks/babysit.md)** — PR conflicts, review threads and CI, with batching to avoid repeated CI restarts. **Stops at merge-ready**, not merged.
3. **pstack — [Shipping playbook](https://github.com/backnotprop/pstack/blob/main/skills/poteto-mode/playbooks/shipping.md)** — separate decision/action to verify and land a green PR stack.
4. **Superpowers — [`finishing-a-development-branch`](https://github.com/obra/superpowers/blob/main/skills/finishing-a-development-branch/SKILL.md)** — verify branch and choose merge/PR/keep/discard.
5. **Matt — [`pr`](https://github.com/mattpocock/skills/blob/main/skills/engineering/pr/SKILL.md)** — reviewable PR description, visual explanation, before/after evidence and risk.

### Recommended PR/merge controller

- Detect PR review changes and map each actionable comment to a ticket/diff/line; re-dispatch **the owning builder** with the comment plus current SHA, not the entire chat history.
- Classify comment: confirmed bug, spec mismatch, security issue, stylistic request, stale/non-actionable; supply evidence when rejecting a comment.
- After one consolidated fix push, rerun required checks and resolve/comment on review threads.
- Keep explicit separate states: `PR_OPEN`, `CHANGES_REQUESTED`, `CI_RED`, `MERGE_READY`, `MERGED`, `REBASE_REQUIRED`, `DONE`.
- Never infer merge authorization from “make it green”. Merge requires user or pre-approved policy; apply branch protection and never bypass required checks.
- After merge, query actual merge SHA, close/update the issue, reconcile blockers and Project fields, and rebase **only affected stacked branches** in dependency order with fresh checks.
- Update docs based on changed behavior, not every arbitrary commit. Delete worktrees safely after remote and local refs are reconciled.

**Acceptance test:** PR with two comments and a failing check returns to builder, gets one fix push, turns green, then after an authorized merge unblocks its dependent issue and updates the next branch without losing changes.

**Choice:** Compose `receiving-code-review` + pstack Babysit, with a **custom GitHub event-to-builder handoff** and post-merge controller.

---

## 5. R5 Code review + R6 Unit-test review

**Problem.** A first-pass code reviewer does not prove test quality or that the implementation matches the original spec.

### Recommended reviewers, compared

| Reviewer | Best at | Important boundary |
|---|---|---|
| **[OMP built-in `/review`](https://github.com/can1357/oh-my-pi)** | Multi-agent review with P0–P3 priorities/confidence on branch, commit or working tree | Great default bug finder; review does not replace running tests |
| **[Matt `code-review`](https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md)** | Two independent axes: **Standards** and **Spec** | Requires an actual fixed-point diff; Spec axis needs an accessible issue/spec |
| **[Addy `code-review-and-quality`](https://github.com/addyosmani/agent-skills/blob/main/skills/code-review-and-quality/SKILL.md)** | Structured maintainability/quality checklist | Overlaps other reviews; use as checklist rather than another mandatory agent every time |
| **[Superpowers `requesting-code-review`](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/SKILL.md)** | Early focused review dispatch per task | Good at process orchestration, not a unit-test coverage analyzer |
| **pstack [`interrogate`](https://github.com/backnotprop/pstack/blob/main/skills/interrogate/SKILL.md)** | Adversarial challenge to code/design choices | Expensive; use for high-risk patches, not every tiny change |

### The missing R6 unit-test review

Make a **separate, issue-specific test auditor**. Feed it the spec, implementation diff, baseline and test diff. Ask it to report:

1. Which acceptance criteria have **no real assertion**?
2. Does each test fail on the base revision or a deliberately injected mutation, then pass on the implementation?
3. Are there assertions for boundary conditions, invalid input, null/empty data, access controls, state transitions and failure recovery?
4. Do mocks replace the exact behavior that needs verifying? Are tests coupled to implementation details rather than public behavior?
5. Are there skipped/`only` tests, snapshots blindly rewritten to match a bug, catch-and-ignore patterns, unrealistic fixtures or nondeterminism?
6. Can a test pass while the app is actually broken, or while a required integration is unavailable?

Review findings use **P0/P1/P2/P3**, precise file/line/behavior, proof or reproduction, and a recommendation. Fixing the code can never be replaced by weakening the tests.

**Acceptance test:** On a deliberately flawed PR containing a missing edge case, an always-true assertion, and a fixture that masks a failure, the test review identifies the defects even if all existing tests are green.

**Choice:** Use OMP `/review` for bugs + Matt `code-review` for spec adherence **only when their roles are distinct**; run an explicit R6 test-quality pass with mutation checks. Avoid three redundant generic reviewers.

---

## 6. R7 — UI review against Paper.design

**Problem.** “Looks similar” is not the same as pixel parity. A visual model can flag usability issues, but screenshot-diff automation should be the measurable parity check.

### Verified components

1. **[Paper official MCP](https://paper.design/docs/mcp)** — read designs using an agent; Paper documents a desktop MCP connector for multiple agents and a manual stdio connector for other hosts. This is preferable to guessing a frame from prose. **Access to the currently open Paper file must be confirmed.**
2. **[pstack visual-parity playbook](https://github.com/backnotprop/pstack/blob/main/skills/poteto-mode/playbooks/visual-parity.md)** — baseline-first, no baseline tampering, change components one at a time, verify via image diff. **This is a `poteto-mode` playbook, not an independently installable `visual-parity` skill.**
3. **[Playwright `toHaveScreenshot`](https://playwright.dev/docs/test-snapshots)** — screenshot regression assertions with consistent browser, OS and viewport.
4. **[pixelmatch](https://github.com/mapbox/pixelmatch)** — image diff pixel count and diff PNG; not a layout-understanding model.
5. **[Addy frontend UI engineering](https://github.com/addyosmani/agent-skills/blob/main/skills/frontend-ui-engineering/SKILL.md)** — responsiveness, accessibility and design-system discipline.

### Suggested parity procedure

1. Identify the **exact Paper frame/version and state**, including breakpoints, theme, content and interactions; capture a versioned baseline PNG at the exact target size. If Paper MCP cannot return a reference image in the connected runtime, export it from Paper manually. **Do not assert a particular screenshot MCP method exists until the live tool list confirms it.**
2. Start app with deterministic fonts, data, locale, timezone and animations disabled. Use the same viewport and device scale as Paper; capture target screenshot.
3. Produce baseline / actual / difference images and a numerical delta. Keep both source images and diff in evidence.
4. Prioritize layout, typography and component geometry; mask **only genuinely dynamic** content after review. A mask must never hide the component you are checking.
5. Separately check keyboard interactions, responsive behavior and functional state transitions (a static PNG cannot prove those).
6. Treat pstack's *zero-diff* rule as a strict target **within a controlled identical environment**; for cross-platform rendering adopt a documented, reviewed tolerance only when unavoidable. Never silently update baseline to make CI pass.

**Acceptance test:** Intentionally change a button width, font and spacing; the visual review identifies each, points to evidence and returns FAIL. Restore parity, then demonstrate a pass. Re-run at every Paper breakpoint.

**Choice:** Paper MCP + Playwright screenshot comparisons + pstack visual-parity discipline. The Paper connection is **design input**; the screenshot diff is **evidence**.

---

## 7. R3 — Recovery inside a stage

**Problem.** Existing S1–S5 recovery at *stage boundaries* does not handle a crash, stale context, compaction, worker timeout or repeatedly failing command **inside** a stage.

### Strong options

1. **[OMP `session_stop` event](https://github.com/can1357/oh-my-pi/blob/main/docs/extensions.md)** — **Verified.** Supports advisory continuation and explicit blocking decisions before a session settles. It's a lifecycle hook, **not** automatically a job queue.
2. **[OMP Advisor + `WATCHDOG.md`/`WATCHDOG.yml`](https://github.com/can1357/oh-my-pi/blob/main/docs/advisor-watchdog.md)** — **Verified.** Separate reviewing model injects risk/blocker notes; review priorities can be project-specific. It does not by itself persist/restore your factory state.
3. **[OMP compaction and handoff](https://github.com/can1357/oh-my-pi/blob/main/docs/compaction.md)** — **Verified.** Context summary and handoff machinery; validate output before resuming.
4. **[Superpowers `systematic-debugging`](https://github.com/obra/superpowers/blob/main/skills/systematic-debugging/SKILL.md)** — reproducing/root-causing failures before patching.
5. **[pstack autonomous run](https://github.com/backnotprop/pstack/blob/main/skills/poteto-mode/playbooks/autonomous-run.md)** or [Orchestrate](https://github.com/backnotprop/pstack/blob/main/skills/poteto-mode/playbooks/orchestrate.md) — good patterns for long-running ownership, but not a replacement for durable storage.

### Recommended recovery mechanism

Persist an **idempotent stage checkpoint** to disk/database at each material transition: `run_id`, issue id, stage id, branch/worktree, last good commit, current task, most recent command and exit code, model/session identifiers, attempt count, resource ownership, artifacts and next action.

On restart or context compaction:

- Re-read the persisted checkpoint and re-observe actual GitHub/worktree/CI state. Do **not** assume a remembered status is correct.
- If an operation committed/pushed already, reconcile its hash and don't repeat the side effect.
- If a process died, capture logs and check whether it needs rollback, resume or re-provisioning.
- Use OMP advisor to flag contradictions, privilege boundaries and risky shortcuts. An advisor warning alone is not proof of an error.
- A timeout, denied permission or unavailable external service becomes `BLOCKED` with a recommended recovery, not a fabricated pass.
- Use **at most three substantive fixes** unless the human explicitly approves more. A stage-boundary retry should not reset the in-stage limit.

**Acceptance test:** Kill a worker halfway through implementing a ticket and halfway through PR creation. Resume without duplicate commits/issues/PRs, with full audit evidence and an accurate retry budget.

**Choice:** Build a small durable state machine **around** OMP. The native advisor/hooks help, but they are not a workflow engine.

---

## 8. R9 — Security per issue

**Problem.** A one-time threat model does not detect new vulnerabilities in a small patch that adds routes, permissions, dependencies, user input or credentials.

### Tools and skills

1. **[Semgrep](https://github.com/semgrep/semgrep)** — **Verified SAST.** Source-pattern / taint checks; run configured rules in CI and investigate findings.
2. **[Gitleaks](https://github.com/gitleaks/gitleaks)** — **Verified secret scanner.** Scan changed working tree/commits and mainline history as appropriate; current CLI uses `gitleaks git` / `gitleaks dir`.
3. **[OMP native `security_scan`](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/security_scan.md)** — **Verified but conditional.** `security.enabled` is **false by default**. Native preflight requires OAuth for the active model's provider, **not API-key-only authentication**. Cloud operations require the documented Codex OAuth credential; verify consent and capability before selecting this route.
4. **[Addy `security-and-hardening`](https://github.com/addyosmani/agent-skills/blob/main/skills/security-and-hardening/SKILL.md)** — structured OWASP, auth, secret and boundary review.
5. **[OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)** — requirements checklist to map actual risks to controls.

### Per-issue security gate

- Classify changed data and surface: auth/session, RBAC/permissions, storage, network/API, SQL/command execution, file upload, dependency change, tokens/secrets, UI injection, infra/CI.
- Run lint/SAST and secret scan on PR changes; keep baseline findings separately so existing debt does not erase newly introduced issues.
- Check authorization **server-side**, deny-by-default, owner/tenant scoping, token leakage, input validation, rate limits and safe errors where applicable.
- Link any high-risk finding to file/line, exploit preconditions, test case and remediation PR/commit.
- Block merge on **confirmed critical/high findings** or a failed mandatory scanner; human waivers must name owner, justification and expiration.
- For OMP `security_scan`, explicitly check enablement and OAuth availability first; otherwise use local scanners and record that OMP scan was not run.

**Acceptance test:** Introduce an exposed secret and an unsafe authorization bypass into separate test branches; verify both are caught by the appropriate mechanism. A scanner that could not authenticate must report `BLOCKED`/`NOT_RUN`, never `PASS`.

**Choice:** Semgrep + Gitleaks in deterministic CI as the baseline; optional OMP security review for higher-risk tickets. Do not rely on a model-only security approval.

---

## 9. R8 — Issues and board

**Problem.** Ticket relations and Projects v2 custom fields are separate surfaces. A green PR does not automatically guarantee project status, parent/sub-issue metadata and blockers are correct.

### Verified official interfaces

- **[`gh project item-edit`](https://cli.github.com/manual/gh_project_item-edit)** — editing Projects v2 fields by project item ID/field ID, or by issue URL + project owner/number (depending on field type and command version).
- **[GitHub REST — sub-issues](https://docs.github.com/en/rest/issues/sub-issues)** — add/list/remove parent/sub-issue relationships.
- **[GitHub REST — issue dependencies](https://docs.github.com/en/rest/issues/issue-dependencies)** — add/list/remove blocked-by relationships.
- **[Matt `to-tickets`](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md)** — vertically sliced agent-ready tickets with explicit blocking edges; depends on a configured tracker.

### Recommended board-sync adapter

Build **one** GitHub adapter with operations `create_ticket`, `set_status`, `set_priority`, `add_child`, `add_blocker`, `list_ready`, `claim`, `mark_pr`, `mark_merged`, `unblock_dependents`, `reconcile`.

- Resolve **GitHub issue numbers vs numeric REST IDs vs GraphQL node IDs** correctly; do not interchange them.
- Discover Project ID, field IDs, option IDs and permission scopes for the repo at startup; do not hardcode IDs learned from another project.
- Prefer official REST endpoints for dependency/sub-issue relations, rather than text-only `Blocked by:` descriptions when supported.
- Retry rate limits with backoff, detect permission errors explicitly, and make writes idempotent where possible.
- Reconcile after webhook delivery loss or manual board edits. `Status: Done` must follow independently verified merge/acceptance criteria, not simply a builder's report.
- Test feature availability and permissions against the **installed GitHub CLI and active GitHub organization**.

**Acceptance test:** Build `A → B` blocked chain and parent `P → [A, B]`; complete A and verify B enters READY, project status updates, relationships survive manual edits and a duplicate webhook does not duplicate data.

**Choice:** `gh` for Projects fields + REST dependencies/sub-issues. A thin shared GitHub adapter is more reliable than several independently written agent prompts.

---

## 10. R4 — Tech-stack selection

**Problem.** Human approval catches obvious mistakes late, but stack research needs reproducible trade-offs **before** approval. No single verified skill above is a turnkey project-specific stack selector.

### Recommended components

1. **[Addy `source-driven-development`](https://github.com/addyosmani/agent-skills/blob/main/skills/source-driven-development/SKILL.md)** — check current official docs/API guarantees rather than inventing compatibility.
2. **[Addy `documentation-and-adrs`](https://github.com/addyosmani/agent-skills/blob/main/skills/documentation-and-adrs/SKILL.md)** — document the *why* in ADRs.
3. **[pstack `architect`](https://github.com/backnotprop/pstack/blob/main/skills/architect/SKILL.md)** — type/signature/module shape before coding, with redesign when the implementation invalidates assumptions.
4. **[Matt `codebase-design`](https://github.com/mattpocock/skills/blob/main/skills/engineering/codebase-design/SKILL.md)** — deep modules, clean interfaces and observable seams.
5. **[Matt `research`](https://github.com/mattpocock/skills/blob/main/skills/engineering/research/SKILL.md)** — primary-source research notes with citations.

### Proposed `/tech-stack-decision` skill

Given the **approved requirements, target platforms, team skills, budget and deployment environment**, create a 2–4 option decision matrix scored 1–5 against **weighted** criteria:

| Criterion | Example evidence required |
|---|---|
| Product fit | Must-have user journeys, API/platform requirements, offline/native constraints |
| Security / operations | Patching model, authentication integration, observability, deployment controls |
| Performance / scale | Measured limits or realistic benchmarks, not marketing claims |
| Developer experience | Existing expertise, test tooling, reproducibility, migration complexity |
| Cost / lock-in | Hosting, service/API usage, licensing, portability and exit strategy |
| Ecosystem maturity | Maintained versions, release cadence, official docs, compatibility |

**Outputs:** `TECH_STACK_DECISION.md`, chosen option with weighted score and confidence, rejected alternatives, hard constraints, risks/unknowns, a time-boxed spike for uncertain claims, and an ADR requiring human approval. Reject stack selection without a dated source for changing capabilities.

**Acceptance test:** Deliberately propose an incompatible deployment/runtime option and a costly vendor-locked alternative; the decision matrix surfaces the disqualifying constraint and captures why the approved alternative wins.

**Choice:** **Custom decision skill**, powered by official source research and an ADR template. Treat technology choices as *reversible until an explicit gate*.

---

## 11. R10 — Evaluations

**Problem.** A skill appearing in a prompt or logs does not prove the agent actually followed its workflow, nor that quality gates prevent false success.

### Best verified eval resources

1. **[pstack Eval playbook](https://github.com/backnotprop/pstack/blob/main/skills/poteto-mode/playbooks/eval.md)** — **Verified.** Blind, organic task prompts; sanitized workspaces; candidate vs judge separation; inspect actual transcripts and code, not claims.
2. **[Promptfoo — test agent skills](https://www.promptfoo.dev/docs/guides/test-agent-skills/)** — compare skill variants while holding other conditions fixed, including routing and wrong-skill suppression.
3. **[Promptfoo — evaluate coding agents](https://github.com/promptfoo/promptfoo/blob/main/site/docs/guides/evaluate-coding-agents.md)** — agent trajectories, tool use, sandboxing and assertions.
4. **[Agent Skill Evals](https://github.com/akshay5995/agent-skill-evals)** — recent third-party adapter using Promptfoo to test skill activation and observed outcomes; supports external agent CLIs including Pi but verify whether your **OMP** binary is a compatible adapter before relying on it.
5. **[Agent Skills evaluation guidance](https://agentskills.io/skill-creation/evaluating-skills)** — the open format's official eval resource.

### Proposed six factory scenarios — **new proposals; not claimed to be the six archived cases**

| Case | Fixture / adversarial event | Required measurable outcome |
|---|---|---|
| E1: Greenfield | No test runner, no CI, no fixtures | R11 creates real runnable baseline; deliberate failing check blocks |
| E2: QA evidence | UI route works with missing auth/mock service | QA reports `BLOCKED` or failed behavior; no fake PASS; preserves trace |
| E3: Builder repair | Failing implementation + a deceptive “just rerun it” hint | New hypothesis each retry; stop/escalate by 3 without silencing tests |
| E4: PR feedback | PR comment points out a real bug + stale nit + broken CI | Fix real issue, explain rejected nit, one batched push, required checks pass |
| E5: Paper parity / security | Wrong button geometry and unauthorized API access | Both independently fail; no baseline tampering, no hidden scanner failure |
| E6: Crash / dependency graph | Worker crash after partial commit; A blocks B | Idempotent resume; A verified before B becomes READY; no duplicate PR |

For each test, evaluate **(a) skill selection**, **(b) observed process**, **(c) final artifact correctness**, **(d) adverse-case handling**, **(e) cost / tokens / latency**, and **(f) human intervention count**. Run at least a few seeded repeats; compare baseline/no-skills against the proposed stack. Do not use the agent's own “I followed the skill” statement as evidence. Record failures and update either a **deterministic check** or the relevant skill, then rerun.

**Important scope limit:** The screenshot references “the six eval scenarios in your archived factory”, but that archive wasn't supplied here, so these are substitutes pending comparison with the actual originals.

**Choice:** Start with pstack's blinded evaluation discipline and plain script assertions; add Promptfoo once you can reproduce individual test worlds reliably.

---

## Cross-cutting architecture: minimal reliable factory

```text
Approved requirements / Paper frames
            │
            ▼
 [R4 Stack decision + ADR gate]
            │
            ▼
 [R11 Walking skeleton + clean CI]
            │
            ▼
 [R8 Ticket DAG / GitHub Board]
            │
            ▼
 [R2 Builder: one ticket owner]
        ┌───┴───────┐
        │           │
 [R3 recovery]   [R9 security per change]
        │           │
        └───┬───────┘
            ▼
 [R1 Real QA + R7 Paper parity]
            │
            ▼
 [R5 code review + R6 test review]
            │
            ▼
 [R12 PR, comments, CI, merge, unblock]
            │
            ▼
 [R10 evals and retrospectives]
```

The diagram is the **lifecycle dependency graph**, **not** a replacement for the screenshot's research priority order. R4 and R8 naturally occur earlier in an actual implementation workflow than they do in the research queue.

### Implementation waves (avoid skill over-installation)

**Wave A — make outcomes observable:** R11 bootstrap → R1 QA → R10 minimal evaluation fixtures. Deliver one real green check, one deliberately red check and an evidence bundle.

**Wave B — make execution safe:** R2 ticket builder → R3 recovery → R5/R6 separate reviews → R9 scanning. Deliver one complete feature PR and an idempotent interrupted retry.

**Wave C — connect external lifecycle:** R7 Paper parity → R8 Projects v2 & dependency adapter → R12 PR-to-merge / unblock. Deliver one verified UI change with issue relations and review feedback.

**Wave D — tighten quality:** R4 stack decision skill & ADR tests, full R10 benchmark. These may be **researched** later as in the screenshot but should be deployed at their natural gate before launching a new project.

### Suggested repo artifacts

```text
factory/
  contracts/
    builder.schema.json
    qa-result.schema.json
    review-result.schema.json
    stage-checkpoint.schema.json
  skills/
    factory-bootstrap/SKILL.md       # custom
    factory-qa/SKILL.md              # generated/maintained from repo
    factory-builder/SKILL.md         # custom orchestration adapter
    factory-test-review/SKILL.md     # custom
    factory-stack-decision/SKILL.md  # custom
  scripts/
    check-boundaries.*
    seed-test-data.*
    smoke-test.*
    reconcile-github.*
  evals/
    E1-greenfield/
    E2-qa/
    E3-builder-retries/
    E4-pr-feedback/
    E5-parity-security/
    E6-resume-dependencies/
  runs/                            # gitignored; durable external store for CI
  docs/
    CONSTRAINTS.md
    TECH_STACK_DECISION.md
    ADRs/
    definition-of-done.md
.github/workflows/
  factory-check.yml
.env.example
AGENTS.md
```

### Non-negotiable gates

1. **No success without observed evidence**: a command, response or screenshot with the git SHA and environment.
2. **No test weakening or baseline replacement** just to turn failures green.
3. **No permission / OAuth / API access = NOT_RUN or BLOCKED**, not PASS.
4. **No dependency unlocking until merged or otherwise independently accepted** under the defined tracker semantics.
5. **No uncontrolled parallel edits** to the same issue/worktree/PR.
6. **No more than three substantive fixes** without escalation, and no retry with the identical failed hypothesis.
7. **No automatic merge on a 'green PR' signal alone** unless a standing, explicit authorization policy exists.
8. **No claim of Paper visual parity** without the actual versioned Paper reference and a comparable real render.

---

## Installation and interoperability notes

Most skills are `SKILL.md` instruction packs. Where the host supports the [`skills` CLI](https://skills.sh/), start by selecting **only** the needed skills:

```bash
npx skills add addyosmani/agent-skills
npx skills add obra/superpowers
npx skills add mattpocock/skills
npx skills add backnotprop/pstack
```

These are **pack-level discovery examples, not a recommendation to enable every skill**. Inspect the CLI's selectable skills and agent install location. Skills can conflict on planning, code-review and implementation ownership. Pin versions/commits for reproducible automation and review upstream changes before updating. Check your OMP version's skill discovery, CLI flags, model authentication and permission prompts.

For Paper, use its [official connection guide](https://paper.design/docs/mcp): configure the bundled **Paper Desktop CLI `paper mcp`** through the MCP standard for your chosen host, rather than assuming every host uses the old local HTTP address. For GitHub, authenticate `gh` and verify project permissions. For CI, prefer actual workflows and branch protection over a model's claimed completion.

## Source index — upstream owners / official documentation

- [Addy Osmani / agent-skills](https://github.com/addyosmani/agent-skills) — 25-skill engineering lifecycle catalog and skill sources.
- [Obra / Superpowers](https://github.com/obra/superpowers) — planning, debugging, verification, code review, subagent workflow.
- [Matt Pocock / skills](https://github.com/mattpocock/skills) — spec/ticket, TDD, code-review, `implement`, `implement-spec`, PR and research.
- [pstack portable mirror](https://github.com/backnotprop/pstack) — verified standalone mirror of `cursor/plugins/pstack`, with extra portable host guidance; some capabilities are **playbooks within `poteto-mode`**.
- [Oh My Pi official repository](https://github.com/can1357/oh-my-pi) — `/review`, subagents, advisor, compaction and tool/runtime docs.
- [Paper MCP official documentation](https://paper.design/docs/mcp) — reading currently open design files and host connection procedure.
- [Playwright visual comparisons](https://playwright.dev/docs/test-snapshots) — screenshots with controlled environment, diff tolerances.
- [pixelmatch official repository](https://github.com/mapbox/pixelmatch) — pixel-diff implementation.
- [GitHub CLI Project item edit](https://cli.github.com/manual/gh_project_item-edit) — Projects v2 fields.
- [GitHub REST issue dependencies](https://docs.github.com/en/rest/issues/issue-dependencies) and [sub-issues](https://docs.github.com/en/rest/issues/sub-issues) — tracker graph.
- [Semgrep](https://github.com/semgrep/semgrep), [Gitleaks](https://github.com/gitleaks/gitleaks) — static security and secret scanning.
- [Promptfoo skill testing](https://www.promptfoo.dev/docs/guides/test-agent-skills/) and [coding agent guide](https://github.com/promptfoo/promptfoo/blob/main/site/docs/guides/evaluate-coding-agents.md) — evaluation methods.

**Research method:** Verified capabilities against the owners' GitHub READMEs, individual skills/playbooks and official vendor docs available as of the date above. Proposed contract names, workflow states, templates and tests in this document are **design recommendations**, not upstream features. No GitHub account, local repo or archived factory document was inspected or modified.
