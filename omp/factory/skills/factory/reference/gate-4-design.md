# Gate 4: design in Paper (human approves)

Only for work with a UI. No UI → skip to issues.

You run the gate; `factory-designer` (GPT, `@factory_designer`) sets the direction and does every Paper write. Never draw in Paper yourself. The designer writes `design.md`, including its revision log; you never edit it.

## Do

Spawn a **fresh** designer for every round, named `factory-designer-<mode>-r<N>` (agent `factory-designer`); `design.md` and the Paper page carry the state between rounds:

```
Work ID: <id>. Mode: <direction | build | revise>.
Read: AGENTS.md; .factory/<id>/requirements.md; .factory/<id>/architecture.md (issue plan); .factory/<id>/design.md (if present).
Paper: <approved file> · page: <approved page>   (omit in direction mode when none is approved)
Human reply: <verbatim>   (revise only)
Write exactly one factory file: .factory/<id>/design.md
```

1. `state.json.paper` unset, or the direction (a reference UI as the base, and the changes on top) not already approved → **direction** mode. Read the first line of `design.md`, then stop for the human (`rules.md`, "Human interaction"). `approve` → record the Paper file and page in `state.json.paper`. Any other reply → direction mode again with the reply, stop again.
2. **build** mode with the approved file, page and direction.
3. Read the first line of `design.md`. `STATUS: BLOCKED` → Paper MCP down or needs auth: tell the human to open Paper Desktop and stop; anything else → ask the human. Never start Paper Desktop.
4. `STATUS: READY` → check that every requirement with a UI maps to an approved artboard; a gap → build mode again naming the missing R-IDs. Then stop for the human, pointing at `design.md` and the Paper page.
5. Any other reply than `approve` → **revise** mode with the reply verbatim, then step 3 again.

Append a trace line per designer run (`retro.md`), with `"step":"gate4"` and the mode.

## Exit

`approve` → `stage: "issues"`. Approved artboards and tokens become the reference for the UI lens and holdout QA. A design change after approval reopens this gate.
