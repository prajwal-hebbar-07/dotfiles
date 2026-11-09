---
name: grill-stack
description: Research and stress-test technology-stack choices in rounds with Haiku/Sonnet, or an authorised GPT 6.1-terra griller and GPT 6.1-sol researcher fallback pair. Give evidence-backed suggestions, record low-impact defaults, and write docs/stack.md. Only high-impact decisions go to docs/stack-questions.md; apply the user's answers and grill again until nothing is left open.
disable-model-invocation: true
---

# grill-stack

Research and stress-test the technology stack against the actual requirements, in rounds. In each round Haiku drafts the questions, Sonnet answers from repository evidence and current primary sources and drafts the report, and Haiku grills Sonnet's research, answers, and draft. Low-impact picks are taken as labelled defaults; the user owns every high-impact stack decision (the impact gate in Step 1) and answers them in `docs/stack-questions.md`. After the user answers, Sonnet applies the answers, the parent updates `docs/stack.md`, and the next round grills the updated report. Rounds repeat until one ends with no decision left for the user.

Invoke explicitly as `/skill:grill-stack [choices or question]`.

## Never

- Choose, approve, reject, replace, or lock a high-impact technology for the user. A verdict or recommendation is advice, not a decision. A default only fills a gap: it never replaces a user-chosen or existing technology.
- Ask the user a question that fails the impact gate. Take the default, mark it `Origin: Default`, and move on.
- Add a service, framework, database, queue, cache, abstraction, dependency, deployment layer, or other technology that no requirement needs. Mention a useful extra only as an optional suggestion; do not add it to the chosen stack.
- Treat popularity, novelty, stars, benchmark headlines, or “industry standard” as sufficient evidence.
- State a version, support date, licence, price, quota, compatibility claim, or performance limit without a source and the date checked.
- Ask what the request, earlier answers, `docs/requirements.md`, `docs/stack.md`, `docs/stack-questions.md`, manifests, lockfiles, repository, or authoritative documentation already settles.
- Ask the same question twice. A user answer is final unless it conflicts with another final answer; quote both and ask which wins.
- Let the parent model replace either specialist outside the authorised pairs below, answer the grill itself, or continue silently when a pinned specialist is unavailable.
- Have Haiku answer its own questions, grill the user, or reopen a user's answer. Haiku questions and challenges Sonnet's research, answers, and drafts only, including how Sonnet applied a user's answer.
- Treat a model suggestion, default, assumption, or consensus as a user choice.
- Edit `docs/requirements.md`, source code, manifests, lockfiles, configuration, ADRs, trackers, or implementation plans. Write only `docs/stack.md` and `docs/stack-questions.md`.
- Implement, install, migrate, benchmark production systems, commit, or approve the stack.

## Specialists

Use only these OMP task agents, in one of these pairs:

Primary pair:

- `stack-haiku-griller` — `anthropic/claude-haiku-5-5`, high thinking. It drafts the current question frontier and attacks the researcher's evidence and reasoning.
- `stack-sonnet-researcher` — `anthropic/claude-sonnet-5-5`, high thinking. It researches primary sources, evaluates choices, suggests alternatives, and drafts the report.

Authorised fallback pair:

- `stack-terra-griller` — `openai-codex/gpt-6.1-terra`, high thinking. It performs the griller's questions and bounded critique.
- `stack-sol-researcher` — `openai-codex/gpt-6.1-sol`, high thinking. It performs the source research, evidence-based answers, rebuttal and report drafting.

Start with the primary pair unless the user requests the fallback pair. If either primary specialist fails (including a rate limit or quota error), is unavailable, or reports a model other than its pin, name the failure and switch both roles to the fallback pair. Restart the unfinished round from `docs/stack.md`, the current repository evidence and any answered `docs/stack-questions.md`; preserve settled user answers, but do not treat an unchecked candidate as accepted. Do not mix pairs or accept further results from the superseded pair. If either fallback specialist fails, reports another model, or is unavailable, stop and name it. No other fallback is authorised.

Spawn each specialist with its named `agent`; do not pass a per-call `model`. Each agent file pins its model; require the specialist to report its actual model identity before substantive work. Throughout the steps below, “Haiku” means the active griller (Haiku or Terra), and “Sonnet” means the active researcher (Sonnet or Sol). Keep the selected pair for the rest of the run.

Keep both agents alive across rounds and send follow-ups through `write agent://<id>`. If either is no longer running, for example because the user answered in a new session, spawn a fresh one from the selected pair: `docs/stack.md` and `docs/stack-questions.md` carry the state.

## Step 1 — establish the stack and constraints

Read:

- the invocation request and settled answers in chat;
- `docs/requirements.md`, `docs/stack.md`, and `docs/stack-questions.md` when present; every answered question in the questions file is a settled user answer, and `defer` is an explicit deferral;
- manifests, lockfiles, deployment files, and configuration that identify the current stack;
- only the source needed to understand how a disputed technology is used.

Classify every stack item:

- **User-chosen** — the user explicitly chose it. Evaluate it; never replace it silently.
- **Existing** — the repository already depends on it. Report that fact without claiming the user chose it.
- **Candidate** — a model suggestion for a high-impact choice. It stays a suggestion until the user accepts it.
- **Default** — a model pick for a choice that fails the impact gate. It is used unless the user overrides it, and is never shown as user-chosen.
- **Fixed constraint** — a requirement or platform forces it.

Map each choice to the requirement or existing dependency it serves. A choice with no such reason is a simplicity question: suggest removing it, but do not remove it.

### Impact gate

A stack decision goes to the user only when getting it wrong would change what the user gets or be costly to undo — at least one of:

1. It is a foundation that is expensive to leave: language or runtime, application framework, primary datastore, hosting or deployment platform, identity or auth provider.
2. It commits money, quotas, accounts, or a contract: a paid or metered service, a plan tier, a vendor the user must sign up with.
3. It brings lock-in, a licence obligation (copyleft, source-available, commercial), or a security or compliance exposure.
4. It conflicts with a requirement, a user-chosen technology, or another of the user's statements.
5. It depends on what only the user knows and has not said: team skills, budget, existing accounts, risk or lock-in tolerance.

Everything else is a default: utility libraries, dev tooling, formatters, linters and test runners when the repository implies none, a version within a supported range, and any pick inside an already-chosen ecosystem that can be swapped later without a data migration or rewrite. Take the smallest sufficient option — the platform or standard library first, then what the existing stack already uses. When unsure, ask whether swapping it after launch needs a migration, a rewrite, or money; only a yes passes the gate.

If there is no requirements file, use only requirements stated by the user or evidenced in the repository. Missing product intent is a user decision, not permission to invent a requirement.

## Step 2 — Haiku drafts the grill

Spawn the griller from the selected pair (`stack-haiku-griller` or `stack-terra-griller`) with the choices, requirements, repository evidence, settled user constraints, and the paths `docs/stack.md` and `docs/stack-questions.md` when they exist. Ask for at most eight questions across the whole current frontier and at most three for one technology. Shared questions cover several choices once.

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

Spawn the researcher from the selected pair (`stack-sonnet-researcher` or `stack-sol-researcher`) with Haiku's questions and the evidence boundaries. Sonnet researches only facts needed to classify a choice. It uses repository evidence first, then at most two external primary sources per technology and twelve external sources per round; a source already cited in an earlier round is reused, not looked up again. One source may support several claims. Secondary sources are allowed only when no primary source covers the point, and must be labelled secondary. Stop looking once the available evidence supports a classification; do not research every property of every technology.

For each question return one classification:

- `SUPPORTED — <answer> — Evidence: <path or URL, checked YYYY-MM-DD>`
- `CONFLICT — <concrete mismatch> — Evidence: <requirement and source>`
- `NEEDS PROOF — <benchmark, spike, or missing fact needed> — Why: <reason>`
- `DEFAULT — <pick taken> — Why safe: <which gate test it fails and why it is cheap to swap>`
- `USER DECISION — <high-impact trade-off only the user can settle> — Impact: <the gate test it passes> — Suggestion: <smallest sufficient option and trade-off>`

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
- a user answer applied with a meaning other than the user's wording;
- a `DEFAULT` that passes the impact gate, or a `USER DECISION` that fails it.

Send Haiku's complete critique to the existing Sonnet agent once. Sonnet must either concede and correct the draft, or maintain the claim with one direct piece of evidence. Its response ends with the complete corrected draft.

Do not send Sonnet's response back to Haiku and do not open another debate exchange in this round. Any disagreement left after this exchange becomes `NEEDS PROOF` when measurement or stronger evidence could settle it, a user decision when it needs preference, budget, risk tolerance, or product intent and passes the impact gate, and a default otherwise. A disagreement about the gate itself goes to the user. Discard unrelated scope.

## Step 5 — write the round's questions to a file

If no high-impact decision remains, go to Step 7.

Otherwise write the whole current frontier of high-impact decisions to `docs/stack-questions.md` instead of asking in chat. Before writing, test each against the impact gate once more and move any that fail it to the defaults. Clear the file first and write only this round's questions, numbered from Q1: earlier answers already live in `docs/stack.md`, which Step 6 updated before this round began. Use this shape:

```markdown
# Stack questions

Write your answer on the `Answer:` line under each question, then say they are answered. `yes` accepts the suggestion; `defer` leaves the decision open. To override a default, write the change under it.

## Round <N>

### Q1. <the choice in plain language>

- Why you: <the gate test it passes, in one line>
- Affects: <the requirement it serves>
- Facts: <verified facts — source, checked YYYY-MM-DD>
- Suggestion: <Sonnet's smallest sufficient option>
- Trade-off: <the strongest trade-off; at most one real alternative and what would make it win>
- Choices: <concise options, worded so `yes` accepts the suggestion when possible>

Answer:

## Defaults taken this round (no answer needed)

- <area>: <pick> — <one-line reason>
```

Omit the defaults section when there are none.

Reply with the file path, the round number, and the number of questions, then wait. Do not mark an unanswered suggestion as chosen.

## Step 6 — apply the answers and grill again

When the user says the questions are answered, read the file. An empty `Answer:` is unanswered: name those questions in chat and wait, unless the user says to defer them. Then:

1. Send the exact answers, and any change written under a default, to the existing Sonnet agent. It applies them to its corrected draft and returns the complete updated draft; an overridden default becomes User-chosen. An answer with two materially different meanings, or one that directly contradicts another final answer (quote both), is not applied; it stays a user decision for the next round.
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

- Origin: User-chosen | Existing | Candidate | Default | Fixed constraint
- Serves: <requirement or existing need>
- Assessment: Supported | Conflict | Needs proof | Default | User decision
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

Omit empty sections and fields. Preserve existing user choices exactly. Suggestions and defaults never change `Origin` to `User-chosen`; only the user's answer does. Do not invent decision IDs, scores, weighted matrices, or a single “best stack” verdict.

Reply with the file path, the number of rounds, counts by assessment, the number of defaults taken and of user decisions, and the most consequential verified risk or `Needs proof` item. Do not repeat the report in chat.
