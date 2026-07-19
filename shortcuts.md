# Keyboard Shortcuts

## WezTerm

These shortcuts come from WezTerm's defaults plus the current local setup.

| Shortcut | Action |
| --- | --- |
| `Option` + `Enter` | Toggle full screen |
| Drag the window edge | Resize the window |

WezTerm's tab bar is disabled in this config. Use tmux windows and panes for
terminal organization instead.

## zsh

| Shortcut | Action |
| --- | --- |
| `Tab` | Complete commands, files, folders, options, and git branches |
| `Tab` then arrow keys | Move through the completion menu |
| `Up` / `Down` | Search history using the command prefix already typed |
| `Ctrl-p` / `Ctrl-n` | Search history using the command prefix already typed |
| `Right` | Accept the current inline autosuggestion |
| `Ctrl-r` | Open visual fuzzy search over command history |
| `Ctrl-y` | Copy the selected command from the `Ctrl-r` history picker |
| `Ctrl-t` | Open visual fuzzy search over files and insert the selected path |
| `Option` + `c` | Open visual fuzzy search over folders and jump to the selected folder |
| `ss` | Pick or create a tmux session with `sesh` and `gum` |
| `yy` | Open `yazi` in the current directory |
| `lt` | Show a three-level `eza` tree |
| `rgi` | Search text with `ripgrep`, including hidden files except `.git` |
| `rgf` | List files with `ripgrep`, including hidden files except `.git` |

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
| `prefix` then `c` | Create a new tmux window, like a terminal tab, in the session start directory |
| `prefix` then `r` or `,` | Rename the current tmux window/tab from an empty prompt |
| `prefix` then `x` | Close the current pane after confirmation |
| `prefix` then `m` | Maximize or restore the current pane |
| `prefix` then `g` | Open `lazygit` in a tmux popup |
| `prefix` then `G` | Open `hunk diff` in a tmux popup |
| `prefix` then `y` | Open `yazi` in a tmux popup |
| `prefix` then `t` | Show a three-level `tree` view in a tmux popup |
| `prefix` then `s` | Pick or create a session with `sesh` and `gum` |
| `prefix` then `h` | Move to the pane on the left |
| `prefix` then `j` | Move to the pane below |
| `prefix` then `k` | Move to the pane above |
| `prefix` then `l` | Move to the pane on the right |
| `prefix` then `H` | Resize pane left by 5 cells |
| `prefix` then `J` | Resize pane down by 5 cells |
| `prefix` then `K` | Resize pane up by 5 cells |
| `prefix` then `L` | Resize pane right by 5 cells |
| `prefix` then `\` | Split pane horizontally in the current directory |
| `prefix` then `-` | Split pane vertically in the current directory |

### Copy Mode And Clipboard

| Shortcut | Action |
| --- | --- |
| `prefix` then `v` or `[` | Enter copy mode, similar to Vim normal mode |
| `h` / `j` / `k` / `l` | Move around in copy mode |
| `v` | Begin character-wise selection in copy mode |
| `V` | Begin line-wise selection in copy mode |
| `Ctrl-v` | Toggle rectangle selection in copy mode |
| `y` | Copy selection to the macOS clipboard and leave copy mode |
| `Enter` | Copy selection to the macOS clipboard and leave copy mode |
| Mouse drag selection | Copy selected text to the macOS clipboard |
| `prefix` then `]` | Paste the latest tmux buffer |

### Notes

After changing the tmux config from this repo, reload it with:

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

If `Ctrl-s` freezes the terminal instead of opening the tmux prefix prompt,
software flow control is enabled in the shell. Add this to the shell startup
file:

```sh
stty -ixon
```
