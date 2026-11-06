---
name: grill-stack
description: Research and stress-test technology-stack choices through Haiku 5.5 high and Sonnet 5.5 high, give evidence-backed suggestions without deciding for the user, and write docs/stack.md. Use when the user wants to choose, validate, compare, research, or grill a tech stack.
disable-model-invocation: true
---

# grill-stack

Research and stress-test the technology stack against the actual requirements. Haiku drafts the questions and grills only Sonnet's research and answers. Sonnet answers from repository evidence and current primary sources. The models give recommendations; the user owns every stack decision.

Invoke explicitly as `/skill:grill-stack [choices or question]`.

## Never

- Choose, approve, reject, replace, or lock a technology for the user. A verdict or recommendation is advice, not a decision.
- Add a service, framework, database, queue, cache, abstraction, dependency, deployment layer, or other technology that no requirement needs. Mention a useful extra only as an optional suggestion; do not add it to the chosen stack.
- Treat popularity, novelty, stars, benchmark headlines, or “industry standard” as sufficient evidence.
- State a version, support date, licence, price, quota, compatibility claim, or performance limit without a source and the date checked.
- Ask what the request, earlier answers, `docs/requirements.md`, `docs/stack.md`, manifests, lockfiles, repository, or authoritative documentation already settles.
- Ask the same question twice. A user answer is final unless it conflicts with another final answer; quote both and ask which wins.
- Let the parent model replace either specialist, answer the grill itself, or continue silently when a pinned specialist is unavailable.
- Have Haiku answer its own questions or grill the user. Haiku questions and challenges Sonnet's research and answers only.
- Treat a model suggestion, assumption, or consensus as a user choice.
- Edit `docs/requirements.md`, source code, manifests, lockfiles, configuration, ADRs, trackers, or implementation plans. Write only `docs/stack.md`.
- Implement, install, migrate, benchmark production systems, commit, or approve the stack.

## Specialists

Use only these OMP task agents:

- `stack-haiku-griller` — `anthropic/claude-haiku-5-5`, high thinking. It drafts the current question frontier and attacks Sonnet's evidence and reasoning.
- `stack-sonnet-researcher` — `anthropic/claude-sonnet-5-5`, high thinking. It researches primary sources, evaluates choices, suggests alternatives, and drafts the report.

Spawn each with its named `agent`; do not pass a per-call `model`. If either agent fails, reports another model, or is unavailable, stop and name it. Keep both agents alive and send follow-ups through `write agent://<id>`.

## Step 1 — establish the stack and constraints

Read:

- the invocation request and settled answers in chat;
- `docs/requirements.md` and `docs/stack.md` when present;
- manifests, lockfiles, deployment files, and configuration that identify the current stack;
- only the source needed to understand how a disputed technology is used.

Classify every stack item:

- **User-chosen** — the user explicitly chose it. Evaluate it; never replace it silently.
- **Existing** — the repository already depends on it. Report that fact without claiming the user chose it.
- **Candidate** — a model suggestion. It stays a suggestion until the user accepts it.
- **Fixed constraint** — a requirement or platform forces it.

Map each choice to the requirement or existing dependency it serves. A choice with no such reason is a simplicity question: suggest removing it, but do not remove it.

If there is no requirements file, use only requirements stated by the user or evidenced in the repository. Missing product intent is a user decision, not permission to invent a requirement.

## Step 2 — Haiku drafts the grill

Spawn `stack-haiku-griller` with the choices, requirements, repository evidence, and settled user constraints. Ask for at most eight questions across the whole current frontier and at most three for one technology. Shared questions cover several choices once.

Questions may cover only what changes the recommendation:

- the requirement and scale the choice must serve;
- compatibility with the rest of the stack;
- support lifecycle, licence, cost, quotas, and operational burden only when one could change the recommendation;
- security or compliance constraints actually present;
- team familiarity, budget, hosting accounts, or lock-in tolerance only when not already known;
- failure, backup, restore, upgrade, migration, and exit costs where relevant;
- whether the platform, standard library, or an existing component already does the job.

No generic checklist. No speculative future scale. No technology shopping list.

## Step 3 — Sonnet researches and answers

Spawn `stack-sonnet-researcher` with Haiku's questions and the evidence boundaries. Sonnet researches only facts needed to classify a choice. It uses repository evidence first, then at most two external primary sources per technology and twelve external sources for the run. One source may support several claims. Secondary sources are allowed only when no primary source covers the point, and must be labelled secondary. Stop looking once the available evidence supports a classification; do not research every property of every technology.

For each question return one classification:

- `SUPPORTED — <answer> — Evidence: <path or URL, checked YYYY-MM-DD>`
- `CONFLICT — <concrete mismatch> — Evidence: <requirement and source>`
- `NEEDS PROOF — <benchmark, spike, or missing fact needed> — Why: <reason>`
- `USER DECISION — <trade-off only the user can settle> — Suggestion: <smallest sufficient option and trade-off>`

For each technology, Sonnet gives at most one best real alternative. It says what would make that alternative win. It must not manufacture an alternative where the current choice plainly fits.
After the classifications, Sonnet includes a complete candidate `docs/stack.md` draft in the Step 6 shape. This is the only full drafting pass before Haiku's critique.

## Step 4 — Haiku grills Sonnet

Send Sonnet's classifications and candidate draft to the existing Haiku agent once. Haiku returns at most five material challenges covering only:

- unsupported, stale, or non-primary evidence;
- a requirements mismatch or compatibility issue;
- an unfair comparison or omitted material alternative;
- hidden cost, lock-in, migration, operational, or lifecycle risk relevant to the requirements;
- vague claims such as “scalable,” “simple,” “popular,” or “cheap” without a condition or number;
- a model preference presented as a user decision;
- an unnecessary stack component.

Send Haiku's complete critique to the existing Sonnet agent once. Sonnet must either concede and correct the draft, or maintain the claim with one direct piece of evidence. Its response ends with the complete corrected draft.

Do not send Sonnet's response back to Haiku and do not open another autonomous round. Any disagreement left after this exchange becomes `NEEDS PROOF` when measurement or stronger evidence could settle it, or a user decision when it needs preference, budget, risk tolerance, or product intent. Discard unrelated scope.

## Step 5 — ask only unresolved decisions

Ask the whole current user-decision frontier in one chat round. For each decision include:

1. the choice and requirement it affects;
2. the verified facts and source dates;
3. Sonnet's smallest sufficient suggestion;
4. the strongest trade-off and at most one real alternative;
5. concise options, worded so `yes` accepts the suggestion when possible.

Wait for the user's answer. Do not mark an unanswered suggestion as chosen. The user may defer; record it as open.

Send the exact user wording to Sonnet, then let Haiku verify Sonnet's interpretation. Haiku may challenge the interpretation, never the user's preference. Ask a follow-up only when the wording has two materially different meanings.

## Step 6 — write the stack report

Use Sonnet's corrected draft from Step 4. If user decisions remain, wait for Step 5 answers before writing. Otherwise the parent writes that draft to `docs/stack.md` without another specialist call. Do not ask either specialist for another general review.

Use this shape unless an existing file already has a clear structure:

```markdown
# Technology stack

Checked: YYYY-MM-DD

## Context

- Requirements and constraints used in this evaluation.

## Choices

### <area>: <technology and version/range when verified>

- Origin: User-chosen | Existing | Candidate | Fixed constraint
- Serves: <requirement or existing need>
- Assessment: Supported | Conflict | Needs proof | User decision
- Evidence: <fact — source, checked date>
- Risks: <only material risks>
- Alternative: <one real alternative, or “None needed”>
- Suggestion: <Keep, reconsider, compare, spike, or decide — advice only>
- Exit: <migration or removal consequence when material>

## Compatibility

- <verified interaction between choices, or an unresolved test>

## Decisions for you

- <only unanswered or explicitly deferred decisions>
```

Omit empty sections and fields. Preserve existing user choices exactly. Suggestions never change `Origin` to `User-chosen`. Do not invent decision IDs, scores, weighted matrices, or a single “best stack” verdict.

Reply with the file path, counts by assessment, the number of user decisions, and the most consequential verified risk or `Needs proof` item. Do not repeat the report in chat.
