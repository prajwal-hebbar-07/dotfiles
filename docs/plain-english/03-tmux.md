# The Workspace Grid

**Twin of:** [Tmux Terminal Multiplexer](../architecture/03-tmux.md)

Think of tmux as a large workbench that you can divide into bays. Each bay is a pane — a
separate work surface running its own task. The bays are grouped into named benches (windows),
and a set of benches belongs to one session. When you close the terminal window and come
back later, the session and all its bays are still running, exactly as you left them.

---

## The prefix key

Everything in tmux starts with a "call the manager" key: `C-s` (hold Control and press S).
That puts tmux into listening mode for one more key. You do not need to hold `C-s` down —
press it, let go, then press the action key.

If an application in a pane needs `C-s` itself, press the prefix *twice*: the second press
is forwarded as a literal `C-s`.

---

## Dividing the workbench

| Key sequence | What it does |
| --- | --- |
| `C-s \` or `C-s |` | Split the current bay left and right — the new bay on the right takes a quarter of the width |
| `C-s -` | Split the current bay top and bottom |
| `C-s m` | Zoom one bay to fill the whole bench (press again to restore) |
| `C-s h` / `j` / `k` / `l` | Move left / down / up / right between bays |
| `C-s x` | Close this bay, immediately, no confirmation |
| `C-s X` | Close this whole bench, immediately, no confirmation |

New splits inherit the directory you are currently in. New benches (`C-s c`) always open at
your home directory.

Benches are numbered from **1**, not 0. Closing a bench in the middle automatically closes
the gap, so `C-s 1` always reaches the first bench.

---

## Pull-down tool trays (popups)

Two commands open a full-screen overlay over the current workbench — a pop-up tray that
closes when you are done, returning you exactly where you were:

| Key | What opens |
| --- | --- |
| `C-s g` | lazygit — a visual git manager, opened on the current repository |
| `C-s t` | tuicr — a TUI task runner, opened in the current directory |

Both need the respective tool installed. If it is missing, the tray opens briefly and
closes with an error.

---

## Managing sessions and benches

| Key | Action |
| --- | --- |
| `C-s r` | Rename this bench (starts from an empty prompt — nothing to delete) |
| `C-s S` | Rename this session (same empty-prompt behaviour) |
| `C-s c` | Open a new bench at your home directory |

---

## The status strip

A strip of information runs along the bottom:

- **Left side:** a `◈` badge with the session name. It is soul-cyan at rest and turns
  infection-amber the moment you press the prefix key, so you always know when tmux is
  waiting for your next key.
- **Right side:** the directory name of the current bay, the clock, and the machine name.
- **Middle:** a list of benches. The active bench shows a `◆` diamond in soul-cyan. A
  zoomed pane adds a `⊡` mark. A bench with a bell turns amber.

The strip refreshes every 5 seconds.

---

## Reloading after a change

Edit `tmux/tmux.conf` in the repository, then reload without restarting:

```
C-s C-r
```

The status bar briefly confirms: "Pale Knight reforged".

---

## Scrolling and copy mode

Mouse mode is on — you can scroll, click to switch panes, and drag borders to resize. In
copy mode, `vi` key motions work: `j`/`k` to move, `/` to search, `v` to select, `y` to
yank. The selection colour is muted lifeblood-blue on void, readable without glare.

---

## The colour palette

All colours use the same 11-token Pale Knight palette as the shell and the terminal window:
- **Soul-cyan** — alive, focused, active
- **Infection-amber** — attention needed, prefix held, bells, warnings
- **Bone** — body text
- **Essence-violet** — quiet metadata (clock, directory)
- **Lifeblood-blue** — clock digits

The palette is embedded as `%hidden` variables — they resolve once when tmux starts and are
not visible in the option list.
