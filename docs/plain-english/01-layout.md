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
| `SKILLS.md` | A written-out inventory of the old skill set, kept so it can be re-added piece by piece |

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

The coding-assistant skills in `ohmypi/skills/` are linked into three different places —
Oh My Pi, Cursor, and Antigravity (`agy`). One directory, three doors: edit the skill once
and all three tools see the change after they restart.

Six skill folders live here today — commit, docs, arc-design, implementation-plan,
follow-implementation-plan, and paper-target. The set was cleared and restarted in
September 2026, so the linking block in `README.md` still names several folders that no
longer exist; those lines create dangling links and can be pruned. One more skill,
`archify`, is installed by its own installer outside this repository and linked in
alongside them.

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
