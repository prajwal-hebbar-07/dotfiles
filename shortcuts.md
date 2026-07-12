# Keyboard Shortcuts

## WezTerm

These shortcuts come from WezTerm's defaults plus the current local setup.

| Shortcut | Action |
| --- | --- |
| `Option` + `Enter` | Toggle full screen |
| Drag the window edge | Resize the window |

WezTerm's tab bar is disabled in this config. Use tmux windows and panes for
terminal organization instead.

## Neovim

The Neovim leader key is:

```text
Space
```

| Shortcut | Action |
| --- | --- |
| `Space` then `?` | Show buffer-local keymaps |
| `-` | Open parent directory with Oil |
| `Space` then `-` | Open Oil in a floating window |
| `Space` then `e` | Toggle the Neo-tree project sidebar |
| `Space` then `f` | Find files |
| `Space` then `fg` | Find Git files |
| `Space` then `fs` | Search text in the project |
| `Space` then `fr` | Find recent files |
| `Space` then `fb` | Find open buffers |
| `Space` then `fk` | Search keymaps |
| `Space` then `fw` | Search for the word under the cursor |
| `Space` then `ft` | Find todo comments |
| `Space` then `vh` | Search help tags |
| `Space` then `sr` | Search and replace across the project or visual range |
| `Space` then `sw` | Replace the word under the cursor in the current file |
| `Space` then `o` | Toggle the code outline |
| `]s` / `[s` | Move to next or previous code symbol |
| `]b` / `[b` | Move to next or previous buffer |
| `Space` then `bd` | Delete the current buffer |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gR` | Go to references |
| `K` | Show hover documentation |
| `Space` then `rn` | Rename symbol |
| `Space` then `ca` | Show code actions |
| `Space` then `D` | Show buffer diagnostics |
| `Space` then `ld` | Show diagnostic details for the current line |
| `Space` then `ls` | Search document symbols |
| `Space` then `lS` | Search workspace symbols |
| `Space` then `lh` | Toggle LSP inlay hints when supported |
| `Space` then `mp` | Format the current file or visual selection |
| `Space` then `mt` | Toggle format-on-save for the current buffer |
| `Space` then `ll` | Run linting |
| `Space` then `rr` | Select and run a project task or test |
| `Space` then `rt` | Toggle the background task list |
| `Space` then `ra` | Select an action for a running or completed task |
| `Space` then `qs` | Restore the session for the current project |
| `Space` then `qS` | Select a saved session |
| `Space` then `ql` | Restore the most recent session |
| `Space` then `gg` | Open Fugitive Git status |
| `]h` / `[h` | Move to next or previous Git hunk |
| `Space` then `gs` | Stage Git hunk |
| `Space` then `gr` | Reset Git hunk |
| `Space` then `u` | Toggle undo tree |
| `Space` then `pv` | In a markdown file, toggle a live browser preview that re-renders as you edit |
| `Space` then `pc` | In a plan markdown file, insert an `@me` comment for Claude below the cursor |
| `Space` then `pr` | In a plan-review split, send the plan and its `@me` comments back to Claude |
| `F5` | Start or continue debugging |
| `F9` | Toggle a breakpoint |
| `F10` / `F11` / `F12` | Step over, into, or out while debugging |
| `Space` then `bu` | Toggle the debugger inspector UI |
| `Space` then `be` | Evaluate the expression under the cursor or selection |
| `Space` then `bt` | Debug the Python test under the cursor |
| `Space` then `bT` | Debug the current Python test class |
| `Space` then `br` | Toggle the debugger REPL |
| `Space` then `bx` | Stop debugging |
| `Esc` twice | Leave terminal input mode |

### Plan review loop

Instead of plan mode, ask Claude Code to `/plan <task>` (any permission mode).
It researches the codebase, writes the plan to `plans/plan-<slug>.md`, and
opens it in a right-hand tmux split running Neovim. Press `Space` then `pv` to
open the plan in a browser tab that re-renders as you edit — flip to it to read
the rendered plan, then back to Neovim to keep editing. Annotate inline with
`@me` HTML comments (`Space` then `pc` inserts one), save, then press `Space` then
`pr` to send your notes back — this runs `/plan-review <file>` in the Claude
pane. Claude resolves each comment, strips the markers, logs the round in the
plan's Review changelog, and rewrites the file in place; the split reloads
automatically. When a round comes back with no comments, Claude marks the plan
`ready to implement`. Close the split with `:q` and tell Claude to implement
it. Outside tmux the same loop works manually: edit the file in any editor and
run `/plan-review plans/plan-<slug>.md` yourself.

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
| `prefix` then `y` | Open `yazi` in a tmux popup |
| `prefix` then `t` | Show a three-level `tree` view in a tmux popup |
| `prefix` then `s` | Pick or create a session with `sesh` and `gum` |
| `prefix` then `h` | Move to the pane on the left |
| `prefix` then `j` | Move to the pane below |
| `prefix` then `k` | Move to the pane above |
| `prefix` then `l` | Move to the pane on the right |
| `Ctrl` + `h` | Move to the pane on the left without pressing prefix |
| `Ctrl` + `j` | Move to the pane below without pressing prefix |
| `Ctrl` + `k` | Move to the pane above without pressing prefix |
| `Ctrl` + `l` | Move to the pane on the right without pressing prefix |
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
