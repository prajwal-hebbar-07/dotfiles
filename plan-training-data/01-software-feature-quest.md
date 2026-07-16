<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Dark Mode for settings-app

Status: reviewed (round 1) — 2026-07-15

## Summary
Add a user-togglable dark theme to `settings-app`. Today color is expressed as
214 hardcoded hex literals scattered across components, so a second theme is
impossible without touching every file. The plan introduces a semantic design
token layer, migrates components to read from it, adds a three-state theme
selector (auto/light/dark) persisted in `localStorage`, and ships behind a
staged rollout flag. The first phase is intentionally invisible: the app
renders entirely from tokens while looking identical to today.

## Context and current state
- Color is hardcoded. A repository scan finds 214 hex literals (`#1a1a2e`,
  `#ffffff`, …) inline in component styles under `src/`. There is no shared
  palette module and no theme switch.
- There is no runtime theming mechanism. Nothing reads a `data-theme`
  attribute; the document root carries no theme state.
- Some hex values are old. A subset dates to 2019 and encodes meaning
  (status colors, brand accents) that is no longer documented, so a blind
  find-replace risks collapsing distinct colors into one token.
- Third-party surfaces exist. The map widget and the payment iframe render
  content we do not control and cannot restyle directly.

## Goals
- Users can switch between light and dark, with an `auto` option that follows
  the OS preference.
- The choice persists across reloads and does not flash the wrong theme on
  first paint.
- All app-owned surfaces render from semantic tokens, passing WCAG AA contrast
  in both themes.
- Rollout is staged and reversible via a flag.

## Non-goals
- Per-component or user-authored custom themes.
- Restyling third-party embeds beyond a themed wrapper frame.
- A visual redesign — light mode must look identical to today after migration.

## Proposed design
Introduce `styles/tokens.css` [new] defining semantic tokens (`--surface`,
`--surface-raised`, `--text-primary`, `--text-muted`, `--accent`) and
`themes/light.css` / `themes/dark.css` [new] binding those tokens to concrete
values. Theme resolves through a `data-theme` attribute on `<html>`.

A `ThemeProvider` [new] holds the selection state machine — `auto → light ⇄
dark` — writes the choice to `localStorage:theme`, and in `auto` follows the OS
via `matchMedia('(prefers-color-scheme: dark)')`. To avoid a white flash, a
tiny synchronous boot script inlined in `<head>` sets `data-theme` from
`localStorage` (or the media query) before first paint.

Components migrate from hex literals to `var(--token)`. A codemod handles the
mechanical ~80%; the remaining ambiguous values (the undocumented 2019 colors)
are mapped by hand. Third-party embeds are wrapped in a themed frame that
matches surrounding surface color; the iframe interior is accepted as a visual
seam.

## Change inventory
| Area | Current artifact | Planned change |
| --- | --- | --- |
| Tokens | — | `[new] styles/tokens.css` — semantic token definitions |
| Themes | — | `[new] themes/light.css`, `[new] themes/dark.css` |
| Provider | — | `[new] src/theme/ThemeProvider.tsx` — state + persistence |
| Boot | `index.html` `<head>` | inline pre-paint `data-theme` resolver |
| Codemod | 214 inline hex literals | `[new] scripts/codemod-hex.ts` rewrites hex → `var()` |
| Layout | `src/layout/{Nav,Sidebar,Footer}.tsx` | adopt tokens |
| Forms | `src/forms/*` | per-theme focus/hover states |
| Charts | `src/charts/palette.ts` | dual-theme dataviz palette |
| Embeds | payment iframe, map widget | themed wrapper frame |

## Implementation plan

### Phase 1 — token layer (invisible)
- [x] 1. `[new] styles/tokens.css` — define semantic tokens; done when the
  five tokens exist and light values equal today's colors.
- [x] 2. `[new] scripts/codemod-hex.ts` — rewrite hardcoded hex to `var()`;
  covers ~80% automatically, remainder flagged for manual review.
- [~] 3. `[new] src/theme/ThemeProvider.tsx` and the `<head>` boot script —
  `data-theme` switch plus `localStorage` persistence. Depends on step 1.
  Done when the app renders 100% from tokens and is visually unchanged.

### Phase 2 — component adoption
- [ ] 4. `src/layout/{Nav,Sidebar,Footer}.tsx` — adopt tokens. Depends on 3.
- [ ] 5. `src/forms/*` — per-theme focus/hover/disabled states. Depends on 3.
- [ ] 6. `src/charts/palette.ts` — palette legible in both themes. Depends on 3.
- [!] 7. payment iframe — vendor ignores our theme; wrap in a themed frame and
  accept the interior seam. Blocked on a themed-frame spec.

### Phase 3 — QA and rollout
- [ ] 8. contrast audit — every text/surface pair passes WCAG AA. Depends on
  4, 5, 6.
- [ ] 9. e2e test — no white flash on dark-mode load. Depends on 3.
- [ ] 10. staged rollout flag: 5% → 25% → 100%. Depends on 8, 9.

## Verification
- Visual regression snapshots before/after Phase 1 confirm light mode is
  pixel-identical.
- Automated contrast check over every token pair asserts WCAG AA.
- e2e: load with `theme=dark` persisted, assert no light-colored first paint.
- Manual spot-check of the codemod's hand-mapped leftovers against the 2019
  color meanings.

## Rollout and rollback
Ship behind a feature flag advancing 5% → 25% → 100% with a day of soak at
each step. Rollback is a flag flip to 0%, which reverts everyone to light mode
with no data migration. Token/component changes are backward compatible: light
mode is the default resolved theme when the flag is off.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Undocumented 2019 hex values collapsed by the codemod | Wrong colors, lost status semantics | Hand-verify every codemod leftover against original usage |
| Theme resolves after CSS on first paint | White flash on dark load | Inline synchronous boot script in `<head>` |
| Third-party embeds can't be themed | Visual seam in dark mode | Themed wrapper frame; accept the iframe interior |

## Open questions
- Should `auto` follow OS preference changes mid-session (live `matchMedia`
  listener) or resolve once at boot? Gates step 3. Low-risk default is a live
  listener; flag if boot-only is preferred.
- Empty-state illustrations: commission dark variants or tint programmatically?
  Gates the scope of Phase 2 (steps 4–5), not the approach; not needed to
  start Phase 1.

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->

### Round 1 — 2026-07-15
- Readiness check: Phase 1 (steps 1–3) is implementation-ready — tokens,
  codemod, and ThemeProvider all have concrete paths and completion
  conditions. Phases 2–3 are specified enough to execute; the two open
  questions gate details, not the overall approach.
- Annotated both open questions with the step they gate (Q1 → step 3;
  Q2 → Phase 2 scope) and recorded the low-risk default for Q1. Left them open
  as decisions for the owner rather than deciding unilaterally.
