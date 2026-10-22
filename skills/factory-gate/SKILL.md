---
name: factory-gate
description: >
  The factory's approval primitive. Optionally runs the builder check, shows
  the whole document in chat, then asks one ask-call questionnaire (one
  question per top-level section, No then Approve). On approval it stamps the
  doc's hash, stages it, and commits. Also the PR variant and the
  feature-brief variant. Use when a factory stage skill says to run a gate, or
  when invoked as /skill:factory-gate.
argument-hint: "<gate> <doc path> [--builder-check]"
disable-model-invocation: true
---

# factory-gate

Read by the stage skills (`skill://factory-gate`). Design:
`SOFTWARE-FACTORY.md` §4.3. Run from the target repo root. State tool:
`F=~/.omp/agent/skills/factory/scripts/factory-state`.

The caller passes: **gate name** (`requirements`, `stack`, `architecture`,
`issues`, `brief`), **doc path**, the doc's **top-level sections** (every `##`
heading), whether to **run the builder check**, and any extra files to stage
(ADRs, out-of-scope notes).

## Never

- Set `recommended` on a gate question, add `preview`s, or add options other
  than `No` and `Approve`. Order is always `No`, then `Approve`.
- Stamp anything when the dialog was cancelled.
- Count a timeout, `Other`, or `Chat about this` as approval.
- Show only the changed sections. Show the whole doc every time.
- Edit the doc after stamping (the guard blocks it); reopen the gate instead.
- Commit in feature mode, or `git add` the brief.

## Steps

1. **Builder check** (only if the caller asked: requirements and stack gates).
   Spawn `factory-builder-check` (`task`, `agent: factory-builder-check`) with
   the doc path. It returns ranked questions or "nothing important left"
   (superpowers `builder-check-prompt.md`, in `builder-check.md`). Sort each
   question:
   - **Answered already**: write the answer into the doc.
   - **Minor**: decide it and mark it "factory's call" in the doc.
   - **Yours**: only the user can answer. Collect them and run **one**
     `factory-grill` round (`read skill://factory-grill`); fold answers in.
2. **Present the whole doc in chat**, every time, revisions included. At the
   top, a header listing (a) what changed since the last review and (b) every
   "factory's call", so they are easy to find. Then the full text.
3. **Ask once** with `ask`: one question per top-level section.

   ```json
   {"questions": [
     {"id": "section-1-slug", "header": "<section name>",
      "question": "Approve the section \"<section name>\" of <doc path>?",
      "options": [{"label": "No"}, {"label": "Approve"}]}
   ]}
   ```

   Unique `id` per section. `header` is the section name; name the section in
   the question text too. No `recommended`, no `preview`, no `multi`. The
   section is read in chat (step 2), not in the dialog.
4. **Read the answer.**
   - Every question answered `Approve`: go to step 6.
   - Any `No`, `Other (type your own)`, `Chat about this`, or a result marked
     `(auto-selected after timeout)` / `timedOut`: the gate is **No**. Typed
     text is the reason. For a timeout or `Chat`, ask in chat what to change.
   - `ToolAbortError` (dialog cancelled): the gate stays open, nothing is
     stamped, nothing is committed. Say so and stop.
5. **On No: revise.** Run a `factory-grill` round on the No reasons, fold the
   answers into the doc, rewrite struck scope (step 7), then go back to step 2:
   present the whole doc again and re-ask **every** section. A No on one
   section rejects the whole doc.
6. **On all Approve:**
   1. `$F stamp <gate> <doc path>`
   2. `git add <doc path>` plus the extra files the stage names (ADRs,
      `docs/factory/out-of-scope/*.md`).
   3. `read skill://commit` and run it (it commits what is staged and writes
      the message).
7. **Rejected scope** (any time, including during a No): each item the user
   strikes becomes `docs/factory/out-of-scope/<concept>.md` with what was
   struck, why, and what would bring it back (mattpocock
   `triage/OUT-OF-SCOPE.md`). Stage it with the doc so later stages do not
   propose it again.

## Variant: feature brief (gate `brief`)

Doc `.factory/feature/<slug>.md`. Same steps 2-5 (the caller says whether to
run step 1). On approval run only `$F stamp brief .factory/feature/<slug>.md`.
The brief is **not committed**: no `git add`, no `commit`. Struck scope goes to
the brief's Out of scope section, not `docs/factory/`.

## Variant: PR gate

No doc and no builder check. Show the caller's PR summary in chat, then one
`ask` question: id `pr`, `header` `PR`, question `Raise PR for <branch>?`,
options `No` then `Approve`, no `recommended`.

- `Approve`: `$F pr-approve <branch> $(git rev-parse HEAD)`, then return
  "approved" to the caller, which creates the PR.
- Any No / Other / Chat / timeout: return the reason (typed text, or ask for
  it in chat) to the caller as an **Act on** item. Nothing is recorded.
- `ToolAbortError`: nothing recorded; the gate stays open.

## Settings

Keep `ask.timeout: 0` (the default). With a timeout, omp submits the first
option, which is why `No` is listed first and never marked recommended. omp's
`ask` always adds `Other (type your own)` and the rich dialog adds
`Chat about this`; both count as No.
