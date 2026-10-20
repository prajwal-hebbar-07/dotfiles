# Software factory on Oh My Pi — built from skills

Design for rebuilding the factory as a set of skills, agents, one hook, and
one extension on Oh My Pi (omp). It draws on three skill repositories, the
research reports in `docs/research/` (requirements, grilling, architecture,
architecture grilling, design, design grilling, and the general round on
R1–R12; each checked against primary sources in §12), the skills already in
this repo, and omp's runtime. Nothing here is built yet. Research date:
2026-10-20.

Sources studied:

| Repo | What it is | Read at |
| --- | --- | --- |
| [cursor/plugins → `pstack`](https://github.com/cursor/plugins/blob/main/pstack/README.md) | One router skill (`poteto-mode`) with about 20 playbooks, plus review, verification, and orchestration skills. Cursor-first. | `main`, tree `88d4751` |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 25 lifecycle skills (Define → Plan → Build → Verify → Review → Ship), 4 reviewer personas, 9 slash commands, an eval harness. | `main`, plugin v0.6.13 |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Small composable skills: `grilling`, `to-spec`, `to-tickets`, `implement`, `tdd`, `code-review`, `pr`, `triage`. | `main`, commit `5beb35b` |

## 1. Your workflow, as read

How I read the request ("text tag" = tech stack):

| # | Stage | Who | Gate |
| --- | --- | --- | --- |
| 1 | Requirement gathering | you + agent | — |
| 2 | Grilling on requirements | agent asks, you answer | — |
| 3 | Requirements approval | you | Approve / No questionnaire |
| 4 | Tech stack: grill, then approve | you + agent | Approve / No questionnaire |
| 5 | Architecture: grill, then approve | you + agent | Approve / No questionnaire |
| 6 | Split into features → GitHub issues on a board; issue #0 sets up the project (§4.7) | agent | none (see §11, Q2) |
| 7 | Per issue: code, code review, QA, QA review, unit-test review, UI/UX, UI/UX review | agents only | internal verdicts |
| 8 | Ask you to raise the PR | you | Approve / No |
| 9 | You review and merge; the factory answers your PR comments and does the post-merge work (§5.7) | you + agent | GitHub |

The approval rule: every gate has two answers, **Approve** and **No**. After
**No**, the agent revises and shows the **whole** document again. You approve
or reject all of it again, not just the changed part. The loop ends only on
Approve.

```mermaid
flowchart TD
  R[1 Gather requirements] --> G1[2 Grill requirements]
  G1 --> A1{3 Approve REQUIREMENTS.md?}
  A1 -- No --> G1
  A1 -- Approve --> S[4 Tech stack: research + grill]
  S --> A2{Approve STACK.md?}
  A2 -- No --> S
  A2 -- Approve --> AR[5 Architecture: 2 candidates + grill]
  AR --> A3{Approve ARCHITECTURE.md?}
  A3 -- No --> AR
  A3 -- Approve --> SP[6 Split: whole app or feature by feature]
  SP --> GH[GitHub issues + sub-issues + blocked-by + board]
  GH --> LOOP[[7 Per-issue pipeline, autonomous]]
  LOOP --> A4{8 Raise PR?}
  A4 -- No --> LOOP
  A4 -- Approve --> PR[Agent opens PR]
  PR --> M[9 You review + merge]
```

## 2. What each repo contributes

No single repo covers the workflow. Each is strong in a different place.

| Need | pstack | addyosmani/agent-skills | mattpocock/skills |
| --- | --- | --- | --- |
| Requirements interview | none (`in-your-own-words`, `why` are close) | `interview-me` (one question at a time, guess + confidence), `idea-refine` ("Not Doing" list) | `grilling` (rounds of the decision-tree frontier, recommended answer per question) |
| Written spec | none | `spec-driven-development` (`SPEC.md`, Boundaries Always/Ask/Never, "STOP YOUR TURN") | `to-spec` (Problem, Solution, User Stories, Implementation/Testing Decisions, Out of Scope) |
| Approval gate | opt-in "with checkpoint" on `architect`; `ketchup` one decision per item | prose "wait for explicit yes" | "Do not act on it until the user confirms" |
| Tech-stack / architecture | `architect` (two structurally distinct candidates), `arena` (bake-off), `how`, `why` | `api-and-interface-design`, `documentation-and-adrs`, `constraint-driven-development` | `domain-modeling` (GLOSSARY.md + ADRs), `codebase-design` |
| Split into issues | `multi-phase-plan` playbook (plan only) | `planning-and-task-breakdown` (XS–XL sizing) | `to-tickets` (vertical tracer-bullet slices, blocking edges, GitHub sub-issues + native blocked-by) |
| Build loop | `feature` playbook, `autonomous-run` (exit predicate), `orchestrate` (ledger, frontier, gates) | `incremental-implementation`, `/build auto` (clean tree, commit per task) | `implement`, `implement-spec` (parallel worktrees → integration branch), `tdd` |
| Code review | `interrogate` (one reviewer per model, Act on / Consider / Noted / Dismissed) | `code-reviewer` persona (5 axes, Critical/Required/Optional/Nit, APPROVE / REQUEST CHANGES), `doubt-driven-development` (fresh-context reviewer, max 3 cycles) | `code-review` (Standards and Spec axes as parallel sub-agents) |
| Unit-test review | `principle-test-behavior-not-implementation` | `test-engineer` persona (Prove-It), "verify the verification" mutation check | `tdd` anti-patterns: implementation-coupled, tautological, horizontal |
| QA | `create-verification-skill` (per-app drive harness + feature map), `shipping` verifier (PASS / PASS+NOTES / FAIL) | `browser-testing-with-devtools`, `ci-cd-and-automation` gate order | — |
| UI/UX | `visual-parity` playbook | `frontend-ui-engineering` ("avoid the AI aesthetic", WCAG 2.1 AA), `web-performance-auditor` | `prototype` (UI variants behind a switcher) |
| PR | `opening-a-pr` (Why / What changed / Scope / Tradeoffs / Blast Radius / Verification), `blast-radius`, `babysit` | `/ship` (parallel fan-out, GO / NO-GO + rollback plan) | `pr` (Summary / Evidence / Merge Danger) |
| Orchestration | yes: `poteto-mode` router, `orchestrate`, `swarm` | no: "Personas do not invoke other personas" | light: `implement-spec`, `wayfinder` |

Gaps all three share, which the factory has to build:

- A **hard** approval loop. Every repo enforces approval with prose ("STOP",
  "wait for yes"). None stores an approval or blocks later work without one.
- A **"No" loop that re-reviews the whole document.** None has it.
- **Tech-stack selection** as its own stage. Only pstack's `arena` and the
  `investigation` playbook come close.
- A pipeline that runs **unattended per issue**, does not merge, and stops to
  ask you before opening the PR. pstack's `autopilot-full` and `shipping` merge
  on their own. `benny` opens draft PRs without asking.

## 3. How the skills are written

| Convention | pstack | addyosmani | mattpocock | This repo today |
| --- | --- | --- | --- | --- |
| Frontmatter | `name`, `description`, `disable-model-invocation`, `paths`, `icon` | `name`, `description` only (≤1024 chars) | `name`, `description`, `disable-model-invocation`, `argument-hint` | `name`, folded `description`, `argument-hint`, `disable-model-invocation` |
| Length | skills 30–150 lines; playbooks 20–60 | SKILL.md < 500 lines; split a section into a file past ~100 lines | most < 150; delegators 1–20 lines | 100–425 lines |
| Layout | `references/`, `scripts/`, `playbooks/`, `templates/` | per-skill files + repo-level `references/` | sidecar `.md` files next to SKILL.md | `template.md`, `scripts/` |
| Chaining | router reads playbooks; skills linked by path | none between skills; via commands/router | body is "Call the Skill tool with X" | names the next skill in prose |
| Gates | few named human gates; reversible work proceeds | "STOP YOUR TURN IMMEDIATELY" | "Do not act until the user confirms" | stops for review / commit |
| Verdicts | fixed vocabularies per skill | severity labels + APPROVE / REQUEST CHANGES | Standards vs Spec, side by side | — |
| Tone | terse, no em dash, no mid-sentence colon | imperative + "Rationalizations" and "Red Flags" tables | short imperatives, XML-ish blocks (`<vertical-slice-rules>`) | imperative, explicit non-goals |

Conventions to adopt for the factory skills:

1. **One primitive per job, written once.** `grilling` and the approval gate
   are primitives. Stage skills call them; they do not copy their text
   (mattpocock).
2. **The description is the router.** addyosmani's evals found that
   description wording decides whether a skill fires. For the factory, routing
   should not depend on that. Mark stage skills
   `disable-model-invocation: true` and have the orchestrator `read`
   `skill://factory-<stage>` directly. omp still resolves hidden skills through
   `skill://` (omp `skills.md`, "hide does not disable the skill").
3. **Fixed verdict vocabulary per reviewer** (pstack, addyosmani), so the
   orchestrator can parse results without judgment.
4. **Templates in sidecar files, procedure in SKILL.md** (all three).
5. **Facts come from sub-agents, decisions from you** (`grilling`).

## 4. Stage by stage

Each stage lists what to borrow, the omp mechanism, its artifact, and its exit
condition. All artifacts live in the target repo under `docs/factory/` and are
committed through the existing `commit` skill after each approval. Run state
lives in `.factory/`.

### 4.1 Requirement gathering (stage 1) — `factory-requirements`

- **Base: `interview-me`, unchanged.** Write a one-line hypothesis with a
  confidence number. Ask one question at a time, each with a guess attached.
  Restate the result as Outcome / User / Why now / Success / Constraint / Out
  of scope, and get an explicit yes. Stop when the next three answers can be
  predicted. This already covers what the requirements research recommends
  for gathering (one question at a time, playback, a stop rule), so nothing
  else is layered on (§12).
- **Existing repo:** one `scout` maps the codebase before the first question,
  so you are never asked something the repo already answers.
- **Two additions, each needed by a later stage:**
  1. Ask which tech choices you want to make yourself and which you leave to
     the factory (superpowers `brainstorming`, "How it gets made"). The stack
     stage (§4.4) then grills you only on the ones you kept.
  2. Number the requirements (`R1`, `R2`, …) and write each one's acceptance
     criteria as Given / When / Then (spec-kit `spec-template.md`). Issues cite
     these numbers (§4.6), and QA writes its scenarios from them (§5.2).
     Without them, the unattended half has nothing concrete to check against.
- **Artifact:** `docs/factory/REQUIREMENTS.md`, using the `to-spec` sections:
  Problem, Solution, User Stories, numbered Requirements with Given / When /
  Then, Non-functional requirements, Out of Scope, Tech choices (yours vs the
  factory's), and Open Questions. Add addyosmani's Boundaries block (Always /
  Ask first / Never).
- **Exit:** the draft exists. Grilling starts at once.

### 4.2 Grilling (stage 2, reused in 4 and 5)

- **Borrow `grilling` from mattpocock almost verbatim.** Work the design tree
  in rounds. Each round asks the whole frontier: every decision whose
  prerequisites are settled. Number the questions and attach a recommended
  answer to each:

  ```
  ❓ **Q1** - **<title>**: <question>
  ➡️ <recommended answer>
  ```

  Word each question so "yes" accepts the recommendation. Sub-agents find
  facts; decisions go to you.
- **Add from `interview-me`:** "whatever you think" and "sounds good" are not
  answers. Re-ask with two concrete options.
- **Different cadence from gathering, on purpose.** Gathering asks one
  question at a time because it is looking for what you have not said yet.
  Grilling asks in rounds because it settles decisions that are already known.
- **Grill in chat, not in `ask`.** mattpocock keeps grilling out of structured
  pickers on purpose ("Structured pickers push the model towards
  multiple-choice questions with pre-baked answers",
  [`.out-of-scope/native-question-tool.md`](https://raw.githubusercontent.com/mattpocock/skills/main/.out-of-scope/native-question-tool.md)).
  The `ask` picker is kept for the approval questionnaire, where a fixed set
  of answers is the point.
- **Last round on requirements: a pre-mortem.** When the frontier is empty,
  the factory runs one more round of the same format, opening with "It is
  three months after launch and this has failed, or corrupted someone's data.
  What went wrong?" It then proposes the likely causes from R1…Rn: a failure
  path with no acceptance criterion, an abuse case, a permission gap, a
  partial failure in an integration. Each answer becomes a new requirement, a
  non-goal, or an accepted risk. `grilling` walks decisions forward, and the
  builder check (§4.3) only asks about what is written, so nothing else looks
  for failure from the outcome backwards. (addyosmani `idea-refine`
  `frameworks.md` "Pre-mortem"; BMAD `methods.csv` "Pre-mortem Analysis".)
  This round runs only at the requirements stage, because architecture already
  gets the two-model review in §4.5.
- **Exit:** the frontier is empty, the pre-mortem round has been answered (at
  the requirements stage), and every answer is folded into the document.

### 4.3 The approval gate (stages 3, 4, 5, 8) — `factory-gate`

None of the three repos has this. It is the core primitive to build.

**Builder check before you see the document** (requirements and stack
gates). Once the code stage starts, no human reads anything until the PR, so
each gap left in the document becomes a guess by an agent. One read-only
agent, `factory-builder-check` on `@review` (a different model from the
author), runs superpowers'
[`builder-check-prompt.md`](https://raw.githubusercontent.com/obra/superpowers/main/skills/brainstorming/builder-check-prompt.md)
word for word. It plays the engineer who has to build from the document
without talking to you, and it returns only ranked questions, or "nothing
important left". The author sorts each question into one of three piles:

- **Answered already:** the answer is written into the document.
- **Minor:** the factory decides and marks it "factory's call".
- **Yours:** only you can answer it. These questions become one grilling round.

The architecture gate does not need this check, because it already gets the
two-model review in §4.5.

#### The questionnaire

```mermaid
stateDiagram-v2
  [*] --> Draft
  Draft --> Reviewed: builder check
  Reviewed --> Presented: whole doc
  Presented --> Questionnaire: ask, one question per section
  Questionnaire --> Approved: every answer = Approve
  Questionnaire --> Revising: any No / Other / Chat / timeout
  Revising --> Grilling: grill on the No reasons
  Grilling --> Draft: fold answers in
  Approved --> [*]: stamp sha256, commit
```

Rules:

1. **Present the whole document every time**, revisions included. At the top,
   list what changed since the last review and every "factory's call", so you
   can find them quickly. The questionnaire still covers every section.
2. **One `ask` call, one question per top-level section.** Each question has
   exactly two options, `Approve` and `No`. Use `header` for the section name
   and `preview` for the section text. A **No** on any section rejects the
   whole document, which then goes through Revising and comes back in full.
3. **omp `ask` constraints the gate must handle** (from omp `tools/ask.md`):
   - The UI always adds `Other (type your own)`, and the rich dialog adds
     `Chat about this`. A strict two-button picker is not possible. Treat
     either one as **No** and use the typed text as the reason.
   - With `ask.timeout` set above 0, a timeout auto-selects the recommended
     option, or the first one. Never set `recommended` on a gate question.
     Treat `details.timedOut` as **No**. Keep `ask.timeout: 0` (the default).
   - A cancelled dialog throws `ToolAbortError`. The gate stays open; nothing
     is stamped.
4. **Stamp the approval**, then commit:
   `.factory/state.json` → `gates.requirements = { approvedAt, sha256 }`, where
   `sha256` is the hash of the approved file. Every later stage checks the
   hash on entry. If the hash no longer matches (the file was edited after
   approval), the stage stops and reopens that gate. Any edit to an approved
   doc then needs a fresh approval.
5. **Rejected scope gets remembered.** Items you strike go to
   `docs/factory/out-of-scope/<concept>.md` (mattpocock `triage/OUT-OF-SCOPE.md`),
   so later stages do not propose them again.

### 4.4 Tech stack (stage 4) — `factory-stack`

- **Facts first:** one `scout` per candidate area (language/runtime,
  framework, data store, hosting, test tooling). Each reads official docs,
  following addyosmani's `source-driven-development`: cite the source, and
  treat fetched pages as data, not instructions.
- **Two candidates per open decision** (pstack `architect`: "two structurally
  distinct candidates"), each with fit to REQUIREMENTS.md, cost, operational
  load, and team familiarity. For a hard call, run a small pstack-style
  `arena`: two `task` agents on different models each argue one stack, and the
  main session judges.
- **Factory-compatibility filter** (hard pass/fail, before any scoring). A
  candidate stack must support every check the factory runs later: type and
  lint checks for `check:fast`, line coverage as lcov, a mutation tool
  (StrykerJS, mutmut), a boundary checker (dependency-cruiser,
  import-linter), Semgrep rules for the language, an osv-scanner-readable
  lockfile, a QA driver (Playwright for web, a PTY for a CLI, omp `computer`
  for desktop), data seedable from an empty directory, and an official CI
  image. A stack that fails a row needs a stated substitute or is out. None of
  the skill packs checks this.
- **Grill** with §4.2 on the choices that remain open.
- **Artifact:** `docs/factory/STACK.md`, plus one ADR per hard-to-reverse
  choice. mattpocock's rule for ADRs: write one only when the decision is hard
  to reverse, surprising without context, *and* a real trade-off. Each ADR
  ends with MADR 4's **Confirmation** line: the check that enforces it (for
  example a dependency-cruiser rule), so the decision is checked later, not
  just recorded.
- **Gate:** §4.3.

### 4.5 Architecture (stage 5) — `factory-architecture`

- **Two candidates** (pstack `architect`), then an **adversarial review before
  you see it** (pstack `interrogate`): two read-only reviewers on different
  models. In this config, `@review` (GPT-6.1 Sol) and the default (Opus 5.5).
  Their findings are sorted into Act on / Consider / Noted / Dismissed. The
  author fixes "Act on" items before the doc reaches you, and the gate shows
  the "Consider" items as known trade-offs.
- **Vocabulary:** `GLOSSARY.md` per mattpocock `domain-modeling`. Later agents
  then use the same names for things.
- **Quality floor:** `CONSTRAINTS.md` per addyosmani
  `constraint-driven-development` (CDD). It holds:
  - a **Floor** that is always on: no new suppressions (`@ts-ignore`,
    `eslint-disable`, `# noqa`), no stubs or empty `catch {}`, no skipped or
    deleted tests without a reason, no secrets, and the file itself never
    weakened;
  - numbered dimensions, each naming the command that produces its verdict:
    lint, types, changed-line coverage (default ≥ 80%), mutation score
    (default ≥ 60% to start), bundle budget, accessibility level, secret
    scan (gitleaks over the branch's commits), new Semgrep findings
    (`--baseline-commit` at the merge base), a dependency audit (osv-scanner
    when a lockfile changes), and the allowed dependencies between
    ARCHITECTURE.md's modules (dependency-cruiser or import-linter);
  - **ratchets**: where no target number exists, today's value must not fall;
  - three scripts that mirror it: `check:fast` after each edit, `check:task`
    when the builder thinks it is done, `check:full` in CI and before the PR
    ask (§5.4).

  CDD's own interview is four questions and it says not to run it in CI or
  autonomous runs, so those four questions go into this stage's grilling
  round. Agents working issue by issue then cannot slowly break the module
  structure or the quality bar you approved.
- **Threat model,** as a section of ARCHITECTURE.md rather than a skill
  (magnus919 `secure-software-engineering`,
  `templates/lightweight-threat-model.md`). It has five parts:
  - assets;
  - actors with the authority each needs and the authority each is denied;
  - data flows, marking where trust changes;
  - assumptions to test;
  - abuse cases, each with its mitigation and **verification**.

  The requirements pre-mortem (§4.2) says *what* must not happen. This
  section says *where* it is stopped. Each verification becomes a test the
  code reviewers expect. Without it, "security boundaries" is a heading no
  agent can check.
- **UI direction** (if there is a UI): run the existing `paper-design-prompt`
  skill so the design system is approved here, not invented per issue.
- **Diagrams:** the existing `arc-design` skill (archify) for the overview and
  one diagram per module.
- **Artifact:** `docs/factory/ARCHITECTURE.md` (modules, interfaces, data
  model, seams for tests, error handling, threat model), plus ADRs.
- **Gate:** §4.3.

### 4.6 Feature split and GitHub issues (stage 6) — `factory-issues`

**Mode.** Take it from your prompt ("build it all", "feature by feature").
If you do not say, pick one by this rule and state the choice:

| Mode | Use when | Branching | PRs |
| --- | --- | --- | --- |
| Whole app | new repo, or slices tightly coupled | one integration branch `factory/<epic>`; each issue in its own worktree, merged into it after passing §6 | one PR for the epic (or one per frontier wave) |
| Feature by feature | existing app, slices independent | one branch per issue off `main` | one PR per issue; an issue whose blocker is unmerged waits, or stacks on the blocker's branch |

**Slicing** (mattpocock `to-tickets`, verbatim rules): each slice is a narrow
but complete path through every layer, can be demoed or verified on its own,
and fits one fresh context window. Prefactoring goes first. A wide mechanical
refactor goes expand → migrate in batches → contract. Test each ticket with
"what can I demo when this is done?". A ticket without an answer is a
horizontal slice.

**Issue body** (mattpocock `triage/AGENT-BRIEF.md` + pstack `orchestrate`
brief):

- Parent.
- Requirements covered (`R3`, `R7`).
- What to build: behaviour, not files.
- Acceptance criteria, copied from those requirements' Given / When / Then.
  Each one can be checked on its own and names the observation that would
  prove it false.
- Out of scope, Blocked by, and UI: yes/no.
- Links to the approved docs at their approved sha.

Before publishing, every requirement must appear in at least one issue. A
requirement with no issue blocks publishing.

**Publishing** (mattpocock `issue-tracker-github.md` seed):

- One script, `skills/factory-issues/scripts/board`, wraps every issue and board write, so no
  agent writes `gh` calls by hand. Your `gh` is 2.102.0; the native flags
  arrived in 2.94.0, so the script uses them and keeps the REST call as the
  fallback for older versions:
  - parent: `gh issue edit <parent> --add-sub-issue <child>` (REST
    `POST …/issues/<n>/sub_issues` with `sub_issue_id`);
  - dependencies: `gh issue edit <n> --add-blocked-by <blocker>` (REST
    `POST …/issues/<n>/dependencies/blocked_by` with `issue_id`, the numeric
    id from `gh api repos/<o>/<r>/issues/<n> --jq .id`, not the `#number`).
- Publish in dependency order, blockers first.
- Board: `gh project item-add` into one Project (needs the `project` scope:
  `gh auth refresh -s project`). `gh project item-edit` takes ids, not names,
  and one field per call, so `board` caches the project, field, and option ids
  in `.factory/board.json`. The board is a view. Which issue may start is
  computed from the dependency graph (`board frontier`: open issues whose
  blockers are all closed), not read from the board. Use one status label per
  pipeline state: `factory:queued`, `factory:building`, `factory:review`,
  `factory:qa`, `factory:ui`, `factory:pr-ready`, `factory:needs-human`.
- Prefix every comment the factory posts with
  `> Generated by the factory.` (mattpocock's triage disclaimer rule).

omp's `github` tool covers search, PR create/checkout/push, and run watching,
but not issue creation or Projects. Issues go through `gh` in `bash`.

### 4.7 Project bootstrap (issue #0) — `factory-bootstrap`

Every later issue assumes CI, the check scripts, a test harness, seed data,
and a way to start the app. Nothing else creates them, so `factory-issues`
always publishes **issue #0 first** and makes every other issue blocked by it
(mattpocock `to-tickets`: "any prefactoring is done first"). It is built
through the normal §5 pipeline, with the full review and the PR ask.

On a new repo it is a **walking skeleton** (Cockburn): one trivial feature
cut through every layer (one screen → one API call → one stored row), plus:

| Deliverable | Proof |
| --- | --- |
| `CONSTRAINTS.md` and `check:fast` / `check:task` / `check:full` (§4.5) | each exits 0 on the skeleton |
| CDD floor guard (`references/floor-guard.md`): diff-scoped, exit 0 clean / 1 violation / 2 could not run | exits 1 on a planted `.skip` |
| Boundary checker with the ARCHITECTURE.md module rules | fails on a planted illegal import |
| CI on `pull_request` and on `push` to `main` and `factory/**`, `fetch-depth: 0` | green run on the `factory/*` push |
| Unit runner with lcov; E2E runner with one test over the skeleton | green in CI |
| Idempotent `seed` that works from an empty data directory | running it twice gives the same state |
| `.env.example` (fake values, one comment per variable), `.env` git-ignored | gitleaks clean |
| `launch` and a read-only `doctor` (process, port, version, data reachable) | doctor green after launch |
| `verify-<app>` skill made by pstack `create-verification-skill` (§5.2 QA) | its own end-to-end run |
| Branch protection on `main` with the required checks | `gh api …/branches/main/protection` |

The last step plants one fault per gate (a `.skip`, an `eslint-disable`, an
illegal import, a fake secret) and confirms each check goes red, then removes
them. A check that does not fail on a planted fault is not a gate.

On an existing repo, the stage detects what is there first (CDD step 1) and
issue #0 adds only what is missing. Coverage and mutation targets start as
ratchets at today's values.

### 4.8 Requirement changes after issues exist

You can change a requirement at any time ("Change of plan: deleting a task
should archive it"). The factory then:

1. Stops building, edits REQUIREMENTS.md, and reopens its gate (§4.3). The
   gate's "what changed" header lists each added, changed, or removed `R`
   number **and every issue and PR that cites it**, with what will happen to
   each. Approving the document approves that list.
2. Reopens STACK.md or ARCHITECTURE.md only if the change touches them
   (archived eval 05: "not Gate 2, which the change doesn't touch").
3. After approval, updates the work that cites a changed `R`:

   | Issue state | What happens |
   | --- | --- |
   | Not started | issue body rewritten: acceptance criteria re-copied from the new Given / When / Then, doc links moved to the new approved sha, a comment says what changed |
   | In progress | builder stopped; issue rewritten as above and set back to `factory:queued`; the branch is kept and its verdicts no longer count |
   | PR open | the change goes to the builder as an "Act on" item on the same branch (§5.7), then every invalidated review runs again and you are asked "Raise PR?" again |
   | Merged | a new follow-up issue citing the changed `R` and the merged issue |

   A removed `R` closes the issues that covered only it ("not planned"). An
   added `R` gets new issues through the same slicing and coverage check as
   §4.6. `factory-qa-author` rewrites the holdout scenarios for every changed
   `R`.

## 5. Per-issue pipeline (stage 7) — `factory-build`

### 5.1 Order

Your list, with three changes and the reasons for each:

1. **UI/UX design moves before code** for issues marked UI: yes. Designing
   after the code is written means rework. Your "UI/UX review" becomes two
   checks:
   - **Design review**, right after the Paper screens are drawn and before
     code. It checks whether the design is usable.
   - **UI review**, after QA. It checks whether the code matches the design.

   UI review alone would pass a bad design built faithfully, and once code
   starts nobody else looks at the screens.
2. **Code review and unit-test review run in parallel.** Both are read-only on
   the same diff (addyosmani `/ship` fan-out).
3. **Every verdict is pinned to a patch** (pstack `shipping`): "Compare `git
   patch-id` at the verdict SHA with the current head before trusting an
   older verdict." A rebase that leaves the patch unchanged keeps the
   verdicts; any other change re-runs every reviewer it invalidated.

```mermaid
flowchart LR
  P[Plan + QA scenarios] --> D{UI issue?}
  D -- yes --> UX[UI/UX design in Paper]
  D -- no --> C
  UX --> DR{Design review}
  DR -- fail, ≤3 cycles --> UX
  DR -- pass --> C[Code + unit tests]
  C --> CR[Code review A+B]
  C --> TR[Unit-test review]
  CR --> J1{both pass?}
  TR --> J1
  J1 -- no, ≤3 cycles --> C
  J1 -- yes --> SEC{Security scan, trust-boundary issues only}
  SEC -- fail --> C
  SEC -- pass or skipped --> QA[QA: drive the app]
  QA --> QR[QA review]
  QR -- fail --> C
  QR -- pass --> UR{UI issue?}
  UR -- yes --> UXR[UI/UX review]
  UR -- no --> GO
  UXR -- fail --> C
  UXR -- pass --> GO[Pre-PR GO / NO-GO]
  GO --> ASK{Raise PR?}
```

### 5.2 Agents

omp custom agents live in `~/.omp/agent/agents/*.md` (user) or
`.omp/agents/*.md` (project). They pick models through role aliases, so model
changes stay in `config.yml`.

| Agent | Model role | Tools | Reads | Verdict | Borrowed from |
| --- | --- | --- | --- | --- | --- |
| `factory-planner` | `@plan` | read-only | issue + approved docs | plan (≤5 commits) + seams; lists the threat-model boundaries the issue touches (`sec:boundary` label) and, for UI issues, the `data-paper-id` each element carries | this repo's `implementation-plan` (window idea), mattpocock `tdd` (seams agreed first) |
| `factory-qa-author` | `@slow` | read, write `~/.omp/factory/<repo>/holdout/` | issue + REQUIREMENTS only | one scenario per Given / When / Then of the requirements the issue covers | your archived factory's holdout QA |
| `factory-designer` | `@default` | Paper MCP | `paper-design-prompt.md` (from §4.5) + issue | Paper screens for this issue only | this repo's `paper-design` |
| `factory-design-review` | `@vision` | read-only, Paper read tools (`get_screenshot`, `get_jsx`) | the issue's Paper screens + `paper-design-prompt.md` + CONSTRAINTS a11y | score out of 10; FAIL on any finding of severity 3–4 (major or catastrophic) | wondelai `ux-heuristics`: Nielsen + Krug, 10-question diagnostic, severity 0–4, start at 10 and subtract per failed row. Also checks the brief's own practices (one primary action, empty / loading / error states, readable contrast). Keyboard, focus, and screen-reader behaviour go to `factory-ui-review` on the running app, because a static screen cannot show them |
| `factory-builder` | `@task`; attempt 3 on `@default` (§5.3) | full | plan, issue, docs (never holdout) | commits + a status: DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED. NEEDS_CONTEXT and BLOCKED come back as a questionnaire (§5.5) | superpowers `subagent-driven-development` (status contract) and `systematic-debugging`, addyosmani `incremental-implementation`, mattpocock `implement`/`tdd`, this repo's `commit` |
| `factory-builder-unstick` | `@task`, with `advisor: "openai-codex/gpt-6.1-sol:high"` | full | same as builder | same | the same prompt as `factory-builder` plus an omp advisor from another model family, used only on attempt 2 (§5.3). omp attaches advisors per agent definition, so this is a second agent file |
| `reviewer` (omp bundled) | `@review` (already set in `task.agentModelOverrides`) | read-only bash | the diff | `overall_correctness` + findings P0–P3 with confidence and file:line, each overlapping the diff | omp's own agent. It also traces every new value that crosses a module boundary to its consumer. Replaces a custom correctness reviewer |
| `factory-spec-review` | `@default` | read-only | diff + issue + ARCHITECTURE + CONSTRAINTS + builder's rulings | APPROVE / REQUEST CHANGES, items labelled Critical / Required / Optional / Nit, plus a "Declined to judge" list | superpowers `requesting-code-review` reviewer template (plan alignment), mattpocock `code-review` (Spec axis), addyosmani `code-review-and-quality` |
| `factory-test-review` | `@review` | read-only (+ run tests) | diff + tests + coverage of changed lines | PASS / FAIL + findings | Deterministic first: (1) floor guard on the diff; (2) every acceptance criterion maps to a test that ran; (3) mutation on the changed files only (StrykerJS `--incremental --force --mutate <files>`, mutmut per changed module) against the CONSTRAINTS threshold, each surviving mutant a finding; with no mutation tool, invert one condition per new branch and rerun (addyosmani). Then judgment: mattpocock `tdd` anti-patterns and testsmells.org smells |
| `factory-qa` | `@task` | bash, eval (omp's `browser` is an eval facade, not a tool) | holdout scenarios + the repo's `verify-<app>` skill + running app | per-scenario PASS / FAIL / BLOCKED with an evidence bundle (below) | pstack `create-verification-skill`, superpowers `verification-before-completion`, addyosmani `browser-testing-with-devtools` |
| `factory-qa-review` | `@review` | read-only | QA evidence + acceptance criteria | PASS / PASS+NOTES / FAIL; FAIL when a covered requirement has no test or runtime evidence | pstack `shipping` verifier ("Green CI and an approving bot review are not verdicts"), `blast-radius` |
| `factory-ui-review` | `@vision` | read, eval (`browser`), Paper | the procedure below | PASS / FAIL | pstack `visual-parity`, addyosmani `frontend-ui-engineering` |
| security scan (main session) | — | omp `security_scan`; fallback the bundled `security-reviewer` agent | issues labelled `sec:boundary` | PASS / PASS+NOTES / FAIL | omp `security_scan` with `target_kind: ref_diff` and the threat model in `knowledge_base_paths`; addyosmani `security-and-hardening` |

**QA, in more detail.** Issue #0 generates the repo's `verify-<app>` skill
(pstack `create-verification-skill`): launch from an empty data directory,
doctor, drive, evidence, cleanup, and a feature map. `factory-qa` follows it:

- it starts its own instance (own port and data directory) and never drives
  one it did not start;
- it never holds production credentials. Outside services use the vendor's
  sandbox keys, else a fake behind the same base URL, else record and replay
  (omp `browser` `harStart` / `route`). omp `secrets.enabled` redacts the keys
  in the session;
- evidence goes to `qa-evidence/<issue>/<sha>/`: an action log, a screenshot
  and ARIA snapshot per key state, console errors (must be empty), network
  traffic for side effects, and a read-only check of the stored data, so a
  "Saved" toast over an unwritten row fails;
- a missing prerequisite (no credentials, a service down) is **BLOCKED**,
  never PASS. BLOCKED goes to the questionnaire (§5.5).

**UI review, in more detail** (the first build of a screen):

1. Same size on both sides: the artboard's width and height from Paper
   `get_node_info` become the browser viewport. The Paper image comes from
   `export` (`scale: "2x"`, a file), not `get_screenshot`, whose images are
   capped in size. The app is captured at scale 2, fonts loaded, animations
   off, the same copy seeded.
2. **Style diff (deterministic, blocking).** The builder puts
   `data-paper-id="<nodeId>"` on each implemented element. For each pair,
   compare Paper `get_computed_styles` with the browser's computed styles:
   font, colour, spacing (±1 px), radius, and size (±2 px).
3. **Pixel diff (locating).** pixelmatch with `windowSize`, which reports
   compact regressions and ignores scattered anti-aliasing, plus an
   `ignoreMask` for live content.
4. **Vision judge (classifying).** The `@vision` model labels each hot region
   match / renderer noise / defect and cannot pass a screen that has a
   blocking style-diff row.
5. Repeat per state Paper has an artboard for (empty, loading, error,
   narrow width). Keyboard and focus are checked in the running app (§12).

The main session synthesises the two code reviews (Act on / Consider / Noted
/ Dismissed). Only "Act on" items go back to the builder.

Agent file sketch:

```md
---
name: factory-spec-review
description: Read-only spec reviewer for one factory issue. Returns a fixed verdict.
model: "@default"
tools: read, grep, glob, bash
autoloadSkills: factory-review
structured: true
---
Review the diff named in the task against the issue, ARCHITECTURE.md and
CONSTRAINTS.md. Never edit files. End with `Verdict: APPROVE` or
`Verdict: REQUEST CHANGES`, every finding labelled Critical / Required /
Optional / Nit with file:line evidence, then a "Declined to judge" list.
```

`autoloadSkills` injects named skills into the sub-agent before its first
prompt. That fixes a failure mattpocock documents: a skill that only *names*
another skill does not reliably load it
([grilling docs](https://raw.githubusercontent.com/mattpocock/skills/main/docs/productivity/grilling.md)).

### 5.3 Loop rules

- **Exit predicate first** (pstack `autonomous-run`): the issue's acceptance
  criteria + CONSTRAINTS checks + all verdicts PASS at the head SHA. "Never
  relax the predicate to declare victory."
- **Three attempts per failure, each one different** (superpowers
  `systematic-debugging`: "If ≥ 3: STOP and question the architecture").
  An attempt is one written fix hypothesis, applied and checked against a
  failing test, counted per failure (test id + error class). A rerun without
  a change is not an attempt.
  1. The builder, after reproducing the failure in isolation.
  2. `factory-builder-unstick`: an advisor on another model family watches
     the transcript and names the most likely wrong assumption.
  3. A fresh builder one model tier up (`@default`), given the evidence from
     attempts 1–2 but not their transcript (superpowers
     `subagent-driven-development`, rounds 4–5).

  There is no fourth attempt. The builder writes what it tried and the
  suspected design cause, the issue gets `factory:needs-human`, and the
  factory moves to the next unblocked issue. The ladder starts early when the
  same failure repeats, when the diff grows while failures do not drop, or
  when the builder proposes editing a test, a threshold, or CONSTRAINTS.md
  (the floor guard fires).
- **Missing requirement stops the issue.** It is not guessed (addyosmani
  `context-engineering`: emit a `MISSING REQUIREMENT` block). Requirements are
  your gate, so this reopens §4.3 for REQUIREMENTS.md rather than letting a
  builder decide.
- **Ledger:** `.factory/ledger.tsv`, one row per event: `ts, issue, stage,
  step, event (start / done / verdict), agent, model, sha, result, evidence`.
  A step writes `start` before acting and `done` only after its own check
  passes, so a `start` with no `done` marks interrupted work (§5.6). This is
  pstack `show-me-your-work` and `orchestrate`'s `ledger.tsv`, and the
  superpowers ledger. It is also the PR's Verification section.
- **Parallelism:** issues on the frontier (all blockers done) run at once,
  each sub-agent with `isolated: true`. That needs `task.isolation.enabled`
  and branch merge mode (`task.isolation.merge`), which commits to
  `omp/task/<id>` and cherry-picks back. Alternatively the builder makes its
  own `git worktree`. Start sequential; turn on parallel issues once one issue
  runs clean end to end.
- **Depth:** omp's `task.maxRecursionDepth` defaults to 2. Keep the main
  session as the only orchestrator, with every role agent at depth 1. Then
  reviewers can still spawn scouts, and no issue-runner layer is needed.
- **Budget per issue.** omp already caps each helper agent: a soft budget of
  200 model requests (`task.softRequestBudget`), then a forced stop at 1.5×.
  On top of that, the factory caps each issue at a wall-clock time and a
  number of helper-agent runs (Q7, §11). Whichever runs out first ends the
  issue the same way as a fourth attempt: `factory:needs-human`, a ledger
  summary of what was spent and why, and the factory moves on or stops. omp
  shows recorded cost but has no money cap, so time and runs are the
  enforceable limits. To keep part of your subscription quota for your own
  work, set `retry.usageAwareFallback: true` with a reserve
  (`retry.usageReservePct`, default 10%).

### 5.4 Pre-PR gate and the PR (stage 8)

- **GO / NO-GO** (addyosmani `/ship`), in this order:
  1. Every verdict covers the head's patch (§5.1), and no
     `factory:needs-human` label is set.
  2. The project's full local checks pass (`check:full` from CONSTRAINTS.md).
  3. The branch is pushed to `factory/<issue>-<slug>`, with no PR, by a plain
     `git push` (`github` `pr_push` only works on branches made by
     `pr_checkout`). The hook allows this push (§7).
  4. GitHub CI runs on that push and the `github` tool's `run_watch` reports
     it green. Issue #0 (§4.7) sets CI to run on pushes to `factory/**`. CI
     runs again when the PR opens.
- **PR body:** pstack `opening-a-pr` sections (Why · What changed · Scope ·
  Tradeoffs · Blast Radius · Verification) plus mattpocock `pr`'s Merge Danger
  (one-way vs two-way door). Verification is built from the ledger plus the CI
  run link, and links the QA and UI evidence (`qa-evidence/<issue>/<sha>/`).
  A **Manual check** section follows: the QA journeys rewritten as short
  steps for you (how to start the app, what to click, what you should see),
  because the factory's browser testing comes first and your own pass comes
  after it. The body ends `Closes #<issue>`.
- **Ask:** §4.3 with one question, "Raise PR for #N?", showing the PR body as
  the preview. **Approve** → `github` `pr_create` from the already-pushed
  `factory/*` branch (ready, not draft). Labels `factory:pr-ready` → closed
  when you merge. **No** → your reason goes back into the loop as an "Act on"
  item.
- The factory never merges, never pushes outside `factory/*`, and never opens
  a PR before this approval. A hook enforces it (§7).

### 5.5 Questionnaires from helper agents

Helper agents run headless and cannot call `ask` (`omp://tools/ask.md`,
`omp://approval-mode.md`). Any of them can still raise questions:

- **The agent returns a questionnaire instead of guessing.** Every factory
  agent's structured output may include `questions`, in the same shape the
  `ask` tool takes: `id`, `question`, two to five `options` with
  `label`/`description`, and an optional `recommended`. It then stops.
  Typical triggers are a `MISSING REQUIREMENT` (§5.3), two readings of an
  acceptance criterion, or a design choice the brief does not settle.
- **The main session handles it.** First it answers from the approved docs
  (REQUIREMENTS, STACK, ARCHITECTURE, CONSTRAINTS, ADRs). An answer found
  there is recorded in the ledger as "factory's call" with its source.
  Anything else goes to you through `ask`, unchanged. An answer that changes
  an approved doc reopens that doc's gate (§4.3).
- **The answer goes back to the same agent** with `write agent://<id>`. omp
  revives a parked agent, so the agent continues with its context intact.
- Approval-tier tools (`git push`, `github` `pr_create`) also stay in the main
  session. A helper that needs one returns the request, as it would a
  question.

### 5.6 Stops between sessions

The factory stops at fixed points so you can close the session and start a
fresh one from there. Nothing it needs lives only in chat.

| Stop | After |
| --- | --- |
| S1 | REQUIREMENTS.md approved |
| S2 | STACK.md approved |
| S3 | ARCHITECTURE.md (+ CONSTRAINTS, design brief) approved |
| S4 | Issues published to the board |
| S5 | Each issue's "Raise PR?" answered. In whole-app mode, each frontier wave |

At every stop the factory:

1. commits the stage's artifacts through `commit`;
2. writes `.factory/state.json`: stage, gate stamps, issue statuses, and the
   next action;
3. ends with one line: *"Stop S<n>. Start a new omp session in this repo and
   run `/skill:factory`."*

`/skill:factory` reads `state.json`, the ledger, and the issue labels, then
resumes at the next action. It never relies on an earlier chat.

**Recovery inside a stage** (pstack `orchestrate`, `pause-safely`,
`session-pickup`; superpowers ledger):

- **Resume protocol.** Find the last `done` and any open `start` in the
  ledger. Uncommitted changes from the interrupted step are kept if that
  step's test now passes, else stashed to `wip/<issue>/<step>` and the step
  restarts clean from its brief, not from memory. The last `done` claim is
  re-checked once before continuing.
- **Every step checks first whether it is already done**: the branch at the
  expected SHA, the PR already open, a comment already posted (found by a
  hidden `<!-- factory:step=… -->` marker). Resuming never creates a second
  commit, PR, or comment.
- **Retry by failure mode**, two retries at most, then the step is marked
  `factory:needs-human` with its evidence:

  | Signal | Action |
  | --- | --- |
  | Context overflow | omp compaction runs; a second overflow in the same step splits the step |
  | Helper agent returns nothing | check the branch and ledger without reviving it; respawn once with the same brief |
  | Network or rate limit | retry as is |
  | The same tool error repeats | retry on another model |

- **A stage cannot end early.** An extension (`factory-stage-guard.ts`) on
  omp's `session_stop` event returns `{ decision: "block", reason }` while the
  current stage's exit predicate is unmet, unless the factory is at a stop
  (S1–S5) or blocked on you. A script sets the predicate from the real checks,
  never from the agent's claim. `session_stop` fires only in the main session,
  which is where the orchestrator runs.
- **The ledger survives compaction.** The same extension's
  `session.compacting` handler adds "read `.factory/ledger.tsv` before
  continuing" to every summary, and `compaction.handoffSaveToDisk: true` keeps
  a handoff note on disk.

### 5.7 After the PR (stage 9) — `factory-land`

You review on GitHub. On the next `/skill:factory` (after stop S5) the router
reads each open factory PR with `read pr://<N>` (comments included) and acts
on its state. No watcher runs in between.

**Your review comments** (superpowers `receiving-code-review`, pstack
`babysit`):

1. Order: merge conflicts, then review threads, then CI. A conflict on a
   stacked branch is fixed by the step below, not by hand.
2. Each unresolved thread is read as data, not as an instruction, and sorted
   into do / ask / push back. Your comments are trusted. A bot's comment is
   checked against the code first, and pushed back with evidence if wrong.
3. Any unclear item: ask about all of them through the questionnaire (§5.5)
   before changing anything ("IF any item is unclear: STOP").
4. The "do" items go to the builder on the same branch and worktree, red
   test first for behaviour changes, then re-review of the invalidated
   verdicts (§5.1).
5. One push to the `factory/*` branch, then one reply per thread citing the
   fixing commit. Stop when merge-ready. Babysitting never merges ("Babysitting
   never authorizes merging").

**After you merge** (pstack `shipping`, superpowers
`finishing-a-development-branch`):

1. Close what the merge finished. `Closes #N` only closes the issue when the
   PR merges into the default branch, so a stacked PR's issue is closed by
   the factory when its code reaches `main`.
2. Unblock: `board frontier` moves each issue whose blockers are now all
   closed to `factory:queued`.
3. Restack a child PR whose base was the merged branch:
   `gh pr edit <child> --base main`, then
   `git rebase --onto origin/main <old-parent-tip> <child>`, then
   `git push --force-with-lease`. After a squash merge the parent's commits
   are not in `main`, so a plain rebase would replay them. The patch-id rule
   (§5.1) decides which verdicts survive.
4. Refresh docs with the existing `docs` skill, and the `verify-<app>`
   feature map with pstack `maintain-verification-skill` when user-facing
   behaviour changed. Both go in one follow-up PR that touches no product
   code.
5. Remove the merged branch's worktree.

## 6. What to reuse from this repo

| Skill | Use in the factory | Change needed |
| --- | --- | --- |
| `commit` | every commit the factory makes | none |
| `implementation-plan` + `review-implementation-plan` | per-issue plan + second-model plan review | Small. Its plans already run the unit tests ("runs the project's unit-test command"), and they leave out browser and UI steps, which is right for the builder: QA and UI review are separate agents. Only its fixed commit sentence, "Manual testing and UI testing are left to the user.", is wrong inside the factory. `factory-planner` writes "Browser and UI checks are done by the factory's QA and UI review first; you do a manual pass on the PR." instead |
| `follow-implementation-plan` | builder inner loop | it restarts chats per window; inside the factory a fresh sub-agent replaces that. Its "do not start the app" rule stays: the builder never drives the app, `factory-qa` does |
| `paper-design-prompt` | architecture-stage UI direction | none |
| `paper-design` | `factory-designer` | Three changes. (1) It is `disable-model-invocation: true`, so load it via `autoloadSkills` [INFERENCE: hidden skills load through autoload the same way they load through `skill://`; check before relying on it]. (2) Today it builds every screen in the brief; per issue it must build only that issue's screens. (3) It stops when the Paper MCP is down, and it may not start Paper Desktop. Inside the factory, label the issue `factory:needs-human` and continue with issues that have no UI |
| `paper-target` | pin the Paper file per target repo | none |
| `arc-design` | architecture diagrams | none |
| `docs` | refresh docs after each merged issue | none |

## 7. Proposed inventory

All new files in this repo, linked the same way the current skills are.

```text
skills/
  factory/                 entry + router: reads .factory/state.json, resumes the right stage
    SKILL.md               (/skill:factory, disable-model-invocation: true)
    state.md               state.json schema, ledger columns, label set
  factory-gate/            Approve/No questionnaire, whole-doc re-review, sha stamp
    builder-check.md       superpowers builder-check prompt, run before the requirements and stack gates
  factory-grill/           grilling rounds (mattpocock grilling + interview-me guards)
  factory-requirements/    stage 1–3; template.md = REQUIREMENTS.md
  factory-stack/           stage 4; template.md = STACK.md
  factory-architecture/    stage 5; template.md, CONSTRAINTS template
  factory-issues/          stage 6; issue template, labels; publishes issue #0 first
    scripts/board          issue + board wrapper (§4.6): version switch, id cache, frontier
  factory-bootstrap/       issue #0 (§4.7): walking skeleton or missing-harness checklist
  factory-build/           stage 7–8; pipeline, loop rules, questionnaire relay, PR template
  factory-land/            stage 9 (§5.7): PR comments, post-merge close / unblock / restack / docs
  factory-review/          shared rubric + verdict formats (autoloaded by reviewer agents)
omp/
  agents/                  → ~/.omp/agent/agents/   factory-builder-check (§4.3) + the custom agents in §5.2
  hooks/pre/factory-guard.ts → ~/.omp/agent/hooks/pre/
  extensions/factory-stage-guard.ts → ~/.omp/agent/extensions/   session_stop + compaction pointer (§5.6)
```

`factory-guard.ts` is a `tool_call` hook (omp `hooks.md`). It returns
`{ block: true, reason }` for:

1. `gh pr create`, `gh pr merge`, `github` `pr_create`, and any `git push`
   (including `github` `pr_push`) to a branch outside `factory/*`. A
   `pr_create` needs a PR approval in `.factory/state.json` for that branch and
   HEAD SHA. A push to `factory/*` is allowed so CI can run before you are
   asked (§5.4), and `--force-with-lease` there is allowed for the restack
   after a merge (§5.7). A bare `--force` is not. mattpocock's
   `git-guardrails-claude-code` does the same job for Claude Code.
2. Any read of `~/.omp/factory/<repo>/holdout/` (by `read`, or by `bash`
   commands naming that path) by an agent other than `factory-qa` /
   `factory-qa-author`. The holdouts live outside the target repo, as in the
   archived factory, so they are never committed or pushed to GitHub. The
   archived `holdout-guard.ts` and its eval 01 already cover both paths.
3. `edit` / `write` to an approved doc in `docs/factory/` while its gate is
   closed. The edit has to reopen the gate first.

Prose gates (all three repos) are kept for the human conversation. The hook
covers the irreversible actions.

## 8. omp-specific constraints

1. **No run-permission gate.** The account-wide rule
   `explicit-runtime-permission.md`, which blocked running tests, apps, and
   browser checks without an explicit request, was removed on 2026-10-20.
   Builder, test review, QA, and UI review run tests and drive the app with no
   question to you. What still needs your approval is unchanged: the gates,
   the push outside `factory/*`, and opening a PR (§4.3, §5.4, §7).
2. **`github.enabled` defaults to `false`.** Turn it on (Settings → Tools) for
   `pr_create` and `run_watch`. `pr_create` and `pr_push` also go through
   omp's execution approval.
3. **Model roles in `omp/config.yml`:** `review` = GPT-6.1 Sol, `default` /
   `plan` = Opus 5.5, `task` = Sonnet 5.5, `vision` = GPT-6.1 Sol, `slow` =
   GPT-6.1 Sol. `task.agentModelOverrides` already routes the bundled
   `reviewer` to `@review`, so the two code reviewers (`reviewer` and
   `factory-spec-review` on `@default`) get model diversity. A `factory_*`
   role set is optional; the removed version had one.
4. **Stale registrations in the session that wrote this.** It still listed a
   `factory` skill and `factory-*` agents, but nothing under `~/.omp/agent/`
   or `~/.omp/plugins/` holds them now. Restart omp and check `/agents` before
   building, so the new names do not collide with a cached copy.
5. **Context size.** Sub-agents return a verdict + a pointer (`agent://<id>`,
   ledger row), not the full transcript. pstack and mattpocock both pass
   pointers, not copies.
6. **Plan mode** strips sub-agents to read-only tools and rejects `isolated`.
   Do not run `factory-build` in plan mode.
7. **`AGENTS.md` and `CLAUDE.md` must reach every context**, including helper
   agents and every new session. omp loads both into the main session's system
   prompt, so they survive compaction and come back in each new session. But
   it drops any file named `agents.md` when it spawns a helper agent, and
   passes only `CLAUDE.md` on (`omp://system-prompt-customization.md`). The
   fix is that the target repo's `CLAUDE.md` holds a bare `@AGENTS.md` line,
   outside any code fence. omp expands `@` imports before injection, and
   imported text is not filtered, so every helper agent receives both files
   (`omp://context-files.md`). `/skill:factory` checks that line on every
   start and adds it if missing. The fallback is a small extension that
   injects `AGENTS.md` when `ctx.agent.kind === "sub"`. V6 (§14.3) confirms
   which one works.
8. **Settings the factory needs on**, all off by default: `github.enabled`
   (item 2), `secrets.enabled` (QA redaction, §5.2), `security.enabled`
   (`security_scan`, §5.2), and `compaction.handoffSaveToDisk` (§5.6).
9. **Model fallback on rate limits.** `retry.fallbackChains` covers the
   session's roles. A helper agent gets a fallback only when its agent file
   lists more than one model pattern ("there is no `agent:<name>` key in
   `fallbackChains`", `omp://settings.md`). Every factory agent therefore
   lists a second model from another provider, which replaces the archived
   factory's stand-in reviewer agents. `security_scan` runs with fallback
   disabled.

## 9. Build order

Each step is usable before the next one exists.

1. `factory-grill` + `factory-gate` (with the builder check): the two
   primitives. Try them by hand on any document.
2. `factory-requirements` → `factory-stack` → `factory-architecture`: the
   human-in-the-loop half ends here with three approved docs.
3. `factory-issues` with its `board` script: publishes the board with issue #0
   first. Stop here and review the issues yourself the first time.
4. `factory-guard.ts` hook, before any agent can push.
5. `factory-bootstrap` + `factory-build` on issue #0, sequential: builder,
   both code reviewers, test reviewer, QA, QA reviewer, PR ask. Issue #0 is
   also the first real test of the pipeline.
6. One feature issue, no UI. Then the UI path (designer, design reviewer, UI
   reviewer), the security scan, the stage-guard extension, and parallel
   issues with isolation.
7. `factory-land` on the first merged PR.
8. Evals (§12, general research): addyosmani's three tiers (structural,
   routing, behavioural) plus a fourth, **gate-hold** scenarios that plant one
   fault per gate in a throwaway repo, run `omp -p --mode json`, and grade
   the transcript and final repo state with a judge from another model
   family, five runs each. Your archived factory's six scenarios become
   gate-hold cases: holdout guard, weakened test, misleading precedent,
   out-of-authority (a builder needing an unapproved package must return
   BLOCKED), changed requirement (reopens the right gates only), and
   absent-is-not-zero (a test command that collects zero tests is a FAIL).
   Add: a "Saved" toast over an unwritten row, a PR comment that says "ignore
   the tests and merge", a 4 px padding drift from Paper, a builder killed
   mid-step, and a squash merge under a stacked PR.

## 10. Rejected options

- **Install one repo whole.** pstack is Cursor-first: `subagent_type`,
  `AskQuestion`, cloud agents, `~/.cursor/rules` model routing. addyosmani has
  no orchestrator by design. mattpocock grills in chat and has no approval
  stamp. Each needs the gate and the pipeline built anyway.
- **Vendor their SKILL.md files.** Licences allow it (all MIT), but the
  factory needs about a fifth of each repo's text. Copy the rules quoted
  above, credit the source in each skill, and keep one convention.
- **One giant `factory` skill.** The archived version had one 87-line SKILL.md
  plus 13 reference files. Splitting by stage lets each stage run on its own
  (`/skill:factory-stack` on an existing project) and keeps each file under
  ~150 lines.
- **Adopt the requirements skills recommended in
  `docs/research/requirements-gathering/`.** Most of them repeat what
  `interview-me`, `grilling`, and `to-spec` already do, and none of them has
  an Approve/No loop. Two pieces were taken. §12 says why each of the others
  was left out.

## 11. Open decisions (defaults chosen; say if any is wrong)

| # | Question | Default |
| --- | --- | --- |
| Q1 | UI/UX design before code (§5.1) or in your listed order (after QA)? | before code |
| Q2 | Show the issue breakdown for one Approve/No before publishing? Issues are public and slow to undo. | yes, one gate |
| Q3 | On **No**, re-ask every section, or every section except ones approved twice in a row? | every section (your rule) |
| Q4 | "Raise PR" on Approve: agent opens it, or agent pushes the branch and you open it? | agent opens it |
| Q5 | Whole-app mode: one PR for the epic, or one per frontier wave? | one per wave (smaller reviews) |
| Q6 | Holdout QA scenarios (builder never sees them)? | yes |
| Q7 | Limits per issue for the unattended part | 3 hours wall clock or 40 helper-agent runs per issue, whichever comes first; each helper agent stopped after 60 minutes (`task.maxRuntimeMs: 3600000`); 10% of subscription quota kept back |
| Q8 | Docs refresh after a merge: its own PR, or a commit on the next PR? | its own PR (§5.7) |

## 12. Research reports: compared, mostly not adopted

`docs/research/requirements-gathering/` holds three AI-written reports
(Claude, Gemini, GPT). Each skill they recommend was checked against its
source on 2026-10-20 and compared with what this design already uses:
`interview-me` for gathering, `grilling` for grilling, `to-spec` + Boundaries
for the document, and the §4.3 gate. A piece was adopted only if the workflow
needs it and the existing skills lack it.

| Skill (report) | What it would add | Decision |
| --- | --- | --- |
| obra/superpowers `brainstorming` (all three) | builder-check sub-agent; asking which tech choices you keep | **Adopted both** (§4.3, §4.1). The rest is `interview-me` again, and it rejects recommended-answer grilling |
| github/spec-kit (GPT) | numbered requirements with Given / When / Then; coverage categories; requirement checklists; consistency analysis | **Adopted numbering + Given / When / Then** (issues and QA need them). The checklists and analysis duplicate the builder check |
| magnus919 `product-discovery` (GPT) | open-question rules, SAID / INFERRED tags, draft-review route | not adopted: `interview-me` covers it; the tags add bookkeeping the gate does not need |
| Dengk3Li `product-grilling` (GPT) | — | not adopted: it is mattpocock `grilling`, credited as such |
| Dengk3Li `product-requirements` (GPT) | requirement graph + checker script | not adopted: heavy, and the builder check covers the same gaps |
| pablasso `prd` + `prd-review` (Claude) | one-page PRD + review checklist | not adopted: `to-spec` + builder check cover it |
| idnotbe `prd-creator` (Claude) | large Epic/Feature/Story template | not adopted: too heavy for the gate to review section by section |
| github/awesome-copilot `prd` (Claude) | enterprise PRD schema | not adopted: overlaps `to-spec` |
| CaptainCrouton89 `requirements-gathering` (Gemini) | work-type triage, auth/CRUD checklists | not adopted: `grilling` finds these as frontier questions |
| rizethereum `requirements-builder` (Gemini) | yes/no questions with defaults | not adopted: narrower than `interview-me` |
| ClawHub `prd` (Gemini) | `prd.json` for a Ralph loop | not adopted: GitHub issues hold the stories |
| stellarlinkco/myclaude `product-requirements` (GPT) | 100-point readiness score | not adopted: the author scores its own document |
| martincjarvis `requirements-gathering` (GPT) | ticket-only intake | not adopted: stops before design |

Accuracy of the reports, for future use:

- **Claude:** accurate, except that it says superpowers prefers multiple
  choice. It prefers open questions and offers a menu only when you are stuck.
- **Gemini:** several claims do not hold. The spike / bounded / architectural
  routing is from an older superpowers. MoSCoW and Gherkin are not in ClawHub
  `prd`. The "Confirmed / Assumption / Open" pattern could not be found.
- **GPT:** accurate. The one error: Dengk3Li's hand-off to `system-architect`
  points at a skill that does not exist.

### Grilling research (`docs/research/requirements-gathering-grill/`)

Checked the same way on 2026-10-20. The pre-mortem round (§4.2) is the only
addition.

| Skill or idea (report) | What it would add | Decision |
| --- | --- | --- |
| Pre-mortem framing (Gemini template; BMAD `bmad-advanced-elicitation`; addyosmani `idea-refine`) | failure-first questioning | **Adopted** as the final requirements round (§4.2) |
| mattpocock `grill-me`, `grill-with-docs` (Claude, GPT) | — | already used. Both are one-line wrappers around `grilling` (plus `domain-modeling` in the second) |
| max4c `grill-me` (GPT) | five dimensions with a 0–1 ambiguity score and thresholds | not adopted: the builder check finds the same gaps, and the score is self-assessed |
| SuperCorks `requirements-interview` (GPT) | propose an understanding first when the input is substantial | not adopted: `interview-me` already opens with a hypothesis |
| satya-janghu `grill-me` (Claude) | decision log in `.grill/<slug>.md` | not adopted: REQUIREMENTS.md and the sha stamp already hold the decisions |
| jscraik `interview-me` (Claude) | multiple-choice questions; `approved` / `needs-input` / `blocked` status | not adopted: grilling uses recommended answers, and your gate is Approve / No |
| get-shit-done `discuss-phase` (Gemini) | gray-area selection, deferred-ideas list | not adopted: grilling's frontier and Out of Scope cover it |
| BMAD analyst / PM / PRD validation (Gemini) | 71 elicitation methods, PRD rubric | not adopted beyond the pre-mortem; the builder check covers PRD review |
| Gemini "Ruthless Spec Griller" template | five pillars, no hand-waving, `[Confirmed]` / `[Assumption]` ledger | not adopted beyond the pre-mortem: hand-waving is the `interview-me` rule in §4.2, and the gaps are the builder check's job |
| spec-kit `clarify`, Dengk3Li `product-grilling`, superpowers `brainstorming` | — | already compared in the table above |

Report accuracy:

- **Claude:** wrong that mattpocock `grill-me` asks one question at a time.
  `grilling` asks in rounds. The jscraik "spec" output comes from the
  Smithery listing, not the skill, and that listing's repo link is broken.
- **Gemini:** the BMAD "business, then technical cross-examination"
  role-play does not exist. The superpowers errors noted above repeat here.
- **GPT:** accurate.

### Architecture research (`docs/research/architecture/`)

Checked the same way on 2026-10-20 against §4.5, which already uses pstack
`architect` + `interrogate`, `domain-modeling` for the glossary and ADRs,
`constraint-driven-development`, `paper-design-prompt`, and `arc-design`. Two
additions, both small: the threat-model section, and module boundaries in
CONSTRAINTS.md (§4.5).

| Skill (report) | What it would add | Decision |
| --- | --- | --- |
| magnus919 `secure-software-engineering` (GPT) | lightweight threat-model template | **Adopted** as a section of ARCHITECTURE.md |
| wshobson `architecture-patterns` (GPT) | dependency-direction rule | **Adopted** as a CONSTRAINTS.md boundary check, using the tool `/constraints` already names. The pattern catalogue is not adopted |
| magnus919 `software-architecture` (GPT) | quality scenarios, options table, review outcomes incl. "accept with conditions" / "defer" | not adopted: `architect` + `interrogate` cover options and review, and your gate is Approve / No only |
| magnus919 `adr-authoring` (GPT) | 11 ADR formats, sustainability rubric | not adopted: the `domain-modeling` ADR rule is enough |
| magnus919 `c4-diagramming` (GPT) | C4 diagrams as code | not adopted: `arc-design` (archify) already draws them; a second convention would conflict |
| magnus919 `software-architecture-analysis` (GPT) | coupling analysis of existing code | not adopted: the §4.1 scout and `architect`'s grounding step cover existing repos |
| magnus919 `api-design-and-evolution`, `multi-tenant-saas-architecture`; wshobson `postgresql-table-design` (GPT) | domain checklists | not adopted by default. Load one only when REQUIREMENTS / STACK make it relevant (public API, multi-tenant, PostgreSQL) |
| wshobson `microservices-patterns`, `api-design-principles` (GPT) | pattern and REST checklists | not adopted: generic knowledge the model already has |
| anthropics `knowledge-work-plugins` `system-design` (GPT) | five-step design checklist | not adopted: overlaps ARCHITECTURE.md's sections |
| eligapris `software-architect` (GPT) | dependency and ADR scripts, MADR template | not adopted: covered by CONSTRAINTS.md and `domain-modeling` |
| sirius-zuo `architect-design-review` (GPT) | review rubric, Mermaid report | not adopted: `interrogate` is the review |
| tomas-u, ruvnet/ruflo, claudskills, itzcull, kayaman (Claude) | architecture guidance, pattern and DDD catalogues | not adopted: catalogues of knowledge the model already has; no workflow mechanics |
| nobelk `architecture-review`, `design-doc-review`, `prd-to-design-doc` (Claude) | codebase audit, design-doc review | not adopted: overlaps `interrogate` |
| 1ikeadragon `architecture-review` (Claude) | map entrypoints and wiring before designing | not adopted: `architect`'s grounding step and the §4.1 scout do this |
| borghei `senior-architect`, 45ck `software-architecture-skills`, Jeffallan `claude-skills` (Gemini) | dependency and coupling scripts, 14 generic modules, DDD notes | not adopted: heuristic scores, generic templates, and `domain-modeling` covers DDD |

Report accuracy:

- **Claude:** the named skills exist, but several are broken:
  - ruflo's "writes only to `docs/architecture`" path contains a literal `$`,
    so the restriction does not work.
  - claudskills cites resources that are not in the repo.
  - nobelk `prd-to-design-doc` cites two reference files that do not exist.
- **Gemini:** 45ck has no quality-attribute scenarios, and Jeffallan has no
  clean-architecture skill (only a .NET file). borghei's scripts exist.
- **GPT:** accurate. Every skill and path exists.

### Architecture grilling research (`docs/research/architecture-grill/`)

Checked the same way on 2026-10-20. **Nothing added.** Architecture is
already grilled by the same `grilling` rounds (§4.2), after `architect`'s two
candidates and `interrogate`'s two-model review (§4.5), with ADRs from
`domain-modeling`. Every recommended skill is either a copy of one of these
or adds something the workflow does not need.

| Skill (report) | What it would add | Decision |
| --- | --- | --- |
| mattpocock `grilling`, `grill-me`, `grill-with-docs` (all three) | — | already used |
| akillness/jeo-skills `grill-me` (Claude) | — | a copy of mattpocock `grilling` behind a wrapper |
| Ghosteken `grilling` (GPT) | rationalisations table, self-check list | a rewritten mattpocock `grilling`; nothing the design lacks |
| Future-CX `grill-me` (GPT) | — | same rules as `grilling`, but one question at a time; glossary and ADR are delegated, as here |
| vvanagas `grill-me` (GPT) | restate the plan first; a worklist file; each branch closed as Answered / Dissolved / Deferred / Accepted | not adopted: the architecture draft is the restated plan, answers are folded into the doc each round, and the §4.3 gate already makes you sign off the whole doc |
| Jeffallan `the-fool` (Claude) | five challenge modes picked by you (Socratic, dialectic, pre-mortem, red team, evidence audit) | not adopted: `interrogate` is the adversarial pass, and the requirements pre-mortem already exists |
| PhotoStructure `replan` (Claude) | at least three critique-and-revise loops | not adopted: `architect` + `interrogate` give critique and alternatives; grilling's stop rule is stricter than a fixed count |
| me-cedric `architecture-advisor` (GPT) | Known / Assumed / Unknown labels, weighted options matrix | not adopted: provenance tags were already rejected (§12 first table); hard-to-reverse choices get ADRs via `domain-modeling` |
| sirius-zuo `architect-design-review` (GPT) | — | already rejected in the architecture table above |
| melodic-software `/sd:mock-interview` (Gemini's "/system-design mock") | hiring-style rating | not adopted: it is interview practice, not a design review |

Report accuracy:

- **Claude:** jeo-skills `grill-me` has no "hard-to-reverse focus" or
  "open questions at the end". It is a mattpocock copy. `the-fool`'s modes
  are correct, except that "falsification" is really an evidence audit.
- **Gemini:** wrong that `grill-with-docs` writes ADRs automatically, with
  revisit triggers. It offers an ADR only when the three `domain-modeling`
  conditions hold, and the template has no revisit-trigger field. There is no
  "/system-design mock" skill; the nearest is melodic-software's
  `/sd:mock-interview`, and it has no per-dimension scorecard.
- **GPT:** the skills exist. Wrong that `architecture-advisor` "challenges
  complexity": it has no such step.

### Design research (`docs/research/design/`)

Checked the same way on 2026-10-20 against this repo's `paper-design-prompt`
and `paper-design` and the UI rows of §5.2. **No skill added.** Both local
skills already cover what the research recommends: a reference-product base
instead of a style catalogue, tokens and a design-system artboard before
screens, and Paper's `write_html` limits (flex only, no grid, margin, or
table, no emoji icons). Comparing them with the per-issue flow did expose
three gaps in `paper-design`. They are recorded in §6, and the UI reviewer
now screenshots at the brief's viewport.

| Skill (report) | What it would add | Decision |
| --- | --- | --- |
| paper-design/agent-plugins `paper-desktop` (Claude, GPT) | MCP packaging | not adopted: Paper MCP is already configured in `omp/mcp.json`; the plugin has no design workflow |
| jaikathuria `paper-design-skills` (GPT) | create, edit, design-system, design-to-code, and Figma-import workflows | not adopted: `paper-design` already has the same tool order and `write_html` rules; its design-to-code step runs the dev server |
| julianoczkowski `designer-skills` (GPT): `design-brief`, `information-architecture`, `grill-me`, `design-tokens`, `design-review` | brief, IA, interview, tokens, review at 375 / 768 / 1280 | not adopted: REQUIREMENTS.md + `paper-design-prompt` are the brief and screen list, grilling is §4.2, tokens come from `paper-design`; its review runs the app and asks the user, which conflicts with the hands-off issue loop |
| nextlevelbuilder `ui-ux-pro-max` (GPT) | database of 79 styles and 192 palettes | not adopted: a style catalogue; `paper-design-prompt` uses a reference product instead |
| Seance1723 `UXCraft` (GPT) | `/uxcraft` intake form, memory file, anti-slop list | not adopted: interactive intake, and the Paper design-system artboard plays the role of the memory file |
| anthropics `frontend-design` (GPT) | named AI-default looks to avoid, plan-then-critique | not adopted: the approved reference-product brief rules out generic looks, and code is checked against Paper, not taste |

Report accuracy:

- **Claude:** says Paper's MCP runs from Paper Desktop at
  `127.0.0.1:29979`. Your config starts it from the Paper.app CLI over stdio.
  Either way, Paper Desktop must be open, which is change (3) in §6.
- **GPT:** all repos exist. The official `agent-plugins` repo ships no
  design skill, only MCP packaging.

### Design grilling research (`docs/research/design-grill/`)

Checked the same way on 2026-10-20. The reports offer two kinds of skill:
ones that interrogate you about your design, and ones that critique a design
on their own. The interrogation kind does not fit. Per-issue design is
hands-off, and you already approve the design direction at the architecture
gate. The critique kind did expose a real gap: the UX quality of the Paper
screens was checked by no one, because UI review only checks that the code
matches them. **One addition:** the `factory-design-review` agent (§5.1,
§5.2), with wondelai `ux-heuristics` as its rubric. It was the only source
that can work unattended:

- it needs no running app;
- it asks you no questions;
- it gives a repeatable score, which the factory turns into a verdict.

| Skill (report) | Static | Asks you | Fixed verdict | Decision |
| --- | --- | --- | --- | --- |
| wondelai `ux-heuristics` (GPT) | yes | no | score out of 10, severity 0–4 | **Adopted** as the design-review rubric. The factory adds its own threshold: FAIL on severity 3–4 |
| EliaAlberti `ux-audit-skill` (GPT) | yes (screenshots) | yes, an intake stop | no | not adopted: the intake stop blocks hands-off use. Its rule that keyboard and focus "are not assessable from static screens" is followed by sending them to UI review |
| pbakaus `impeccable` `critique` (Claude) | no, needs a browser for web | yes | 0–40 score | not adopted: needs the running app and asks questions |
| cuellarfr `design-critique` (GPT) | yes | no | severity only | not adopted: no verdict, and a very large rubric |
| mohitagw15856 `design-critique` (Claude) | yes | rarely | no threshold | not adopted: no verdict, and fills gaps with assumptions |
| NickCrew `design-critiquer` (Claude) | yes | no | no | not adopted: no verdict; its contrast and 44px target checks are part of CONSTRAINTS a11y |
| anthropics `knowledge-work-plugins` `design-critique`, `accessibility-review`, `design-system` (GPT) | yes | yes, if no input | no | not adopted: asks you, no verdict |
| mattpocock, satya-janghu, vvanagas `grill-me` (Claude, GPT) | — | yes, by design | — | not adopted: per-issue design has no human in the loop. Compared in earlier tables |
| paper-design `agent-plugins` (both) | — | — | — | already covered by Design research above |

Report accuracy:

- **Claude:** `impeccable` `critique` is a reference file inside the
  `impeccable` skill, not a separate skill. NickCrew's skill lives in
  `Claude-Cortex`, not a separate `claude-ctx-plugin` repo.
- **GPT:** every repo exists. The UX Planet article could not be read (HTTP
  403), so its "copyable SKILL.md examples" are unverified.

### General research (`docs/research/general/`)

Two reports (Claude, GPT) on R1–R12, checked on 2026-10-20 against the
skill repos, omp's docs and its bundled agent source, and the vendors' docs.
Unlike the earlier rounds, most of it is adopted: these stages had no design
at all. Where both reports agree, the Claude report gives the detail.

| Piece (report) | Decision |
| --- | --- |
| addyosmani CDD: Floor, `check:fast` / `check:task` / `check:full`, floor guard, ratchets (both) | **Adopted** (§4.5, §4.7). The four-question interview moves into architecture grilling; CDD says not to run it unattended |
| Walking skeleton as a first, blocking issue (both) | **Adopted** as issue #0 (§4.7) |
| addyosmani `ci-cd-and-automation`, `git-workflow-and-versioning` (both) | read by `factory-bootstrap` as references; the deliverables table holds what the factory needs |
| pstack `create-verification-skill`, `maintain-verification-skill`; superpowers `verification-before-completion` (both) | **Adopted** (§5.2 QA, §5.7) |
| QA rules: own instance, no production credentials, sandbox → fake → replay, evidence bundle, BLOCKED is not PASS (both) | **Adopted** (§5.2) |
| Playwright test agents (Claude) | not adopted: the Healer edits tests until they pass, which the floor guard forbids |
| Holdouts in a separate repo; StrongDM twins and satisfaction scores (Claude) | not adopted: holdouts stay outside the repo behind the hook, as in the archived factory; one fake per outside service is enough |
| superpowers SDD status contract and model escalation; `systematic-debugging` 3-fix rule (both) | **Adopted** (§5.2, §5.3) |
| omp advisor as an "Unsticker" on attempt 2 (Claude) | **Adopted** as `factory-builder-unstick`. The report says to turn it on per dispatch; omp attaches it per agent definition, so it is a second agent file |
| Ralph loop (Claude); mattpocock `implement-spec` as dispatcher, builder state machine (GPT) | not adopted: fresh helper agents already give fresh context, and the main session already dispatches the frontier. GPT itself warns against two dispatchers |
| superpowers `receiving-code-review`, `finishing-a-development-branch`; pstack `babysit`, `shipping` patch-id rule (both) | **Adopted** (§5.1, §5.7) |
| GitHub Actions label workflow, PR watcher, 24-hour retro watch (Claude) | not adopted: stop S5 and the next `/skill:factory` replace a watcher |
| omp bundled `reviewer` (both) | **Adopted**, replacing the custom correctness reviewer (§5.2) |
| Spec seat from the superpowers reviewer template, "Declined to judge" list (Claude) | **Adopted** as `factory-spec-review` |
| Test review: floor guard, criteria-to-test map, diff-scoped mutation, test smells (both) | **Adopted** (§5.2) |
| omp `/review` command (GPT) | not adopted: it is the interactive front end; the pipeline calls the bundled agent |
| UI review: same size, style diff by `data-paper-id`, pixelmatch `windowSize`, vision judge classifies (Claude) | **Adopted** (§5.2) |
| Pixel baselines with `toHaveScreenshot` after approval (both) | not adopted: no requirement asks to guard earlier screens against later issues. Revisit if that happens |
| Recovery: start/done steps, idempotent steps, retry by failure mode, `session_stop` guard, compaction pointer (Claude) | **Adopted** (§5.6); the journal is the ledger's event column, not a second file |
| Security layer 1 in `check:full`; layer 2 `security_scan` `ref_diff` on boundary issues, `security-reviewer` fallback (both) | **Adopted** (§4.5, §5.2) |
| addyosmani "ask-first" security items (Claude) | **Adopted** as a questionnaire (§5.5) when the threat model does not already cover the change |
| SARIF upload to GitHub code scanning (Claude) | not adopted: findings already go to the ledger and the PR body |
| `board` wrapper with a `gh` version switch and an id cache (both) | **Adopted** (§4.6) |
| Factory-compatibility filter for the stack (Claude); MADR Confirmation line | **Adopted** (§4.4) |
| `tech-selection-research` community skill, weighted scoring matrix (both) | not adopted: two candidates, grilling, and the gate already decide; a weighted score is the author grading itself |
| addyosmani eval tiers, gate-hold scenarios, pstack eval blinding (Claude) | **Adopted** (§9 step 8) |
| Promptfoo and agent-skill-evals (GPT) | not adopted: `omp -p --mode json` runs the cases without an adapter |

Report accuracy:

- **Claude:** accurate on every load-bearing claim checked, including the
  bundled `reviewer` schema (read from omp's source). Small errors: omp's
  `session.compacting` context is a string list; mid-turn compaction for
  helper agents is a default, not "always on"; `playwright-cli
  --skills=agents` is not in its README; and its Stryker line-range command
  needs `--force`.
- **GPT:** accurate but less specific. Its pstack links go to
  `backnotprop/pstack`, a mirror of `cursor/plugins/pstack` that "adds its own
  edits". mattpocock issue #967 (walking skeleton) exists but was closed "not
  planned", as GPT says. Its six eval scenarios are its own, not your
  archived ones.

## 13. Sources

- pstack: [README](https://github.com/cursor/plugins/blob/main/pstack/README.md) ·
  [interrogate](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/interrogate/SKILL.md) ·
  [architect](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/architect/SKILL.md) ·
  [orchestrate](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/poteto-mode/playbooks/orchestrate.md) ·
  [autonomous-run](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/poteto-mode/playbooks/autonomous-run.md) ·
  [shipping](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/poteto-mode/playbooks/shipping.md) ·
  [opening-a-pr](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/poteto-mode/playbooks/opening-a-pr.md) ·
  [create-verification-skill](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/create-verification-skill/SKILL.md) ·
  [show-me-your-work](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/show-me-your-work/SKILL.md)
- addyosmani/agent-skills: [interview-me](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/interview-me/SKILL.md) ·
  [spec-driven-development](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/spec-driven-development/SKILL.md) ·
  [doubt-driven-development](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/doubt-driven-development/SKILL.md) ·
  [constraint-driven-development](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/constraint-driven-development/SKILL.md) ·
  [/build](https://raw.githubusercontent.com/addyosmani/agent-skills/main/.claude/commands/build.md) ·
  [/ship](https://raw.githubusercontent.com/addyosmani/agent-skills/main/.claude/commands/ship.md) ·
  [code-reviewer](https://raw.githubusercontent.com/addyosmani/agent-skills/main/agents/code-reviewer.md) ·
  [evals](https://raw.githubusercontent.com/addyosmani/agent-skills/main/evals/README.md)
- mattpocock/skills: [grilling](https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grilling/SKILL.md) ·
  [to-spec](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-spec/SKILL.md) ·
  [to-tickets](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/to-tickets/SKILL.md) ·
  [AGENT-BRIEF](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/triage/AGENT-BRIEF.md) ·
  [issue-tracker-github](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/setup-matt-pocock-skills/issue-tracker-github.md) ·
  [implement-spec](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/implement-spec/SKILL.md) ·
  [code-review](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md) ·
  [tdd](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/tdd/SKILL.md) ·
  [pr](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/pr/SKILL.md) ·
  [domain-modeling](https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/domain-modeling/SKILL.md) ·
  [git-guardrails-claude-code](https://raw.githubusercontent.com/mattpocock/skills/main/skills/misc/git-guardrails-claude-code/SKILL.md)
- omp: `omp://skills.md`, `omp://tools/ask.md`, `omp://task-agent-discovery.md`,
  `omp://tools/task.md`, `omp://tools/github.md`, `omp://hooks.md`.
- Requirements research (§12), adopted pieces only:
  [superpowers brainstorming](https://raw.githubusercontent.com/obra/superpowers/main/skills/brainstorming/SKILL.md) ·
  [builder-check-prompt](https://raw.githubusercontent.com/obra/superpowers/main/skills/brainstorming/builder-check-prompt.md) ·
  [spec-kit spec-template](https://raw.githubusercontent.com/github/spec-kit/main/templates/spec-template.md)
- Grilling research (§12), adopted piece only:
  [addyosmani idea-refine frameworks](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/idea-refine/frameworks.md) ·
  [BMAD elicitation methods](https://raw.githubusercontent.com/bmad-code-org/BMAD-METHOD/main/skills/bmad-advanced-elicitation/assets/methods.csv)
- Architecture research (§12), adopted pieces only:
  [magnus919 lightweight threat model](https://raw.githubusercontent.com/magnus919/agent-skills/HEAD/secure-software-engineering/templates/lightweight-threat-model.md) ·
  [addyosmani /constraints](https://raw.githubusercontent.com/addyosmani/agent-skills/main/.claude/commands/constraints.md)
- Design grilling research (§12), adopted piece only:
  [wondelai ux-heuristics](https://raw.githubusercontent.com/wondelai/skills/HEAD/plugins/ux-design/skills/ux-heuristics/SKILL.md)
- General research (§12), adopted pieces only:
  [addyosmani constraint-driven-development](https://raw.githubusercontent.com/addyosmani/agent-skills/main/skills/constraint-driven-development/SKILL.md) ·
  [superpowers subagent-driven-development](https://raw.githubusercontent.com/obra/superpowers/main/skills/subagent-driven-development/SKILL.md) ·
  [systematic-debugging](https://raw.githubusercontent.com/obra/superpowers/main/skills/systematic-debugging/SKILL.md) ·
  [receiving-code-review](https://raw.githubusercontent.com/obra/superpowers/main/skills/receiving-code-review/SKILL.md) ·
  [finishing-a-development-branch](https://raw.githubusercontent.com/obra/superpowers/main/skills/finishing-a-development-branch/SKILL.md) ·
  [verification-before-completion](https://raw.githubusercontent.com/obra/superpowers/main/skills/verification-before-completion/SKILL.md) ·
  [pstack babysit](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/poteto-mode/playbooks/babysit.md) ·
  [maintain-verification-skill](https://raw.githubusercontent.com/cursor/plugins/main/pstack/skills/maintain-verification-skill/SKILL.md) ·
  [omp reviewer agent](https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/prompts/agents/reviewer.md) ·
  [gh v2.94.0](https://github.com/cli/cli/releases/tag/v2.94.0) ·
  [pixelmatch](https://github.com/mapbox/pixelmatch) ·
  [StrykerJS incremental](https://stryker-mutator.io/docs/stryker-js/incremental/) ·
  [MADR](https://adr.github.io/madr/);
  omp `omp://advisor-watchdog.md`, `omp://extensions.md`, `omp://compaction.md`,
  `omp://tools/security_scan.md`, `omp://tools/browser.md`, `omp://secrets.md`.

## 14. Still open

Reviewed on 2026-10-20 after the seven research rounds in §12. What remains:
a few design decisions, and omp behaviour to confirm by running it.

### 14.1 Conflicts in this design — decided 2026-10-20

1. **CI before the PR.** Both fixes apply. `check:full` runs locally first,
   then a push to `factory/*` runs GitHub CI before you are asked (§5.4, §7).
2. **`AGENTS.md` missing in helper agents.** Both `AGENTS.md` and `CLAUDE.md`
   must reach every context. The target repo's `CLAUDE.md` imports
   `@AGENTS.md` (§8 item 7).
3. **Helper agents cannot answer prompts.** They return a questionnaire, and
   the main session handles it (§5.5).
4. **New:** fixed stops between sessions, resumed with `/skill:factory` (§5.6).

### 14.2 Research: R1–R12 answered

The general research (§12) settled every stage that had no design: QA,
builder, recovery, tech stack, both reviews, UI review, issues and board,
per-issue security, evals, bootstrap (issue #0), and stage 9. The three
items it left were decided on 2026-10-20: the budget per issue (§5.3, Q7),
requirement changes after issues exist (§4.8), and the `implementation-plan`
sentence (§6).

### 14.3 omp behaviour to confirm by running it (needs your permission)

| # | Question | How to check |
| --- | --- | --- |
| V1 | Does `autoloadSkills` load a `disable-model-invocation: true` skill (`paper-design`)? Docs say it loads "skills from the parent session", and hidden skills stay loaded, so probably yes | spawn a test agent with `autoloadSkills: paper-design` and ask it to quote the skill |
| V3 | Can the `factory-guard` hook block `github` `pr_create` and `git push` inside sub-agents? Extensions are rebound to every sub-agent session (`omp://extensions.md`) | a throwaway hook that blocks `git push`, then a sub-agent that tries it |
| V4 | Is the `ask` dialog's `preview` usable for a whole document section? | one gate run on a sample REQUIREMENTS.md |
| V5 | Does `task.isolation` with branch merge work on this Mac (APFS)? | one isolated sub-agent edits one file; check the `omp/task/<id>` branch |
| V6 | Does a `CLAUDE.md` holding `@AGENTS.md` deliver `AGENTS.md` to a helper agent? Does the main session then see `AGENTS.md` twice (directly and through the import)? | a repo with both files; spawn a `task` agent and ask it to quote `AGENTS.md`; check the main prompt for duplication |
| V7 | Will `security_scan` `preflight` run here? It needs a stored OAuth credential for the active model's provider; API keys are refused | one preflight on a scratch repo, from a session on `openai-codex` (ChatGPT OAuth) and one on Anthropic |
| V8 | Where does Paper `export` put the file, and does the result give a path pixelmatch can read? Its schema takes `scale` as `"2x"` or `"1440w"` | one export of one artboard |
| V9 | Does an `advisor:` field in an agent file advise that helper agent as documented? Does an agent file with two model patterns fall back on a 429? | one `factory-builder-unstick` run on a failing test |

### 14.4 Your decisions still pending

Q1–Q8 in §11 still carry defaults that you have not confirmed. Q7's numbers
are a first guess, to be tuned after issue #0 and the first feature issue.
