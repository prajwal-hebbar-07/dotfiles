---
name: build-ui
description: Implement a design — a screen from docs/design.md, a Paper board or selection, a screenshot, or a spec document — through the implement skill's plan and approval flow, taking exact values from Paper, mapping them to the repository's tokens and components, and applying ui-craft's interface, motion, platform and worst-case rules. Use when the user wants a design built in code.
disable-model-invocation: true
---

# build-ui

`implement`, for UI. Run `skill://implement` in full — plan in
`docs/implementation-plan.md`, explicit approval, smallest complete
change, `docs/codebase-map.md` — with the additions below. Where this file
and `implement` disagree, this file wins.

Invoke explicitly as `/skill:build-ui <what to build>`, where the target is
one of:

- `S<n>` or a screen name from `docs/design.md`;
- `paper` (the current Paper selection) or a Paper board name;
- an attached screenshot or image;
- a spec document path (a section guide, a measured design spec).

Read `skill://ui-craft` and the parts it lists for the platform before
planning.

## Never

- Do only what the request needs. Build the named screen or section with
  its designed states; add no screen, control, option, animation or
  dependency the design does not show. A useful extra goes under
  `Not doing`.
- Never ask what is already settled: read the design source, this chat,
  `docs/design.md`, `docs/codebase-map.md`, `docs/stack.md` and the
  existing components and tokens first.
- Read sizes, colors or spacing off a screenshot when Paper or a spec
  document has the exact value.
- Put a raw color, font size, spacing, radius, duration or easing in a
  component when a token exists or should exist.
- Write a new component where the repository, its UI library or an
  installed dependency already has one.
- Change Paper, or change `docs/design.md` beyond its `Open decisions`.
- Run the app, a dev server, a build, tests or a browser. The
  no-self-testing rule overrides `implement`'s verify step.

## Step A — read the design (before `implement` Step 2)

1. **Find the source of truth.**
   - `docs/design.md` screen: build from it when `Status: Approved`. If it
     is `Drawn` or `Directions`, say so and stop unless the invocation says
     to build anyway; then record that under `Risks`.
   - Paper: confirm the file with `get_basic_info` (the `Paper:` line in
     `docs/design.md` when present), call `get_guide` once, then
     `get_jsx` for structure (Tailwind format when the repository uses
     Tailwind), `get_computed_styles` for exact values, `get_fill_image`
     or `export` for images and icons. Never edit the design.
   - Screenshot only: estimate values, snap each to the nearest existing
     token, and list every estimate under `Risks`.
   - Spec document: its values are exact; follow its own precedence notes.
2. **Map tokens once.** For each design token, find the repository's
   equivalent (Tailwind `@theme`, CSS variables, MUI theme, RN theme file,
   SwiftUI asset catalog). Reuse matches; add missing tokens to that one
   source. A design value that conflicts with an existing token is an open
   decision, not a silent override.
3. **Map components.** For each element, name the existing component,
   library primitive or new component that renders it.
4. **States and worst case.** List every state the design shows and every
   dynamic field's wrap, truncate or clamp rule (`stress.md`). A state the
   design omits but the data can produce (empty, error, loading) is an open
   decision with a recommendation.
5. **Motion.** For each designed interaction, take the recipe from
   `docs/design.md` or run the gate in `motion.md`; pick the cheapest tool
   for the platform (`platforms.md`).

## Plan additions

Add these sections to `docs/implementation-plan.md` after `Reuse`:

```markdown
## Design source

- <docs/design.md S<n> | Paper file · page · board | screenshot | spec path>, status <…>

## Design mapping

| Design element | Component / file | Tokens | States |
| --- | --- | --- | --- |

## Tokens

- `<design token>` → `<repository token>` (reused | added in `<file>`)

## Motion

- <trigger> — <purpose> — <tool, properties, duration, easing>; reduced motion: <fallback>

## Worst case

- <field> — <wrap | truncate end | truncate middle | clamp 2>, <fix from stress.md>
```

`Verification` lists the commands and checks for the user to run, not
results: the dev or preview command; the screens and states to open;
widths 320, 375, 768, 1024, 1440 (web) or small and large phone (native);
dark mode; reduced motion; 200% zoom or largest text; keyboard-only pass;
the motion feel check from `motion.md` §9; and a side-by-side comparison
with the Paper board or reference.

## While implementing

- Apply `interface.md` and `platforms.md` to everything touched: real
  semantics, accessible names, focus states, target sizes, safe areas.
- Build the designed states, not only the happy path.
- Motion uses the motion tokens and ships with its reduced-motion and
  hover-gating rules in the same change.
- Keep the structure close to Paper's JSX only where it matches the
  repository's patterns; the repository's conventions win.

## Close

Follow `implement`'s close with this change: do not run checks. Set
`Status: Implemented` when every step is done, and keep `Verification` as
the exact commands and visual checks for the user. Reply with the plan
path, the files changed, tokens added, anything built from an estimate,
and those commands. Say it was not run or tested.
