---
name: review-requirements
description: >
  Reviews docs/requirements.md as an independent reviewer, usually when
  another model captured or grilled it: checks fidelity to what the user said,
  measurability, contradictions, missing categories and buildability, and
  writes ranked findings with a verdict to
  docs/review/requirements-review.md. Never edits the requirements; each
  finding carries the /requirements change that would fix it. Use when the
  user says "/review-requirements" or wants the requirements reviewed.
argument-hint: "[status | <focus text>]"
disable-model-invocation: true
---

# review-requirements

Read `docs/requirements.md` cold, as a reviewer who did not write it, and say
what is wrong with it, how bad, and what change fixes it. The author is
usually another model, so nothing about how it was captured is evidence that
it is right: the file, the user's recorded words, and the facts are. The
review does not interview, add requirements, or edit. It ends in a verdict the
user can act on, and every finding names the `/requirements` change that would
fix it.

Files, all in the app repo (git root, else the current directory):

| File | Role |
| --- | --- |
| `docs/requirements.md` | Under review. Read only |
| `docs/glossary.md` | Read only |
| `docs/grill/requirements-log.md` | Read only, and only to see what the user answered, word for word. A rationale there is not evidence that an item is right |
| `docs/project.md` | Tracker: only **Next action** and the log change |
| `docs/review/requirements-review.md` | The report. One `## Review N` per run, newest last |

Same mechanics as `/review-stack`, `/review-architecture` and
`/review-design`; keep the four in step.

## Never

- Edit any file except `docs/review/requirements-review.md` and
  `docs/project.md`. The fix is the user's to apply, through `/requirements`.
- Write a requirement, a number, or an acceptance criterion yourself. A
  finding says what is missing or wrong; the user supplies the content. A
  `Fix:` that needs a number the user has not given says `ask the user for
  <the number>`.
- Change a `Status:`, set `approved`, commit, or start the stack.
- Report a finding without evidence: the item ID and the quoted line, or the
  logged answer it contradicts. No evidence, no finding.
- Report taste. Wording is a finding only when two engineers would read it
  two ways.
- Reopen a `settled` decision on preference. A finding against an item the
  user has settled must show a contradiction with another ID or with the
  user's logged words; it is labelled `challenges settled`.
- Say something was checked that was not. A check skipped is listed under
  **Not judged**.

## Step 1 — state

```sh
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
date +%F
shasum -a 256 docs/requirements.md | cut -c1-12
```

Read `docs/requirements.md`, `docs/glossary.md`, `docs/project.md`,
`docs/grill/requirements-log.md` and `docs/review/requirements-review.md`, if
they exist.

- No `requirements.md`: stop, say to run `/requirements` first.
- Argument `status`: print the last review's number, verdict, hash, findings
  by severity and status, and whether `requirements.md` has changed since.
  Change nothing.
- The report exists and the hash equals the last review's: say "Review N
  already covers this version: <verdict>, <k> open findings", and stop.
- The report exists and the hash differs: this is a **re-review** (Step 4).
- No report: create it, Review 1.
- Any other text is a **focus**: check that first and hardest, then
  everything else. It never narrows the review.

## Step 2 — check

Work the list against the file, not memory. Each row yields findings or a
pass; record the pass count in the report.

1. **Fidelity.** An item that reads as the model's inference and not the
   user's statement: a technology the user did not name, a number with no
   `Said:` line, a tidy "shall" sentence where the log shows a loose remark.
   Where the grill log exists, compare each `Answer:` the user gave with the
   item it became: a changed number, a softened "must" / "never", or a lost
   "only". `Accept:` lines are added by the grill, never at capture; one on an
   `R` that was never grilled is a finding.
2. **Sorting.** Each item is in the right section: what it does is `R`, how
   well is `N`, a platform, budget, deadline or named technology is `C`, a
   refusal is `X`. A solution hiding in an `R` ("uses a queue") is a design
   decision, not a requirement, unless the user fixed it, then it is a `C`.
3. **One idea per item.** An item with "and" joining two testable things.
4. **Measurable.** A word with no number or test beside it makes a finding for
   a value: fast, easy, simple, intuitive, secure, reliable, scalable,
   modern, large, many, often, soon, support, handle, manage, as needed, any,
   all, etc. Each `N` has a number and the condition it holds under. Each
   "never" and "always" has no exception, or says which.
5. **Acceptance.** Where `Accept:` exists, it is Given / When / Then, can be
   failed by a test, and covers the failure path, not only the happy one.
6. **Contradictions.** Item against item, including `X` against `R`, `C`
   against `N`, and two numbers that cannot both hold. Quote both IDs.
7. **Coverage.** Walk the categories: actors and roles; permissions and
   ownership; objects and their lifecycle; data volume, retention and
   deletion; workflows and edge cases (empty, duplicate, two people at once,
   undo); errors and failure; scale and performance numbers; security and
   abuse; privacy, legal and compliance; integrations; money; notifications;
   platforms and devices; accessibility, languages and time zones; admin and
   operations; success measures; delivery constraints; what it replaces;
   content; version boundary; launch and rollback. A category the app clearly
   has, with nothing in the file, no `X`, no `A` and no `Q`, is a finding. A
   category that cannot apply is not.
8. **Open ends.** Each `Q` names the item it touches and what is unclear. A
   `Q` that blocks a core `R` is at least major. Each `A` says why it was
   left. An open `Q` that the log shows was answered is a finding.
9. **Buildability.** Read it as an engineer who cannot reach the author: list
   what you could not build correctly, and where two reasonable engineers
   would build different things. Quote the line or name what is missing.
10. **Consistency.** A user type in **Users** that no `R` serves; an `R` with
    no user; the **Overview** saying something no item backs; a term used for
    two things or missing from the glossary; an ID cited that does not exist;
    a reused or renumbered ID; a removed item that lost its line.

Severity:

- **blocker**: building on this builds the wrong app (a contradiction between
  two requirements, a core `R` that two engineers would build differently,
  an invented requirement, a softened "must").
- **major**: likely to cost rework or a launch problem (an `N` with no
  number, a missing category the app clearly has, an `R` with no failure
  case, a blocking `Q`).
- **minor**: unclear but recoverable (a vague word on a minor item, a mis-sorted
  item, a term not in the glossary).
- **nit**: harmless. Report at most five; skip if there are blockers.

Confidence: **confirmed** (the file or the log shows it) or **likely** (the
reasoning holds but the user's intent is unknown). Never report a guess.

## Step 3 — advisor, then write

Before the verdict is written, consult the advisor (see **Advisor**) with the
full finding list: ask it to find a finding that is wrong, a severity that is
too high or too low, and a serious problem the list misses. Re-check each
point it raises against the file; keep it, change it, or drop it, and never
adopt a claim the file contradicts.

Then append to `docs/review/requirements-review.md` (create it with the
header if missing). Header, once:

```
# Requirements review: <project>

Tracker: [project.md](../project.md)

IDs are permanent. A finding keeps its ID across reviews. Prefix `RR`.
Severity: blocker · major · minor · nit. Status: open · accepted · conceded · contested · intent · resolved (review N) ·
moot (item dropped) · declined (user's reason).
```

Each review:

```
## Review N · <date>

Reviewed: requirements.md @ <hash> (Status: <status>)
Captured by: <as the file says, else unknown> · Reviewed by: <this model>
Focus: <text, or none>
Verdict: <approve-ready | changes needed | blocked> · <b> blocker · <m> major · <i> minor · <n> nit

<Three lines at most: what the requirements get right, and what decides the verdict.>

### Checks

| # | Check | Result |
| --- | --- | --- |
| 1 | Fidelity | 11 of 12 pass · RR1 |

### Findings

**RR1 · blocker · confirmed · R3, N2** — <the defect, one sentence>
- Evidence: <quoted line, ID, or the logged answer>
- Failure: <what gets built wrong, or what two engineers do differently>
- Fix: <the smallest change; for a missing value, ask the user for it>
- Command: `/requirements <change text>`
- Status: open

### Not judged

- <what was not checked and why, or what only the user can decide>

### Fix list

<The `Command:` lines of the open blocker and major findings, in the order to
apply them, one per line, ready to paste.>
```

Verdict: **blocked** with any open blocker; **changes needed** with any open
major; otherwise **approve-ready**, which says the review found nothing that
should stop the user from running `/requirements approve` once the grill has
passed, and does not replace the grill.

Update `project.md`: **Next action** (`Review N of the requirements:
<verdict>, <k> to fix; apply the fix list with /requirements, then run
/review-requirements again`, or the approval line when approve-ready), and one
log line. Do not touch the stage table.

## Step 4 — re-review

When the hash differs from the last review: before checking anything new,
re-test every `open` finding against the current file and mark it
`resolved (review N)`, `moot (item dropped)`, or leave it `open` with a line
`Still: <what remains>`. Then run Step 2 in full, because a fix can break
something else; new findings take the next IDs and are marked `new in review
N`. A finding the user declined (`declined: <their reason>`) stays declined
unless the file contradicts the reason. The summary says how many were fixed,
how many remain, and how many are new.

## Responses and disputes

The models settle what they can in this report before the user is asked. The
author answers a finding with a `Response:` line written under it; the
reviewer answers that with a `Rejoinder:` line; whatever is still disputed
then is marked for the user. A dispute ends after one rebuttal and one
rejoinder: nobody argues twice. The statuses `accepted`, `conceded`,
`contested` and `intent` are added to the report's Status list.

At the start of any re-review, before the re-test in Step 4, read the
`Response:` under each open finding (written by `/requirements respond`) and handle it:

| Response | What you do | Status |
| --- | --- | --- |
| `accepted — <what changed>` | Re-test the finding against the current file. Fixed: `resolved (review N)`. Not fixed: leave it `open` with `Still: <what remains>` | `resolved`, or `open` |
| `rebutted — <evidence>` | Check the evidence in the file itself, not the author's word. It holds: write `Rejoinder: conceded — <what the evidence showed>`; status `conceded`, counted as resolved. It does not: write `Rejoinder: maintained — <evidence that answers the rebuttal>`; status `contested` | `conceded`, or `contested` |
| `intent — <the question>` | Decide whether it is really something only the user can answer: what they meant, wanted or decided. If so keep the finding as `intent`. If the file already answers it, say where and treat it as a rebuttal | `intent` |

Rules:

- Evidence only. A rejoinder that repeats the finding, or a concession made
  without looking, does not count. Concede when the evidence shows you wrong;
  maintain when it does not. Do not concede to be agreeable or maintain to be
  consistent, and do not weigh how confident the author sounds.
- A `contested` or `intent` finding is not argued again. A later review
  changes it only when the file changes so that it is settled, or the
  user declines it.
- For the verdict, `contested` and `intent` findings count as open.
- A finding with no `Response:` is handled as before.

Under the verdict line of a review that has any `contested` or `intent`
finding, add:

```
### For you

- **<ID> · <severity> · contested | intent** — <the finding, one line>
  - Reviewer: <the evidence>
  - Author: <the evidence, or the question only you can answer>
  - Yours to decide: apply the finding's command, or settle the question, or `declined: <reason>`
```

Leave the block out when there is nothing in it. Lead the reply with the
`For you` list, then the counts of findings accepted, conceded and still open.

## Step 5 — reply

Reply in at most twelve lines: the verdict and counts; the blockers and
majors, one line each with ID and item; the number held back as minor and nit;
what was not judged; that nothing was edited except the review file and the
tracker. Then: "Apply the fix list with `/requirements`, or tell me which
findings you decline, then run `/review-requirements` again."

## Advisor

If an advisor is on (`/advisor`), consult it before writing the verdict
(Step 3). Claude decides the timing, so state the point in the consultation.
If it is off, unavailable, or declines, say so in one line and go on; the
review does not stop on it. Advice is advice: where the file contradicts a
claim, follow the file and say so. The advisor never answers for the user or
supplies a requirement.
