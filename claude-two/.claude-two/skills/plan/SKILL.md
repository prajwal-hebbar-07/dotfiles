---
name: plan
description: File-native planning that replaces plan mode entirely. Researches the real repository, writes a self-contained senior-engineering implementation plan to plans/plan-SLUG.md, and opens it for review in Plan Visualizer when available plus a right-hand tmux split running nvim. The user annotates it with inline "@me" HTML comments resolved later by /plan-review. Runs in the active permission mode and never enters plan mode. Use when the user asks to plan a task, make or write a plan, create a plan document, or prepare a plan for editor review.
---

# Plan (file-native, no plan mode)

Research the real repository and write a reviewable technical implementation
plan to `plans/plan-<slug>.md`. Open it in Plan Visualizer when that local app
is available and in a right-hand tmux split running nvim when inside tmux.
`/plan-review` resolves inline `@me` annotations in later rounds.

The only artifact is the plan file, never implementation or a plan-mode
session.

## Document standard

Write a self-contained engineering document that a senior engineer could use
to review the design, understand the trade-offs, and implement the change
without reconstructing missing context from the conversation.

- State the problem, intended outcome, and scope boundary.
- Describe the verified current behavior before proposing changes.
- Record material design decisions and explain why they fit the repository.
- Identify affected interfaces, data, state, failure behavior, compatibility,
  security, performance, and operations when relevant.
- Name concrete files and stable symbols. Mark planned artifacts `[new]`.
- Sequence implementation work by dependency and make each step verifiable.
- Separate facts, decisions, assumptions, risks, and unresolved questions.
- Include only sections relevant to the task, but never omit information an
  implementer or reviewer needs.
- Prefer clear prose, lists, and tables. Do not include visualization prompts,
  renderer metadata, or machine-specific formatting contracts.

Avoid tutorials, generic framework explanations, speculative architecture,
and filler. Concision is useful only when the document remains independently
understandable.

## Repository grounding

Before writing:

1. Read relevant existing documents in `plans/`.
2. Inspect affected entry points, implementation paths, symbols, data and
   control flow, configuration, tests, and operational hooks.
3. Verify every referenced existing file, directory, command, function, type,
   class, module, component, state, and interface in the repository.
4. Check history only when it materially explains a constraint or prior
   decision.

Never invent repository structure. Distinguish verified current behavior from
the proposed design.

## Flow

1. **Never enter plan mode.** Do not call EnterPlanMode. Do not use
   ExitPlanMode to present the result. Work in the active permission mode.

2. **Understand the task.** Take it from invocation arguments or conversation.
   Ask only when an ambiguity would materially change scope or design.
   Otherwise document the interpretation and any assumption for inline review.

3. **Research before writing.** Follow "Repository grounding" completely.
   Do not create the plan until the relevant implementation and tests have
   been read.

4. **Choose the file path.** Resolve the repository root with
   `git rev-parse --show-toplevel 2>/dev/null || pwd`. Write
   `<root>/plans/plan-<slug>.md` using a short kebab-case task slug, such as
   `plan-oauth-refresh.md`. Create `plans/` if absent. Never silently
   overwrite an existing plan; choose another slug or ask before replacing it.

5. **Write the file** with the Write tool using "Plan file format". Adapt the
   document to the task: omit irrelevant subsections, add a focused subsection
   when the template does not capture an important concern, and keep all
   claims tied to repository evidence.

6. **Open the review surfaces.** They share the same Markdown file; neither is
   a separate source of truth.

   - When `$TMUX` is set, open the nvim split. Pass Claude's pane id into nvim
     so `<leader>pr` sends comments back:

     ```bash
     plan="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/plans/plan-<slug>.md"
     : "${TMUX_PANE:?not in tmux}"
     tmux split-window -h -t "$TMUX_PANE" \
       -e "CLAUDE_PANE=$TMUX_PANE" -e "PLAN_FILE=$plan" \
       nvim "$plan"
     ```

   - Probe `${PLAN_VISUALIZER_URL:-http://127.0.0.1:4823}`. If reachable,
     URL-encode the absolute plan path and open
     `<visualizer>/?path=<encoded-plan-path>` in the browser. Do not start,
     install, or search for the app when it is unavailable; report the plan
     path and keep the nvim/manual workflow usable.

   Substitute the real slug. Outside tmux, skip only the split.

7. **Explain the loop concisely.** In Plan Visualizer, add margin or selection
   comments and click **Run plan review**; the app invokes `/plan-review` in a
   headless Claude process and reloads the file when it exits. In nvim, use
   `<leader>pc`, save, and press `<leader>pr` (leader = Space). Close nvim with
   `:q` when Status says ready. Mention `/plan-detail <question>` for follow-up
   analysis and `/plan-done` after implementation. Stop and wait for the next
   review round.

## Plan file format

`plans/plan-<slug>.md`:

```markdown
<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In Plan Visualizer, use a block's margin control or select text.
    In nvim, Space+pc inserts one under the cursor.
  - In Plan Visualizer, click Run plan review. In nvim, save and press Space+pr.
  - Claude edits this file in place; the review surface reloads it.
  - Close nvim (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# <Plan title>

Status: draft — <YYYY-MM-DD>

## Summary
<Problem, intended outcome, proposed direction, and scope in a short overview.>

## Context and current state
<Verified current behavior, relevant architecture, entry points, constraints,
and repository evidence. Reference concrete paths and symbols.>

## Goals
- <Observable outcome>

## Non-goals
- <Explicit boundary that prevents scope drift>

## Proposed design
<Target behavior and material design decisions. Cover interfaces, data/state,
error handling, compatibility, security, performance, and operations only when
relevant. Explain non-obvious choices and rejected alternatives briefly.>

## Change inventory
| Area | Current artifact | Planned change |
| --- | --- | --- |
| <subsystem> | `path/to/file.ts:symbol` | <specific responsibility change> |

## Implementation plan
- [ ] 1. `path/to/file.ts:symbol` — <change, dependencies, and completion condition>
- [ ] 2. `[new] path/to/file.test.ts` — <coverage or behavior established>

## Verification
- <Automated tests and exact commands when known>
- <Integration, manual, migration, or operational checks when relevant>

## Rollout and rollback
<Deployment order, compatibility window, observability, rollback trigger, and
recovery path. State "Not required" with a reason when the change is local and
atomic.>

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| <credible failure mode> | <consequence> | <prevention, detection, or recovery> |

## Open questions
- <Only decisions that repository research could not settle; include owner or
  decision point when known.>

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
```

## Hard rules

- **No plan mode, ever.** Never call EnterPlanMode or use ExitPlanMode.
- **Never implement.** The user triggers implementation after review.
- **Never skip research.** Read related plans, relevant code, configuration,
  and tests before writing.
- **Never clobber an existing plan file** without the user's approval.
- **Do not optimize the document for a visualization tool.** Write ordinary,
  durable Markdown for engineering review; the user owns any later visual.
- **Do not hide uncertainty.** Record assumptions, unresolved decisions, and
  material evidence gaps explicitly.
- Requires tmux only for the nvim split. Without tmux or Plan Visualizer,
  write the file and report the path for manual review. Never substitute an
  in-conversation review.
