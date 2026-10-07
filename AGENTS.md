# Oh My Pi harness config

This repo hosts multiple Oh My Pi modules under `ohmypi/`.

## Skills

Skills live under `ohmypi/skills/<name>/SKILL.md`, linked into
`~/.omp/agent/skills/`, `~/.cursor/skills/`, and `~/.gemini/config/skills/`:

- `commit` — commits already-staged changes with a semantic message.
- `paper-target` — pins the Paper file/page this repo's design work reads from.
- `paper-design-prompt` — turns a design direction into one Paper prompt
  (a reference UI as the base, then the requested changes). Does not draw.
- `paper-design` — builds that prompt (`paper-design-prompt.md`) in Paper:
  tokens and design system, then the screens in order. Does not write code.
- `implementation-plan` — turns this chat's finalized decisions into one
  commit-by-commit plan file, in windows of at most five commits.
- `review-implementation-plan` — a second model reviews that plan file,
  editing sequence and outcomes before follow; never implements.
- `follow-implementation-plan` — implements the current window (at most five
  commits) via `commit`, stamps `Landed:<sha>`, then starts the next window
  in a new chat.
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

## Cursor skills

Cursor's built-in skills are copied from `~/.cursor/skills-cursor/` into
`cursor/skills/<name>/`. Cursor still loads the live copies from
`~/.cursor/skills-cursor/`; this tree is the repo copy.

- `automate`
- `autopilot`
- `canvas`
- `create-hook`
- `create-rule`
- `create-skill`
- `create-subagent`
- `deploy-with-vercel`
- `goal`
- `loop`
- `migrate-to-skills`
- `new-repo`
- `onboard`
- `origin`
- `rename-chat`
- `review`
- `review-bugbot`
- `review-security`
- `sdk`
- `share`
- `shell`
- `split-to-prs`
- `statusline`
- `update-cli-config`
- `update-cursor-settings`
- `visualize`

## Agents

Agents live under `ohmypi/agents/`:

- `committer` — creates semantic commits.
