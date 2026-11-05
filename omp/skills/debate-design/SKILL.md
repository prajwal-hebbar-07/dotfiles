---
name: debate-design
description: >
  Takes the design from an approved architecture to drawn in Paper,
  reviewed, and ready to approve in Oh My Pi, after first checking that
  everything the design needs is ready. Claude Sonnet 5.5 (medium) proposes
  docs/design.md, answers the grill, folds answers in and responds to the
  review; Claude Opus 5.5 (medium) designs the alternative idea, grills the
  design and runs the cold fresh-eyes check; GPT-6 Astra (medium) draws the
  settled design in Paper; Kimi K2.6 (high) reviews the file and the boards.
  Questions only the user can answer go to docs/grill/design-questions.md,
  best-practice answers go there pre-filled, and what the models proved from
  the documents is folded in and listed. Replaces Claude Code's /design,
  /grill-design, /design build and /review-design, and writes the same
  files. Use when the user says "/skill:debate-design".
argument-hint: "[brief <text> | change text | status | approve]"
disable-model-invocation: true
---

# debate-design

`/skill:debate-requirements`, for the design, with its own four models and a
Paper build before the review. The loop, the classes, the debate round, the
review and the questions file are those of `debate-rules.md` (that skill,
linked). The stage rules are Claude Code's `/design`, `/grill-design` and
`/review-design`: `design-rules.md`, `grill-rules.md` and `review-rules.md`,
with their templates (`design-template.md`, `direction.md`,
`paper-build.md`, `design-log-template.md`, `design-coverage-template.md`,
`probes.md`). Follow them in full, except where this file or
`debate-rules.md` says otherwise; where the two disagree, this file wins.

The design is about the thought, not the look: no model asks about colour,
type, spacing, radius, shadow or icons. The **Visual direction** is proposed
by the designer, drawn by the builder, and judged by the user in Paper.

**Oh My Pi runs this.** If this is not Oh My Pi, stop and say so.

## Models

Four models, and only these four.

| Role | `task` agent | Model (its frontmatter) | Does |
| --- | --- | --- | --- |
| Designer | `design-designer` | `anthropic/claude-sonnet-5-5`, medium | Proposes `design.md`; answers each grill question once (settle with evidence, accept, or the user's); folds answers in; applies the user's changes; responds to the review |
| Griller | `design-griller` | `anthropic/claude-opus-5-5`, medium | Designs the alternative idea cold; drafts each grill round with a proposed class and answer per question; replies once to the designer; runs the fresh-eyes check as a new task given only the file paths |
| Builder | `design-builder` | `openai-codex/gpt-6-astra`, medium | Draws `design.md` in Paper by `paper-build.md`; writes only the `Paper:` lines in `design.md` |
| Reviewer | `design-reviewer` | `ollama-cloud/kimi-k2.6`, high | Reviews `design.md` and the boards by `review-rules.md` (Paper read tools only), and answers the designer's responses |

`debate-rules.md`'s roles map onto them like this: **Round** item 1 (Draft)
is the griller's, item 2 (Challenge) the designer's, item 3 (Reply) the
griller's, items 4 and 5 are skipped: a block still disputed after the
griller's reply is `user`, with both positions under **Known**. **Fold**,
**Ingest**, **Respond** and every change to `design.md` are the designer's;
the review and its rejoinders are the reviewer's. Start each as a `task`
with `agent` set to its name and no `model` field. If one is missing or
cannot start, or its result names a different model, stop and say which;
never substitute another agent or model, or do its part yourself. A model
naming itself wrongly in its reply is not that: check the session's
resolved model.

## Names

Read `debate-rules.md` with these substitutions:

| In `debate-rules.md` | Here |
| --- | --- |
| `requirements.md` (the document) | `docs/design.md` |
| `capture-rules.md` | `design-rules.md` |
| **Capture** | **Propose** (below) |
| questions `G<N>.<k>` | `D<N>.<k>`, grill-design's own |
| debate blocks `D<N>.<k>` | `P<N>.<k>`, so they never clash with the questions |
| `requirements-log.md`, `-questions.md`, `-coverage.md`, `-debate.md` | `docs/grill/design-log.md`, `design-questions.md`, `design-coverage.md`, `design-debate.md` |
| `log-template.md`, `coverage-template.md` | `design-log-template.md`, `design-coverage-template.md` |
| `docs/review/requirements-review.md` | `docs/review/design-review.md` |
| the ID check's IDs | items `grep -oE '^### [UJSP][0-9]+'`, `grep -oE '\*\*BR[0-9]+\*\*'` and `grep -oE '\*\*D[QA][0-9]+\*\*'` |
| grill Step 5 items 1–4 | grill Step 5 items 1–7 (simplicity sweep and pre-mortem included) |
| the tracker row | the Design row |
| `/skill:debate-requirements` | `/skill:debate-design` |

The fresh-eyes check is a new `design-griller` task given only the paths of
`requirements.md`, `architecture.md`, `stack.md`, `glossary.md` and
`design.md` and the fresh-eyes prompt from `probes.md`, nothing from the
debate. It counts only while the three hashes grill Step 5 item 8 names
still match.

## Never

Everything in `debate-rules.md`'s **Never**, and in the `Never` lists of the
three stage rule files, holds, with these changes:

- Never settle, and never pre-fill: the say-it-back and the one thing; the
  **Idea**, its feel words and their rules, and what it refuses; who uses it,
  where and when (`U` items); anything that touches a `BR` item; anything
  that costs money; a requirement, stack or architecture gap.
- Never ask about, settle or grill the **Visual direction**. What the user
  says about the look is filed there as grill-design says.
- A model never sets `State: settled`. Only the answer to a lock question
  does; a pre-filled lock of a screen, journey or pattern left blank is the
  user's `yes`. The Idea's lock is never pre-filled.
- Never edit `requirements.md`, `stack.md` or `architecture.md`. A gap goes
  to the user as a **Needs you** question naming the
  `/skill:debate-requirements`, `/skill:debate-stack` or
  `/skill:debate-architecture <change>` to run.
- Never draw before the design is `grilled`, never draw on a file or page
  other than the pinned one, and never start Paper Desktop.
- Never write application code.

## Step 1 — readiness

Every run starts here. Run Step 1 of `design-rules.md` (hashes and reads),
then check, and print the result as a checklist, one line each, `ready`,
`not ready: <what and the command that fixes it>`, or `warning: <what>`:

| # | Check | When it fails |
| --- | --- | --- |
| 1 | `requirements.md`, `stack.md` and `architecture.md` exist, each `Status:` `grilled` or `approved` | Stop. Name the stage and its `/skill:debate-<stage>` command |
| 2 | None of the three has an open `Q`, `SQ` or `AQ`, or an open gap in its log | Stop, as above |
| 3 | Nothing is stale: the hashes `stack.md` and `architecture.md` record match the current files | Stop: the earlier stage moved; run the later stage's skill to re-check |
| 4 | `glossary.md` exists | Warning; the designer creates terms only through the grill |
| 5 | The four agents exist in `~/.omp/agent/agents/` | Stop: run `omp/link-skills` in the dotfiles |
| 6 | A Paper pin: a `paper-target` block in `AGENTS.md` or `CLAUDE.md`, or a `Paper:` line in `design.md` naming a file and page; the two agree if both exist | Not ready for the build only: say to pin one with `/paper-target` in Claude Code. Proposing and grilling go on |
| 7 | Paper answers: `get_guide` (`paper-mcp-instructions`) once, then `get_basic_info` with the pinned `fileId` and `pageId`; the file and page names match the pin | Not ready for the build only: say to open Paper Desktop (never start it) or re-pin |

A brief is optional; say whether one is filed. Checks 6 and 7 are re-run
before every **Build**. With any stop, change nothing else.

Then, by argument and state:

| State / argument | Do |
| --- | --- |
| `status` | The checklist, then `debate-rules.md`'s status lines with the design ones of `design-rules.md` and `grill-rules.md`, screens by `Paper:` state, and the last review's verdict. Change nothing |
| `approve` | Only when `Status: grilled`, every live `S` is `Paper: built <date>` (none `stale` or `not built`), and the last review is `approve-ready`, looked at the boards, and is on the current hashes; otherwise say what is missing. Then `design-rules.md`'s approve, with **Next action** `Design approved; run /skill:debate-issues`. Typing it is the user's approval of the idea and the boards |
| No `design.md` | **Propose** (any text is the brief), then **Next** |
| A hash recorded in `design.md` differs from the current one | **Earlier stage moved**, then **Next** |
| Argument starting with `brief`, or a change (including what the user saw on a board) | Designer: `design-rules.md` Step 3. A board that does not match the file, with the file right, only sets that screen `Paper: stale`. Run the ID check. Then **Next** |
| `proposed` | Start the grill as grill Step 1 does with no log, then **Next** |
| `grilling` | **Ingest**, then **Next** |
| `grilled` | **Next** |

## Propose

1. **Two ideas, in parallel.**
   - Designer: `design-rules.md` Step 2, all but item 3's sub-agent, the
     brief filed as `BR` items word for word.
   - Griller, started with only the paths of `requirements.md`,
     `architecture.md` and the brief: the structurally different idea (a
     different home screen, navigation, or central object, not a restyle),
     as Step 2 item 3's sub-agent would, written to `design-debate.md` under
     `## Proposal · <date>`.
2. **Pick** (designer). Compare as Step 2 item 3 says, pick one, write the
   other as `Alternative idea` with why it loses and what would force it,
   and write `docs/design.md` (Step 2 item 13, `Status: proposed`).
   Each `Draw:` line names states only, and each state is drawn as its own
   whole-screen board: a message the person sees (a failure, a refusal) is
   a state of the screen it appears on, never a note on another board.
3. **Counter** (griller). For the Idea and each `U`, `J`, `S`, `P` item,
   append `### <ID> <name>` and `Griller: agree` or `Griller: object —
   <reason and evidence>`. Object for a `BR` item broken or ignored, a feel
   word with no rule, a screen with two primary actions or none, a missing
   state, a dead end or orphan, an `R` no journey serves, an architecture
   failure with no state, or a part no number asks for.
4. **Reply** (designer). Under each objection: `Designer: concede` (apply it,
   diagram and traceability included) or `Designer: rebut — <evidence>`. A
   rebutted objection becomes a `DQ` with both positions; nobody argues
   twice.
5. **Check** (runner). Every screen reachable from a journey and every
   journey ends; run the ID check.

Then start the grill, with no pause.

## Earlier stage moved

Designer: `design-rules.md` Step 1's check of each item against the changed
files. Each item it lists becomes a `user` question in the next round,
debated like any other. Once all are answered, the designer records the new
hashes.

## Next

Replaces `debate-rules.md`'s **Next** list. After every step, take the first
that applies, in the same run, until one says stop:

1. Open questions in the log: write the questions file and stop.
2. No round has run since the last change to `design.md`, or grill Step 5
   items 1–7 do not hold: **Round** (the simplicity sweep, then the
   pre-mortem, when those are what is missing).
3. The fresh-eyes check is not current: **Round** (fresh-eyes).
4. The confirm round is not answered `yes` and `none` on this `design.md`:
   write it (grill-design's wording) and stop.
5. `Status:` is not `grilled`: set it as grill Step 5 says.
6. A live `S` is `Paper: not built` or `stale`: **Build**. Checks 6 or 7 not
   ready: stop, saying exactly what to do, and that rerunning the skill
   draws the boards.
7. The last review did not look at the boards as they are now, or has
   findings the models can still move: **Review** (below).
8. The review left findings for the user: `debate-rules.md`'s **Review
   questions**, then stop.
9. Otherwise **End**.

If a whole pass changes neither `design.md`, the log, the review report nor
a board, stop and say what is stuck.

## Build

1. **Runner.** Re-run checks 6 and 7; pass the `fileId`, `pageId`, the file
   and page names, and the list of screens to draw to the builder. If
   `design.md` has no `Paper:` line, the builder writes it from the pin.
2. **Builder.** `paper-build.md`, from "File and page" to "After drawing",
   for the `Design system` board (first build only, or when the Visual
   direction changed) and each screen that is `not built` or `stale`, in
   journey order, each `Draw:` state beside it. Paste the text of
   `paper-build.md` and of the screens and Visual direction from
   `design.md` into its task; do not send it a path to find. Give it these
   rules too, in its task:
   - Every screen board and every state board is a whole screen at the
     platform size (390×844 phone, 1440×900 desktop), drawn as the person
     would see it in that state. `fit-content` may only make a board taller
     than that, never shorter.
   - A screen or state board shows only what the person sees: no notes,
     labels, annotations or explanations of behaviour. A failure's words
     appear as the message the person sees, in the state's board. The
     `Design system` board is the exception: it labels each token, the type
     scale, the spacing step, the radius, the primary action and each
     pattern, as `paper-build.md` says.
   - Text uses only the type tokens the Visual direction names, and every
     colour is a token; placeholder and secondary text keep readable
     contrast against the ground.
   - Every word, value and control comes from the screen's fields; a gap in
     the file is not filled in, it is reported.
   It sets each drawn screen `Paper: built <date>` and returns the boards
   drawn and anything it could not draw from the file.
3. **Check** (runner). `get_basic_info` with the pinned ids: one artboard
   per drawn screen named `<n> <name>`, one per `Draw:` state, one `Design
   system`, no duplicates, and each screen and state board at least the
   platform size. `get_screenshot` of each new board: look for clipping,
   content touching an edge, and notes or labels that are not part of the
   screen. Send what is wrong back as a new `design-builder` task (not a
   message to the finished one), with the same pasted text and a list naming
   each board, what is wrong, and what it must be (for example `01 Checklist
   · error: 390×75, must be 390×844 showing the whole screen in that state`).
   Check again; still wrong, set that screen `Paper: stale` and stop with
   what is wrong.
   Run the ID check. Anything the builder could not draw from the file
   becomes a `DQ` for the designer, not a guess on the board.

## Review

One review of the file and the boards together, after they are built:
`debate-rules.md`'s **Review** with these changes.

1. **Review** (reviewer). `review-rules.md` Steps 1–5 and **Responses and
   disputes**, Step 3 (the boards) included, with the pinned `fileId` and
   `pageId`. Skip its advisor and its Step 6 reply; return the verdict and
   the counts. Paste the pinned ids and the screens' names into its task.
2. **Respond** (designer), unless the verdict is `approve-ready`:
   `design-rules.md`'s **Respond to a review**, deciding where each fix
   lives. A board that does not match `design.md`, with the file right, is
   `accepted — redraw S<n>` and that screen becomes `Paper: stale`. A fix in
   the file follows `design-rules.md` Step 3, which reopens the grill only
   for the idea, moments, journeys, screens or patterns, and marks the
   screens it touches stale. A finding about the look alone that breaks no
   rule in the file is `intent`: the user judges the look.
3. **Again or on.** Back to **Next**: stale screens go to the builder first,
   then the reviewer re-reviews, as `debate-rules.md` says.

## End

`Status: grilled`, every live screen built, and the last review
`approve-ready` with the boards on the current hashes. Set **Next action**
`Look at the boards in Paper, then run /skill:debate-design approve, or tell
me what to change with /skill:debate-design <change>`. Reply with the file
and page, the boards drawn, the review verdict and counts, anything drawn on
an assumption (`DQ` IDs), and that no application code was changed.

The chat reply after a round ends with `Slides of the design:
/brief docs/design.md in Claude Code.` in place of the requirements slides
line, since the boards in Paper are the design's own pictures.
