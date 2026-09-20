# The Terminal Window

**Covers:** the terminal window — its frame, colours, and behaviour

Think of Ghostty as the studio window your whole development environment sits behind. The
glass is chosen carefully: the right tint, the right opacity, the right frame — so the room
inside looks exactly the way it should without the outside world bleeding through, and
without any one colour shouting over the rest.

---

## A fully solid window

The window is intentionally opaque. No desktop shows through, no wallpaper bleeds in, no
half-visible background distracts from the text. Three settings work together to make that
happen:

1. The background is set to full opacity.
2. The macOS title bar is drawn in the theme colour, not the transparent system default.
3. An inactive split (a secondary pane that is not focused) stays at full strength instead
   of fading to grey.

The result is that every surface — active or inactive, chrome or content — reads as a
single solid room.

---

## The colours: Pale Knight

The colour palette is called **Pale Knight**. It sits in the same violet-indigo part of
the colour wheel as Material Palenight, but held down in intensity so that:

- The background is near-black (`#0f111a`), dark enough that body text reads at 8.4:1
  contrast — clear for long sessions, not eye-straining for one glance.
- The six accent colours (red, green, yellow, blue, violet, cyan) are all generated at
  exactly the same lightness. Equal lightness means equal attention — none grabs the eye
  before the others.
- The same six colours at a brighter level form the second set (used by some tools for bold
  or "bright" variants).

The palette has been benchmarked against Tokyo Night and Material Palenight. Palenight's
calm surface, Tokyo Night Storm's even accent weighting — pushed a step further down in
saturation.

The theme file lives at `ghostty/themes/pale-knight`. Ghostty discovers it automatically
because it sits next to the main config file.

---

## The font

**JetBrains Mono** is the primary typeface — the one every character is drawn in. Behind
it sits **Symbols Nerd Font Mono** as a fallback, which provides the small icons the
shell prompt and the file listing tool use for directories, git status markers, and
file-type badges.

- Size: 13 pt
- Line height: 12 % extra breathing room so box-drawing characters (used by tmux borders)
  still join at the edges
- Ligatures are **off**: `->`, `!=`, and `=>` stay as the three separate characters they
  are, not merged into a single glyph

---

## Reloading after a change

Edit `ghostty/config` or `ghostty/themes/pale-knight` in the repository, then press:

```
Cmd+Shift+,
```

That reloads the configuration and theme in every open window immediately.

Before reloading, you can check for typos:

```sh
ghostty +validate-config
```

---

## The one parser quirk to remember

Ghostty does not allow comments at the end of a setting line. This is wrong:

```
font-size = 13   # the size I like
```

The `# the size I like` becomes part of the value and the line fails silently. Comments
must go on their own line:

```
# the size I like
font-size = 13
```

---

## Scrollback and session behaviour

- The scrollback buffer holds 100 MB of output — enough for very long log tails in a bare
  shell. Inside tmux, tmux keeps its own 50 000-line history per pane; Ghostty's buffer
  only matters for shells running outside tmux.
- Selecting text copies it to the system clipboard automatically.
- Closing a window does not show a confirmation dialog, because tmux keeps the session alive
  regardless.

---

## What to edit vs. what to leave alone

| You want to… | Edit this |
| --- | --- |
| Change a colour | `ghostty/themes/pale-knight` — and update the matching entries in the shell and tmux configs |
| Change the font or size | `ghostty/config`, the Type section |
| Change padding or window feel | `ghostty/config`, the Window section |
| Change opacity or blur | `ghostty/config`, the Fully opaque section |

The theme and the config are separate files on purpose. The theme holds only colours;
everything else stays in the config.
