# dotfiles

Personal configuration for my daily development setup.

> Status: the shell (`zsh/`), terminal multiplexer (`tmux/`), and terminal
> (`ghostty/`) configurations are committed and live on
> this machine. The remaining tools listed below are still to land; this README
> records them so the layout is known in advance.

## What I use

Seven tools make up my environment:

| Tool | Role |
| --- | --- |
| [Brave](https://brave.com) | Browser |
| [Ghostty](https://ghostty.org) | Terminal emulator |
| Oh My Pi | Coding harness / agent environment |
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

### Oh My Pi

The coding harness (`omp`). `omp/` holds its settings and MCP servers, each
symlinked to where omp reads it:

| Repo file | Live path | What it is |
| --- | --- | --- |
| `omp/config.yml` | `~/.omp/agent/config.yml` | Settings: model roles, per-agent model overrides, theme, symbol preset, and the settings the factory needs (GitHub, secrets, security scan, task isolation, usage-aware fallback, 1-hour helper cap) |
| `omp/mcp.json` | `~/.omp/agent/mcp.json` | MCP servers: `paper`, started from the binary inside `/Applications/Paper.app` |
| `omp/agents/factory-*.md` | `~/.omp/agent/agents/` (one link per file) | The factory's helper agents: planner, builder, reviewers, QA, designer, explainer |
| `omp/hooks/pre/factory-guard.ts` | `~/.omp/agent/hooks/pre/factory-guard.ts` | Blocks merges, pushes outside `factory/*` / `feature/*`, PRs you have not approved, edits to approved docs, and holdout reads |
| `omp/extensions/factory-stage-guard.ts` | `~/.omp/agent/extensions/factory-stage-guard.ts` | Keeps an unattended factory run from ending early; points compaction at the run state |
| `skills/factory*/`, `skills/feature/`, `skills/tour/` | `~/.omp/agent/skills/<name>` | The factory skills, the feature factory, and the feature tour (below) |
| `skills/commit`, `paper-design-prompt`, `paper-design`, `paper-target`, `arc-design`, `docs` | `~/.omp/agent/skills/<name>` | Existing skills the factory reuses |

`config.yml` is also written by omp itself (settings UI, `/model`, saved
settings). Edits made there land in the repo file through the link; if a save
ever replaces the link with a plain file, copy it back over `omp/config.yml`
and re-link.

omp reads skills from `~/.omp/agent/skills/`, not `~/.claude/skills/`, so
only the skills linked there are visible to it. Two third-party skills are
linked from `~/.agents/skills/`: `ponytail` (the simplicity rules four factory
agents load) and `archify` (used by `arc-design`).

**Software factory** — `/skill:factory` in an app repo. Builds a whole
application: requirements, tech stack, and architecture, each grilled and
approved by you; then GitHub issues on a board (issue #0 sets up CI and the
checks); then each issue through plan, build, reviews, QA, and UI review
without you; then it asks "Raise PR?". It stops at fixed points (S1–S5);
start a new session and run `/skill:factory` again to resume.
`/skill:factory status` shows where a run is; `/skill:factory change <text>`
changes a requirement mid-run. Run state lives in the app repo's `.factory/`
(kept out of git). Design: `SOFTWARE-FACTORY.md`.

**Feature factory** — `/skill:feature <description>` (or `#<issue>`)
in an existing app repo. One feature, fitted into the current architecture:
scout, a short interview, one solution sketch with a simplicity round, your
Approve on the brief, then plan, build, two reviews, and QA without you, then
your Approve on the PR. It stops instead of designing a new module, service,
datastore, or runtime, or past 10 commits. Run it with no arguments to resume.
Design: `FEATURE-FACTORY.md`.

Both need `gh` logged in (`gh auth refresh -s project` for the board),
`git config user.email` set in the app repo, and an `AGENTS.md` at its root.

**Moving a run to a new chat.** Press Escape to stop the running turn, then
run `/skill:feature pause` (or `/skill:factory pause`) in that same chat. It
stops the helper agents and writes `.factory/handoff.md` with everything only
that chat knows: decisions not yet in the brief, open review findings,
questions waiting on you, what was in progress. Open a new chat in the repo
and run `/skill:feature` (or `/skill:factory`) with no arguments: it reads the
handoff, checks its claims against the branch and ledger, and carries on.
If you already quit with Ctrl+C twice or Ctrl+D, reopen the chat with
`omp --resume` and pause from there; or start a new chat directly, which
resumes from the brief, ledger, and commits but without the chat-only context.

**Evals** — `python3 omp/factory-evals/run structural` checks every factory
skill and agent file, link, and scenario offline in seconds.
`run routing` and `run gate-hold` drive real `omp -p` runs against fixture
repos and grade them with a judge model (see `omp/factory-evals/README.md`).

**`tour` skill** — run in any repo. `/skill:tour`
(or "what features does this project have?") prints a numbered table of
the features in the code, and nothing else.
`/skill:tour explain <name or number>` has `factory-explainer`
write `docs/features/<feature>.md`: each code snippet on the feature's path
in the order it runs, what it does line by line, and why it is written that
way, with sources. `scripts/check-snippets.py` compares every snippet with
the file before the document is saved. The document is not committed.
Design: `SOFTWARE-FACTORY.md` §4.9.

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

**Software factory** — `/factory` in an app repo, `/feature` for one feature
in an app that already exists. Same stages as the omp factory
(`SOFTWARE-FACTORY.md`, `FEATURE-FACTORY.md`). The Cursor host is
`cursor/factory/`: entry skills, subagents in `~/.cursor/agents/`, and user
hooks that block merges, unapproved PRs, pushes outside `factory/*` and
`feature/*`, and edits to an approved doc. Run state stays in the app repo's
`.factory/`. `python3 cursor/factory/hooks/tests/test_guard.py` checks the
hooks. Approval gates and the stop-before-PR rule live in this host.

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
host-specific — linked into Cursor (`~/.cursor/skills/`), Gemini
(`~/.gemini/config/skills/`), and Claude Code (`~/.claude/skills/`).

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
├── omp/        # Oh My Pi settings, MCP servers, agents
│   ├── config.yml
│   ├── mcp.json
│   └── agents/factory-explainer.md
├── skills/     # Agent Skills, linked into Cursor, Gemini, and Claude Code
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
│   ├── pdocs/SKILL.md
│   ├── tour/SKILL.md               # omp only
│   ├── feature/SKILL.md            # omp only
│   └── factory*/SKILL.md           # omp only
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
ln -sfn "$PWD/cursor/factory/skills/factory" ~/.cursor/skills/factory
ln -sfn "$PWD/cursor/factory/skills/feature" ~/.cursor/skills/feature
mkdir -p ~/.cursor/agents ~/.cursor/hooks ~/.cursor/factory/bin
for a in cursor/factory/agents/*.md; do
  ln -sfn "$PWD/$a" ~/.cursor/agents/$(basename "$a")
done
chmod +x cursor/factory/hooks/factory_guard.py cursor/factory/hooks/factory_stage.py
ln -sfn "$PWD/cursor/factory/hooks/factory_guard.py" ~/.cursor/hooks/factory-guard.py
ln -sfn "$PWD/cursor/factory/hooks/factory_stage.py" ~/.cursor/hooks/factory-stage.py
ln -sfn "$PWD/cursor/factory/hooks.json" ~/.cursor/hooks.json
ln -sfn "$PWD/skills/factory/scripts/factory-state" ~/.cursor/factory/bin/factory-state
ln -sfn "$PWD/skills/factory-issues/scripts/board" ~/.cursor/factory/bin/board

mkdir -p ~/.gemini/config/skills
ln -sfn "$PWD/skills/commit" ~/.gemini/config/skills/commit
ln -sfn "$PWD/skills/archify" ~/.gemini/config/skills/archify
ln -sfn "$PWD/skills/docs" ~/.gemini/config/skills/docs
ln -sfn "$PWD/skills/docs-twins" ~/.gemini/config/skills/docs-twins
ln -sfn "$PWD/skills/docs-verify" ~/.gemini/config/skills/docs-verify
ln -sfn "$PWD/skills/follow-implementation-plan" ~/.gemini/config/skills/follow-implementation-plan
ln -sfn "$PWD/skills/repo-docs" ~/.gemini/config/skills/repo-docs

mkdir -p ~/.omp/agent/skills ~/.omp/agent/agents ~/.omp/agent/hooks/pre ~/.omp/agent/extensions
ln -sfn "$PWD/omp/config.yml"  ~/.omp/agent/config.yml
ln -sfn "$PWD/omp/mcp.json"    ~/.omp/agent/mcp.json
for s in skills/factory skills/factory-* skills/feature skills/tour skills/commit skills/paper-design-prompt \
         skills/paper-design skills/paper-target skills/arc-design skills/docs; do
  ln -sfn "$PWD/$s" ~/.omp/agent/skills/$(basename "$s")
done
for a in omp/agents/*.md; do ln -sfn "$PWD/$a" ~/.omp/agent/agents/$(basename "$a"); done
ln -sfn "$PWD/omp/hooks/pre/factory-guard.ts" ~/.omp/agent/hooks/pre/factory-guard.ts
ln -sfn "$PWD/omp/extensions/factory-stage-guard.ts" ~/.omp/agent/extensions/factory-stage-guard.ts
npx skills add DietrichGebert/ponytail -g --skill ponytail
ln -sfn ~/.agents/skills/ponytail ~/.omp/agent/skills/ponytail
ln -sfn ~/.agents/skills/archify  ~/.omp/agent/skills/archify

mkdir -p ~/.claude/skills
for s in arc-design commit follow-implementation-plan follow-plan-with-review \
         implementation-plan paper-design paper-design-prompt paper-target \
         review-implementation-plan sync-lyik-docs pdocs; do
  ln -sfn "$PWD/skills/$s" ~/.claude/skills/$s
done
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
