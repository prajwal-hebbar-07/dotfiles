# The Command Deck

**Twin of:** [Zsh Shell Environment](../architecture/02-zsh.md)

Think of the terminal prompt as a ship's command deck. There is a heads-up display at the
top of the screen — branch name, dirty indicators, how long the last manoeuvre took — and
below it a console where you type. The console has a co-pilot that whispers the rest of
your command in grey before you finish typing it, and a searchlight that colours every word
as you write so a mistyped command turns amber before you ever press Enter.

---

## The heads-up display (the prompt)

The prompt occupies two lines:

```
◈ ~/personal/dotfiles  on main +1 ●2 ?3 ↑4          3.0s ✘ 2
❯
```

What each piece means:

| Mark | What it tells you |
| --- | --- |
| `on main` | The current branch; shows `⟨rebase-i⟩` during an operation |
| `+1` | One staged file ready to commit |
| `●2` | Two modified files not yet staged |
| `?3` | Three new files the repo has not seen |
| `↑4` | Four commits ahead of the remote |
| `3.0s` | The last command took this long (only shown past 2 seconds) |
| `✘ 2` | The last command failed with exit code 2 |
| `❯` | Soul-cyan on success; infection-amber on failure |

`user@host` is only shown when connected over SSH.

**The top line never wraps.** If the path and branch together would run past the edge of
the pane, the shell shows just the project directory instead of the full path; if even that
is too wide, the front of it is clipped to a `…`. A wrapped prompt costs an extra row to
repeat what the window title already told you, so it is not allowed to happen.

---

## The typing helpers

**The grey suggestion.** As you type, the shell guesses what you mean — first from past
commands, then from what completion would offer — and shows the rest of the line in grey.

| Key | What it does |
| --- | --- |
| `→` | Step one character into the suggestion |
| `C-e` | Accept the whole grey suggestion |
| `C-space` | Accept it and run it in one keystroke |

**Live colouring.** Every word is coloured while you type. A command that resolves turns
soul-cyan; one that does not (a typo, a missing tool) turns infection-amber. Strings are
amber-orange. A dangerous `rm -rf` gets branded on an amber background before Enter.

**History search.** `↑` walks history, but only entries that contain what you have already
typed. If you typed `git`, `↑` shows only past git commands.

---

## The fuzzy picker (Tab)

Pressing Tab opens a live fuzzy picker instead of a static list. You type letters to narrow
the candidates; the right side shows a preview of whatever is highlighted:

- A **directory** shows a file tree two levels deep.
- A **file** shows its contents with syntax highlighting.
- A **binary** shows a description and a hex preview.
- A **git file** in `git add` context shows the diff.
- A **process** in `kill` context shows CPU and memory.

| In the picker | What it does |
| --- | --- |
| `/` | Accept a directory and keep descending into it |
| `<` / `>` | Jump between match groups (files, directories, …) |
| `C-/` | Toggle the preview pane off and on |

---

## Navigation shortcuts

| Shortcut | Where it goes |
| --- | --- |
| `C-r` | Fuzzy history search; `C-y` copies the entry without running it |
| `C-t` | Insert a file path from under the current directory |
| `M-c` | Jump to a directory below here |
| `C-x C-e` | Open the current command in your editor |

---

## Listing files

`ls` is replaced with a tool that shows icons and sorts directories first. The colour of
each entry follows the Pale Knight palette — directories in soul-cyan, executables in
lifeblood-blue, archives in infection-amber — so the palette never contradicts the terminal
window's own colours.

| Alias | What you get |
| --- | --- |
| `ls` | Names and icons |
| `l` | Full listing, git status, relative timestamps |
| `ll` | Full listing, git status, precise timestamps |
| `la` | Like `ll` but includes dotfiles |
| `lt` / `lta` | Tree (2 levels) / tree (3 levels, dotfiles included) |
| `lS` / `lm` | Sorted by size / by modification time |

`cat` is replaced with a reader that adds line numbers, syntax highlighting, and marks
changed lines. `catp` strips all decoration. Both use the terminal's own 16-colour palette
so they cannot drift from Pale Knight.

---

## Navigating directories

| Alias or command | What it does |
| --- | --- |
| `z <fragment>` | Jump to the directory that name has meant most often |
| `zi` | Pick from the ranked directory list with the fuzzy picker |
| `..` / `...` | Go up one / two levels |
| `up 3` | Go up three levels |
| `mkcd <name>` | Make a directory and step into it |
| `-` | Go back to the previous directory |
| `d` | Show the last 10 directories you visited |
| `M-c` | Pick a directory below here with the fuzzy picker |

---

## Starting a workspace

| Command | What it does |
| --- | --- |
| `tn` | Start a session named after the current directory, rooted there |
| `tn work ~/code/thing` | Same, with a name and a directory you choose |
| `ta <name>` | Attach to an existing session |
| `tl` | List the sessions that are running |

`tn` attaches instead of complaining when a session of that name already exists, so it is
safe to type twice. Run from inside a session, it creates the new one in the background and
switches you to it — sessions cannot be nested inside each other.
---

## Node and nvm

The Node version manager (`nvm`) is available but does not slow down shell startup. The
newest installed version of Node is always on the path from the moment the shell opens.
Typing `nvm` for the first time loads the full manager and then runs your command — after
that it works like normal. If no version of Node is installed, Node is simply absent from
the path.

---

## Local overrides

Anything machine-specific or secret belongs in `~/.zshrc.local`. That file is sourced last
and is deliberately not tracked in this repository. Anything an installer appends to
`~/.zshrc` lands in the repository file — move it into `~/.zshrc.local` or into the right
section of the main config.
