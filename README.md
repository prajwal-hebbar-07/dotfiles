# dotfiles

Personal configuration for my daily development setup.

> Status: the shell (`zsh/`), terminal multiplexer (`tmux/`), and terminal
> (`ghostty/`) configurations are committed and live on
> this machine. The remaining tools listed below are still to land; this README
> records them so the layout is known in advance.

## What I use

Six tools make up my environment:

| Tool | Role |
| --- | --- |
| [Brave](https://brave.com) | Browser |
| [Ghostty](https://ghostty.org) | Terminal emulator |
| [Cursor](https://cursor.com) | Code editor |
| Gemini (Antigravity) | AI coding assistant / CLI |
| [zsh](https://www.zsh.org) | Shell (macOS default) |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer |

### Brave

Chromium-based browser with tracker and ad blocking built in. Used as the
default browser for both general browsing and web development, since it keeps
Chrome-compatible DevTools and extension support.

### Ghostty

GPU-accelerated terminal emulator, and the terminal every shell workflow in this
repo assumes. `ghostty/config` carries the settings and `ghostty/themes/pale-knight`
the colours — the same Pale Knight palette as tmux and zsh, so all three layers
agree on what soul-cyan and infection-amber mean.

The palette is built to be **low-contrast on purpose**. Every accent is generated
in OKLCH at one fixed lightness, so hue is the only thing that changes between
them: ANSI 1-6 all land at 6.4-6.7:1 against the background and ANSI 9-14 at
8.5-8.9:1. Equal lightness means equal attention — six colours you can tell
apart, none of which grabs the eye first. Chroma sits at 0.055-0.070, roughly
half of Tokyo Night. The background is lifted off near-black to L = 0.244 so
bright glyphs stop haloing, and body text reads at 7.6:1 rather than 12.7:1:
comfortable for a long session instead of maximally legible for one glance.
Benchmarked against Tokyo Night and Material Palenight — Palenight's calm
surface, Tokyo Night Storm's even accent weighting, both pushed further down.

The window is deliberately **opaque**. `background-opacity = 1` and
`background-blur = false` are already Ghostty's defaults; what actually leaked the
desktop through was `macos-titlebar-style`, which defaults to `transparent`. This
config pins it to `tabs`, blanks `background-image`, and sets
`unfocused-split-opacity = 1` so an inactive split reads solid instead of faded.
Nothing behind the window shows through.

Two Ghostty parser details worth remembering when editing that file:

- **No trailing comments.** `key = value  # note` makes the comment part of the
  value and the line fails to parse. Comments get their own line.
- **Custom themes** are read from the `themes` subdirectory of the config
  directory, so `theme = pale-knight` resolves to
  `~/.config/ghostty/themes/pale-knight`. Check a theme is visible with
  `ghostty +list-themes`, and check a config with `ghostty +validate-config`.

### Cursor

Editor for hands-on code work: an AI-native fork of VS Code, so VS Code
keybindings, settings, and extensions carry over.

**Skills** — Cursor discovers user-level skills from `~/.cursor/skills/` (and
`~/.agents/skills/`, plus the Claude and Codex directories for compatibility),
so `paper-target`, `implement-commit-prompt`, `implementation-plan`,
`review-implementation-plan`, `follow-implementation-plan`, `report-arc`,
`repo-docs`, and `twitter-campaign` are linked there from `skills/`.
`~/.cursor/skills-cursor/` is Cursor's own directory for its built-in skills,
kept in sync from a `.sync-manifest.json`; nothing of mine goes in it. `commit`
is linked in too — it is plain `git` over the staged index, so it behaves the
same in every host. The review
skill is linked here for completeness; the intended use is to copy that
`SKILL.md` plus the plan into another agent.

**Paper MCP** — comes from the `paper-desktop` plugin here rather than a hand
written server: Cursor expands `${userHome}` in plugin manifests, so the
manifest spawns correctly, and its tool schemas are cached
per project under `~/.cursor/projects/<slug>/mcps/`.

### Gemini (Antigravity)

Google's AI coding assistant environment (`agy`).

**Skills** — Antigravity discovers global skills from `~/.gemini/config/skills/`
(as well as workspace skills under `.agents/skills/`). The shared documentation,
commit, and implementation skills — `commit`, `docs-twins`, `docs-verify`,
`follow-implementation-plan`, and `repo-docs` — are linked into
`~/.gemini/config/skills/` from `skills/`.

### zsh

Default macOS login shell, themed **Pale Knight** in the same palette as tmux.
`zsh/zshrc` is the single source of truth — `~/.zshrc` is a symlink to it, so
edits in this repository take effect in every new shell with no copy step, and
anything an installer appends lands in the repo file where it can be reviewed.
Machine-specific or secret values go in `~/.zshrc.local`, which is sourced last
and is deliberately not tracked here.

Startup is ~80 ms: the completion dump is rebuilt at most once a day and cached
under `~/.cache/zsh`, and the prompt asks git for its state once per draw
rather than the three times `vcs_info` would.

**The prompt.** Two lines, so a long path never crowds what is being typed:

```
❖ ~/personal/opensource/dotfiles on main ✚1 ●2 ?3 ⇡4          3.0s ✘ 2
❯
```

| Mark | Meaning |
| --- | --- |
| `on main` | Current branch; `⟨rebase-i⟩` appears during an operation |
| `✚n` `●n` | Staged / unstaged files |
| `?n` `✖n` | Untracked files / merge conflicts |
| `⇡n` `⇣n` | Commits ahead of / behind upstream |
| `⚙n` | Background jobs in this shell |
| `3.0s` | How long the last command took, shown past two seconds |
| `✘ 2` | Exit status of the last command, when it failed |

The `❯` is soul-cyan after a success and infection-amber after a failure.
`user@host` is prefixed only over SSH.

**Typing.** Three plugins do the work, and load order in `zshrc` matters —
syntax highlighting must come after the widgets it wraps, and substring search
after that:

- **zsh-syntax-highlighting** colours the line as it is typed. A command that
  resolves turns soul-cyan; one that does not turns infection-amber, so a typo
  shows before Enter. A recursive `rm -rf` is branded on an amber background.
- **zsh-autosuggestions** greys in the rest of the line, guessed from history
  first and from completion second.
- **zsh-history-substring-search** makes `↑` walk only the history entries
  containing what has already been typed.

| Key | Action |
| --- | --- |
| `→` | Step into the grey suggestion |
| `C-e` | Accept all of it |
| `C-space` | Accept it **and run it** |
| `↑` `↓` | History filtered by the fragment already typed |
| `Tab` | fzf picker over the completion candidates |
| `/` (in picker) | Accept a directory and keep descending |
| `<` `>` (in picker) | Move between match groups |
| `C-/` (in picker) | Toggle the preview pane |
| `C-r` | Fuzzy history search; `C-y` copies without running |
| `C-t` | Insert a file path, with preview |
| `M-c` | Jump to a directory below here |
| `C-x C-e` | Open the current line in `$EDITOR` |

**Completion** is case- and dash-insensitive, then substring, then anywhere —
the cheapest match that works wins. `fzf-tab` replaces the menu with an fzf
picker whose preview pane is `zsh/bin/pk-preview`: a tree for directories,
syntax-highlighted text for files, a hexdump for binaries, `git diff` for
`git add`/`git restore` candidates, and `ps` for `kill`. It is a script on
`PATH` rather than a shell function because fzf runs previews in a fresh shell
that never reads `~/.zshrc`.

**`ls`.** [eza](https://github.com/eza-community/eza) with icons, directories
first, and file colours from the same palette:

| Alias | Listing |
| --- | --- |
| `ls` | Names and icons, in columns |
| `l` | Long, with git status and relative times |
| `ll` | Long, with git status and ISO timestamps |
| `la` | `ll` plus dotfiles |
| `lt` / `lta` | Tree, two levels / three levels including hidden |
| `lS` / `lm` | Sorted by size / by modification time, largest and newest first |

`cat` is [bat](https://github.com/sharkdp/bat), which also renders `man` pages;
`catp` skips the line numbers and header. `BAT_THEME=ansi` makes it highlight
through the terminal's own 16 colours rather than shipping a second, louder
palette, so it can never drift from Pale Knight. `z` is
[zoxide](https://github.com/ajeetdsouza/zoxide) — `z dotfiles` from anywhere
reaches the directory that name has meant most often, and `zi` picks from the
ranked list. `ff` fuzzy-finds a file and opens it. `mkcd` makes a directory and
steps into it; `up 3` climbs three levels.

**Node** comes from [nvm](https://github.com/nvm-sh/nvm), installed under
`~/.nvm` (not in this repository). Sourcing `nvm.sh` costs ~0.85s per shell, so
`zshrc` does not: it puts the newest installed version's `bin` directly on
PATH — `node`, `npm`, and `npx` are there in every shell — and defines an `nvm`
function that sources `nvm.sh` on first call, replaces itself, and forwards the
arguments. Startup stays at ~0.09s; `nvm install`, `nvm use`, and `nvm ls` all
work, and a `nvm use X` inside a shell overrides the PATH entry for that shell.

### tmux

Terminal multiplexer, themed **Pale Knight** — a Hollow Knight palette: dusk-blue
chrome, bone text, soul-cyan for the focused window and pane, and
infection-amber for prompts, bells, and the session badge while the prefix is
held.

The prefix is `C-s`. Windows and panes are numbered from 1 and renumbered on
close, so `prefix 1` always reaches the first window.

| Key | Action |
| --- | --- |
| `prefix` `\` or `\|` | Split left / right, in half |
| `prefix` `-` | Split top / bottom |
| `prefix` `r` | Rename this window, from an empty prompt |
| `prefix` `S` | Rename this session, from an empty prompt |
| `prefix` `x` | Close this pane, no confirmation |
| `prefix` `X` | Close this window, no confirmation |
| `prefix` `c` | New window in the current pane's directory |
| `prefix` `g` | lazygit in a popup, on the current pane's repository |
| `prefix` `v` | fzf over the Markdown files below the current pane's directory; Enter renders the pick in the browser |
| `prefix` `y` | yazi in a popup, on the current pane's directory; `o` on a Markdown file renders it in the browser |
| `prefix` `C-s` | Send a literal `C-s` to the pane |
| `prefix` `C-r` | Reload the config in place |

Splits, new windows, and the popups all inherit the current pane's
directory. Renaming starts from an empty prompt, so the new name is typed from
scratch with nothing to delete first. Mouse mode is on — drop the
`set -g mouse on` line to disable it.

`prefix g` needs [lazygit](https://github.com/jesseduffield/lazygit) on `PATH`
(`brew install lazygit`). `prefix v` needs `fd` and `fzf`, and
`zsh/bin/pk-mdopen` linked into `~/.local/bin`: it writes an HTML page under
`$TMPDIR/pk-mdopen/` that renders the file client-side with
[marked](https://github.com/markedjs/marked) and github-markdown-css (both
from jsdelivr), so the Markdown itself never leaves the machine, then opens it
in the default browser. Relative images and links resolve against the file's
own directory.

`prefix y` needs [yazi](https://github.com/sxyazi/yazi) (`brew install yazi`)
and `yazi/yazi.toml` linked into `~/.config/yazi/`. That config sends `.md`
and `.markdown` files to `pk-mdopen` on `o` / Enter, with the editor offered
under `O`; every other file type keeps yazi's default opener. The popup stays
open after a render, so several files can be opened in a row; `q` closes it.

## Skills

`skills/` holds plain Agent Skills packages — Markdown instructions, nothing
host-specific — linked into Cursor (`~/.cursor/skills/`) and Gemini
(`~/.gemini/config/skills/`). None of them are linked into Claude Code.

Claude Code has its own set, started from scratch on 2026-10-26:
`claude/skills/<name>/SKILL.md`. `claude/link-skills` links each one into
both accounts — `~/.claude/skills/` (`cc`) and `~/.claude-work/skills/`
(`ccw`) — and prunes links to skills that were removed. Rerun it after adding
or removing a skill. Each account's `skills/synced/` (skills synced from
claude.ai) is left alone.

Codex has counterparts under `codex/skills/`, adapted from the Claude Code
set: `commit`, `design`, `grill-design`, `review-requirements`,
`review-stack`, `review-architecture`, `review-design`, `review-code`. Requirements, stack
and architecture authoring and grilling stay in Claude Code; Codex can
review their output files.
Run `codex/link-skills` to link them into `~/.agents/skills/` for use across
repos. It can be rerun, prunes its own broken links, and refuses to overwrite
another skill. The approval gates, templates and logged progress are the
same, so either host can resume from an app's `docs/` files. Keep the two
sets in step when changing a workflow.

Use `$commit` (`plan` to preview a split, `now` to skip its confirmation),
`$design`, and `$grill-design` in Codex. `$design brief <text>`,
`$design build`, and `$design approve` work
the same way as their Claude counterparts; drawing needs a connected Paper
MCP. Explicit-only invocation is preserved through `agents/openai.yaml`;
`commit` remains available for automatic selection. If the skills do not
appear, restart Codex. See the [official skill documentation](https://learn.chatgpt.com/docs/build-skills).

Use `$review-requirements`, `$review-stack`, `$review-architecture`, or
`$review-design` in an app repo for an independent review. They write ranked
findings, a verdict and a paste-ready fix list to `docs/review/`, leaving the
stage documents unchanged. Run the reviewer again after fixes to track what
was resolved. Each accepts `status` or focus text; `$review-design no-paper`
reviews only the document. Fix commands for requirements, stack and
architecture are labeled for pasting into Claude Code; design fixes use
`$design` in Codex. The Codex reviewers have no advisor step.

Use `$review-code` (or `/review-code` in Claude Code) on an issue branch that
`/implement` has built, to get a second model's view before raising the PR. It
writes ranked findings to `docs/review/code/<key>-review.md`, shared between
the two hosts, runs the issue's own tests, and changes no code. `/implement`
(Claude Code only) builds the issues in plan order, one branch each, stops
after each without pushing or opening a PR, and fixes review findings when
run again.

- **`commit`** (`/commit`) — stops if `user.name` or `user.email` is not set.
  Commits what is staged; when nothing is, it stages everything first. One
  commit by default; several focused commits only where the changes separate
  cleanly (`/commit plan` previews, `/commit now` skips the confirmation).
  Each message is a semantic `type(scope): summary` with two or more bullets,
  and never carries a `Co-Authored-By:` or any other attribution trailer.
  Replaces the former `split-commit`.

**`pdocs` skill** (`/pdocs`) — the `docs` skill under another name for Claude
Code, whose account-synced skills already include a `docs`. Only `SKILL.md` is
its own; every other file is a relative link into `skills/docs/`.

**`commit` skill** (`/commit`) — turns staged changes into one semantic
commit. It checks that `user.name` and `user.email` are set, refuses to run with
an empty index, writes a `type(scope): summary` subject followed by pointer
bullets, and adds no `Co-Authored-By:` or "Generated with" trailer, so git
history carries no tool attribution. It never runs `git add` — staging stays
my decision.

**`implementation-plan` skill** (`/implementation-plan`) — after an
architecture conversation is done, writes numbered files under
`docs/implementation-plan/` (gitignored): at most five commits each. Each
step is an outcome plus a prompt; how to build it is left to the
implementing agent. The file itself is the protocol — implement one step
exactly, stop for that commit, then the next in that file. When the file
is done it is deleted and the next file starts on its own. Nothing in it
is host-specific.

**`review-implementation-plan` skill** (`/review-implementation-plan`) — a
second agent (often a stronger implementer, and often a different host) reads
one plan file and updates it before anyone codes: split or merge steps,
reorder, strip how-to, add missing outcomes, re-chunk if a file grows past
five commits. It does not implement, and it does not replace the planner's
how with its own. Pass one plan file plus this `SKILL.md`; review the next
file in a new window. It is a plain Agent Skill, not a Cursor feature.

**`follow-implementation-plan` skill** (`/follow-implementation-plan`) —
executes the plan from one invoke: the next unfinished step, exactly as
written, `git add` only that step's files, then `/commit` with the
plan's subject. It does not `git commit` itself. An empty index is not the
end of the plan — add the files and commit. After the SHA lands, it takes
the next step in that file. When the file is done, it deletes it and starts
the next remaining file in a new agent with empty history — never this
same agent. On Cursor that is a Task/subagent. After every step it emits a
**report-arc** report.

**`report-arc` skill** (`/report-arc`) — the step-report shape (status,
Done when table, changed, leftover unstaged, verification, next) and a
second mode that turns any such report — pasted, a file, or this chat —
into a page under `docs/reports/`. It does not implement. Pass the report
plus this `SKILL.md` to any agent.

**`repo-docs` skill** (`/repo-docs`) — the same paired docs as
`docs-twins` (architecture + plain-English, same number, stored baseline,
one writer per pair, never commit), for **any** tree: a dotfiles repo, Python,
Go, Rust, a single crate. The path → pair table lives in that repo's
`docs/README.md`, not in the skill, so `docs-twins` can stay hardcoded for
the monorepos it already serves. Incremental by default; `full` or named
numbers for a sweep.

**`docs-twins` skill** (`/docs-twins`) — generates or refreshes twin
documentation (technical doc in `docs/architecture/` and plain-English twin in
`docs/plain-english/`) for monorepos, diff-driven from a stored baseline SHA
in `docs/README.md`.

**`docs-verify` skill** (`/docs-verify`) — audits documentation claims
against the code in the reverse direction of `docs-twins`. Finds dead paths,
dead symbols, renamed modules, and stale counts, running `check-claims.py`
mechanically and delegating prose checking.

**`implement-commit-prompt` skill** (`/implement-commit-prompt`) —
extracts **one** step from that plan into a copy-pastable prompt for a fresh
chat. If the step already has a Prompt block, that is what gets copied rather
than a rewrite. Use this when you want a new session per commit; following
the whole sequence from one invoke is `follow-implementation-plan`. These live in
`skills/` and are linked into Cursor, same as `paper-target`.

**`twitter-campaign` skill** (`/twitter-campaign`) — walks a project
directory and writes `docs/twitter-campaign.md`: a coordinated developer
launch campaign for Twitter/X and Reddit, from architecture, release notes,
and commit history. Copy is first-person and honest about trade-offs. Tweets
are ≤ 280 characters; Reddit posts are long-form for named subreddits and
reuse the Twitter screenshots/recordings 1:1. A
`twitter-campaign-baseline:` sha in that file is the commit the plan was
last read against; a later run diffs from there and appends, it does not
start over. `full` rewrites. It does not post, and it does not invent
features that are not in the tree. Linked into Cursor, same as
`paper-target`.

**`paper-target` skill** (`/paper-target`) — pins which Paper file and
page a repository's design work reads from. It resolves them through the Paper
MCP (`list_files`, `open_file`, `get_basic_info` — never a guessed id) and writes
the result into that repo's `AGENTS.md` / `CLAUDE.md` between
`<!-- paper-target:start -->` markers, so the target is already in context at the
start of every later session instead of depending on whatever file Paper has
focused. `show` reports the block against a live `get_basic_info` and says
whether they agree; `clear` removes the block and nothing else. The write is
idempotent, touches only the marked region, and Paper stays read-only throughout.

Page ids are the awkward part: the MCP cannot enumerate pages, so when only a
page name is known the skill records `pageId: UNKNOWN` and leaves the consuming
skill to confirm the page by name — it never pins a page it did not see.

It is a plain Agent Skills package that reads the Paper MCP and writes Markdown,
linked into `~/.cursor/skills/paper-target`.

## Intended layout

As configuration is added, it should land under one directory per tool:

```
dotfiles/
├── brave/      # browser preferences, extension notes
├── ghostty/    # terminal config
│   ├── config
│   └── themes/pale-knight
├── claude/     # Claude Code, both accounts (cc, ccw)
│   ├── link-skills                 # links claude/skills/* into both
│   └── skills/<name>/SKILL.md
├── skills/     # Agent Skills, linked into Cursor and Gemini
│   ├── commit/SKILL.md
│   ├── docs/SKILL.md
│   ├── implementation-plan/SKILL.md
│   ├── review-implementation-plan/SKILL.md
│   ├── follow-implementation-plan/SKILL.md
│   ├── follow-plan-with-review/SKILL.md
│   ├── arc-design/SKILL.md
│   ├── paper-target/SKILL.md
│   ├── paper-design-prompt/SKILL.md
│   ├── paper-design/SKILL.md
│   ├── sync-lyik-docs/SKILL.md
│   └── pdocs/SKILL.md
├── cursor/     # editor settings, keybindings, extension list
├── zsh/        # zshrc, and bin/pk-preview for the fzf preview pane
├── tmux/       # tmux.conf, Pale Knight theme and keys
└── yazi/       # yazi.toml, Markdown opens through pk-mdopen
```

## Setup

No install script exists yet. Each tool's files are symlinked into the location
that tool expects. Two kinds of machine use this repo, and they take different
slices of it:

- **macOS (Apple silicon)** — the whole workshop: Ghostty, zsh, tmux, Neovim,
  Cursor, Gemini.
- **Ubuntu server** — bash, tmux, Neovim, and git. Ghostty, zsh, Cursor,
  Gemini and their links stay out.

### macOS

The shell depends on Homebrew packages. Nothing in `zsh/zshrc` breaks without
them — every block is guarded — but the shell is only itself with all of them:

```sh
brew install \
  zsh-syntax-highlighting zsh-autosuggestions zsh-completions \
  zsh-history-substring-search fzf-tab \
  eza bat fzf fd ripgrep zoxide
brew install --cask font-symbols-only-nerd-font   # the icons eza prints
```

`compinit` refuses to load completions from a group-writable directory, which
is how Homebrew leaves `share`. Once, after installing:

```sh
chmod go-w "$(brew --prefix)/share"
```

Node is not a Homebrew package here — nvm owns it, and the `nvm` block in
`zsh/zshrc` stays silent until `~/.nvm/nvm.sh` exists:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
nvm install --lts     # or any version; the newest installed one lands on PATH
```

The installer appends its own two-line loader to `~/.zshrc`; delete that — it is
the ~0.85s load the block above exists to avoid.

Already linked:

```sh
ln -sfn "$PWD/zsh/zshrc"       ~/.zshrc
mkdir -p ~/.local/bin ~/.config/tmux ~/.config/yazi ~/.config/ghostty ~/.cursor/skills
ln -sfn "$PWD/zsh/bin/pk-preview" ~/.local/bin/pk-preview
ln -sfn "$PWD/zsh/bin/pk-mdopen" ~/.local/bin/pk-mdopen
ln -sfn "$PWD/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
ln -sfn "$PWD/yazi/yazi.toml"  ~/.config/yazi/yazi.toml
ln -sfn "$PWD/ghostty/config" ~/.config/ghostty/config
ln -sfn "$PWD/ghostty/themes" ~/.config/ghostty/themes
ln -sfn "$PWD/skills/commit"     ~/.cursor/skills/commit
ln -sfn "$PWD/skills/archify"    ~/.cursor/skills/archify
ln -sfn "$PWD/skills/docs"       ~/.cursor/skills/docs
ln -sfn "$PWD/skills/paper-target" ~/.cursor/skills/paper-target
ln -sfn "$PWD/skills/implement-commit-prompt" ~/.cursor/skills/implement-commit-prompt
ln -sfn "$PWD/skills/implementation-plan" ~/.cursor/skills/implementation-plan
ln -sfn "$PWD/skills/review-implementation-plan" ~/.cursor/skills/review-implementation-plan
ln -sfn "$PWD/skills/follow-implementation-plan" ~/.cursor/skills/follow-implementation-plan
ln -sfn "$PWD/skills/report-arc" ~/.cursor/skills/report-arc
ln -sfn "$PWD/skills/repo-docs" ~/.cursor/skills/repo-docs
ln -sfn "$PWD/skills/twitter-campaign" ~/.cursor/skills/twitter-campaign

mkdir -p ~/.gemini/config/skills
ln -sfn "$PWD/skills/commit" ~/.gemini/config/skills/commit
ln -sfn "$PWD/skills/archify" ~/.gemini/config/skills/archify
ln -sfn "$PWD/skills/docs" ~/.gemini/config/skills/docs
ln -sfn "$PWD/skills/docs-twins" ~/.gemini/config/skills/docs-twins
ln -sfn "$PWD/skills/docs-verify" ~/.gemini/config/skills/docs-verify
ln -sfn "$PWD/skills/follow-implementation-plan" ~/.gemini/config/skills/follow-implementation-plan
ln -sfn "$PWD/skills/repo-docs" ~/.gemini/config/skills/repo-docs

npx skills add DietrichGebert/ponytail -g --skill ponytail

./claude/link-skills
```

### Ubuntu server

A headless box reached over ssh (Tailscale) from the Mac. It runs tmux and
Neovim in bash — `bash/bashrc` is that shell's share of
`zsh/zshrc` and needs no Homebrew, Ghostty, eza, bat or fzf. Nothing under
`ghostty/`, `zsh/`, `skills/`, or the Cursor and Gemini link lists above
belongs here.

Packages, all from apt:

```sh
sudo apt install git tmux neovim ripgrep build-essential
```

`build-essential` is for Treesitter — `nvim/init.lua` compiles its parsers with
`cc` on first launch and silently falls back to plain syntax colour without it.

Links — only the Linux slice:

```sh
ln -sfn "$PWD/bash/bashrc"     ~/.bashrc
mkdir -p ~/.config/tmux ~/.config/nvim
ln -sfn "$PWD/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
ln -sfn "$PWD/nvim/init.lua"      ~/.config/nvim/init.lua
ln -sfn "$PWD/nvim/lazy-lock.json" ~/.config/nvim/lazy-lock.json
```

`git/config` needs no link — `bash/bashrc` points `GIT_CONFIG_GLOBAL` at it,
and it includes `~/.gitconfig` for the machine's identity.

**Ghostty over ssh.** Ghostty sets `TERM=xterm-ghostty`, and ssh forwards it.
A stock Ubuntu has no terminfo entry by that name, so tmux, nvim, less and
`clear` all fail with `'xterm-ghostty': unknown terminal type`. `bash/bashrc`
falls back to `xterm-256color` whenever `infocmp "$TERM"` fails, which is
enough. To have the real entry instead (keeps Ghostty's own capabilities), run
once from the Mac:

```sh
infocmp -x xterm-ghostty | ssh <server> -- tic -x -
```

Ghostty can also do this on every connection by itself with
`shell-integration-features = ssh-terminfo` in `ghostty/config`.

Any pre-existing real `~/.zshrc` was copied to `~/.zshrc.backup.<timestamp>`
before the link was created. `reload` (`exec zsh`) picks up shell edits in the
current window. A running tmux server picks up edits to `tmux/tmux.conf` with
`prefix C-r`; new servers read it on start. Ghostty reloads with
`Cmd+Shift+,` — a config change does not reach already-open windows until then.
Cursor also reads its skill directories at startup: **Developer: Reload Window**
is enough, and the skill then appears under Customize → Skills and as
`/paper-target` in Agent chat.
