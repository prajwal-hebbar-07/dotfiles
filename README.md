# dotfiles

Personal configuration for my daily development setup.

> Status: the shell (`zsh/`), terminal multiplexer (`tmux/`), terminal
> (`ghostty/`), and harness (`ohmypi/`) configurations are committed and live on
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

The coding harness I work through — agent-driven editing, search, and
verification against this machine rather than a hosted sandbox. `ohmypi/` holds
its rules, skills, task agents, and MCP servers, symlinked into `~/.omp/agent/`.

**Hard rules** (`ohmypi/RULES.md` → `~/.omp/agent/RULES.md`) — omp loads a
top-level `RULES.md` as an always-apply *sticky* rule: unlike `AGENTS.md`, it is
re-attached near the current turn, so it keeps its hold after a long conversation
has pushed the opening context out of view. Seven prohibitions live there, and
they outrank the harness's own instruction to verify by running things:

1. **No starting, stopping, or restarting applications** — no `open -a`,
   `osascript -e 'quit app …'`, `kill`/`pkill`/`killall`, no window reloads to
   pick up config. The agent names what needs a restart; I do it.
2. **No starting the server, the app, or a dev command** — not to check whether
   it works, and not to see what is happening before deciding what to do next. I
   start it, test it by hand, and report what I saw; the agent waits for that.
3. **No opening or driving the browser tool** — including as "verification".
   Much of my work is desktop apps, where a browser proves nothing.
4. **No unrequested investigation** — no going through the list, reading around
   the codebase, or working out what is going on until I ask, and I say when I am
   done. Until then: implement what I asked for and nothing else.
5. **No reaching for the `planner` or `hand` subagents** — that two-model
   workflow runs only on `/delegate` or an explicit request; otherwise the agent
   reads, decides, and edits with its own tools.
6. **No documents outside a skill I invoked** — a document in any format
   (`*.md`, notes, summary, report, plan, design doc) is written only by
   `repo-docs`, `docs-twins`, `docs-verify`, `design-sync`, and
   `twitter-campaign`, in the places those skills own. Nothing anywhere else,
   for any reason; keeping an existing document true after a code change is
   still fine.
7. **No amending** — no `--amend`, rebase, reset onto an existing commit,
   fixup/squash, or force-push, even over my own one-line-old commit. A
   correction is always a new commit on top.

Permission lifts a rule only for the action I name in that request; "go ahead" or
"make it work" is not permission. When a rule blocks verification the agent must
state plainly that verification needs me to check it — what is unverified, the
command I would run, what result means success — rather than presenting
unverified work as done. Reading the files it is about to edit, search, LSP,
read-only git, and syntax checks on changed files stay allowed.

Rule 5 is preventive: neither `planner`/`hand` nor `/delegate` exists in this
install today — bundled agents are `scout`, `designer`, `reviewer`,
`security-reviewer`, `librarian`, `task`, `sonic`, plus the local `committer` —
so it takes hold the moment that workflow lands.

**`commit` skill** (`/skill:commit`) — turns staged changes into one semantic
commit. It checks that `user.name` and `user.email` are set, refuses to run with
an empty index, writes a `type(scope): summary` subject followed by pointer
bullets, and adds no `Co-Authored-By:` or "Generated with" trailer, so git
history carries no harness attribution. It never runs `git add` — staging stays
my decision.

**`committer` agent** — the skill's whole job is delegation. It dispatches this
agent, which runs `anthropic/claude-haiku-4-5` at `thinking-level: minimal` with
`bash` as its only tool, so the diff is read by the cheap model and never enters
the main session's context.

**`implementation-plan` skill** (`/skill:implementation-plan`) — after an
architecture conversation is done, writes numbered files under
`docs/implementation-plan/` (gitignored): at most five commits each. Each
step is an outcome plus a prompt; how to build it is left to the
implementing agent. The file itself is the protocol — implement one step
exactly, stop for that commit, then the next in that file. When the file
is done it is deleted and the next file starts on its own. Nothing in it
is harness-specific.

**`review-implementation-plan` skill** (`/skill:review-implementation-plan`) — a
second agent (often a stronger implementer, and often not this harness) reads
one plan file and updates it before anyone codes: split or merge steps,
reorder, strip how-to, add missing outcomes, re-chunk if a file grows past
five commits. It does not implement, and it does not replace the planner's
how with its own. Pass one plan file plus this `SKILL.md`; review the next
file in a new window. It is a plain Agent Skill, not a Cursor feature.

**`follow-implementation-plan` skill** (`/skill:follow-implementation-plan`) —
executes the plan from one invoke: the next unfinished step, exactly as
written, `git add` only that step's files, then `/skill:commit` with the
plan's subject. It does not `git commit` itself. An empty index is not the
end of the plan — add the files and commit. After the SHA lands, it takes
the next step in that file. When the file is done, it deletes it and starts
the next remaining file in a new agent with empty history — never this
same agent. On Cursor that is a Task/subagent; on omp it is the `task`
tool with agent `task` (not isolated). After every step it emits a
**report-arc** report.

**`report-arc` skill** (`/skill:report-arc`) — the step-report shape (status,
Done when table, changed, leftover unstaged, verification, next) and a
second mode that turns any such report — pasted, a file, or this chat —
into a page under `docs/reports/`. It does not implement. Pass the report
plus this `SKILL.md` to any agent.

**`repo-docs` skill** (`/skill:repo-docs`) — the same paired docs as
`docs-twins` (architecture + plain-English, same number, stored baseline,
one writer per pair, never commit), for **any** tree: a dotfiles repo, Python,
Go, Rust, a single crate. The path → pair table lives in that repo's
`docs/README.md`, not in the skill, so `docs-twins` can stay hardcoded for
the monorepos it already serves. Incremental by default; `full` or named
numbers for a sweep.

**`docs-twins` skill** (`/skill:docs-twins`) — generates or refreshes twin
documentation (technical doc in `docs/architecture/` and plain-English twin in
`docs/plain-english/`) for monorepos, diff-driven from a stored baseline SHA
in `docs/README.md`.

**`docs-verify` skill** (`/skill:docs-verify`) — audits documentation claims
against the code in the reverse direction of `docs-twins`. Finds dead paths,
dead symbols, renamed modules, and stale counts, running `check-claims.py`
mechanically and delegating prose checking.

**`implement-commit-prompt` skill** (`/skill:implement-commit-prompt`) —
extracts **one** step from that plan into a copy-pastable prompt for a fresh
chat. If the step already has a Prompt block, that is what gets copied rather
than a rewrite. Use this when you want a new session per commit; following
the whole sequence from one invoke is `follow-implementation-plan`. These live in
`ohmypi/skills/` and are linked into both omp and Cursor, same as
`paper-target`.

**`twitter-campaign` skill** (`/skill:twitter-campaign`) — walks a project
directory and writes `docs/twitter-campaign.md`: a coordinated developer
launch campaign for Twitter/X and Reddit, from architecture, release notes,
and commit history. Copy is first-person and honest about trade-offs. Tweets
are ≤ 280 characters; Reddit posts are long-form for named subreddits and
reuse the Twitter screenshots/recordings 1:1. A
`twitter-campaign-baseline:` sha in that file is the commit the plan was
last read against; a later run diffs from there and appends, it does not
start over. `full` rewrites. It does not post, and it does not invent
features that are not in the tree. Linked into both omp and Cursor, same as
`paper-target`.

**`paper-target` skill** (`/skill:paper-target`) — pins which Paper file and
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

Nothing in it is omp-specific — it is a plain Agent Skills package that reads the
Paper MCP and writes Markdown — so the one directory is linked into both hosts:
`~/.omp/agent/skills/paper-target` and `~/.cursor/skills/paper-target`. One file
to edit, no copy to drift, and both hosts resolve the same target block.

**`paper` MCP server** (`ohmypi/mcp.json`) — stdio server for Paper Desktop,
`~/.paper/bin/paper mcp`, and the only definition of that server on this
machine. The `paper-desktop@paper` marketplace plugin (v0.2.1) declared the
same server, but its manifest hardcodes `${HOME}/.paper/bin/paper` and omp
expands `${...}` only in native config, so the plugin's copy failed to spawn
every startup with `ENOENT ... posix_spawn '${HOME}/.paper/bin/paper'`. The
plugin carried nothing else — no skills, agents, or commands, just that
manifest and logo assets — so it and the `paper` marketplace
(`paper-design/agent-plugins`) were uninstalled rather than shadowed:

```sh
omp plugin uninstall paper-desktop@paper
omp plugin marketplace remove paper
```

Reinstalling is worthwhile only once upstream ships an absolute path or omp
expands variables in plugin manifests; until then this entry is what makes the
`paper` tools work.

**`ponytail` plugin** (`ponytail@ponytail`, v4.9.0, user scope) — installed from
the `DietrichGebert/ponytail` marketplace, which omp reads through its
Claude-Code-compatible `.claude-plugin/marketplace.json` fallback. It prepends a
"lazy senior dev" ruleset (YAGNI, reuse, stdlib, native platform feature, one
line) to the system prompt on every turn and ships six skills — `ponytail`,
`ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`,
`ponytail-help`. Its `pi-extension/index.js` loads through the legacy
`package.json` `pi.extensions` key that omp still honours, and registers
`/ponytail lite|full|ultra|off` plus one command per skill. Default level is
`full`; override with `PONYTAIL_DEFAULT_MODE` or `/ponytail default <mode>`. The
repo's Node lifecycle hooks (`hooks/claude-codex-hooks.json`) are Claude/Codex
event names and are unused here, so they never run.

### Cursor

Editor for hands-on code work: an AI-native fork of VS Code, so VS Code
keybindings, settings, and extensions carry over.

**Skills** — Cursor discovers user-level skills from `~/.cursor/skills/` (and
`~/.agents/skills/`, plus the Claude and Codex directories for compatibility),
so `paper-target`, `implement-commit-prompt`, `implementation-plan`,
`review-implementation-plan`, `follow-implementation-plan`, `report-arc`,
`repo-docs`, and `twitter-campaign` are linked there from `ohmypi/skills/`.
`~/.cursor/skills-cursor/` is Cursor's own directory for its built-in skills,
kept in sync from a `.sync-manifest.json`; nothing of mine goes in it. `commit`
is linked in too — it is plain `git` over the staged index, with no omp task
agent behind it, so it behaves the same in every host. The review
skill is linked here for completeness; the intended use is to copy that
`SKILL.md` plus the plan into another agent.

**Paper MCP** — comes from the `paper-desktop` plugin here rather than a hand
written server: Cursor expands `${userHome}` in plugin manifests, so the same
manifest that fails under omp spawns correctly, and its tool schemas are cached
per project under `~/.cursor/projects/<slug>/mcps/`.

### Gemini (Antigravity)

Google's AI coding assistant environment (`agy`).

**Skills** — Antigravity discovers global skills from `~/.gemini/config/skills/`
(as well as workspace skills under `.agents/skills/`). The shared documentation,
commit, and implementation skills — `commit`, `docs-twins`, `docs-verify`,
`follow-implementation-plan`, and `repo-docs` — are linked into
`~/.gemini/config/skills/` from `ohmypi/skills/`.

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
| `prefix` `\` or `\|` | Split left / right — new pane takes 25%, current keeps 75% |
| `prefix` `-` | Split top / bottom |
| `prefix` `r` | Rename this window, from an empty prompt |
| `prefix` `S` | Rename this session, from an empty prompt |
| `prefix` `x` | Close this pane, no confirmation |
| `prefix` `X` | Close this window, no confirmation |
| `prefix` `c` | New window in the current pane's directory |
| `prefix` `g` | lazygit in a popup, on the current pane's repository |
| `prefix` `t` | tuicr in a popup, in the current pane's directory (overrides clock-mode) |
| `prefix` `C-s` | Send a literal `C-s` to the pane |
| `prefix` `C-r` | Reload the config in place |

Splits, new windows, and the lazygit popup all inherit the current pane's
directory. Renaming starts from an empty prompt, so the new name is typed from
scratch with nothing to delete first. Mouse mode is on — drop the
`set -g mouse on` line to disable it.

`prefix g` needs [lazygit](https://github.com/jesseduffield/lazygit) on `PATH`
(`brew install lazygit`).

## Intended layout

As configuration is added, it should land under one directory per tool:

```
dotfiles/
├── brave/      # browser preferences, extension notes
├── ghostty/    # terminal config
│   ├── config
│   └── themes/pale-knight
├── ohmypi/     # harness sticky rules, skills, task agents, MCP servers
│   ├── RULES.md
│   ├── skills/commit/SKILL.md
│   ├── skills/docs-twins/SKILL.md
│   ├── skills/docs-verify/SKILL.md
│   ├── skills/implement-commit-prompt/SKILL.md
│   ├── skills/implementation-plan/SKILL.md
│   ├── skills/review-implementation-plan/SKILL.md
│   ├── skills/follow-implementation-plan/SKILL.md
│   ├── skills/report-arc/SKILL.md
│   ├── skills/repo-docs/SKILL.md
│   ├── skills/paper-target/SKILL.md
│   ├── skills/twitter-campaign/SKILL.md
│   ├── agents/committer.md
│   └── mcp.json
├── cursor/     # editor settings, keybindings, extension list
├── zsh/        # zshrc, and bin/pk-preview for the fzf preview pane
└── tmux/       # tmux.conf, Pale Knight theme and keys
```

## Setup

No install script exists yet. Each tool's files are symlinked into the location
that tool expects on this machine (macOS, Apple silicon).

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
mkdir -p ~/.local/bin ~/.config/tmux ~/.config/ghostty ~/.omp/agent/skills ~/.omp/agent/agents ~/.cursor/skills
ln -sfn "$PWD/zsh/bin/pk-preview" ~/.local/bin/pk-preview
ln -sfn "$PWD/tmux/tmux.conf"  ~/.config/tmux/tmux.conf
ln -sfn "$PWD/ghostty/config" ~/.config/ghostty/config
ln -sfn "$PWD/ghostty/themes" ~/.config/ghostty/themes
ln -sfn "$PWD/ohmypi/skills/commit"     ~/.omp/agent/skills/commit
ln -sfn "$PWD/ohmypi/skills/docs-twins" ~/.omp/agent/skills/docs-twins
ln -sfn "$PWD/ohmypi/skills/docs-verify" ~/.omp/agent/skills/docs-verify
ln -sfn "$PWD/ohmypi/skills/paper-target" ~/.omp/agent/skills/paper-target
ln -sfn "$PWD/ohmypi/skills/implement-commit-prompt" ~/.omp/agent/skills/implement-commit-prompt
ln -sfn "$PWD/ohmypi/skills/implementation-plan" ~/.omp/agent/skills/implementation-plan
ln -sfn "$PWD/ohmypi/skills/review-implementation-plan" ~/.omp/agent/skills/review-implementation-plan
ln -sfn "$PWD/ohmypi/skills/follow-implementation-plan" ~/.omp/agent/skills/follow-implementation-plan
ln -sfn "$PWD/ohmypi/skills/report-arc" ~/.omp/agent/skills/report-arc
ln -sfn "$PWD/ohmypi/skills/repo-docs" ~/.omp/agent/skills/repo-docs
ln -sfn "$PWD/ohmypi/skills/twitter-campaign" ~/.omp/agent/skills/twitter-campaign
ln -sfn "$PWD/ohmypi/agents/committer.md" ~/.omp/agent/agents/committer.md
ln -sfn "$PWD/ohmypi/mcp.json"            ~/.omp/agent/mcp.json
ln -sfn "$PWD/ohmypi/RULES.md"            ~/.omp/agent/RULES.md

ln -sfn "$PWD/ohmypi/skills/commit"     ~/.cursor/skills/commit
ln -sfn "$PWD/ohmypi/skills/paper-target" ~/.cursor/skills/paper-target
ln -sfn "$PWD/ohmypi/skills/implement-commit-prompt" ~/.cursor/skills/implement-commit-prompt
ln -sfn "$PWD/ohmypi/skills/implementation-plan" ~/.cursor/skills/implementation-plan
ln -sfn "$PWD/ohmypi/skills/review-implementation-plan" ~/.cursor/skills/review-implementation-plan
ln -sfn "$PWD/ohmypi/skills/follow-implementation-plan" ~/.cursor/skills/follow-implementation-plan
ln -sfn "$PWD/ohmypi/skills/report-arc" ~/.cursor/skills/report-arc
ln -sfn "$PWD/ohmypi/skills/repo-docs" ~/.cursor/skills/repo-docs
ln -sfn "$PWD/ohmypi/skills/twitter-campaign" ~/.cursor/skills/twitter-campaign

mkdir -p ~/.gemini/config/skills
ln -sfn "$PWD/ohmypi/skills/commit" ~/.gemini/config/skills/commit
ln -sfn "$PWD/ohmypi/skills/docs-twins" ~/.gemini/config/skills/docs-twins
ln -sfn "$PWD/ohmypi/skills/docs-verify" ~/.gemini/config/skills/docs-verify
ln -sfn "$PWD/ohmypi/skills/follow-implementation-plan" ~/.gemini/config/skills/follow-implementation-plan
ln -sfn "$PWD/ohmypi/skills/repo-docs" ~/.gemini/config/skills/repo-docs
```

Marketplace plugins live outside this repo, in `~/.omp/plugins`; ponytail is
reinstalled on a new machine with:

```sh
omp plugin marketplace add DietrichGebert/ponytail
omp plugin install ponytail@ponytail
```

Any pre-existing real `~/.zshrc` was copied to `~/.zshrc.backup.<timestamp>`
before the link was created. `reload` (`exec zsh`) picks up shell edits in the
current window. A running tmux server picks up edits to `tmux/tmux.conf` with
`prefix C-r`; new servers read it on start. Ghostty reloads with
`Cmd+Shift+,` — a config change does not reach already-open windows until then.
Task agents are rediscovered on every dispatch, but skills and rules are read at
startup — a new or renamed skill needs an omp restart before `/skill:<name>` sees
it, and edits to `RULES.md` take hold in the next session, not the running one.
Cursor also reads its skill directories at startup: **Developer: Reload Window**
is enough, and the skill then appears under Customize → Skills and as
`/paper-target` in Agent chat.
