---
name: design
description: After settled requirements, stack and blueprint (or a feature spec), design in Paper in two stages — low-fidelity wireframes that show each screen's regions and the flow between screens, then, once the flow is approved, the full design (direction, tokens, screens with every state, motion) checked against ui-craft — recorded in docs/design.md. Use when the user wants something designed before issues are raised.
disable-model-invocation: true
---

# design

Design in Paper, record it in `docs/design.md`, and stop for the user to
look. Wireframes come first so the flow is settled before anyone judges a
colour; the full design follows. The approved design is what
`raise-issues` cuts into issues, what `implement` builds from, and what
`review-ui` compares the code against.

Invoke explicitly:

- `/skill:design [direction | brief | docs/features/<slug>/spec.md]` —
  start, or continue from the current state. A direction (a product to
  start from, how it should feel) is kept for the full design.
- `/skill:design <change>` — change the design; redraws what it touches.
- `/skill:design approve` — approve the stage waiting for review: the
  wireframes, or the full design.
- `/skill:design pick <direction> [changes]` — choose a drawn direction.

Read `skill://ui-craft`, then `skill://ui-craft/interface.md`,
`skill://ui-craft/motion.md` and `skill://ui-craft/stress.md` before the
full design. Read `skill://design/direction.md` before choosing a direction
and `skill://design/paper.md` before any Paper call.

## Never

- Do only what the request needs. Design the screens the requirements, the
  blueprint's chunks or the feature spec imply; add no screen, feature,
  control or destination. A useful extra is named in the reply, not drawn.
- Never ask what is already settled: read the direction or brief, this
  chat, `docs/requirements.md`, `docs/stack.md`, `docs/blueprint.html`,
  `docs/design.md`, the feature spec when given, reference documents the
  user pointed at, and the repository's existing tokens and components
  first.
- Ask about color, type or layout taste in chat. Draw the options instead
  and let the user pick on the boards.
- Start the full design before the user approves the wireframes.
- Draw on a Paper file other than the pinned one, or on a page other than
  its pinned wireframe and design pages, or start Paper Desktop.
- Write application code, or change files other than `docs/design.md`.
- Approve a stage without the user's explicit `approve`.

## States

`docs/design.md` carries one status:

1. `Wireframes` — wireframes and the flow are drawn; waiting for `approve`.
2. `Directions` — direction boards are drawn; waiting for `pick`.
3. `Drawn` — design system and screens are drawn; waiting for `approve`.
4. `Approved` — the user approved; `raise-issues` may cut it into issues.

A change to the flow or a screen's regions returns the status to
`Wireframes`; any other change after `Approved` returns it to `Drawn`.

## Step 0 — readiness

Print one line per check, `ready` or `not ready: <what> — run <command>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `docs/requirements.md` exists, or the feature spec given is `Settled` | `/skill:grill-requirements`, or `/skill:feature` |
| 2 | `docs/stack.md` exists | `/skill:grill-stack` |
| 3 | For a new app: `docs/blueprint.html` exists | `/skill:blueprint` |
| 4 | No decision the user has not deferred prevents defining the screens in scope | the grill that owns the decision |

Any `not ready` stops the run before anything is written or drawn. A
screen that depends on a deferred decision is drawn with the open part
marked, and the decision goes under `Open decisions`. Paper is not part of
this check; it is checked when drawing starts.

## Step 1 — gather

1. Read the settled sources listed under `Never`. The screens come from the
   requirements' user journeys and the blueprint's `Screens` per chunk;
   their failure cases (offline, permission denied, an outside system down)
   become screen states. A screen that needs something the requirements or
   stack do not provide is an open decision naming the grill that owns it,
   not a design workaround.
2. Establish, from evidence: who uses it and how often, the platform and
   size (`platform` in `skill://ui-craft` decides; phone 390×844, desktop
   1440×900, tablet 834×1194), the screens and their states, and each
   screen's single primary action.
3. If the repository already has UI, its tokens and components are the
   direction. Read them (Tailwind `@theme`, CSS variables, MUI theme, RN
   theme file) and design inside them; new tokens only where a screen
   needs one that does not exist.
4. Ask the decisions only the user can make (audience, platform, a screen
   or state the requirements leave open) in one batch, each with a
   recommendation. Never ask about the look.

For a feature spec, the scope is the screens its `Impact: UI` line names;
other screens in `docs/design.md` stay untouched.

## Step 2 — wireframes

Skip this step when the screens in scope already have approved wireframes.

1. Write `docs/design.md` with `Status: Wireframes`, the `Flow` section and
   each screen's `Job`, `Primary action`, `Regions` and `Next`.
2. Draw on the wireframe page by `paper.md`'s wireframe rules: one `Flow`
   board, then one wireframe board per screen in journey order. Grey boxes
   with plain labels saying what goes there ("Invoices, newest first, 20
   per page"), the primary action marked, and arrows or notes saying where
   each action leads ("Pay → S4 Receipt; card declined → S3 · error"). No
   colour, tokens, icons or real styling.
3. Check each board by screenshot: every screen in the flow has a board,
   every `Next` arrow lands on a screen, nothing is clipped.
4. Stop. Reply with the screens and the flow in one table and ask the user
   to `approve` the flow or request changes.

## Step 3 — directions

After the wireframes are approved. Skip this step when the direction is
settled: given in the invocation or the chat, existing UI tokens, a
reference the user named as the base, a `pick` already made, or a
`Direction` section in `docs/design.md`.

Otherwise follow `direction.md` to write two or three directions that
differ on a named axis (density, layout, personality, color attitude, type
voice), never only in color. Name them by their feel (`Quiet`, `Editorial`,
`Dense`), not `Option A`. Each gets dials, tokens and a `Refuses` line.

Draw the most important screen once per direction, side by side on the
design page, from its approved wireframe, with real copy and plausible
data. Set `Status: Directions`, write all directions under
`## Directions`, and stop. Reply with a table:

| Direction | Axis | Right when | Costs |
| --- | --- | --- | --- |

Do not recommend one unless the user asks.

## Step 4 — full design

After `pick`, or when Step 3 was skipped:

1. Keep the picked or given direction and apply the changes the user gave
   with it; move any others to `## Rejected directions`, one line each.
2. Write the full `docs/design.md` in the shape below. Each screen keeps
   its wireframe's regions and `Next`; a change to them goes back to
   Step 2.
3. For each screen, design every state it needs (empty, loading, error,
   partial, success, no permission) and check each dynamic field against
   `stress.md`: decide wrap, truncate or clamp, and draw one worst-case
   state for screens that show lists or user data.
4. For each interaction, run the motion gate (`motion.md` §1). Record the
   purpose and the recipe with exact values, or `none` with the reason.
5. Draw on the design page by `paper.md`: tokens, the `Design system`
   board, then the screens in journey order with their states beside them.
6. Check each board by screenshot against `interface.md` §1–§6: contrast,
   target sizes, one primary action, alignment of repeated rows, nothing
   clipped. Fix the board before the next one.
7. Set `Status: Drawn` and stop.

## Step 5 — review loop

- A change in chat: update `docs/design.md` first, mark the affected
  screens `Paper: stale`, redraw only those, and set the status the
  `States` rule gives.
- A board that differs from the document while the document is right:
  redraw the board.
- `approve` at `Wireframes`: set `Wireframes: approved YYYY-MM-DD` and go
  on to Step 3 in the same run.
- `approve` at `Drawn`: confirm no screen is `stale` or `not built`, then
  set `Status: Approved` and the date.

## `docs/design.md`

```markdown
# Design: <product or feature>

Status: Wireframes | Directions | Drawn | Approved
Updated: YYYY-MM-DD
Wireframes: drawn YYYY-MM-DD | approved YYYY-MM-DD
Paper: <file name> (fileId <id>)
Wireframe page: <page name> (pageId <id>)
Design page: <page name> (pageId <id>)
Platform: <phone 390×844 | desktop 1440×900 | …>
Sources: <requirements, blueprint, spec, brief, reference documents used>

## Flow

- S<n> <name> → <action> → S<m> <name>

## Direction

- Base: <named product or kind of UI> · Changes: <what differs from it>
- Dials: variance <1–10> · motion <1–10> · density <1–10>
- <feel word> — <the rule it means>
- Refuses: <what this UI never does>

## Tokens

| Token | Light | Dark | Use |
| --- | --- | --- | --- |

| Type token | Family | Size / line-height | Weight | Tracking |
| --- | --- | --- | --- | --- |

- Space: step <4|8>; scale <values>
- Radius: <values> · Elevation: <values>

| Motion token | Value | Use |
| --- | --- | --- |

## Patterns

- P<n> <name> — <rule shared by several screens>

## Screens

### S<n> <name>

- Job: <what the person does here> · Primary action: <one>
- Regions: <region — what goes there, top to bottom>
- Next: <action — S<m> | state>
- Content: <fields with sample values>
- States: <state — what the person sees>
- Worst case: <field — wrap | truncate end | truncate middle | clamp 2>
- Motion: <trigger — purpose — recipe with values> | none (<reason>)
- Wireframe: built YYYY-MM-DD | stale
- Paper: built YYYY-MM-DD | stale | not built

## Rejected directions

- <name> — <why it lost>

## Open decisions

- <only what the user must still decide>
```

During `Wireframes`, only the header (without `Design page`), `Flow`,
`Open decisions` and each screen's `Job`, `Primary action`, `Regions`,
`Next` and `Wireframe` lines exist. During `Directions`, `## Directions`
holds one `### <name>` block per direction with its dials, key tokens and
`Refuses`, in place of `## Direction` and `## Tokens`.

## Reply

Reply with the Paper file and pages, the boards drawn, tokens created, the
status, open decisions, and the next command (`approve`, `pick`, or, once
approved, `/skill:raise-issues`; within `feature`, `/skill:feature`). Do
not repeat the document. Say that no application code was changed.
