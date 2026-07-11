<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g. a line:
        @me: use Postgres, not Redis
    written inside an HTML comment, anywhere in the plan. In nvim, Space+pc
    inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
-->

# Remove Herdr from the dotfiles repo and the system

Status: reviewed (round 1) — 2026-07-11

## Goal

Fully remove Herdr (the agent-multiplexer terminal workspace manager) from
both places it lives:

1. **The repo** — the `herdr` stow package, its wiring in `install.sh`, and
   all documentation in `README.md`, `shortcuts.md`, and `zsh/.zshrc`.
1. **The system** — the running Homebrew service, the brew formula itself,
   the launchd plist, the leftover `~/.config/herdr` state (symlinks, logs,
   sockets, session file), the Homebrew download cache, and the
   `~/.local/state/herdr` XDG state directory. **Zero cache or state files
   remain anywhere on the system.**

Interpretation: "everything related to herdr" means a clean uninstall — no
config, no binary, no service, no docs, no caches — but I will not touch
unrelated tools (tmux keeps its `Ctrl-s` prefix; that predates Herdr's
mirroring of it).

## Current footprint (from research)

**Repo:**

- `herdr/` stow package: `herdr/.config/herdr/config.toml`, `.gitignore`,
  and `bin/{herdr-agents,herdr-keymaps,herdr-reset-session}`
- `install.sh:13` — `herdr` in the `PACKAGES` array
- `install.sh:78-80` — `remove_repo_symlink` calls for `~/.config/herdr`,
  `~/.config/herdr/bin`, `~/.config/herdr/config.toml`
- `install.sh:92-94` — comment + `mkdir -p "$HOME/.config/herdr"`
- `README.md:25` — `herdr` in the example stow command
- `README.md:104-149` — the entire `## Herdr` section
- `README.md:266` — the `herdr-stop-all` bullet in the `## zsh` section
- `shortcuts.md:191-239` — the entire `## Herdr` section (runs to EOF)
- `zsh/.zshrc:141` — the `herdr-stop-all` alias
- `zsh/.zshrc:182-185` — the `HERDR_ENV` prompt-padding block

**System:**

- Homebrew formula `herdr 0.7.3` (from homebrew-core, no custom tap)
- Running brew service: `herdr started` via
  `~/Library/LaunchAgents/homebrew.mxcl.herdr.plist`, server process
  currently live (PID 802)
- `~/.config/herdr/` — real dir containing repo symlinks (`bin`,
  `config.toml`) plus runtime state: `herdr-client.log`, `herdr-server.log`,
  `herdr-client.sock`, `herdr.sock`, `session.json`
- **Homebrew download cache** — `~/Library/Caches/Homebrew/herdr--0.7.3` and
  `herdr_bottle_manifest--0.7.3` (symlinks) pointing at the bottle tarball
  (~5.9 MB) and manifest JSON in `~/Library/Caches/Homebrew/downloads/`
- **XDG state** — `~/.local/state/herdr/` (agent-detection rules and
  `status.toml`, ~76 KB)
- Nothing under `~/Library/{Logs,Application Support}`, `~/.cache`,
  `~/.local/share`, `/tmp`, or a custom tap

## Plan

Ordered so the service stops before its files disappear.

### 1. Stop and uninstall Herdr from the system

1. `brew services stop herdr` — stops the server and removes
   `~/Library/LaunchAgents/homebrew.mxcl.herdr.plist`.
1. Verify no `herdr` process remains (`pgrep -fl herdr`); kill if needed.
1. `brew uninstall herdr` — removes `/opt/homebrew/Cellar/herdr/0.7.3` and
   the `/opt/homebrew/bin/herdr` symlink.
1. Purge the Homebrew download cache:
   `rm -f ~/Library/Caches/Homebrew/herdr--*`
   `~/Library/Caches/Homebrew/herdr_bottle_manifest--*`
   `~/Library/Caches/Homebrew/downloads/*--herdr--*.bottle.tar.gz`
   `~/Library/Caches/Homebrew/downloads/*--herdr-*.bottle_manifest.json`.
1. `rm -rf ~/.config/herdr` — removes the two repo symlinks and the runtime
   logs/sockets/session state in one go.
1. `rm -rf ~/.local/state/herdr` — removes the agent-detection state.
1. Final system sweep: confirm `command -v herdr` is empty and
   `find ~/Library/Caches ~/Library/LaunchAgents ~/.config ~/.local -iname '*herdr*'` returns nothing.

### 2. Remove the stow package from the repo

1. `git rm -r herdr/` — deletes the whole package
   (`config.toml`, `.gitignore`, the three `bin/` scripts).

### 3. Unwire install.sh

1. Remove `herdr` from `PACKAGES` (`install.sh:13`).
1. Remove the three `remove_repo_symlink` lines for `~/.config/herdr`
   (`install.sh:78-80`).
1. Remove the Herdr comment and `mkdir -p "$HOME/.config/herdr"`
   (`install.sh:92-94`).

### 4. Clean zsh/.zshrc

1. Delete the `herdr-stop-all` alias (`zsh/.zshrc:141`).
1. Delete the `HERDR_ENV` prompt-padding block (`zsh/.zshrc:182-185`),
   keeping the `# Prompt` comment attached to the Starship init below it.

### 5. Clean documentation

1. `README.md`: drop `herdr` from the stow command on line 25, delete the
   `## Herdr` section (lines 104-149), and delete the `herdr-stop-all`
   bullet (line 266).
1. `shortcuts.md`: delete the `## Herdr` section (lines 191-239, through
   EOF).

### 6. Verify

1. `grep -rin herdr . --exclude-dir=.git` returns nothing.
1. `bash install.sh` runs clean (re-stows remaining packages, confirms
   nothing recreates `~/.config/herdr`).
1. Open a fresh shell to confirm `.zshrc` sources without errors.
1. Re-run the system sweep from step 1.7 to confirm zero herdr files remain.

## Edge cases & risks

- **Herdr may be the thing hosting this session.** If Claude/tmux is running
  inside a Herdr pane, stopping the server (step 1) kills this session.
  Research suggests tmux is the active multiplexer (`$TMUX` is set), but
  worth confirming before pulling the trigger.
- The `~/.config/herdr` symlinks will dangle the moment `git rm -r herdr/`
  runs, which is why the system cleanup happens first.
- `brew autoremove` afterward could clear now-orphaned dependencies, but it
  can also remove leaves shared with other workflows — left out on purpose;
  say the word if you want it included.
- Not committing as part of this plan; after implementation the diff stays
  in the working tree for you to `/ship` when satisfied.

## Open questions

- Any Herdr sessions/agents currently running that you care about? Stopping
  the server ends them.

## Review changelog

### Round 1 — 2026-07-11

- Goal: per your note, tightened scope to "zero cache or state left on the
  system" and made it an explicit requirement.
- Footprint: fresh research found two cache/state locations the draft
  missed — the Homebrew download cache (bottle tarball + manifest, ~5.9 MB)
  and `~/.local/state/herdr` (~76 KB agent-detection state); both added.
- Step 1: added explicit cache purge (1.4), state-dir removal (1.6), and a
  final system-wide sweep (1.7); Verify now re-runs that sweep.
- Open question about the Homebrew bottle cache: resolved into the plan as
  step 1.4 — it is deleted, not left to `brew cleanup`.

<!-- /plan-review appends a dated round entry here each pass -->
