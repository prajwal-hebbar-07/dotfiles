# Platform notes

Use the section for the app being changed. Installed dependencies and the
repository's own components come first; a library below is only a
suggestion when nothing installed does the job, and adding one is a plan
decision the user approves.

## Web: Astro, React, Tailwind v4

- Tokens live in one place: Tailwind v4 `@theme` in the global CSS (or the
  existing CSS variables). Components use the generated utilities
  (`bg-surface`, `text-muted-foreground`), never arbitrary values like
  `bg-[#111]` or `p-[13px]` unless the design measures it and no token fits.
- Astro: static by default; hydrate a React island only when it needs
  interactivity, with the lightest directive that works (`client:visible`
  over `client:load`). Motion that CSS can do stays in CSS, without an
  island.
- Tailwind v4 `hover:` already applies only on hover-capable pointers.
- Use `motion-safe:` / `motion-reduce:` variants for reduced motion.
- Smooth scrolling libraries (Lenis) must not break anchor links, focus
  scrolling, or reduced motion; disable them under reduced motion.
- Buttons are `<button>`, links are `<a>`; never a clickable `<div>`.

## Mobile web (any web app used on a phone)

- `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover, interactive-widget=resizes-content">`;
  never `user-scalable=no`.
- `-webkit-tap-highlight-color: transparent` on `html`, with your own
  `:active` state; `touch-action: manipulation` on controls.
- Inputs 16px or larger, with `inputmode`, `type`, `autocomplete`,
  `autocapitalize="none"` for emails, `enterkeyhint`.
- `overscroll-behavior: none` on `html, body`, `contain` on inner scrollers;
  never `touchmove` + `preventDefault`.
- Safe areas: `env(safe-area-inset-*, 0px)`; a bottom sheet pads with
  `calc(1rem + env(safe-area-inset-bottom))`.
- `user-select: none` and `-webkit-touch-callout: none` on controls only,
  never on `body`.
- Carousels: `scroll-snap-type: x mandatory`, `touch-action: pan-y`.
- One `theme-color` per scheme plus `color-scheme: light dark`.

## Expo and React Native

- Spacing and sizes in the theme file; `StyleSheet` values reference it.
- Targets 44pt / 48dp via `hitSlop`; `Pressable` with
  `accessibilityRole`, `accessibilityLabel`, `accessibilityState`.
- Feedback on press-in, commit on press-out; `scale 0.97` over 100–150ms.
- Animation ladder: Reanimated CSS transitions for state changes → layout
  animations (`entering`, `exiting`) for mount and unmount → shared values
  plus Gesture Handler for gestures → Expo Router native stack options for
  screens, `presentation: 'formSheet'` for a sheet that is its own screen.
  Core `Animated` only when Reanimated is not installed and the change is a
  single fade.
- Never animate layout props, `elevation` or `BlurView` intensity;
  crossfade a static layer. Transform order matters: translate first.
- Thread rules: no `setState` in gesture or scroll handlers; call back to
  JS (`scheduleOnRN`) only in `onEnd`; never read shared values during
  render; use `.get()` / `.set()`.
- Tabs never slide. Screen transitions use the platform default (iOS push
  about 350ms); reduced motion makes them `'fade'`.
- Haptics (`expo-haptics`): selection for value ticks, light impact for a
  snap or drag commit, medium for destructive, notification success/error
  for outcomes. One per action, same frame as the visual, never the only
  feedback.
- Custom dialogs and sheets instead of the system alert when the design
  defines them.
- Text scales: never hardcode heights around text; measure with
  `onLayout`. Respect `useSafeAreaInsets`.
- Judge feel on a release build on a slow device, not Expo Go.

## Tauri desktop (React in a webview)

- It should feel like a desktop app, not a website: default cursor on
  buttons, no text selection on chrome (`user-select: none` on toolbars
  and sidebars, never on content), no page-level rubber-band
  (`overscroll-behavior: none`).
- Window dragging through `data-tauri-drag-region` on the title area.
- System font stack and the OS accent where the design allows.
- Every command has a keyboard shortcut, shown in menus and tooltips;
  keyboard-triggered actions are not animated.
- Dense layout: 28–32px rows and controls are normal on desktop.

## MUI (React)

- Colors, type and spacing come from the theme (`theme.palette`,
  `theme.typography`, `theme.spacing`); `sx` uses theme keys, never raw hex.
- Extend the theme for a new token; do not style one component locally.
- Durations from `theme.transitions.duration`, set to the motion tokens.

## SwiftUI (widgets, macOS and iOS)

- Text styles (`.body`, `.headline`) for Dynamic Type; SF Symbols for
  icons; semantic colors (`.primary`, `.secondary`, system backgrounds).
- Widgets set `containerBackground(for: .widget)` and keep content glanceable:
  one fact, one supporting line.
- Changing numbers: `.monospacedDigit()` and
  `.contentTransition(.numericText())`.
- Springs: `.spring(response: 0.4, dampingFraction: 1)` to move,
  `dampingFraction: 0.8` after a gesture with momentum.

## Library picks (React, only when nothing installed covers it)

| Task | Library |
| --- | --- |
| Accessible unstyled primitives (menu, dialog, popover) | base-ui |
| Command menu | cmdk |
| Toasts | sonner |
| OTP input | input-otp |
| Springs, layout, exit, gesture animation | motion |
| Animated numbers | @number-flow/react |
| Drag and drop | @dnd-kit |
| Long lists | react-virtuoso |
| Charts | recharts |
| Variant class names | clsx, class-variance-authority |

Mismatches worth flagging: a hand-rolled toast, a `<div>` dropdown with
manual focus handling, 1,000+ rows rendered directly, nested className
ternaries.
