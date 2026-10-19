# Gate 4: design in Paper (human approves)

Only for work with a UI. No UI → skip to issues.

You run the gate; `factory-designer` (Sonnet, `@factory_designer`) sets the direction and does every Paper write, and `factory-review-design` (GPT-6 Astra, `@factory_design_review`) reviews every built or revised design before the human sees it. Never draw in Paper yourself. The designer writes `design.md`, including its revision log; you never edit it.

## Do

Spawn a **fresh** designer for every round, named `factory-designer-<mode>-r<N>` (agent `factory-designer`); `design.md` and the Paper page carry the state between rounds:

```
Work ID: <id>. Mode: <direction | build | revise>.
Read: AGENTS.md; .factory/<id>/requirements.md; .factory/<id>/architecture.md (issue plan); .factory/<id>/design.md (if present).
Paper: <approved file> · page: <approved page>   (omit in direction mode when none is approved)
Human reply: <verbatim>   (revise from the human only)
Design review: .factory/<id>/design-review/r<N>/factory-review-design.md   (revise from review only)
Write exactly one factory file: .factory/<id>/design.md
```

Spawn a **fresh** reviewer for every review round, named `factory-review-design-r<N>` (agent `factory-review-design`). Review rounds are numbered across the whole gate:

```
Step: design. Round: <N>. Work ID: <id>.
Read: AGENTS.md; .factory/<id>/requirements.md; architecture.md (issue plan); stack.md; design.md.
Paper: <approved file> · page: <approved page>
Your previous verdict (round ≥ 2): .factory/<id>/design-review/r<N-1>/factory-review-design.md
Checklist: skill://factory/reference/review.md, section "design".
Write exactly one file: .factory/<id>/design-review/r<N>/factory-review-design.md
```

1. `state.json.paper` unset, or the direction (a reference UI as the base, and the changes on top) not already approved → **direction** mode. Read the first line of `design.md`, then stop for the human (`rules.md`, "Human interaction"). `approve` → record the Paper file and page in `state.json.paper`. Any other reply → direction mode again with the reply, stop again.
2. **build** mode with the approved file, page and direction.
3. Read the first line of `design.md`. `STATUS: BLOCKED` → Paper MCP down or needs auth: tell the human to open Paper Desktop and stop; anything else → ask the human. Never start Paper Desktop.
4. `STATUS: READY` → check that every requirement with a UI maps to an approved artboard; a gap → build mode again naming the missing R-IDs.
5. **Design review**: spawn the reviewer. A missing file or a first line that is not a verdict → rerun once, then report to the human. `VERDICT: CHANGES` → **revise** mode with the verdict file, then step 3 again. Max 3 review rounds per pass through this step; then stop for the human with the open findings listed. A spawn that fails with a rate-limit or quota error has no stand-in: tell the human and stop.
6. `VERDICT: PASS` → stop for the human, pointing at `design.md`, the last design-review verdict and the Paper page.
7. Any other reply than `approve` → **revise** mode with the reply verbatim, then step 3 again (the revised design is reviewed before the human sees it).

Append a trace line per designer run and per reviewer run (`retro.md`), with `"step":"gate4"` and the mode, or `"step":"design-review"` with the round, verdict and findings.

## Exit

`approve` → `stage: "issues"`. Approved artboards and tokens become the reference for the UI lens and holdout QA. A design change after approval reopens this gate.
