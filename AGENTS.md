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
- `tour` — omp only, linked into `~/.omp/agent/skills/`. Lists
  a project's features; `explain <feature>` has the `factory-explainer`
  agent (GPT) write `docs/features/<feature>.md`. Not committed.

Factory procedures live under `skills/factory*` and `skills/feature/`,
linked into `~/.omp/agent/skills/<name>`. Design: `SOFTWARE-FACTORY.md`
(full factory) and `FEATURE-FACTORY.md` (feature factory). Only `factory`
and `feature` are run by the user; the rest set
`disable-model-invocation: true` and are read through `skill://` by those
two. Cursor runs the same procedures from `cursor/factory/` (`/factory`,
`/feature`, subagents, hooks); `cursor/factory/runtime.md` is the tool map.

- `factory` — `/skill:factory`: entry and router for the full factory;
  preflight, resume from `.factory/state.json`, `status`, `change <text>`.
  `scripts/factory-state` is the run-state and ledger tool every factory skill
  calls.
- `feature` — `/skill:feature`: one feature in an existing
  app, from scout to PR, with two gates (brief, PR).
- `factory-grill` — grilling rounds, including the pre-mortem and simplicity
  rounds.
- `factory-gate` — the Approve/No questionnaire, builder check, sha stamp,
  and the PR gate.
- `factory-requirements`, `factory-stack`, `factory-architecture` — stages
  1–5, each ending at an approved doc under `docs/factory/`.
- `factory-issues` — splits the app into GitHub issues on a board;
  `scripts/board` is the only path for issue and Project writes.
- `factory-bootstrap` — issue #0: CI, check scripts, floor guard, test
  harness, `verify-<app>` skill.
- `factory-build` — the per-issue pipeline, GO/NO-GO, and PR.
- `factory-land` — PR comments and post-merge work; never merges.
- `factory-review` — shared rubric and verdict formats for reviewer agents.

The factory reuses `commit`, `paper-design-prompt`, `paper-design`,
`paper-target`, `arc-design`, and `docs` (also linked into omp). It never uses
`implementation-plan`, `review-implementation-plan`,
`follow-implementation-plan`, or `follow-plan-with-review`. `ponytail`
(third-party, DietrichGebert/ponytail) is installed like `archify`
(`npx skills add DietrichGebert/ponytail -g --skill ponytail`) and linked
from `~/.agents/skills/ponytail` into `~/.omp/agent/skills/`; do not vendor
it.

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
- `agents/factory-*.md` → `~/.omp/agent/agents/` (one link per file) — the
  factory's helper agents; each file's `model:` line carries its model
  (`SOFTWARE-FACTORY.md` §5.2). `factory-explainer` writes
  `tour` explanations.
- `hooks/pre/factory-guard.ts` → `~/.omp/agent/hooks/pre/` — blocks merges,
  pushes outside `factory/*`/`feature/*`, unapproved PRs, edits to approved
  docs, and holdout reads, only in repos with an active `.factory/state.json`.
  Tests: `node --test omp/hooks/tests omp/extensions/tests`.
- `extensions/factory-stage-guard.ts` → `~/.omp/agent/extensions/` — keeps
  an unattended run from ending before its exit predicate is met.
- `factory-evals/` — not linked. `python3 omp/factory-evals/run structural`
  checks every factory skill, agent, link, and scenario offline.

The account-wide rule `rules/explicit-runtime-permission.md` (no launching
apps, servers, or tests without an explicit request) was removed on
2026-10-20 at the user's request; it is in git history.

The first software factory (`omp/factory/` plugin, `factory_*` model
aliases) was removed on 2026-10-20 and is archived at
`~/.local/share/ohmypi/factory-archive-20261020-084936/` (also in git
history). The current one was rebuilt from `SOFTWARE-FACTORY.md` on
2026-10-22 as the skills, agents, hook, and extension listed above.

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
