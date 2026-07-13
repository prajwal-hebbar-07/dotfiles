---
name: plan
description: Terminal-native planning that replaces plan mode entirely. Researches the real repository, writes a terse diagram-first execution map to plans/plan-<slug>.md, and opens it for review in a right-hand tmux split running nvim so the user can annotate it with inline "@me" HTML comments (resolved later by /plan-review). Runs in whatever permission mode is active — never enters plan mode. Use when the user says "/plan <task>", "plan this", "make/write a plan for X", "create a plan doc", or asks for a plan they can review in the editor.
---

# Plan (terminal-native, no plan mode)

Research the real repository. Write `plans/plan-<slug>.md`. Open it in a
right-hand tmux split running nvim for inline review. `/plan-review` resolves
the user's `@me` annotations in later rounds.

The only artifact is the plan file — never implementation or a plan-mode
session.

## Output contract

Write a technical execution map for a senior software engineer.

- Aggressively minimize prose and sentence count. Prefer fragments, labels,
  arrows, and one-line decisions.
- Goal: normally 1-2 short lines.
- No tutorials, concept explanations, walkthroughs, framework/library
  explanations, standard engineering detail, or obvious implementation steps.
- `/plan-detail` owns reasoning and deeper explanation. `/plan` owns
  architecture, structure, flow, state, boundaries, decisions, dependency
  order, and touched code.
- **If removing a sentence does not reduce the developer's ability to
  implement the change correctly, remove it.**
- Keep empty sections empty; never pad with generic content.

Target density:

```text
Goal            1-2 lines
Shape           1-3 small diagrams
Plan            one line per touched file/symbol
Risks           non-obvious one-liners
Open questions  unresolved decisions only
```

## Diagram-first shape

Make `## Shape` the primary technical explanation. Research first; select the
diagram type that exposes the actual change:

- architecture, ownership, boundaries → boxes + labeled arrows
- current → target architecture → before/after
- request, data, control, async/event flow → directional flow + branches
- state or lifecycle → state machine
- dependency order → vertical/horizontal chain
- touched files/components → tree or boundary view

Use ASCII fenced blocks only. Never Mermaid or Graphviz. Prefer several small,
focused diagrams over one large diagram. Do not force architecture diagrams.
Do not invent architecture. Caption every diagram per "AI-renderable layer".

## Repository grounding

Before writing:

1. Read relevant existing documents in `plans/`.
2. Inspect affected implementation paths, symbols, patterns, flows, and tests.
3. Verify every referenced existing file, directory, function, type, class,
   module, component, state, and command in the repository.

Planned artifacts are allowed; mark them `[new]` when referenced. Use
`[existing]` when a diagram or list would otherwise be ambiguous. Never invent
repository structure.

## Plan entries

Normally one implementation change per line:

```text
path/to/file.ts:symbol — change
```

Prefer stable symbols over line numbers. Group only for a real phase or
subsystem boundary; never add headings for decoration.

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

1. **Never enter plan mode.** Do not call EnterPlanMode. Do not use
   ExitPlanMode to present the result. Work in the active permission mode.

2. **Understand the task.** Take it from invocation args
   (`/plan add oauth refresh`) or conversation. Ask only when genuinely
   ambiguous; otherwise record the terse interpretation in `## Goal` for
   inline correction.

3. **Research before writing.** Follow "Repository grounding" completely.
   Do not create the plan until relevant code, patterns, and tests are read.

4. **Choose the file path.** Repo root is
   `git rev-parse --show-toplevel 2>/dev/null || pwd`. Write
   `<root>/plans/plan-<slug>.md`, using a short kebab-case task slug, e.g.
   `plan-oauth-refresh.md`. Create `plans/` if absent. Never silently
   overwrite an existing plan; choose another slug or ask before replacing it.

5. **Write the file** with the Write tool using "Plan file format". Put only
   decisions research could not settle in `## Open questions`; the user
   answers them with inline `@me` comments.

6. **Open the review split** only when `$TMUX` is set. Pass Claude's pane id
   into nvim so `<leader>pr` sends comments back:

   ```bash
   plan="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/plans/plan-<slug>.md"
   : "${TMUX_PANE:?not in tmux}"
   tmux split-window -h -t "$TMUX_PANE" \
     -e "CLAUDE_PANE=$TMUX_PANE" -e "PLAN_FILE=$plan" \
     nvim "$plan"
   ```

   Substitute the real slug. Outside tmux, skip the split; report the path and
   tell the user to open it and run `/plan-review <path>` after commenting.

7. **Explain the loop concisely.** Annotate with `@me` HTML comments
   (`<leader>pc` inserts one), save, press `<leader>pr` (leader = Space), and
   close with `:q` when Status says ready. Mention `/plan-detail <question>`
   for depth and `/plan-done` after implementation. Stop; the next round
   arrives as `/plan-review <path>`.

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
  - Leave notes for Claude as HTML comments beginning with @me, e.g. a line:
        @me: use Postgres, not Redis
    written inside an HTML comment, anywhere in the plan. In nvim, Space+pc
    inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for depth; /plan-done to delete when implemented.
-->

# <Plan title>

Status: draft — <YYYY-MM-DD>

## Goal
<1-2 short lines: outcome + necessary scope interpretation>

## Shape
<1-3 task-specific ASCII diagrams; verified [existing] artifacts and clearly
marked [new] artifacts only; each fence immediately followed by its
[DIAGRAM PROMPT: …] caption line>

## Plan
<numbered checkbox one-liners: `- [ ] 1. path/to/file.ts:symbol — change`;
prefer symbols over line numbers; one change per line; optional
`(effort: S|M|L|XL)` and `needs: <nums>` tags; headings only for
phases/subsystems>

## Edge cases & risks
<non-obvious implementation risks, one `⚠️ RISK:` line each>

## Open questions
<unresolved decisions repository research could not settle, one line each>

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
```

## Hard rules

- **No plan mode, ever.** Never call EnterPlanMode or use ExitPlanMode.
- **Never implement.** The user triggers implementation after review.
- **Never skip research.** Read related plans, relevant code, patterns, and
  tests before writing.
- **Never invent repository artifacts.** Verify existing references; mark new
  artifacts `[new]`.
- **Never clobber an existing plan file** without the user's say-so.
- **ASCII diagrams only.** Never Mermaid, Graphviz, or renderer-dependent
  formats.
- **Keep the renderer grammar exact.** Frontmatter keys, `[DIAGRAM PROMPT: …]`
  captions, numbered checkbox entries, and `⚠️ RISK:` prefixes are parsed
  verbatim by a downstream AI — never paraphrase or restyle the tokens.
- Requires tmux for the split; without tmux, write the file and report the
  path — never use another editor or an in-conversation review.
