---
name: grill-requirements
description: Grill a requirements request through a Haiku 5.5 high questioner and a Sonnet 5.5 high answerer, ask the user only for unresolved decisions, and write docs/requirements.md. Use when the user asks to grill, clarify, or turn a request into requirements.
disable-model-invocation: true
---

# grill-requirements

Turn the user's request into `docs/requirements.md`. Haiku drafts the questions and grills only Sonnet's answers. Sonnet answers first from evidence. Ask the user only when the request, repository, documentation, and model debate cannot settle a decision.

Invoke explicitly as `/skill:grill-requirements [request]`.

## Never

- Make a product, scope, UX, policy, priority, or trade-off decision for the user. A recommendation is not permission to adopt it.
- Add a feature, option, layer, abstraction, dependency, future-proofing, cleanup, or requirement the user did not request. Mention a useful extra only as an optional suggestion; do not put it in the requirements.
- Ask what the request, earlier answers, `docs/requirements.md`, repository, or authoritative documentation already settles.
- Ask the same question twice. Treat the user's answer as final unless it directly contradicts another final answer; quote both and ask which wins.
- Let the parent model answer the grill, replace either specialist, or silently continue when a pinned specialist is unavailable.
- Have Haiku answer its own questions or grill the user. Haiku questions and challenges Sonnet's answers only.
- Treat a model recommendation, assumption, or majority view as a user decision.
- Write trackers, logs, glossaries, architecture documents, tickets, tests, or implementation plans.
- Implement, commit, or change files other than `docs/requirements.md`.

## Specialists

Use only these OMP task agents:

- `requirements-haiku-griller` — `anthropic/claude-haiku-5-5`, high thinking. It drafts the current question frontier and challenges Sonnet.
- `requirements-sonnet-answerer` — `anthropic/claude-sonnet-5-5`, high thinking. It answers from explicit evidence and drafts the requirements.

Spawn each specialist with its named `agent`. Do not pass a per-call `model`; the agent files pin it. If either agent fails, reports another model, or is unavailable, stop and name the missing specialist. Do not substitute the parent or another model.

Keep both agents alive for the run. Use the first returned agent ID for follow-ups through `write agent://<id>` instead of spawning a fresh copy.

## Step 1 — collect evidence

Read the invocation request, this chat's settled answers, and `docs/requirements.md` if it exists. Inspect only repository files needed to answer factual questions. Look up authoritative external documentation only when the request depends on it.

Classify every potential unknown:

- **Fact** — repository or documentation can answer it. Find it; do not ask the user.
- **Already decided** — the user or existing requirements answered it. Preserve the answer exactly.
- **User decision** — intent or a trade-off with no final user answer. Models may recommend; only the user may settle it.

An existing `docs/requirements.md` is the baseline. Preserve settled content outside the requested change. Do not renumber, reformat, or expand unrelated requirements.

## Step 2 — Haiku drafts the grill

Spawn `requirements-haiku-griller` with:

- the user's request and settled chat answers;
- the path `docs/requirements.md` when it exists;
- the relevant repository paths and authoritative sources found in Step 1;
- an instruction to return the whole current frontier: every material question whose prerequisites are already settled.

Questions must test scope, observable behavior, failure and empty cases, constraints, exclusions, and contradictions only where relevant to this request. No generic checklist and no speculative feature hunt.

## Step 3 — Sonnet answers first

Spawn `requirements-sonnet-answerer` with Haiku's questions and the same evidence boundaries. Sonnet must answer each question as one of:

- `ANSWERED — <answer> — Evidence: <user statement, path, or source>`
- `UNRESOLVED — <decision the user must make> — Recommendation: <smallest sufficient choice and brief trade-off>`

Sonnet must not convert a recommendation into an answer. It must not infer intent from common practice.

## Step 4 — Haiku grills Sonnet

Send Sonnet's complete response to the existing Haiku agent. Ask it to check every `ANSWERED` item against the evidence and challenge only:

- an unsupported inference;
- a contradiction;
- vague or untestable behavior material to the request;
- a missed prerequisite or consequence of an answer;
- a real user decision mislabeled as fact.

For each challenge, send it to the existing Sonnet agent for one evidence-based rebuttal. Send that rebuttal back to Haiku for one rejoinder.

- Haiku accepts it → settled.
- Haiku and Sonnet still disagree about a fact → inspect the source and settle from evidence.
- It needs user intent or a trade-off → unresolved for Step 5.
- It proposes functionality outside the request → discard it.

One rebuttal and one rejoinder per challenge. Do not make the models argue repeatedly.

Repeat Steps 2–4 only when a settled answer exposes a new material question. Stop when Haiku reports no material question left except explicit user decisions.

## Step 5 — ask only unresolved decisions

If decisions remain, ask the whole current frontier in one chat round. For each question include:

1. the decision in plain language;
2. what is already known;
3. Sonnet's smallest sufficient recommendation and its main trade-off;
4. concise choices, worded so `yes` accepts the recommendation when possible.

Wait for the user's answers. Do not write a final requirement for an unanswered decision. A user may explicitly defer it; record that as open, not settled.

After the answer, send the exact user wording to Sonnet to update its answers and candidate requirements. Send Sonnet's revised answer to Haiku for the same evidence check. Haiku may challenge Sonnet's interpretation of the answer, but not the user's decision itself. Ask a follow-up only if the wording has two materially different interpretations.

## Step 6 — write the requirements

Ask the existing Sonnet agent for a final, minimal `docs/requirements.md` draft containing only settled material. Haiku checks the draft against the request, evidence, and user answers; it reports omissions or inventions, not stylistic preferences. Sonnet may correct only those evidence-backed findings. The parent writes the accepted draft.

Use this shape unless an existing file already has a clear structure:

```markdown
# Requirements

## Goal

<what the user is trying to achieve>

## Requirements

- <observable required behavior>

## Constraints

- <explicit limit, dependency, platform, or quality constraint>

## Out of scope

- <explicit exclusion>

## Open questions

- <only a decision the user explicitly deferred>
```

Omit empty sections. Keep the user's exact numbers and force words such as “must,” “only,” “never,” and “always.” Do not invent IDs or acceptance criteria. Create `docs/` only if needed.

Reply with the file path, the count of requirements, constraints, exclusions, and deferred questions, plus one sentence naming any limitation. Do not repeat the document in chat.
