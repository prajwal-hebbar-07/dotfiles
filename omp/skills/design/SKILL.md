---
name: design
description: After approved requirements, stack and architecture, turn them into a design in Paper and docs/design.md — direction, tokens, screens with every state, and motion — by drawing two or three real directions to pick from, then the design system and screens, checked against ui-craft. Implementation verification is not a prerequisite. Use when the user wants something designed before it is built.
disable-model-invocation: true
---

# design

Design in Paper, record it in `docs/design.md`, and stop for the user to
look. The user judges the look on the boards; this skill makes the boards
good enough to judge and keeps the document exact enough that `build-ui`
can implement it without guessing.

Invoke explicitly:

- `/skill:design [brief]` — start, or continue from the current state.
- `/skill:design pick <direction> [changes]` — choose a drawn direction.
- `/skill:design <change>` — change the design; redraws what it touches.
- `/skill:design approve` — mark the drawn design approved.

Read `skill://ui-craft`, then `skill://ui-craft/interface.md`,
`skill://ui-craft/motion.md` and `skill://ui-craft/stress.md` before
designing. Read `skill://design/direction.md` before choosing a direction
and `skill://design/paper.md` before any Paper call.

## Never

- Do only what the request needs. Design the screens the requirements or
  brief name; add no screen, feature, control or destination. A useful
  extra is named in the reply, not drawn.
- Never ask what is already settled: read the brief, this chat,
  `docs/requirements.md`, `docs/stack.md`, `docs/architecture.md`,
  `docs/design.md`, reference documents the user pointed at, and the
  repository's existing tokens and components first.
- Ask about color, type or layout taste in chat. Draw the options instead
  and let the user pick on the boards.
- Draw on a Paper file or page other than the pinned one, or start Paper
  Desktop.
- Write application code, or change files other than `docs/design.md`.
- Mark the design approved without the user's explicit `approve`.

## States

`docs/design.md` carries one status:

1. `Directions` — direction boards are drawn; waiting for `pick`.
2. `Drawn` — design system and screens are drawn; waiting for review.
3. `Approved` — the user approved; `build-ui` may implement it.

A change after `Approved` returns the status to `Drawn`.

## Step 0 — readiness

Design needs an approved, consistent intended design, not working software.
Every run starts with this check; print it as a checklist, one line each,
`ready` or `not ready: <what> — <next action>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `docs/requirements.md` exists | `/skill:draft-docs requirements`, then `/skill:grill-requirements` |
| 2 | `docs/stack.md` exists | `/skill:draft-docs stack`, then `/skill:grill-stack` |
| 3 | `docs/architecture.md` exists | `/skill:draft-docs architecture` |
| 4 | The documents or current chat establish user approval of the intended design | Ask only for the missing approval; never approve on the user's behalf |
| 5 | No unresolved decision or contradiction prevents defining the requested screens | Resolve from the approved sources first; ask only for a remaining user decision, or name `/skill:grill-architecture` for a blocking architecture gap |

Any `not ready` stops the run before anything is written or drawn. Scope
decisions and contradictions to the requested screens; unrelated or
explicitly deferred work does not block them.

A standalone architecture review is optional. Use it when present, or the
review embedded in the architecture when that supersedes it. A missing or
outdated review, `Not verifiable` verdict, missing implementation, runtime
tests or deployment evidence are warnings, not wireframe blockers. Inspect
any relevant finding for an actual screen-definition gap rather than
blocking on a verdict, date or unresolved-evidence heading alone. Never
relabel a review as verified or treat design approval as implementation
proof, provider permission or release readiness.

Print relevant evidence gaps and deferred items as `warning:` lines.
Record risks that affect a screen in the design's `Risks and evidence
gaps`; put only decisions the user still needs to make in `Open decisions`.
Paper is not part of this check; it is checked when drawing starts.

## Step 1 — gather

1. Read the settled sources listed under `Never`, including any standalone
   or embedded architecture review that is available and not superseded.
   The screens follow the architecture's flows and its failure modes
   become screen states (offline, sync conflict, permission denied, rate
   limited). Distinguish an intended capability awaiting implementation
   evidence from a capability the architecture does not provide. Record
   the former under `Risks and evidence gaps`; the latter is an open
   decision naming `/skill:grill-architecture`, not a design workaround.
2. Establish, from evidence: who uses it and how often, the platform and
   size (`platform` in `skill://ui-craft` decides; phone 390×844, desktop
   1440×900, tablet 834×1194), the screens and their states, and what each
   screen's single primary action is.
3. If the repository already has UI, its tokens and components are the
   direction. Read them (Tailwind `@theme`, CSS variables, MUI theme, RN
   theme file) and design inside them; new tokens only where a screen
   needs one that does not exist.
4. Ask the decisions only the user can make (audience, platform, a screen
   or state the requirements leave open) in one batch, each with a
   recommendation. Never ask about the look.

## Step 2 — directions

Skip this step when the direction is settled: existing UI tokens, a
reference the user named as the base, a `pick` already made, or a
`Direction` section in `docs/design.md`.

Otherwise follow `direction.md` to write two or three directions that
differ on a named axis (density, layout, personality, color attitude, type
voice), never only in color. Name them by their feel (`Quiet`, `Editorial`,
`Dense`), not `Option A`. Each gets dials, tokens and a `Refuses` line.

Pin the Paper file and page (`paper.md`), then draw the most important
screen once per direction, side by side, with real copy and plausible
data. Write `docs/design.md` with `Status: Directions`, all directions
under `## Directions`, and stop. Reply with a table:

| Direction | Axis | Right when | Costs |
| --- | --- | --- | --- |

Do not recommend one unless the user asks.

## Step 3 — design

After `pick` (or when Step 2 was skipped):

1. Keep the picked direction and apply the changes the user gave with it;
   move the others to `## Rejected directions`, one line each.
2. Write the full `docs/design.md` in the shape below.
3. For each screen, design every state it needs (empty, loading, error,
   partial, success, no permission) and check each dynamic field against
   `stress.md`: decide wrap, truncate or clamp, and draw one worst-case
   state for screens that show lists or user data.
4. For each interaction, run the motion gate (`motion.md` §1). Record the
   purpose and the recipe with exact values, or `none` with the reason.
5. Draw in Paper by `paper.md`: tokens, the `Design system` board, then
   the screens in journey order with their states beside them.
6. Check each board by screenshot against `interface.md` §1–§6: contrast,
   target sizes, one primary action, alignment of repeated rows, nothing
   clipped. Fix the board before the next one.
7. Set `Status: Drawn` and stop.

## Step 4 — review loop

- A change in chat: update `docs/design.md` first, mark the affected
  screens `Paper: stale`, redraw only those, set `Status: Drawn`.
- A board that differs from the document while the document is right:
  redraw the board.
- `approve`: confirm no screen is `stale` or `not built`, then set
  `Status: Approved` and the date.

## `docs/design.md`

```markdown
# Design: <product or feature>

Status: Directions | Drawn | Approved
Updated: YYYY-MM-DD
Paper: <file name> · <page name> (fileId <id>, pageId <id>)
Platform: <phone 390×844 | desktop 1440×900 | …>
Sources: <requirements, brief, reference documents used>

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
- Content: <fields with sample values>
- States: <state — what the person sees>
- Worst case: <field — wrap | truncate end | truncate middle | clamp 2>
- Motion: <trigger — purpose — recipe with values> | none (<reason>)
- Paper: built YYYY-MM-DD | stale | not built

## Rejected directions

- <name> — <why it lost>

## Risks and evidence gaps

- <screen affected, unverified assumption or integration, and required evidence; not a claim of working software>

## Open decisions

- <only what the user must still decide>
```

During `Directions`, `## Directions` holds one `### <name>` block per
direction with its dials, key tokens and `Refuses`, in place of
`## Direction`, `## Tokens` and `## Screens`.

## Reply

Reply with the Paper file and page, the boards drawn, tokens created, the
status, open decisions, and the next command (`pick`, `approve`, or
`/skill:build-ui S<n>`). Do not repeat the document. Say that no
application code was changed.
