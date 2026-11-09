---
name: grill-requirements
description: Grill requirements in one session with a Haiku 5.5 questioner and Sonnet 5.5 answerer, or the GPT 6.1 Terra questioner and Sol answerer when either is unavailable or hits a limit. The models answer and debate everything they can, settle low-impact choices as recorded defaults, and interview the user in the session only for high-impact decisions, until nothing is left ambiguous.
disable-model-invocation: true
---

# grill-requirements

Turn the user's request into `docs/requirements.md` in rounds, in one session. In each round Haiku drafts the questions, Sonnet answers everything it can first — from evidence, or from its own expertise as a labelled default — Haiku grills Sonnet's answers, and Haiku checks Sonnet's candidate draft. Only a decision that passes the impact gate (Step 1) and that the debate cannot settle reaches the user, through an interview in the same session. Sonnet applies the answers, the parent updates `docs/requirements.md`, and the next round grills the updated requirements at once. Rounds repeat until one ends with no question for the user and a clean draft check; then a final round with a fresh Sonnet griller and an Opus answerer checks the whole document once more (Step 7).

Requirements are the first step for a new app and for every feature, and there is no architecture grill after them: what the system keeps, who may do what and which outside systems it depends on must be settled here. The grill ends with nothing ambiguous. A high-impact decision is either answered or deferred by the user in their own words; nothing is left vague.

Invoke explicitly as `/skill:grill-requirements [request]`, or `/skill:grill-requirements final` to run only the final round (Step 7) against the saved `docs/requirements.md`.

## Never

- Make a high-impact product, scope, UX, policy, priority, or trade-off decision for the user. A recommendation is not permission to adopt it.
- Ask the user a question that fails the impact gate. Take the default, record it under `Defaults`, and move on.
- Add a feature, option, layer, abstraction, dependency, future-proofing, cleanup, or requirement the user did not request. Mention a useful extra only as an optional suggestion; do not put it in the requirements.
- Ask what the request, earlier answers, `docs/requirements.md`, repository, or authoritative documentation already settles.
- Ask the same question twice. Treat the user's answer as final unless it directly contradicts another final answer; quote both and ask which wins.
- Let the parent model answer the grill, replace either specialist outside the authorised pairs below, or silently continue when a pinned specialist is unavailable.
- Have Haiku answer its own questions, grill the user, or reopen a user's answer. Haiku questions and challenges Sonnet's answers and drafts only, including how Sonnet applied a user's answer.
- Treat a model recommendation, default, assumption, or majority view as a user decision. A default is labelled as one until the user confirms or overrides it.
- Write trackers, logs, glossaries, architecture documents, tickets, tests, or implementation plans.
- Implement, commit, or change files other than `docs/requirements.md`.

## Specialists

Use only these OMP task agents. The main rounds (Steps 2–6) use one of the first two pairs; the final round (Step 7) always uses the final pair.

Primary pair:

- `requirements-haiku-griller` — `anthropic/claude-haiku-5-5`, high thinking. It drafts the current question frontier and challenges the answerer.
- `requirements-sonnet-answerer` — `anthropic/claude-sonnet-5-5`, high thinking. It answers from explicit evidence and drafts the requirements.

Authorised fallback pair:

- `requirements-terra-griller` — `openai-codex/gpt-6.1-terra`, high thinking. It performs the griller's questions, challenges and candidate-draft checks.
- `requirements-sol-answerer` — `openai-codex/gpt-6.1-sol`, high thinking. It performs the answerer's evidence-based answers, rebuttals and drafting.

Start with the primary pair unless the user requests the fallback pair. If either primary specialist fails (including a rate limit or quota error), is unavailable, or reports a model other than its pin, name the failure and switch both roles to the fallback pair. Restart the unfinished round from `docs/requirements.md`, the current repository evidence and the answers the user gave in this session; preserve settled user answers, but do not treat an unchecked candidate as accepted. Do not mix pairs or accept further results from the superseded pair. If either fallback specialist fails, reports another model, or is unavailable, stop and name it. No other fallback is authorised.

Final pair, for Step 7 only:

- `requirements-final-sonnet-griller` — `anthropic/claude-sonnet-5-5`, high thinking. It asks and challenges in the final round.
- `requirements-final-opus-answerer` — `anthropic/claude-opus-5-5`, high thinking. It answers, rebuts and writes the final draft.

The final pair has no fallback. If either fails (including a rate limit or quota error), is unavailable, or reports a model other than its pin, name the failure and stop: `docs/requirements.md` already holds the main rounds' result, and `/skill:grill-requirements final` resumes at Step 7.

Spawn each specialist with its named `agent`. Do not pass a per-call `model`; each agent file pins its model. Require the specialist to report its actual model identity before substantive work. Throughout Steps 2–6, “Haiku” means the active griller (Haiku or Terra), and “Sonnet” means the active answerer (Sonnet or Sol). Keep the selected pair for the rest of the main rounds.

Keep the agents alive across rounds. Use the first returned agent ID for follow-ups through `write agent://<id>` instead of spawning a fresh copy. If one is no longer running, for example because the run resumes in a new session, spawn a fresh one from the same pair: `docs/requirements.md` carries the state.

## Step 1 — collect evidence

Read the invocation request, this chat's settled answers, and `docs/requirements.md` if it exists. A deferral is only the user's: `Not sure — come back to this later` in an interview, or words to the same effect in chat. The models never defer a decision for the user.

Classify every potential unknown:

- **Fact** — repository or documentation can answer it. Find it; do not ask the user.
- **Already decided** — the user or existing requirements answered it. Preserve the answer exactly.
- **Default** — a choice with no final user answer that fails the impact gate. The models take the smallest sufficient option consistent with the request, earlier answers and the repository's conventions, record it with a one-line reason, and do not ask.
- **User decision** — a choice that passes the impact gate. Models may recommend; only the user may settle it.

### Impact gate

A choice goes to the user only when getting it wrong would change what the user gets or be costly to undo — at least one of:

1. It moves scope: a feature, user group, platform, or integration in or out.
2. It changes core behaviour a user of the application would notice, not a detail of it.
3. It is expensive to reverse later: stored data and its shape, a public interface or URL, authentication, permissions, privacy, or anything needing a migration, a rewrite, or someone else's sign-off.
4. It commits money, accounts, deadlines, legal or compliance exposure.
5. Only the user can know it and no default is safe: their intent, audience, budget, or risk tolerance.
6. Two of the user's own statements conflict.

Everything else is a default: naming, copy and error wording, ordering, layout details, empty-state text, sensible limits and timeouts, behaviour the existing product or a platform convention already implies, and anything a later edit can change in minutes without touching stored data. When unsure, ask whether reversing the choice after launch needs a migration, a rewrite, or another person; only a yes passes the gate.

An existing `docs/requirements.md` is the baseline. Preserve settled content outside the requested change. Do not renumber, reformat, or expand unrelated requirements.

## Step 2 — Haiku drafts the grill

Spawn the griller from the selected pair (`requirements-haiku-griller` or `requirements-terra-griller`) with:

- the user's request and settled chat answers;
- the path `docs/requirements.md` when it exists;
- the relevant repository paths and authoritative sources found in Step 1;
- an instruction to return the whole current frontier: every material question whose prerequisites are already settled.

Questions must test scope, observable behavior, failure and empty cases, constraints, exclusions, and contradictions only where relevant to this request. Because no architecture grill follows, they also cover, where the request touches them: the users and roles and what each may see and do, the data kept and for how long, the outside systems involved and what the user sees when one fails. No generic checklist and no speculative feature hunt. Haiku may still ask Sonnet about low-impact gaps; the gate decides only what reaches the user. Haiku also flags any requirement line still open to two readings; it is a question, never a line left as written.

## Step 3 — Sonnet answers first

Spawn the answerer from the selected pair (`requirements-sonnet-answerer` or `requirements-sol-answerer`) with Haiku's questions and the same evidence boundaries. Sonnet must answer each question as one of:

- `ANSWERED — <answer> — Evidence: <user statement, path, or source>`
- `DEFAULT — <choice taken> — Why safe: <which gate test it fails and why it is cheap to change>`
- `UNRESOLVED — <decision the user must make> — Impact: <the gate test it passes> — Recommendation: <smallest sufficient choice and brief trade-off>`

Sonnet must not convert a recommendation into an answer, or a high-impact decision into a default. It must not infer intent from common practice on a high-impact decision.

## Step 4 — Haiku grills Sonnet

Send Sonnet's complete response to the existing Haiku agent. Ask it to check every `ANSWERED` item against the evidence and challenge only:

- an unsupported inference;
- a contradiction;
- vague or untestable behavior material to the request;
- a missed prerequisite or consequence of an answer;
- a real user decision mislabeled as fact;
- a `DEFAULT` that passes the impact gate (it becomes `UNRESOLVED`);
- an `UNRESOLVED` that fails the impact gate (it becomes a `DEFAULT`).

For each challenge, send it to the existing Sonnet agent for one evidence-based rebuttal. Send that rebuttal back to Haiku for one rejoinder.

- Haiku accepts it → settled.
- Haiku and Sonnet still disagree about a fact → inspect the source and settle from evidence.
- It needs user intent or a trade-off → unresolved for Step 5 if it passes the impact gate, otherwise a default.
- Haiku and Sonnet still disagree whether it passes the impact gate → apply the "when unsure" test in Step 1; if that does not settle it, it goes to the user.
- It proposes functionality outside the request → discard it.

One rebuttal and one rejoinder per challenge. Do not make the models argue repeatedly.

Repeat Steps 2–4 within the round only when a settled answer exposes a new material question. Stop when Haiku reports no material question left except explicit user decisions.

Then ask the existing Sonnet agent for a candidate `docs/requirements.md` containing only settled material and labelled defaults, in the shape under Step 8. Haiku checks it against the request, evidence, and every user answer; it reports omissions, inventions, defaults presented as user requirements, and answers applied with a meaning other than the user's wording, not stylistic preferences. Sonnet corrects only those evidence-backed findings.

## Step 5 — interview the user

If no high-impact decision remains, go to Step 7.

Otherwise interview the user now, in this session, with the `ask` tool; do not write a questions file or wait for a later message. Before asking, test each decision against the impact gate once more and move any that fails it to the defaults. One form holds at most five questions; more go in a second form straight after. For each question:

- a `<fieldset>` whose `<legend>` is the decision in plain language;
- a `<p>` with `Why you:` (the gate test it passes), `Known:` (what is settled or found) and `Trade-off:` (of Sonnet's recommendation);
- one radio per concise choice, the recommendation labelled `(recommended)`, and a last radio `Not sure — come back to this later`. The form adds a free-text answer by itself.

After the questions, list the defaults taken this round in a `<ul>`, each with its one-line reason, followed by one optional `<textarea name="override_defaults">` for changing any of them. Omit the list when there are none.

Never preselect an answer. A form that times out or returns without an answer leaves that question unanswered; it is not the recommendation. Ask an unanswered question once more in the next form. If the user cancels the interview, write the settled draft as in Step 6 item 2, list the open questions in chat, and stop; rerunning the skill resumes from `docs/requirements.md`. Do not write a requirement for an unanswered decision.

## Step 6 — apply the answers and grill again

As soon as the interview returns, in the same run:

1. Send the exact answers to the existing Sonnet agent: the chosen option, the user's own words, `Not sure` as a deferral with any words given, and any default override. It applies them to its checked candidate draft and returns the complete updated draft; an overridden default becomes a settled answer. An answer with two materially different interpretations, or one that directly contradicts another final answer (quote both), is not applied; it stays unresolved for the next round.
2. The parent writes the updated draft to `docs/requirements.md`, so the file always holds every settled answer.
3. Start the next round at Step 2 with the updated `docs/requirements.md` as the baseline. Haiku drafts the fresh frontier: questions the answers unlocked, consequences of the answers, gaps the updated requirements expose, and anything left unresolved in item 1. Steps 3 and 4 run in full, including the candidate-draft check, and Step 5 interviews the user again only if a high-impact decision remains.

Every settled answer, and every deferral under `Open questions`, lives in `docs/requirements.md`; that is what lets a later session resume.

## Step 7 — final round

The main rounds end when a round finishes with no material question from Haiku, no decision left for the user, and a draft check with no omission or invention. The parent writes Sonnet's corrected draft to `docs/requirements.md`, then runs this final round in the same run. The main pair is not used again.

Spawn the final pair fresh. Give both the request, the settled chat answers, every interview answer from this session, `docs/requirements.md`, and the evidence from Step 1.

1. The final Sonnet reviews the whole document and drafts the remaining frontier: lines still open to two readings or not testable, contradictions between lines, gaps the main rounds missed (roles, kept data, outside systems, failure cases), defaults that pass the impact gate, and user answers applied with a meaning other than the user's wording. It never reopens a user's answer.
2. Opus answers each question as in Step 3 and returns a complete corrected draft in the shape under Step 8.
3. The final Sonnet challenges Opus's answers as in Step 4: one rebuttal from Opus and one rejoinder from the final Sonnet per challenge, settled by the same rules. It then checks Opus's draft as in Step 4's candidate-draft check, and Opus corrects only evidence-backed findings.
4. If a high-impact decision remains, interview the user as in Step 5. Opus applies the answers as in Step 6 item 1, the parent writes the updated draft to `docs/requirements.md`, and the final round repeats from item 1 with the same final pair.

The final round ends when the final Sonnet reports no material question, no decision is left for the user, and the draft check finds no omission or invention.

## Step 8 — close the grill

The grill closes when the final round ends. The parent writes Opus's corrected draft to `docs/requirements.md`.

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

## Defaults

- <low-impact choice the models took, not confirmed by the user> — <one-line reason>

## Open questions

- <decision the user explicitly deferred, with their words>
```

Omit empty sections. Keep the user's exact numbers and force words such as “must,” “only,” “never,” and “always.” Do not invent IDs or acceptance criteria. Create `docs/` only if needed. A default stays under `Defaults`, never under `Requirements`, until the user confirms or overrides it.

Reply with the file path, the number of main rounds and final rounds, what the final round changed (one line), the count of requirements, constraints, exclusions, defaults, and deferred questions, plus one sentence naming any limitation. Do not repeat the document in chat. Name the next command: `/skill:grill-stack` for a new app; within `feature`, the feature continues on its own.
