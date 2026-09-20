# Documentation

Twin docs: a technical reading and a plain-English reading of the same area.

| Architecture | Plain English |
| --- | --- |
| [`01-layout.md`](architecture/01-layout.md) — Repository Layout | [`01-layout.md`](plain-english/01-layout.md) — The Blueprint |
| [`02-zsh.md`](architecture/02-zsh.md) — Zsh Shell Environment | [`02-zsh.md`](plain-english/02-zsh.md) — The Command Deck |
| [`03-tmux.md`](architecture/03-tmux.md) — Tmux Terminal Multiplexer | [`03-tmux.md`](plain-english/03-tmux.md) — The Workspace Grid |
| [`04-ghostty.md`](architecture/04-ghostty.md) — Ghostty Terminal Emulator | [`04-ghostty.md`](plain-english/04-ghostty.md) — The Terminal Window |
| [`05-ohmypi.md`](architecture/05-ohmypi.md) — Oh My Pi Harness and Skills | [`05-ohmypi.md`](plain-english/05-ohmypi.md) — The Agent Workshop |

## Freshness

plain-english: on

docs-baseline: 425d279a0545fd400f6928631b278ea5a5cb5da9

Last sweep: 2026-09-20 — plain English only (`no-arch`). The architecture pages were not
refreshed and still read against `0147ec0`; run the docs skill with `full arch` to catch
that surface up.

## Mapping

Path globs to pair numbers. A path may list several numbers.

| Changed path | Pairs |
| --- | --- |
| `README.md` | `01` |
| `AGENTS.md` | `01` |
| `SKILLS.md` | `01` |
| `.gitignore` | `01` |
| `zsh/**` | `02` |
| `tmux/**` | `03` |
| `ghostty/**` | `04` |
| `ohmypi/**` | `05` |
