# Interface rules

Priority order: fix a higher section before a lower one. Numbers are
defaults; a value in `docs/design.md` or the repository's tokens wins.
Adapted from ui-ux-pro-max's quick reference (MIT); its product-to-style
lookup tables are deliberately left out.

## 1. Accessibility (critical)

- Contrast: body text 4.5:1, large text (≥24px, or ≥18.7px bold) 3:1,
  icons and control boundaries 3:1, focus indicator 3:1 against its
  neighbours. Check light and dark separately; dark mode uses desaturated,
  lighter tonal variants, not inverted colors.
- Focus: visible ring 2–4px, never removed; never hidden behind a sticky
  header or bottom bar. Tab order matches visual order.
- Names: every icon-only control has an accessible name and state
  (`aria-label`, `accessibilityLabel`). Decorative icons next to text are
  hidden from assistive tech.
- Color is never the only signal: pair it with text, icon or pattern.
- Headings do not skip levels. Inputs have real labels, not placeholders.
- Drag has a single-pointer or keyboard alternative. Paste and password
  managers are allowed in auth fields.
- Respect reduced motion, reduced transparency and larger text (Dynamic
  Type, Android font scale, browser zoom to 200%).
- On route or screen change, move focus to the main content.

## 2. Touch and interaction (critical)

- Targets: 44×44pt iOS, 48×48dp Android, 24×24 CSS px minimum on the web
  (44px for primary touch actions). Grow the hit area (`hitSlop`, padding,
  pseudo-element), not the visual.
- At least 8px between adjacent targets.
- Feedback within 100ms of press; a press state never changes layout bounds.
- Async buttons show progress and block double submit.
- No hover-only affordances; anything revealed on hover is reachable by
  tap and keyboard.
- No horizontal swipe on main content that fights system back gestures.

## 3. Performance (high)

- Reserve space for media (`width`/`height` or `aspect-ratio`); no layout
  shift when content loads.
- Images in WebP/AVIF with `srcset`/`sizes`; lazy-load below the fold.
- Fonts: `font-display: swap`, preload only the critical face.
- Virtualize lists past about 50 rows; paginate or aggregate past 1,000.
- Frame budget 16ms at 60Hz, 8ms at 120Hz. Debounce or throttle scroll and
  input handlers.
- Skeletons only for waits over about 1s; no spinner for work that finishes
  under 300ms.

## 4. Style consistency (high)

- One style family per product; effects (shadow, blur, radius) match it.
- Blur means "the thing behind is dismissed or secondary", not decoration.
- Elevation scale is consistent; a higher surface is always visibly higher.
- Prefer platform controls (native pickers, switches, sheets) over custom.
- Official brand logos only.

## 5. Layout and responsive (high)

- Web breakpoints 375 / 768 / 1024 / 1440. Mobile-first. Never disable zoom.
- App shells use `min-h-dvh` (`100dvh`), heroes `100svh`; never `100vh`.
- Line length: 60–75 characters desktop, 35–60 mobile (`max-width: 65ch`).
- Spacing on the 4/8 step; section rhythm 16 / 24 / 32 / 48.
- z-index scale 0 / 10 / 20 / 40 / 100 / 1000; nothing else.
- No horizontal scroll on mobile; no nested scroll regions.
- Fixed bars get matching content insets; respect safe areas.
- Sidebar navigation from 1024px; below that, bottom bar or drawer.
- Chips and labels wrap before they shrink; a `+n` overflow is an operable
  control.

## 6. Typography and color (medium)

- Body 16px minimum on mobile (also prevents iOS input zoom); never under
  12px anywhere. Body line-height 1.5–1.75; headings 1.05–1.25.
- Weights: body 400, labels 500, headings 600–700.
- Starting scale when nothing is given: 12 14 16 18 24 32.
- Semantic color tokens: background, foreground, surface, muted,
  muted-foreground, border, primary, on-primary, accent, destructive,
  on-destructive, ring. Components use roles, never raw palette values.
- Long tokens (emails, URLs, hashes): `overflow-wrap: anywhere` on a
  shrinkable child (`min-width: 0`); never `word-break: break-all` on prose.
- `text-wrap: balance` on headings as an enhancement.

## 7. Forms and feedback (medium)

- Visible label above each field, helper text below, error below the field
  linked by `aria-describedby`, announced with `role="alert"`.
- Validate on blur, not per keystroke. Errors say the cause and the fix.
- After a failed submit, focus the error summary (with links to fields),
  else the first invalid field.
- Inputs at least 44px tall; correct `type`, `inputmode`, `autocomplete`.
- Disabled: opacity 0.38–0.5 plus the semantic disabled attribute.
- Toasts: `aria-live="polite"`, never steal focus, auto-dismiss 3–5s,
  persistent when they carry an action.
- Destructive actions are visually separated and confirmed or undoable.
- Every list and data view has an empty state that says what to do next.

## 8. Navigation (high)

- Bottom navigation 3–5 items, icon plus label, top-level destinations only.
- Back is predictable and preserves scroll, filters and input.
- Never mix tab bar, sidebar and bottom nav at the same level.
- Modals are for focused tasks, not navigation; they have a visible close
  and dismiss with Escape (web) or swipe-down (mobile sheet).
- Breadcrumbs from three levels deep (web).
- Disabled destinations explain why instead of disappearing.

## 9. Charts and data (low)

- Trend → line, comparison → bar, part of whole → bar (pie only up to 5
  categories). Over 15 bar categories → horizontal or table.
- Series lines and bars 3:1 against the ground, labels 4.5:1; never
  red/green alone.
- Legends near the chart, axis units shown, no rotated labels on mobile.
- Tooltips work by keyboard and touch; offer a table alternative.
- Locale-aware number formatting; tabular figures in tables.
- Over 1,000 points: aggregate or sample; canvas over SVG.
