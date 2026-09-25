# Oh My Pi harness config

This repo hosts multiple Oh My Pi modules under `ohmypi/`.

## Skills

Skills live under `ohmypi/skills/<name>/SKILL.md`, linked into
`~/.omp/agent/skills/`, `~/.cursor/skills/`, and `~/.gemini/config/skills/`:

- `commit` — commits already-staged changes with a semantic message.
- `paper-target` — pins the Paper file/page this repo's design work reads from.
- `implementation-plan` — turns a finished design chat into commit-by-commit
  plan files of at most five steps each.
- `review-implementation-plan` — a second model edits one plan file's
  sequence and outcomes before follow; never implements.
- `follow-implementation-plan` — implements the next unfinished plan step,
  commits via `commit`, stamps `Landed:<sha>`, chains the next file.
- `arc-design` — directs `archify` to build a diagram set (overview + one per
  piece) under `docs/architecture/diagrams/`, then commits via `commit`.
- `docs` — generate or verify architecture and/or plain-English docs
  (each surface pinned per repo in `docs/README.md`), then commit via
  `commit`.
- `sync-lyik-docs` — copies `lyik_forms_v3/docs/architecture/` into
  `lyik_docs/docs/lyik_enterprise/design/architecture/`. No checks, no commit.

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
