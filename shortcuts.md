# Keyboard Shortcuts

## WezTerm

These shortcuts come from WezTerm's defaults plus the current local setup.

| Shortcut | Action |
| --- | --- |
| `Option` + `Enter` | Toggle full screen |
| Drag the window edge | Resize the window |

WezTerm's tab bar is disabled in this config. Use tmux windows and panes for
terminal organization instead.

## tmux

The tmux prefix is:

```text
Ctrl-s
```

In the tables below, `prefix` means press `Ctrl-s` first, release it, then press
the next key.

### Prefix

| Shortcut | Action |
| --- | --- |
| `Ctrl-s` | tmux prefix |
| `prefix` then `Ctrl-s` | Send the prefix key to a nested tmux or remote session |

### Panes

| Shortcut | Action |
| --- | --- |
| `prefix` then `c` | Create a new tmux window, like a terminal tab, in the current directory |
| `prefix` then `r` or `,` | Rename the current tmux window/tab from an empty prompt |
| `prefix` then `x` | Close the current pane after confirmation |
| `prefix` then `m` | Maximize or restore the current pane |
| `prefix` then `h` | Move to the pane on the left |
| `prefix` then `j` | Move to the pane below |
| `prefix` then `k` | Move to the pane above |
| `prefix` then `l` | Move to the pane on the right |
| `Option` + `h` | Move to the pane on the left without pressing prefix |
| `Option` + `j` | Move to the pane below without pressing prefix |
| `Option` + `k` | Move to the pane above without pressing prefix |
| `Option` + `l` | Move to the pane on the right without pressing prefix |
| `prefix` then `H` | Resize pane left by 5 cells |
| `prefix` then `J` | Resize pane down by 5 cells |
| `prefix` then `K` | Resize pane up by 5 cells |
| `prefix` then `L` | Resize pane right by 5 cells |
| `prefix` then `\` | Split pane horizontally in the current directory |
| `prefix` then `-` | Split pane vertically in the current directory |

### Copy Mode And Clipboard

| Shortcut | Action |
| --- | --- |
| `prefix` then `[` | Enter copy mode |
| `v` | Begin selection in copy mode |
| `Ctrl-v` | Toggle rectangle selection in copy mode |
| `y` | Copy selection to the macOS clipboard and leave copy mode |
| `Enter` | Copy selection to the macOS clipboard and leave copy mode |
| Mouse drag selection | Copy selected text to the macOS clipboard |
| `prefix` then `]` | Paste the latest tmux buffer |

### Notes

After changing the tmux config from this repo, reload it with:

```sh
tmux source-file tmux/tmux.conf
```

If `Ctrl-s` freezes the terminal instead of opening the tmux prefix prompt,
software flow control is enabled in the shell. Add this to the shell startup
file:

```sh
stty -ixon
```
