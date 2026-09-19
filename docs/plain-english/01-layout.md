# The Blueprint

**Twin of:** [Repository Layout](../architecture/01-layout.md)

Think of this repository as the architectural blueprint for a personal workshop. Every tool
in the workshop — the shell, the terminal window, the session manager, the coding assistant
— has its own storage locker in the blueprint. When you set up a new machine, you run a
series of "move the key to the lock" steps: symbolic links that point each tool to its locker
in the blueprint instead of a private copy it keeps on its own.

That matters because there is only one blueprint. When you change something in the locker,
every tool that holds a key sees the new version the next time it opens its door.

---

## What is in each locker

| Locker | Contents |
| --- | --- |
| `zsh/` | Shell startup file and the preview helper script for the fuzzy picker |
| `tmux/` | Session manager settings — split layouts, key shortcuts, colour strip at the bottom |
| `ghostty/` | Terminal window settings and the Pale Knight colour palette |
| `ohmypi/` | Coding assistant rules, specialised skills (task scripts), and MCP server connection |
| `docs/` | Twin documentation — this file included |
| `.gitignore` | Tells git to skip the ephemeral implementation-plan folder |

---

## The linking step

After cloning the blueprint, you run a block of linking commands from `README.md`. Each
line follows the same pattern:

```
key → lock      (symbolic link from the tool's expected location to the locker in the repo)
```

For example:
- The shell looks for `~/.zshrc`. The link makes it read `zsh/zshrc` from the blueprint.
- Ghostty looks for `~/.config/ghostty/config`. The link points there to `ghostty/config`.

From that moment on, editing `ghostty/config` is the same as editing Ghostty's settings —
no copy step, no drift, no "which version is live?"

---

## Three coding editors share the same skills

The coding-assistant skills in `ohmypi/skills/` are linked into three different places:

- **Oh My Pi** — the primary coding harness; gets all ten skills
- **Cursor** — the code editor; gets seven (the commit skill is skipped because Cursor has
  its own commit workflow)
- **Antigravity (agy)** — Google's coding assistant CLI; gets five skills

One directory, three doors. Edit the skill once, all three tools see the change after they
restart.

---

## When do changes take effect?

| What you changed | How to apply it |
| --- | --- |
| Shell config (`zsh/zshrc`) | Open a new terminal tab, or type `reload` |
| Session manager (`tmux/tmux.conf`) | Press prefix then `C-r` inside tmux |
| Terminal window (`ghostty/config` or theme) | Press `Cmd+Shift+,` in Ghostty |
| A coding skill or rule | Restart the coding assistant (Oh My Pi, Cursor, or agy) |

---

## What is not yet set up

The blueprint notes two future lockers — one for the browser (Brave) and one for the editor
(Cursor) — but neither has been added to the repository yet. They are placeholders in the
intended floor plan, not live rooms.

There is also no install script. The linking commands must be run by hand from the `README.md`
setup block. Running them a second time is harmless.

---

## A trap to know about

After installing Homebrew's shell completions for the first time, one permission fix is
needed or the shell silently skips loading them:

```sh
chmod go-w "$(brew --prefix)/share"
```

This is not automated. It must be run once on a fresh machine.
