---
name: debate-requirements
description: >
  Takes an app's requirements from first words to ready-to-approve in Oh My
  Pi: captures them, grills them, has them reviewed, and fixes the review,
  with models answering first. Claude Haiku 5.5 captures, drafts each round,
  folds answers in and responds to the review; Claude Sonnet 5.5 challenges
  it; GPT-6 Luna takes what is still open or disputed; Claude Opus 5.5
  reviews the grilled result until it is approve-ready. Questions only the
  user can answer go to docs/grill/requirements-questions.md, best-practice
  defaults go there pre-filled for a skim, and what the models settled from
  the user's own words, the repo or a sourced fact is folded in and listed.
  Replaces Claude Code's /requirements, /grill-requirements and
  /review-requirements, and writes the same files. Use when the user says
  "/skill:debate-requirements".
argument-hint: "[requirements text | done | status | approve]"
disable-model-invocation: true
---

# debate-requirements

Claude Code's `/requirements`, `/grill-requirements` and
`/review-requirements` in one loop, with fewer questions for the user. The
rules are theirs: `capture-rules.md`, `grill-rules.md` and `review-rules.md`
in this skill's directory are those three skills, linked, with their
templates (`requirements-template.md`, `project-template.md`,
`log-template.md`, `coverage-template.md`, `probes.md`). Follow them in full,
except where this file says otherwise. What changes is who answers: models
settle every question they can prove from the user's own words, the repo or a
source, pre-fill the ones where a best-practice default is enough, and argue
out the review between them. The user answers the rest, skims the defaults,
confirms once at the end, and approves.

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Models

| Role | `task` agent | Model (its frontmatter) | Does |
| --- | --- | --- | --- |
| Drafter | `debate-drafter` | `anthropic/claude-haiku-5-5`, medium | Captures, drafts each round, replies to objections, folds answers into the files |
| Challenger | `debate-challenger` | `anthropic/claude-sonnet-5-5`, medium | Checks every draft question and proposal, adds what was missed, answers Luna |
| Tiebreaker | `debate-tiebreaker` | `openai-codex/gpt-6-luna`, medium | Takes every question still open or disputed after the first two; runs the fresh-eyes check |
| Reviewer | `debate-reviewer` | `anthropic/claude-opus-5-5`, medium | Reviews the grilled requirements and answers the drafter's responses (`review-rules.md`) |

Start each as a `task` with `agent` set to its name and no `model` field;
the agent files (`omp/agents/` in the dotfiles, linked by `omp/link-skills`)
pin the model. If one is missing or cannot start (not logged in, quota), or
its result names a different model, stop and say which; never substitute
another agent or model, or do its part yourself.

You, the session, are the **runner**: you start the sub-agents in order,
check their evidence, write the tracker, log and questions file, and reply.
You never draft a question, settle one, or fold an answer yourself.

Every sub-agent starts blank. Give it: the repo root, the absolute paths of
the rule files it needs (resolve this skill's directory with `realpath`), the
files it reads and writes, its step below, and, for capture, the user's words
verbatim. Nothing from the chat beyond that.

## Never

Everything in the `Never` lists of `capture-rules.md` and `grill-rules.md`
holds, with these changes:

- "Answer for the user" becomes: a model settles a question only with a
  quoted source the runner has checked (**Round**, item 6). Everything else
  is the user's.
- Never settle, and never pre-fill: the confirm round; a contradiction
  between two things the user said; what the app is for, who it is for, or
  what is in or out of this version; money, budget, pricing, a legal or
  compliance risk to accept; reopening or changing an `X`; a `Q` the user
  parked as their own doubt.
- Never let a model's answer reach `requirements.md` without the log line
  that names it settled by models, with the evidence.
- Never change a model's classification by your own judgement. You only
  demote: a `settle` whose evidence fails your check becomes `default`; any
  item on the never-settle list becomes `user`.
- Never reword the user's words, renumber or reuse an ID. After every
  sub-agent edit to `requirements.md`, check every ID that was there before
  is still there (`grep -oE '\*\*[RNCXAQ][0-9]+\*\*'`, before and after);
  if one is gone, restore the file from your copy and stop with what broke.
- Do only what the request needs. A model's extra (feature, option,
  "nice to have") is a `user` question, recommended `no` unless a
  requirement needs it.
- Ask what is already settled. Every model reads the log, `requirements.md`,
  `later.md` and `glossary.md` first; a question already answered in any
  round is dropped, not asked again.
- Stage, commit or push.

## Files

Those of the three rule files, plus one:

| File | Role |
| --- | --- |
| `docs/grill/requirements-debate.md` | The models' working notes: each round's draft, objections, replies and rulings. Append only. Read by the runner and the models, never by the user |

The tracker's **Next action** names `/skill:debate-requirements` wherever the
rules name `/requirements` or `/grill-requirements`.

## Step 1 — state

Run Step 1 of `capture-rules.md`, then read the files Step 1 of
`grill-rules.md` reads. Then by argument and status:

| Status / argument | Do |
| --- | --- |
| `status` | Print the capture lines (capture Step 3), once grilling the grill status lines, and the last review's verdict and open findings. Change nothing |
| `approve` | Only when the status is `grilled` and the last review is `approve-ready` on the current hash; otherwise say what is missing. Then capture Step 3's approve, with **Next action** `Run /skill:debate-stack` |
| none of the files, or `capturing`, with text | **Capture** |
| `capturing`, no text | Reply "What else? Or say done." |
| `capturing` or `captured`, `done` | **Capture** Step 5 (status `captured`), then start the grill as grill Step 1 does with no log, then **Next** |
| `captured` | Start the grill as above, then **Next** |
| `grilling` | **Ingest**, then **Next** |
| `grilled` or `approved`, with text | Reopen as capture's **Reopening** says, then **Capture** |
| `grilled` | Reply with the counts and `Review docs/requirements.md, then /skill:debate-requirements approve` |

## Next

After every step, take the first of these that applies, in the same run,
until one says stop:

1. Open questions in the log: write the questions file and stop.
2. No round has run since the last change to `requirements.md`, or grill
   Step 5 items 1–4 do not hold: **Round** (the pre-mortem when Step 5 item
   4 is what is missing). A round whose draft finds no question counts as
   run.
3. The fresh-eyes check is not current on this hash: **Round** (fresh-eyes).
4. The last review is not on this hash, or has findings the models can
   still move: **Review**.
5. The review left findings for the user: **Review questions**, then stop.
6. The confirm round is not answered `yes` and `none` on this hash: write it
   to the questions file and stop.
7. Otherwise finish (**End**).

If a whole pass through this list changes neither `requirements.md`, the
log nor the review report, stop and say what is stuck instead of going round
again.

## Capture

Drafter: apply `capture-rules.md` Step 2 or 4 to the user's words, given
verbatim, and update `project.md` as it says. Return the changed-items lines.
Run the ID check. Reply with those lines, then "Keep going, or say done."

## Ingest

Drafter: apply grill Step 2 to `requirements-questions.md` and the user's
message: blank `Answer:` takes the recommendation (a pre-filled default
included), the confirm round's blank stays open, volunteered text is filed,
and a line `reopen G<N>.<k>: <why>` under **Anything else** reopens that
settled question: log it under the question, revert what it became, and
carry it as a `user` question. Run the ID check.

## Round

One round is the grill's Step 3 and 4, or the closing round grill Step 5
calls for (pre-mortem, then fresh-eyes), run as a debate. The confirm round
is not a debate: it goes straight to the user, and only once the review is
`approve-ready` (**Next**, item 6), so the user confirms the final version.

Each question ends in one class. Give every model these definitions:

| Class | When |
| --- | --- |
| `settle` | A quoted source answers it: the user's own words in the docs or the log, the repo, or a fetched page |
| `default` | Not on the never-settle list, and a reasonable owner would accept the answer without thinking: the plain meaning of the user's words, the usual convention for this kind of app, or the strictest safe option, and cheap to change later |
| `user` | A real choice between answers that differ in cost, behaviour or scope, or anything on the never-settle list |
| `drop` | Already answered in the log, or a duplicate of another block |

Lean to `default` when a question has one obvious answer: the user skims
defaults in seconds but thinks about each `user` question.

1. **Draft** (drafter). Look up facts (grill Step 3), then list the whole
   frontier, grill Step 4 items 1–7, with no cap. For the fresh-eyes round
   the tiebreaker first runs the fresh-eyes prompt from `probes.md` cold
   (only the two file paths) and its questions are the frontier. Append
   `## Round N · <date>` and one block per question to the debate file:

   ```
   ### D<N>.<k> <title> · touches R3, N1
   Question: <one idea, five lines at most>
   Known: <fact and source, or omit>
   Proposal: settle | default | user | drop
   Answer: <the recommended answer, for every class but drop; the strictest that fits>
   Evidence: <for settle: path:line and the exact quote, or URL and the quoted passage>
   ```

2. **Challenge** (challenger). For each block append `Challenger: agree` or
   `Challenger: object — <reason and evidence>`. Object when the evidence
   does not say what the answer says, the question is the user's call, the
   default is looser than the requirement or adds an extra, the question is
   already answered in the log, or it duplicates another. Append any
   question the draft missed as a new block with its own proposal.
3. **Reply** (drafter). Under each objection, and each block the challenger
   added, append `Drafter: concede` (take the challenger's position) or
   `Drafter: rebut — <evidence>`. One reply; no second round.
4. **Tiebreak** (tiebreaker). Take every block still disputed and every
   block both agree is `user`. Under each append `Ruling: settle | default |
   user | drop — <answer and evidence>`, by the class definitions.
5. **Answer** (challenger). Under each ruling that moved a block off `user`,
   append `Challenger: accept` or `Challenger: object — <evidence>`. An
   object leaves it `user`.
6. **Check** (runner). Each block's final class is the agreed one, else the
   ruling, else `user`. For every `settle`: confirm the quoted text is at
   that path and line (`grep -nF`), or `read` the URL and find the passage;
   failed, it becomes `default`. Apply the never-settle list. Leave out
   `drop` blocks and any the log already answers. `user` questions past the
   round's 15 are held for the next round (grill Step 4), not dropped.
7. **Log** (runner). Append every surviving block to `requirements-log.md`
   as `G<N>.<k>` in `log-template.md`'s form, adding under `Recommended:`
   a line `Class: settled by models | default | user`. A settled one gets
   `Answer: <the answer>` and `Settled by: <models that agreed> — <evidence>`.
8. **Fold** (drafter). Fold every settled answer into the files as grill
   Step 2 does, sourced `(from G<N>.<k>, settled by models)`, and fill each
   `Became:`. Run the ID check.
9. **Ask or go on.** No `user` and no `default` left this round: back to
   **Next**. Otherwise write the questions file and stop.

## Review

The grilled file goes to the reviewer, then the reviewer and the drafter
settle the findings between them, as the dispute rules in `review-rules.md`
(**Responses and disputes**) and capture's **Respond to a review** say.

1. **Review** (reviewer). `review-rules.md` Steps 1–4 and **Responses and
   disputes**: a review, or a re-review that first handles each `Response:`.
   Skip its advisor and its Step 5 reply; return the verdict and the counts.
   Give it this rule too: a finding whose question the user answered
   `declined: <reason>` in the log is `declined`, with that reason.
2. **Respond** (drafter), unless the verdict is `approve-ready`: capture's
   **Respond to a review**, one `Response:` under each open finding. Run the
   ID check.
3. **Again or on.** Any `accepted` or `rebutted` response: back to 1, as a
   re-review. Otherwise back to **Next**.

The runner overrides the **Next action** the reviewer writes with the one
**Next** leads to.

## Review questions

Each finding the models could not settle becomes a `user` question in a new
grill round `N`, logged and written like any other: `contested` and
`intent` findings, and open ones whose fix asks the user for a value. Title
it `<RR ID> · <finding>`, put the reviewer's and the author's evidence under
**Known**, and recommend the reviewer's fix when it needs nothing from the
user, else say there is no recommendation and give the trade-off. The
questions file says that `declined: <reason>` keeps the file as it is. The
answers are ingested like any round; the next review reads them.

## Questions file

Replace `docs/grill/requirements-questions.md` only once every answer in the
old one is in the log. Grill Step 4's shape, in three parts:

```
# Requirements grill · Round N · <date>

<u> need you · <d> pre-filled · <s> settled by the models.
Leave an `Answer:` blank to take the recommendation or the pre-filled
answer. Write under it only to change it; everything down to the `---` is
your answer. Also: `idk`, `n/a: <reason>`, `defer: <reason>`.
Then run `/skill:debate-requirements`.

## Needs you

<the `user` questions, grouped under `###` themes, in grill Step 4's
question format, most important first, at most 15 (say how many are held)>

## Pre-filled · skim and change only what is wrong

### ❓ G<N>.<k> · <title> · touches R3

<question, one or two lines>

➡️ Pre-filled: <the default>

Answer:

---

## Settled by the models · nothing to do

- G<N>.<k> <title> → <answer> (<evidence, short>)

To reopen one, write `reopen G<N>.<k>: <why>` under Anything else.

## Anything else

(Anything about the app that no question asked. Leave blank if none.)
```

The confirm round keeps grill Step 5's wording, with no pre-filled or
settled part; a blank there does not count.

## Reply and tracker

Update `project.md` as grill Step 4 does. In chat, only:

```
Round N · <u> need you · <d> pre-filled · <s> settled (<l> by Luna)
in docs/grill/requirements-questions.md
<themes with counts>
Review: <last verdict, findings fixed, conceded, left for you>, if one ran
Answer there, then run /skill:debate-requirements.
Slides of the requirements: /requirements-slides in Claude Code.
```

## End

When the confirm round is `yes` and `none`, the review is `approve-ready` on
this hash and grill Step 5 holds: finish as grill Step 5 says (`Status:
grilled`), with **Next action** `Review docs/requirements.md, then run
/skill:debate-requirements approve`. Reply with the final counts, the review
verdict, and that line. Approval stays the user's command: the skill never
sets `approved` itself.
