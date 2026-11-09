---
name: grill-stack
description: Research and stress-test technology-stack choices in one session with a Haiku 5.5 griller and Sonnet 5.5 researcher, or the GPT 6.1 Terra griller and Sol researcher when either is unavailable or hits a limit. The models answer and debate everything they can, record low-impact defaults, write docs/stack.md, and interview the user in the session only for high-impact decisions, until nothing is left open.
disable-model-invocation: true
---

# grill-stack

Research and stress-test the technology stack against the actual requirements, in rounds, in one session. In each round Haiku drafts the questions, Sonnet answers everything it can — from repository evidence and current primary sources, or from its own expertise as a labelled default — and drafts the report, and Haiku grills Sonnet's research, answers, and draft. Only a high-impact decision (the impact gate in Step 1) that the debate cannot settle reaches the user, through an interview in the same session. Sonnet applies the answers, the parent updates `docs/stack.md`, and the next round grills the updated report at once. Rounds repeat until one ends with no decision left for the user; then a final round with a fresh Sonnet griller and an Opus researcher checks the whole report once more (Step 7).

Invoke explicitly as `/skill:grill-stack [choices or question]`, or `/skill:grill-stack final` to run only the final round (Step 7) against the saved `docs/stack.md`.

## Never

- Choose, approve, reject, replace, or lock a high-impact technology for the user. A verdict or recommendation is advice, not a decision. A default only fills a gap: it never replaces a user-chosen or existing technology.
- Ask the user a question that fails the impact gate. Take the default, mark it `Origin: Default`, and move on.
- Add a service, framework, database, queue, cache, abstraction, dependency, deployment layer, or other technology that no requirement needs. Mention a useful extra only as an optional suggestion; do not add it to the chosen stack.
- Treat popularity, novelty, stars, benchmark headlines, or “industry standard” as sufficient evidence.
- State a version, support date, licence, price, quota, compatibility claim, or performance limit without a source and the date checked.
- Ask what the request, earlier answers, `docs/requirements.md`, `docs/stack.md`, manifests, lockfiles, repository, or authoritative documentation already settles.
- Ask the same question twice. A user answer is final unless it conflicts with another final answer; quote both and ask which wins.
- Let the parent model replace either specialist outside the authorised pairs below, answer the grill itself, or continue silently when a pinned specialist is unavailable.
- Have Haiku answer its own questions, grill the user, or reopen a user's answer. Haiku questions and challenges Sonnet's research, answers, and drafts only, including how Sonnet applied a user's answer.
- Treat a model suggestion, default, assumption, or consensus as a user choice.
- Edit `docs/requirements.md`, source code, manifests, lockfiles, configuration, ADRs, trackers, or implementation plans. Write only `docs/stack.md`.
- Implement, install, migrate, benchmark production systems, commit, or approve the stack.

## Specialists

Use only these OMP task agents. The main rounds (Steps 2–6) use one of the first two pairs; the final round (Step 7) always uses the final pair.

Primary pair:

- `stack-haiku-griller` — `anthropic/claude-haiku-5-5`, high thinking. It drafts the current question frontier and attacks the researcher's evidence and reasoning.
- `stack-sonnet-researcher` — `anthropic/claude-sonnet-5-5`, high thinking. It researches primary sources, evaluates choices, suggests alternatives, and drafts the report.

Authorised fallback pair:

- `stack-terra-griller` — `openai-codex/gpt-6.1-terra`, high thinking. It performs the griller's questions and bounded critique.
- `stack-sol-researcher` — `openai-codex/gpt-6.1-sol`, high thinking. It performs the source research, evidence-based answers, rebuttal and report drafting.

Start with the primary pair unless the user requests the fallback pair. If either primary specialist fails (including a rate limit or quota error), is unavailable, or reports a model other than its pin, name the failure and switch both roles to the fallback pair. Restart the unfinished round from `docs/stack.md`, the current repository evidence and the answers the user gave in this session; preserve settled user answers, but do not treat an unchecked candidate as accepted. Do not mix pairs or accept further results from the superseded pair. If either fallback specialist fails, reports another model, or is unavailable, stop and name it. No other fallback is authorised.

Final pair, for Step 7 only:

- `stack-final-sonnet-griller` — `anthropic/claude-sonnet-5-5`, high thinking. It asks and challenges in the final round.
- `stack-final-opus-researcher` — `anthropic/claude-opus-5-5`, high thinking. It researches, answers, rebuts and writes the final report.

The final pair has no fallback. If either fails (including a rate limit or quota error), is unavailable, or reports a model other than its pin, name the failure and stop: `docs/stack.md` already holds the main rounds' result, and `/skill:grill-stack final` resumes at Step 7.

Spawn each specialist with its named `agent`; do not pass a per-call `model`. Each agent file pins its model; require the specialist to report its actual model identity before substantive work. Throughout Steps 2–6, “Haiku” means the active griller (Haiku or Terra), and “Sonnet” means the active researcher (Sonnet or Sol). Keep the selected pair for the rest of the main rounds.

Keep the agents alive across rounds and send follow-ups through `write agent://<id>`. If one is no longer running, for example because the run resumes in a new session, spawn a fresh one from the same pair: `docs/stack.md` carries the state.

## Step 1 — establish the stack and constraints

Read:

- the invocation request and settled answers in chat;
- `docs/requirements.md` and `docs/stack.md` when present. A deferral is only the user's: `Not sure — come back to this later` in an interview, or words to the same effect in chat. The models never defer a decision for the user;
- manifests, lockfiles, deployment files, and configuration that identify the current stack;
- only the source needed to understand how a disputed technology is used.

Classify every stack item:

- **User-chosen** — the user explicitly chose it. Evaluate it; never replace it silently.
- **Existing** — the repository already depends on it. Report that fact without claiming the user chose it.
- **Candidate** — a model suggestion for a high-impact choice. It stays a suggestion until the user accepts it.
- **Default** — a model pick for a choice that fails the impact gate. It is used unless the user overrides it, and is never shown as user-chosen.
- **Fixed constraint** — a requirement or platform forces it.

Map each choice to the requirement or existing dependency it serves. A choice with no such reason is a simplicity question: suggest removing it, but do not remove it.

There is no architecture grill after this one, and `blueprint` builds the setup steps and project structure from this report. The report therefore names a choice, of any origin, or a user deferral for every area the requirements need: language and runtime, application framework, datastore, authentication, hosting and deployment, and, when the requirements have a user interface, the component library and styling approach. An area the requirements do not need is left out, not filled.

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

Spawn the griller from the selected pair (`stack-haiku-griller` or `stack-terra-griller`) with the choices, requirements, repository evidence, settled user constraints, and the path `docs/stack.md` when it exists. Ask for at most eight questions across the whole current frontier and at most three for one technology. Shared questions cover several choices once.

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
After the classifications, Sonnet includes a complete candidate `docs/stack.md` draft in the shape under Step 8. This is the only full drafting pass before Haiku's critique.

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
- a `DEFAULT` that passes the impact gate, or a `USER DECISION` that fails it;
- an area Step 1 says the requirements need with neither a choice nor a user deferral.

Send Haiku's complete critique to the existing Sonnet agent once. Sonnet must either concede and correct the draft, or maintain the claim with one direct piece of evidence. Its response ends with the complete corrected draft.

Send each maintained claim back to Haiku for one rejoinder: it accepts the evidence, or states the disagreement that remains. One rebuttal and one rejoinder per challenge; do not open another exchange in this round. A disagreement left after the rejoinder becomes `NEEDS PROOF` when measurement or stronger evidence could settle it, a user decision when it needs preference, budget, risk tolerance, or product intent and passes the impact gate, and a default otherwise. A disagreement about the gate itself goes to the user. Discard unrelated scope.

## Step 5 — interview the user

If no high-impact decision remains, go to Step 7.

Otherwise interview the user now, in this session, with the `ask` tool; do not write a questions file or wait for a later message. Before asking, test each decision against the impact gate once more and move any that fails it to the defaults. One form holds at most five questions; more go in a second form straight after. For each question:

- a `<fieldset>` whose `<legend>` is the choice in plain language;
- a `<p>` with `Why you:` (the gate test it passes), `Affects:` (the requirement it serves), `Facts:` (verified facts with source and date checked) and `Trade-off:` (the strongest trade-off; at most one real alternative and what would make it win);
- one radio per concise option, Sonnet's suggestion labelled `(suggested)`, and a last radio `Not sure — come back to this later`. The form adds a free-text answer by itself.

After the questions, list the defaults taken this round in a `<ul>` as `<area>: <pick> — <one-line reason>`, followed by one optional `<textarea name="override_defaults">` for changing any of them. Omit the list when there are none.

Never preselect an answer. A form that times out or returns without an answer leaves that question unanswered; it is not the suggestion. Ask an unanswered question once more in the next form. If the user cancels the interview, write the settled draft as in Step 6 item 2, list the open decisions in chat, and stop; rerunning the skill resumes from `docs/stack.md`. Never mark an unanswered suggestion as chosen.

## Step 6 — apply the answers and grill again

As soon as the interview returns, in the same run:

1. Send the exact answers to the existing Sonnet agent: the chosen option, the user's own words, `Not sure` as a deferral with any words given, and any default override. It applies them to its corrected draft and returns the complete updated draft; a chosen option or an overridden default becomes User-chosen. An answer with two materially different meanings, or one that directly contradicts another final answer (quote both), is not applied; it stays a user decision for the next round.
2. The parent writes the updated draft to `docs/stack.md`, so the file always holds every settled answer.
3. Start the next round at Step 2 with the updated `docs/stack.md` as the baseline. Haiku drafts the fresh frontier: questions the answers unlocked, consequences of the answers for the rest of the stack, gaps the updated report exposes, and anything left unresolved in item 1. Steps 3 and 4 run in full, and Step 5 interviews the user again only if a high-impact decision remains.

Every settled answer, and every deferral under `Decisions for you`, lives in `docs/stack.md`; that is what lets a later session resume.

## Step 7 — final round

The main rounds end when a round's Step 4 leaves no decision for the user. The parent writes Sonnet's corrected draft to `docs/stack.md`, then runs this final round in the same run. The main pair is not used again.

Spawn the final pair fresh. Give both the choices, `docs/requirements.md`, the settled chat answers, every interview answer from this session, `docs/stack.md`, and the repository evidence from Step 1.

1. The final Sonnet reviews the whole report and drafts at most eight remaining questions: claims without a current source, incompatibilities between choices, an area the requirements need with neither a choice nor a user deferral, defaults that pass the impact gate, unnecessary components, and user answers applied with a meaning other than the user's wording. It never reopens a user's answer.
2. Opus researches and answers each question as in Step 3, within the same source limits and reusing sources already cited, and returns a complete corrected report in the shape under Step 8.
3. The final Sonnet challenges Opus's research, answers and report as in Step 4: at most five challenges, one rebuttal from Opus and one rejoinder from the final Sonnet per challenge, settled by the same rules.
4. If a high-impact decision remains, interview the user as in Step 5. Opus applies the answers as in Step 6 item 1, the parent writes the updated report to `docs/stack.md`, and the final round repeats from item 1 with the same final pair.

The final round ends when its challenges leave no decision for the user.

## Step 8 — close the grill

The grill closes when the final round ends. The parent writes Opus's corrected report to `docs/stack.md`. Do not ask any specialist for another general review.

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

Reply with the file path, the number of main rounds and final rounds, what the final round changed (one line), counts by assessment, the number of defaults taken and of user decisions, and the most consequential verified risk or `Needs proof` item. Do not repeat the report in chat. Name the next command: `/skill:blueprint` for a new app; within `feature`, the feature continues on its own.
