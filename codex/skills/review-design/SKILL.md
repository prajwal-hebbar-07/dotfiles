---
name: review-design
description: >
  Reviews docs/design.md, and the boards drawn from it in Paper, as an
  independent reviewer, usually when another model designed and drew it:
  checks the idea, journeys, screens and every state against the requirements,
  architecture and brief, looks at each board through the Paper MCP without
  changing it, and writes ranked findings with a verdict to
  docs/review/design-review.md. Never edits the design or Paper; each finding
  carries the $design change that would fix it. Use when the user says
  "$review-design" or wants the design reviewed.
---

# review-design

Invoke as `$review-design [status | no-paper | <focus text>]`.

The `/requirements`, `/stack` and `/architecture` commands in findings
are handoffs to Claude Code, where those authoring skills live. Label
them as Claude Code commands in the report and reply, and keep their
fix lists ready to paste there. `$design` and `$review-<stage>` commands
run in Codex. Do not apply fixes during a review.

Read `docs/design.md` cold, as a reviewer who did not write it, then look at
what was drawn from it, and say what is wrong, how bad, and what change fixes
it. The author is usually another model, so nothing about how it was made is
evidence that it is right: the file, the brief, the requirements, the
architecture and the boards are. The review does not interview, redesign,
restyle, or edit. It ends in a verdict the user can act on, and every finding
names the `$design` change that would fix it.

Files, all in the app repo (git root, else the current directory):

| File | Role |
| --- | --- |
| `docs/design.md` | Under review. Read only |
| `docs/requirements.md`, `docs/architecture.md`, `docs/stack.md`, `docs/glossary.md` | Read only |
| `docs/grill/design-log.md` | Read only, and only to see what the user answered. A rationale there is not evidence that an item is right |
| `docs/project.md` | Tracker: only **Next action** and the log change |
| `docs/review/design-review.md` | The report. One `## Review N` per run, newest last |

Same mechanics as `$review-requirements`, `$review-stack` and
`$review-architecture`; keep the four in step. Discover the available
Paper MCP tools in Codex; this file uses their short names regardless of
the server prefix. Use the connected tools' actual schemas.

## Never

- Edit any file except `docs/review/design-review.md` and `docs/project.md`.
  The fix is the user's to apply, through `$design`.
- Change anything in Paper. Use only the reading tools: `get_guide`,
  `get_basic_info`, `get_tree_summary`, `get_children`, `find_nodes`,
  `get_node_info`, `get_screenshot`, `get_computed_styles`, `get_jsx`,
  `get_tokens`, `get_font_family_info`. Never write, update, duplicate, move,
  rename, delete, create, or call `finish_working_on_nodes`. Do not start
  Paper Desktop; if the MCP is down or needs auth, say so, review the file
  alone, and list the boards under **Not judged**.
- Change a `Status:`, set `approved`, commit, or write application code.
- Report a finding without evidence: the item ID and quoted line, the board
  name and what is on it, or the brief item it breaks. No evidence, no finding.
- Report taste. Colour, type and styling are reviewed against the design's own
  rules (its Visual direction, `Refuses`, and the practices below), never
  against what you would choose. "I prefer a darker ground" is not a finding;
  "body text is grey on a tinted ground, which the design says it never
  does" is.
- Reopen a `settled` item on preference. A finding against a settled item
  must show a contradiction with an ID, a brief item, or the architecture; it
  is labelled `challenges settled`. A `BR` item is the user's own words and
  outranks every proposal; a finding may say a proposal breaks it, never that
  the brief is wrong.
- Show raw node ids in chat or the report; name boards by their artboard
  name.
- Say something was checked that was not.

## Step 1 — state

```sh
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
date +%F
for f in requirements stack architecture design; do
  [ -f docs/$f.md ] && echo "$f $(shasum -a 256 docs/$f.md | cut -c1-12)"
done
```

Read `docs/design.md`, `docs/requirements.md`, `docs/architecture.md`,
`docs/stack.md`, `docs/glossary.md`, `docs/project.md`,
`docs/review/design-review.md`, and any `paper-target` block in `AGENTS.md`
or `CLAUDE.md`, if they exist.

- No `design.md`: stop, say to run `$design` first. No `requirements.md`:
  stop. A missing `architecture.md` or `stack.md` is said and the checks that
  need it go under **Not judged**.
- Argument `status`: print the last review's number, verdict, hashes,
  findings by severity and status, and whether the design has changed since.
  Change nothing.
- The report exists and every hash equals the last review's: say "Review N
  already covers this version: <verdict>, <k> open findings", and stop. The
  boards may have changed without the file; if the user says so, run Step 3.
- The report exists and a hash differs: this is a **re-review** (Step 5).
- No report: create it, Review 1.
- Argument `no-paper`: skip Step 3 and list the boards under **Not judged**.
- Any other text is a **focus**: check that first and hardest, then
  everything else. It never narrows the review.

## Step 2 — check the file

Work the list against the files, not memory. Each row yields findings or a
pass; record the pass count in the report.

1. **Brief.** Every live `BR` item is honoured by an item that cites it, or
   answered by a `DQ`. A proposal that breaks a `BR` is a blocker. `BR` words
   are unedited; a softened or paraphrased brief is a finding.
2. **Idea.** One sentence for what it is and one for what the person gets.
   Each feel word is a rule that can be checked on a screen (`calm` = one
   primary action per screen, no badges), not the word. The reference base is
   named, the changes to it are rules, and `Refuses` says what it will not
   become. The alternative idea is structurally different (another home
   screen, navigation, or central object), not a restyle, and the reason it
   loses holds up.
3. **Moments.** Each kind of user in the requirements has a `U` item; device,
   hurry, frequency, what they did just before. An assumption has a `DQ`.
4. **Journeys.** Every `R` a person does, and every architecture flow with a
   person-visible step, is served by a `J`. Steps are ordered, start at a real
   screen, and end. Length is stated and fits the person's hurry. At each
   failure the architecture names, the person sees something and can do
   something; the words match the architecture's "Seen by the caller".
5. **Screens.** For each `S`: one purpose stated as a task; one primary
   action; what is seen first; reached from and goes to are mirror images
   across screens; the deletion test (a screen that only forwards, or shows
   what a neighbour could, is a finding); content in glossary terms, real
   values from the user, anything else marked `(sample)`.
6. **States.** Every screen that shows data has default, empty, loading and
   error. Empty says the words and the way forward; error says what the
   person can do next. Denied exists wherever a role sees something
   different, from the architecture's permissions. A missing state is a major
   finding, or a blocker on the main journey.
7. **Navigation.** Every screen is reachable from the start; none is a dead
   end; the person can tell where they are and go back; the mermaid graph
   matches the `Goes to` fields edge for edge.
8. **Patterns.** A `P` exists only where two or more screens share it, applies
   to screens that exist, and the screens it names do follow it.
9. **Visual direction (against its own rules).** One spacing step used
   everywhere; a short type scale with two weights; body text readable (no
   grey body on a tinted ground); alignment to one grid; the primary
   action's look distinct; token names stated. Not graded on taste.
10. **Platform and access.** The platform and size are stated and match the
    requirements; the smallest screen, keyboard use, text size and a screen
    reader are addressed where the requirements ask; language and locale from
    the requirements.
11. **Traceability.** Every live `R` and `N`, and every architecture flow with
    a visible step, maps to an `S`, `J`, `P` or `no UI: <reason>`, and the
    reason is sound. The table matches the `Serves` fields.
12. **Over-design.** A screen, control, journey or pattern that no `R`, `N`,
    `C` or `BR` asks for. Each is a finding, with the simpler design stated.
13. **Consistency.** An ID cited that does not exist or is dropped; a term used
    for two things or missing from the glossary; recorded hashes that no
    longer match; `settled` items whose content differs from their `Was:`;
    `Paper: built` on a screen that changed after that date.

## Step 3 — check the boards

Skip if the argument is `no-paper`, no `S` has `Paper: built`, or the Paper
MCP is unavailable (list each as **Not judged**).

1. `get_guide` with topic `paper-mcp-instructions` once, before any other
   Paper tool. Use the `Paper:` line in the header (file and page) or the
   `paper-target` block; call `get_basic_info` with that `fileId` and confirm
   the file and page name. If they disagree with the pin, or nothing is
   pinned, say so under **Not judged** and review the focused file only if
   the user confirms it. Do not switch the user's file.
2. `get_tree_summary` for the page, then match artboards to the screens by
   name (`<n> <name>`, and `<n> <name> · <state>` for `Draw:` states) and find
   the `Design system` board. A screen marked `Paper: built` with no board, a
   board with no screen, or a duplicate name is a finding.
3. `get_screenshot` of the design system board and of each screen board, and
   look at it. For each, check:
   - the board is the platform's size (desktop 1440×900, phone 390×844) and
     nothing clips or overflows;
   - every control, value and word on it comes from the screen's own fields;
     a control, screen link, or destination the file does not list is a
     finding; so is a listed control that is missing;
   - exactly one primary action, and it is the one the file names, and it is
     what the eye lands on first;
   - the states in `Draw:` are drawn and their words match the file;
   - the patterns look the same on every screen that shares them;
   - body text is readable and the type and spacing follow the design
     system board.
4. `get_computed_styles` or `get_jsx` for a board only to settle a doubt a
   screenshot raised (a raw colour where the file says a token, a font size
   outside the scale, a spacing off the step). Never read sizes or colours
   from a screenshot.
5. Cross-check boards against each other: the same fact worded the same way,
   the same pattern drawn the same way, a journey's boards in order.

Judge the drawing against the file, not against taste. A board that is right
by the file but ugly is a finding only if it breaks a rule the design states.

## Step 4 — severity, verify findings, write

Severity:

- **blocker**: building on this builds the wrong app (a proposal that breaks
  a `BR`, a requirement with no journey, the main journey dead-ending, a
  missing error state on the main flow, a board that shows a different
  thing than the file).
- **major**: likely rework or a person getting stuck (a missing state, a
  screen with two competing primary actions, a feel word with no rule, a
  failure with no words, a pattern drawn two ways).
- **minor**: unclear but recoverable (a sample not marked, a diagram out of
  step, a token name unused).
- **nit**: harmless. Report at most five; skip if there are blockers.

Confidence: **confirmed** (the file or the board shows it) or **likely** (the
reasoning holds but the intent is unknown). Never report a guess.

Before writing the verdict, re-check the full finding list against the
files and evidence: remove false positives, correct severities that are too
high or too low, and check for serious problems the list misses. Keep only
claims the evidence supports.

Then append to `docs/review/design-review.md` (create it with the header if
missing). Header, once:

```
# Design review: <project>

Tracker: [project.md](../project.md)

IDs are permanent. A finding keeps its ID across reviews. Prefix `DR`.
Severity: blocker · major · minor · nit. Status: open · resolved (review N) ·
moot (item dropped) · declined (user's reason).
```

Each review:

```
## Review N · <date>

Reviewed: design.md @ <hash> (Status: <status>) · requirements.md @ <hash> · architecture.md @ <hash | none> · stack.md @ <hash | none>
Paper: <file> · <page>, <k> boards looked at, or `not looked at: <reason>`
Built by: <as the header says, else unknown> · Reviewed by: <this model>
Focus: <text, or none>
Verdict: <approve-ready | changes needed | blocked> · <b> blocker · <m> major · <i> minor · <n> nit

<Three lines at most: what the design gets right, and what decides the verdict.>

### Checks

| # | Check | Result |
| --- | --- | --- |
| 5 | Screens | 8 of 9 pass · DR2 |

### Findings

**DR1 · blocker · confirmed · S3, board 03 Today, R4** — <the defect, one sentence>
- Evidence: <quoted line, ID, or what is on the board>
- Failure: <what the person sees or cannot do>
- Fix: <the smallest change that removes it>
- Command: `$design <change text>` (add `then $design build` when a board must be redrawn)
- Status: open

### Not judged

- <what was not checked and why, or what only the user can decide>

### Fix list

<The `Command:` lines of the open blocker and major findings, in the order to
apply them, one per line, ready to paste. A fix that belongs to another stage
says `/requirements <text>`, `/stack <text>` or `/architecture <text>`.>
```

Verdict: **blocked** with any open blocker; **changes needed** with any open
major; otherwise **approve-ready**, which says the review found nothing that
should stop the user from running `$design approve` once the grill has passed
and the boards are built, and does not replace the grill.

Update `project.md`: **Next action** (`Review N of the design: <verdict>, <k>
to fix; apply the fix list with $design, then run $review-design again`, or
the approval line when approve-ready), and one log line. Do not touch the
stage table.

## Step 5 — re-review

When a hash differs from the last review, or the user says the boards changed:
before checking anything new, re-test every `open` finding against the
current file and boards and mark it `resolved (review N)`, `moot (item
dropped)`, or leave it `open` with a line `Still: <what remains>`. Then run
Steps 2 and 3 in full, because a fix can break something else; new findings
take the next IDs and are marked `new in review N`. A finding the user
declined (`declined: <their reason>`) stays declined unless the file
contradicts the reason. The summary says how many were fixed, how many remain,
and how many are new.

## Step 6 — reply

Reply in at most twelve lines: the verdict and counts; the blockers and
majors, one line each with ID and screen; how many boards were looked at; the
number held back as minor and nit; what was not judged; that nothing was
edited except the review file and the tracker, and that Paper was not
changed. Then: "Apply the fix list with `$design`, or tell me which findings
you decline, then run `$review-design` again."
