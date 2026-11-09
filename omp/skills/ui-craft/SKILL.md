---
name: ui-craft
description: Shared interface, motion, platform and worst-case-data rules read by the design and review-ui skills, and by implement or work when a change touches UI. Distilled from ui-ux-pro-max (rules with numbers) and Emil Kowalski's skills (motion, mobile, break-ui).
disable-model-invocation: true
---

# ui-craft

Reference rules, not a workflow. `design` and `review-ui` read this file
and the parts below; `implement` and `work` read it when a change adds or
changes UI. Read only the parts the task needs.

| File | Read when |
| --- | --- |
| `skill://ui-craft/interface.md` | Any screen, component or style: accessibility, touch, layout, type, color, forms, navigation, charts, performance |
| `skill://ui-craft/motion.md` | Anything that moves, appears, disappears or responds to a press or gesture |
| `skill://ui-craft/platforms.md` | Code for a specific stack: Astro/React/Tailwind web, mobile web, Expo, Tauri, MUI, SwiftUI; picking a library |
| `skill://ui-craft/stress.md` | A screen shows data a person or an API supplies |

## Detect the platform first

Never assume a stack. Read `docs/stack.md`, then the manifests:
`package.json` dependencies (`astro`, `react`, `tailwindcss`, `expo`,
`react-native`, `@tauri-apps/api`, `@mui/material`), `*.xcodeproj` or
`Package.swift`. A monorepo has one platform per app; use the app being
changed. If nothing settles it, ask once.

## The bar

These hold everywhere; the files give the numbers.

1. One primary action per screen or region. Everything else is visibly
   secondary.
2. Every value is a token: color, type, space, radius, shadow, duration,
   easing. No raw hex or ad-hoc pixel values in components.
3. A short type scale (about five sizes, two or three weights) and one
   spacing step (4 or 8) used everywhere.
4. Text is readable: 4.5:1 body contrast in every theme, never grey body
   text on a tinted ground.
5. Every screen that shows data has its empty, loading, error and
   worst-case states designed, not left to chance.
6. Motion has a purpose and a frequency budget; when unsure, remove it.
7. Repeated rows share fixed slots (avatar, icon, trailing action) so
   columns align.
8. Real copy and plausible data, never lorem ipsum.

## Taste rules that catch generic AI UI

- No purple-to-pink gradients, glassmorphism or glow unless the direction
  names them.
- No emoji as icons. One icon family, one stroke weight (1.5 or 2px), one
  of filled or outline per hierarchy level.
- No card around everything. Hierarchy comes from weight, size and space
  before borders and shadows.
- No centered hero plus three feature cards by reflex; follow the content.
- Headings get slight negative tracking (about `-0.02em`); body text none.
- Changing numbers use tabular figures.
- Relative dates switch to absolute after about a week.

## Never

- Treat these rules as a reason to change code the request does not touch.
  A finding outside the scope is named, not fixed.
- Override a decision recorded in `docs/design.md`, `docs/stack.md` or the
  repository's own tokens with a rule from here; flag the conflict instead.
