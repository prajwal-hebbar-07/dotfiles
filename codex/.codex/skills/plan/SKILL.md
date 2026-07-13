---
name: plan
description: Terminal-native planning. Researches the task in the real codebase, writes a terse diagram-first execution map to plans/plan-<slug>.md, and opens it for review in a right-hand tmux split running nvim so the user can annotate it with inline "@me" HTML comments (resolved later by the plan-review skill). Never implements and never presents the plan only in conversation — the file is the medium. Use when the user says "/plan <task>", "$plan <task>", "plan this", "make/write a plan for X", "create a plan doc", or asks for a plan they can review in the editor.
---

# Plan (terminal-native)

Produce a reviewable technical execution map as a markdown file, not a
conversational proposal. Research the real codebase, write
`plans/plan-<slug>.md`, and open it in a right-hand tmux split running nvim.
The `plan-review` skill resolves inline `@me` annotations in later rounds.

The output is always the plan file only — never the implementation.

## Writing contract

Write for a senior software engineer scanning at speed.

- **Aggressively concise.** Prefer fragments and one-line decisions. Goal:
  normally 1-2 short lines. Risks and open questions: one line each.
- **Execution map, not documentation.** No tutorials, concept explanations,
  implementation walkthroughs, obvious engineering details, or standard
  framework/library behavior.
- **Decision-bearing content only.** Remove prose that does not change scope,
  structure, ordering, ownership, behavior, or verification.
- **Information-density rule.** If removing a sentence does not reduce the
  developer's ability to implement the change correctly, remove it.
- **Separation of concerns.** `plan-detail` owns reasoning and explanation.
  `plan` owns structure, decisions, ordering, and touched code.
- **Smallest executable plan.** No completeness padding; leave a section empty
  when research yields nothing decision-relevant.

## Diagram-first shape

Make `## Shape` the primary technical explanation. A developer should
understand the intended change from the diagrams, then confirm it from the
one-line `## Plan` entries.

Research first; choose only diagrams that clarify the real task:

- architecture or ownership/boundaries → boxes and labeled arrows
- request, data, control, async, or event flow → directional flow with branches
- state transitions or lifecycle → state machine
- dependency or implementation ordering → vertical/horizontal chain
- current vs target structure → before/after view
- components or files touched → boundary or tree view

Use ASCII in fenced code blocks. Prefer multiple focused diagrams of roughly
five lines over one noisy diagram. Do not force every concern into a generic
architecture diagram.

Never invent architecture. Every path, function, type, module, state, and
component shown must be verified in the repository or marked as an explicitly
planned new artifact, e.g. `[new] RefreshTokenStore`.

## AI-renderable layer

Plan files double as input to an AI visual renderer that turns them into
diagrams and dashboards without reading the repository. This grammar is a
parse contract, not decoration — keep it exact:

- **Frontmatter first.** The file opens with YAML frontmatter (see "Plan file
  format"): `plan`, `slug`, `kind`, `created`, `horizon`. One value each, no
  prose.
- **Caption every diagram.** Immediately after each ASCII diagram's closing
  fence, add one line:

  ```text
  [DIAGRAM PROMPT: <diagram type; named elements + labeled relationships;
  what to emphasize>]
  ```

  Self-contained: a renderer with zero codebase context must be able to draw
  the visual from this line alone. Name every node, state, and edge direction
  explicitly; never write "the components above".
- **Statused plan entries.** Every `## Plan` line is a numbered checkbox:
  `- [ ] 3. path/to/file.ts:symbol — change (effort: M) needs: 1,2`.
  Statuses: `[ ]` todo, `[~]` in progress, `[x]` done, `[!]` blocked.
  Add `(effort: S|M|L|XL)` when it informs ordering; `needs: <step numbers>`
  only for real dependencies.
- **Tokened callouts.** Each risk line starts `⚠️ RISK:`. Optional
  phase-boundary checkpoints are `🎉 MILESTONE:` lines.

## Flow

1. **The file is the medium.** Do not deliver the plan as a chat message or
   through any built-in planning/approval feature; the review loop lives in
   the plan file.

2. **Understand the task.** Take it from invocation args
   (`/plan add oauth refresh`) or conversation. Ask only when genuinely
   ambiguous; otherwise put the terse interpretation in `## Goal` for inline
   correction.

3. **Research before writing.** Read related files in `plans/` first
   (`overview.md`, `step-*.md`, other `plan-*.md`), then inspect the actual
   files, symbols, patterns, flows, states, and tests involved. Base diagram
   selection and plan decisions on this research. Every referenced artifact
   must exist or be explicitly marked `[new]`.

4. **Choose the file path.** Repo root is
   `git rev-parse --show-toplevel 2>/dev/null || pwd`. Write
   `<root>/plans/plan-<slug>.md`, using a short kebab-case task slug, e.g.
   `plan-oauth-refresh.md`. Create `plans/` if absent. Never silently
   overwrite an existing plan; choose another slug or ask before replacing it.

5. **Write the file** using "Plan file format" and the contracts above. Put
   only research gaps that affect implementation in `## Open questions`; the
   user answers them with inline `@me` comments.

6. **Open the review split** only when `$TMUX` is set. Pass this pane's id as
   `CLAUDE_PANE` so `<leader>pr` can send comments back regardless of which
   agent runs in the pane:

   ```bash
   plan="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/plans/plan-<slug>.md"
   : "${TMUX_PANE:?not in tmux}"
   tmux split-window -h -t "$TMUX_PANE" \
     -e "CLAUDE_PANE=$TMUX_PANE" -e "PLAN_FILE=$plan" \
     nvim "$plan"
   ```

   Substitute the real slug. Outside tmux, skip the split; report the path and
   tell the user to open it and send `/plan-review <path>` after commenting.

7. **Explain the loop concisely.** Annotate with `@me` HTML comments
   (`<leader>pc` inserts one), save, press `<leader>pr` (leader = Space) to
   type `/plan-review <path>` into this pane, then close with `:q` when Status
   says ready. Mention `plan-detail` for depth and `plan-done` after
   implementation. Stop; the next round arrives as `/plan-review <path>`.

## Plan file format

`plans/plan-<slug>.md`:

```markdown
---
plan: <Plan title>
slug: <slug>
kind: <feature|bugfix|refactor|migration|infra|tooling>
created: <YYYY-MM-DD>
horizon: <rough effort span, e.g. 2 days>
---

<!-- plan-review guide (delete when done):
  - Leave notes for the agent as HTML comments beginning with @me, e.g. a line:
        @me: use Postgres, not Redis
    written inside an HTML comment, anywhere in the plan. In nvim, Space+pc
    inserts one under the cursor.
  - Save, then press Space+pr to send your notes back for review.
  - The agent edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - plan-detail <question> for depth; plan-done to delete when implemented.
-->

# <Plan title>

Status: draft — <YYYY-MM-DD>

## Goal
<1-2 short lines: outcome and any necessary scope interpretation>

## Shape
<task-specific ASCII diagram(s): architecture, flow, state, lifecycle,
dependencies, before/after, ownership, or touched components; verified
existing artifacts plus clearly marked [new] artifacts only; each fence
immediately followed by its [DIAGRAM PROMPT: …] caption line>

## Plan
<numbered checkbox one-liners: `- [ ] 1. path/to/file.ts:line-or-symbol — change`>
<mark new files/symbols `[new]`; optional `(effort: S|M|L|XL)` and
`needs: <nums>` tags; add `###` groups only for meaningful phases
or subsystem boundaries>

## Edge cases & risks
<decision-relevant one-liners only, each starting `⚠️ RISK:`>

## Open questions
<unsettled implementation decisions, one line each; answer via @me comments>

## Review changelog
<!-- plan-review appends a dated round entry here each pass -->
```

## Hard rules

- **Never implement in this skill.** Output is the plan file only; the user
  triggers implementation explicitly after review.
- **Never skip research.** Read related plans and relevant code before writing.
- **Never clobber an existing plan file** without the user's say-so.
- **ASCII diagrams only.** The plan is read in terminal nvim; never use
  mermaid, graphviz, or renderer-dependent formats.
- **Keep the renderer grammar exact.** Frontmatter keys, `[DIAGRAM PROMPT: …]`
  captions, numbered checkbox entries, and `⚠️ RISK:` prefixes are parsed
  verbatim by a downstream AI — never paraphrase or restyle the tokens.
- Requires tmux for the split; without tmux, write the file and report the
  path — never use another editor or an in-conversation review.
