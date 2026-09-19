# Oh My Pi harness config

This repo hosts multiple Oh My Pi modules under `ohmypi/`.

## Skills

Skills live under `ohmypi/skills/<name>/SKILL.md`, linked into
`~/.omp/agent/skills/`, `~/.cursor/skills/`, and `~/.gemini/config/skills/`:

- `commit` — commits already-staged changes with a semantic message.
- `paper-target` — pins the Paper file/page this repo's design work reads from.
- `implementation-plan` — turns a finished design chat into commit-by-commit
  plan files of at most five steps each.
- `follow-implementation-plan` — implements the next unfinished plan step,
  commits via `commit`, stamps `Landed:<sha>`, chains the next file.

`archify` (third-party, tt-a1i/archify) is **not** vendored here. Install it
with `npx skills add tt-a1i/archify -g`; it lands in `~/.agents/skills/archify`
and is symlinked into the omp and gemini skill dirs. Do not copy its Node
sources into `ohmypi/skills/` — the installer owns updates.

`ohmypi/skills/` was otherwise cleared on 2026-09-19 to start over; the old set
is described in `SKILLS.md` at the repo root and archived at
`~/.local/share/ohmypi/skills-archive-20260919-171738/skills` (also in git
history). List new skills here.

## Agents

Agents live under `ohmypi/agents/`:

- `committer` — creates semantic commits.
