---
plan: The Quest for Dark Mode
slug: dark-mode
kind: feature
created: 2026-07-13
horizon: 3 weeks
mood: heroic-quest
structure: phased
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

# The Quest for Dark Mode ⚔️🌙

Status: draft — 2026-07-13

## Goal
Ship user-togglable dark mode across settings-app: semantic tokens first, then
component adoption, behind a staged rollout flag. Retinas of the 2am users saved.

## Shape

```text
today                              target
component ── "#1a1a2e"             component ── var(--surface)
component ── "#ffffff"             component ── var(--text-primary)
   (214 hardcoded hex)                    │
                                   styles/tokens.css [new]
                                   themes/{light,dark}.css [new]
                                   resolved via <html data-theme=…>
```
[DIAGRAM PROMPT: before/after quest map on parchment — left village "Light Mode
Only": components wired straight to hardcoded hex strings; right castle "Dark
Mode Shipped": components read semantic CSS variables (--surface,
--text-primary, --accent) resolved through a data-theme attribute selecting
light.css or dark.css. Emphasize the new token layer as the bridge between the
two lands; mark "214 hardcoded hex" as a dragon on the left.]

```text
        ┌──────── auto (system pref) ────────┐
boot ──▶│  auto  ──toggle──▶ light ⇄ dark    │
        └── choice persisted localStorage:theme
```
[DIAGRAM PROMPT: three-state machine — states "auto", "light", "dark"; entry
arrow from "boot" into "auto"; user-toggle edges auto→light, light⇄dark; every
state writes to a small scroll labeled "localStorage:theme". Draw states as
wax seals; emphasize that "auto" follows the OS preference.]

## Plan

### Phase 1 — The Token Mines
- [x] 1. styles/tokens.css [new] — semantic tokens: surface, surface-raised, text-primary, text-muted, accent (effort: S)
- [x] 2. scripts/codemod-hex.ts [new] — rewrite hardcoded hex → var(); covers ~80%, rest by hand (effort: M)
- [~] 3. src/theme/ThemeProvider.tsx [new] — data-theme switch + localStorage persistence (effort: M) needs: 1
- 🎉 MILESTONE: app renders 100% from tokens, visually unchanged — that's the point

### Phase 2 — The Component Forest
- [ ] 4. src/layout/Nav.tsx, Sidebar.tsx, Footer.tsx — adopt tokens (effort: M) needs: 3
- [ ] 5. src/forms/* — per-theme focus/hover states; the goblins live here (effort: L) needs: 3
- [ ] 6. src/charts/palette.ts — dataviz palette that survives both themes (effort: L) needs: 3
- [!] 7. payment iframe — vendor ignores our theme; wrap in themed frame, accept the seam (effort: XL)

### Phase 3 — The QA Mountains
- [ ] 8. contrast audit — every text/surface pair passes WCAG AA (effort: M) needs: 4,5,6
- [ ] 9. e2e: no white flash on dark-mode load (effort: S) needs: 3
- [ ] 10. rollout flag 5% → 25% → 100% (effort: S) needs: 8,9
- 🎉 MILESTONE: Jules the QA ranger cannot find a contrast bug (budget a day; Jules always finds one)

## Edge cases & risks
⚠️ RISK: some of the 214 hex values date to 2019 and encode meaning nobody remembers — hand-verify the codemod's leftovers.
⚠️ RISK: white flash on first paint if theme resolves after CSS — inline the boot script in <head>.
⚠️ RISK: third-party embeds (map widget, payment iframe) can't be themed — themed wrapper frame is the ceiling.

## Open questions
- Follow system preference changes mid-session, or only re-read on load?
- Empty-state illustrations: commission dark variants or programmatic tint?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
