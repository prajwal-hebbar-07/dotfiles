---
name: grill-stack
description: Research and stress-test technology-stack choices in rounds through Haiku 5.5 high and Sonnet 5.5 high, give evidence-backed suggestions without deciding for the user, and write docs/stack.md. Each round writes unresolved decisions to docs/stack-questions.md; after the user answers, Sonnet updates docs/stack.md and the next round grills it again, until nothing is left open. Use when the user wants to choose, validate, compare, research, or grill a tech stack.
disable-model-invocation: true
---

# grill-stack

Research and stress-test the technology stack against the actual requirements, in rounds. In each round Haiku drafts the questions, Sonnet answers from repository evidence and current primary sources and drafts the report, and Haiku grills Sonnet's research, answers, and draft. The models give recommendations; the user owns every stack decision and answers them in `docs/stack-questions.md`. After the user answers, Sonnet applies the answers, the parent updates `docs/stack.md`, and the next round grills the updated report. Rounds repeat until one ends with no decision left for the user.

Invoke explicitly as `/skill:grill-stack [choices or question]`.

## Never

- Choose, approve, reject, replace, or lock a technology for the user. A verdict or recommendation is advice, not a decision.
- Add a service, framework, database, queue, cache, abstraction, dependency, deployment layer, or other technology that no requirement needs. Mention a useful extra only as an optional suggestion; do not add it to the chosen stack.
- Treat popularity, novelty, stars, benchmark headlines, or “industry standard” as sufficient evidence.
- State a version, support date, licence, price, quota, compatibility claim, or performance limit without a source and the date checked.
- Ask what the request, earlier answers, `docs/requirements.md`, `docs/stack.md`, `docs/stack-questions.md`, manifests, lockfiles, repository, or authoritative documentation already settles.
- Ask the same question twice. A user answer is final unless it conflicts with another final answer; quote both and ask which wins.
- Let the parent model replace either specialist, answer the grill itself, or continue silently when a pinned specialist is unavailable.
- Have Haiku answer its own questions, grill the user, or reopen a user's answer. Haiku questions and challenges Sonnet's research, answers, and drafts only, including how Sonnet applied a user's answer.
- Treat a model suggestion, assumption, or consensus as a user choice.
- Edit `docs/requirements.md`, source code, manifests, lockfiles, configuration, ADRs, trackers, or implementation plans. Write only `docs/stack.md` and `docs/stack-questions.md`.
- Implement, install, migrate, benchmark production systems, commit, or approve the stack.

## Specialists

Use only these OMP task agents:

- `stack-haiku-griller` — `anthropic/claude-haiku-5-5`, high thinking. It drafts the current question frontier and attacks Sonnet's evidence and reasoning.
- `stack-sonnet-researcher` — `anthropic/claude-sonnet-5-5`, high thinking. It researches primary sources, evaluates choices, suggests alternatives, and drafts the report.

Spawn each with its named `agent`; do not pass a per-call `model`. If either agent fails, reports another model, or is unavailable, stop and name it. Keep both agents alive across rounds and send follow-ups through `write agent://<id>`. If either is no longer running, for example because the user answered in a new session, spawn a fresh one: `docs/stack.md` and `docs/stack-questions.md` carry the state.

## Step 1 — establish the stack and constraints

Read:

- the invocation request and settled answers in chat;
- `docs/requirements.md`, `docs/stack.md`, and `docs/stack-questions.md` when present; every answered question in the questions file is a settled user answer, and `defer` is an explicit deferral;
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

Spawn `stack-haiku-griller` with the choices, requirements, repository evidence, settled user constraints, and the paths `docs/stack.md` and `docs/stack-questions.md` when they exist. Ask for at most eight questions across the whole current frontier and at most three for one technology. Shared questions cover several choices once.

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

Spawn `stack-sonnet-researcher` with Haiku's questions and the evidence boundaries. Sonnet researches only facts needed to classify a choice. It uses repository evidence first, then at most two external primary sources per technology and twelve external sources per round; a source already cited in an earlier round is reused, not looked up again. One source may support several claims. Secondary sources are allowed only when no primary source covers the point, and must be labelled secondary. Stop looking once the available evidence supports a classification; do not research every property of every technology.

For each question return one classification:

- `SUPPORTED — <answer> — Evidence: <path or URL, checked YYYY-MM-DD>`
- `CONFLICT — <concrete mismatch> — Evidence: <requirement and source>`
- `NEEDS PROOF — <benchmark, spike, or missing fact needed> — Why: <reason>`
- `USER DECISION — <trade-off only the user can settle> — Suggestion: <smallest sufficient option and trade-off>`

For each technology, Sonnet gives at most one best real alternative. It says what would make that alternative win. It must not manufacture an alternative where the current choice plainly fits.
After the classifications, Sonnet includes a complete candidate `docs/stack.md` draft in the shape under Step 7. This is the only full drafting pass before Haiku's critique.

## Step 4 — Haiku grills Sonnet

Send Sonnet's classifications and candidate draft to the existing Haiku agent once. Haiku checks the draft against every user answer as well, and returns at most five material challenges covering only:

- unsupported, stale, or non-primary evidence;
- a requirements mismatch or compatibility issue;
- an unfair comparison or omitted material alternative;
- hidden cost, lock-in, migration, operational, or lifecycle risk relevant to the requirements;
- vague claims such as “scalable,” “simple,” “popular,” or “cheap” without a condition or number;
- a model preference presented as a user decision;
- an unnecessary stack component;
- a user answer applied with a meaning other than the user's wording.

Send Haiku's complete critique to the existing Sonnet agent once. Sonnet must either concede and correct the draft, or maintain the claim with one direct piece of evidence. Its response ends with the complete corrected draft.

Do not send Sonnet's response back to Haiku and do not open another debate exchange in this round. Any disagreement left after this exchange becomes `NEEDS PROOF` when measurement or stronger evidence could settle it, or a user decision when it needs preference, budget, risk tolerance, or product intent. Discard unrelated scope.

## Step 5 — write the round's questions to a file

If no user decision remains, go to Step 7.

Otherwise write the whole current user-decision frontier to `docs/stack-questions.md` instead of asking in chat. Clear the file first and write only this round's questions, numbered from Q1: earlier answers already live in `docs/stack.md`, which Step 6 updated before this round began. Use this shape:

```markdown
# Stack questions

Write your answer on the `Answer:` line under each question, then say they are answered. `yes` accepts the suggestion; `defer` leaves the decision open.

## Round <N>

### Q1. <the choice in plain language>

- Affects: <the requirement it serves>
- Facts: <verified facts — source, checked YYYY-MM-DD>
- Suggestion: <Sonnet's smallest sufficient option>
- Trade-off: <the strongest trade-off; at most one real alternative and what would make it win>
- Choices: <concise options, worded so `yes` accepts the suggestion when possible>

Answer:
```

Reply with the file path, the round number, and the number of questions, then wait. Do not mark an unanswered suggestion as chosen.

## Step 6 — apply the answers and grill again

When the user says the questions are answered, read the file. An empty `Answer:` is unanswered: name those questions in chat and wait, unless the user says to defer them. Then:

1. Send the exact answers to the existing Sonnet agent. It applies them to its corrected draft and returns the complete updated draft. An answer with two materially different meanings, or one that directly contradicts another final answer (quote both), is not applied; it stays a user decision for the next round.
2. The parent writes the updated draft to `docs/stack.md`, so the file always holds every settled answer.
3. Start the next round at Step 2 with the updated `docs/stack.md` and the answered questions file as the baseline. Haiku drafts the fresh frontier: questions the answers unlocked, consequences of the answers for the rest of the stack, gaps the updated report exposes, and anything left unresolved in item 1. Steps 3 and 4 run in full, and Step 5 replaces the file with the next round's questions.

Every settled answer, and every deferral under `Decisions for you`, lives in `docs/stack.md`; that is what lets the next round clear the questions file.

## Step 7 — close the grill

The grill closes when a round's Step 4 leaves no decision for the user. The parent writes Sonnet's corrected draft from that round to `docs/stack.md`. Do not ask either specialist for another general review.

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

Reply with the file path, the number of rounds, counts by assessment, the number of user decisions, and the most consequential verified risk or `Needs proof` item. Do not repeat the report in chat.
