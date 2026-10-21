# dotfiles

## Skills

Skills live under `skills/<name>/SKILL.md`, linked into `~/.cursor/skills/`,
`~/.gemini/config/skills/`, and `~/.claude/skills/`:

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
- `follow-plan-with-review` — same plan as `follow-implementation-plan`, but
  stops after each step for review; commits via `commit` only on the user's
  go-ahead, then does the next step. At the window's end it hands over a
  prompt for the next window's new chat instead of starting one.
- `arc-design` — directs `archify` to build a diagram set (overview + one per
  piece) under `docs/architecture/diagrams/`, then commits via `commit`.
- `docs` — generate or verify architecture and/or plain-English docs
  (each surface pinned per repo in `docs/README.md`), then commit via
  `commit`.
- `sync-lyik-docs` — copies `lyik_forms_v3/docs/architecture/` into
  `lyik_docs/docs/lyik_enterprise/design/architecture/`. No checks, no commit.
- `pdocs` — `docs` renamed for Claude Code; only `SKILL.md` is its own, the
  rest are relative links into `skills/docs/`.
- `factory-features` — omp only, linked into `~/.omp/agent/skills/`. Lists
  a project's features; `explain <feature>` has the `factory-explainer`
  agent (GPT) write `docs/features/<feature>.md`. Not committed.

`archify` (third-party, tt-a1i/archify) is **not** vendored here. Install it
with `npx skills add tt-a1i/archify -g`; it lands in `~/.agents/skills/archify`
and is symlinked into the Cursor, Gemini, and Claude Code skill dirs. Do not copy its Node
sources into `skills/` — the installer owns updates.

The skill directory was otherwise cleared on 2026-09-19 to start over; the old
set is described in `SKILLS.md` at the repo root and archived at
`~/.local/share/ohmypi/skills-archive-20260919-171738/skills` (also in git
history). List new skills here.

## Oh My Pi

`omp/` holds the omp harness config, each file symlinked to its live path:

- `config.yml` → `~/.omp/agent/config.yml` — settings and model roles; omp also
  writes this file.
- `mcp.json` → `~/.omp/agent/mcp.json` — MCP servers (`paper`).
- `agents/factory-explainer.md` → `~/.omp/agent/agents/factory-explainer.md`
  — read-only agent on `@slow` that writes `factory-features` explanations.

The account-wide rule `rules/explicit-runtime-permission.md` (no launching
apps, servers, or tests without an explicit request) was removed on
2026-10-20 at the user's request; it is in git history.

The software factory (`omp/factory/` plugin, `factory_*` model aliases,
`SOFTWARE-FACTORY.md`) was removed on 2026-10-20 to be rebuilt from scratch as
multiple skills. The removed version is archived at
`~/.local/share/ohmypi/factory-archive-20261020-084936/` (also in git history).
The rebuild design — which skills to borrow from pstack,
addyosmani/agent-skills, and mattpocock/skills, and how they map onto omp —
is `SOFTWARE-FACTORY.md` at the repo root.

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
