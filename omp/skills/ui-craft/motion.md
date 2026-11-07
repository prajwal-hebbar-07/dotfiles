# Motion rules

Adapted from Emil Kowalski's skills (emil-design-eng, animate,
animate-expo, review-animations, animation-performance, choreograph). Run
the gate before anything else; deleting an animation is a valid outcome.

## 1. Gate

| How often the person sees it | Decision |
| --- | --- |
| 100+ times a day, or triggered from the keyboard (command palette, shortcuts, tab switches) | No animation |
| Tens of times a day (hover, list navigation, toggles) | Under 150ms, opacity or color only, or nothing |
| Occasional (modal, drawer, toast, sheet) | Standard animation |
| Rare or first time (onboarding, success, empty state) | May delight |

Then name the purpose: spatial consistency, state change, explanation,
feedback, or preventing a jarring jump. "Looks nice" is not a purpose.
Text the person is reading never moves.

## 2. Tokens

```css
--ease-out:    cubic-bezier(0.23, 1, 0.32, 1);   /* enter, exit, default */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);  /* movement on screen */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);   /* sheets and drawers */
```

- Entering or exiting → ease-out. Moving or morphing on screen →
  ease-in-out. Hover or color → `ease`. Constant progress → linear.
- Never `ease-in` on UI; it feels slow. Never invent a curve.

| Element | Duration |
| --- | --- |
| Press feedback | 100–160ms (native 100–150ms) |
| Tooltip, small popover | 125–200ms |
| Dropdown, select, toggle | 150–250ms |
| Modal, drawer, sheet | 200–500ms |
| Marketing reveal | up to 600ms, fires once |

Product UI stays under 300ms. Exit is faster than enter (about 60–80% of
it). Stagger 30–80ms per item, under 300ms in total, never blocking input;
exits are simultaneous, never reverse-staggered.

## 3. Physical correctness

- Never start from `scale(0)`: start at `scale(0.95)` plus `opacity: 0`.
- Press: `scale(0.97)` (range 0.95–0.98), 160ms ease-out on `:active` or
  press-in.
- Popovers, dropdowns and tooltips grow from their trigger
  (`transform-origin` at the anchor; Base UI exposes
  `var(--transform-origin)`). Modals stay centered.
- Things leave the way they came; a drawer from the bottom exits downward.
- Forward navigation moves left or up; back moves right or down.
- A pure fade entrance with no transform reads as a glitch; add a small
  translate (8px) or scale (0.95).
- One or two animated elements per view; everything else stays still.

## 4. Interruption

- State-driven UI uses CSS transitions (they retarget mid-flight), not
  keyframes (they restart).
- Gesture-driven motion uses springs and starts from the current on-screen
  value, inheriting the finger's velocity. Never lock input during an
  animation.
- Set the final state explicitly; correctness never depends on
  `animationend`.

## 5. Springs and gestures

| Interaction | Web (Motion) | React Native (Reanimated) |
| --- | --- | --- |
| Default settle | `{ type: "spring", duration: 0.5, bounce: 0.2 }`, or `bounce: 0` for plain moves | `{ duration: 400, dampingRatio: 1 }` |
| Snap back after drag | `{ duration: 0.4, bounce: 0.2 }` | `{ duration: 400, dampingRatio: 0.8, velocity }` |
| Sheet, drawer | `--ease-drawer` 500ms, or spring `{ duration: 0.3, bounce: 0.2 }` | `{ duration: 300, dampingRatio: 0.8, velocity }` |

- Bounce 0.1–0.3 and only after a gesture carried momentum.
- Dismiss when velocity (`|distance| / ms`) exceeds about 0.11 or distance
  passes the threshold (about 40% of the sheet height).
- Past a boundary, rubber-band: `(o * dim * 0.55) / (dim + 0.55 * |o|)`.
- Momentum projection: `((v / 1000) * 0.998) / (1 - 0.998)`; snap to the
  nearest target to the projected point.
- About 10px of movement before a drag starts. Highlight on touch-down,
  commit on touch-up, cancel by dragging away.

## 6. Recipes (web)

| Recipe | Values |
| --- | --- |
| Button press | `transform 160ms var(--ease-out)`, `:active { scale: 0.97 }` |
| Popover, dropdown | opacity + transform 200ms ease-out from `scale(0.95)`, origin at trigger |
| Tooltip | 125ms from `scale(0.97)`; later tooltips in a group open instantly |
| Modal | 250ms ease-out from `scale(0.96)`, backdrop opacity 250ms |
| Drawer | `translateY(100%)` → 0, 500ms `--ease-drawer` |
| Toast | `transform 400ms ease`, enter via `@starting-style { translateY(100%) }` |
| Accordion | height (measured, never `auto`) + opacity 200ms ease-out |
| List entrance | `translateY(8px)` + fade, 300ms ease-out, 50ms steps |
| Hold to confirm | `clip-path` fill 2s linear; release snaps back 200ms ease-out |
| Tab indicator | `clip-path` 250ms `--ease-in-out` |
| Crossfade that will not settle | add `filter: blur(2px)` for 200ms |

Tool ladder, cheapest first: CSS transition → `@starting-style` → CSS
animation → WAAPI → Motion (springs, layout, exit, gestures only). A
request that is really a component (toast, drawer, menu) uses a library;
see `platforms.md`.

## 7. Performance

- Animate `transform` and `opacity`; `clip-path` and `filter` are
  acceptable. `height` only for accordions. Never `transition: all`.
- Swaps: width/height → `scale`, top/left/margin → `translate`,
  display/visibility → `opacity`, `box-shadow` → `filter: drop-shadow()`.
- Animated blur stays under 20px (2–5px is usually enough).
- Per-frame values go to `ref.current.style` or a motion value, never
  React state. An inherited CSS variable driving many children causes a
  style-recalc storm; set `style.transform` on the element.
- Motion `x`/`y` shorthands are hardware-accelerated only from motion
  14.2; `layout`, `layoutId`, `onUpdate` and `useTransform` run on the
  main thread.
- `will-change` only on the animating element, only after seeing a 1px
  shift or measured dropped frames.

## 8. Accessibility

- `prefers-reduced-motion`: fewer and gentler, not none. Keep opacity and
  color, drop translate, scale and parallax; screen transitions become a
  fade. React: `useReducedMotion()`; Reanimated: `ReduceMotion.System`.
- Hover motion only under `@media (hover: hover) and (pointer: fine)`.
- No auto-playing loop without a pause; no loop near 0.2Hz; no sudden
  full-screen brightness flips.

## 9. Feel check (for the person running the app)

Play at 2–5× slower (DevTools animation panel at 10–25%), step frame by
frame, toggle reduced motion, try on a real phone, and look again the next
day. These are instructions to hand the user, not steps to run yourself.
