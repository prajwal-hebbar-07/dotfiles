# dotfiles

## Skills

Claude Code, Codex, Cursor and Gemini keep only `commit`; git history and
`SKILLS.md` hold older sets. OMP skills are listed below.

`commit` has one copy per host:

- `skills/commit/SKILL.md` — plain Agent Skill, linked into `~/.cursor/skills/`
  and `~/.gemini/config/skills/`. Not used by Claude Code.
- `claude/skills/commit/SKILL.md` — Claude Code. `claude/link-skills` links
  each skill under `claude/skills/` into both accounts, `~/.claude/skills/`
  (`cc`) and `~/.claude-work/skills/` (`ccw`), and prunes links to removed
  ones; rerun it after adding or removing one. The same script links
  `claude/CLAUDE.md`, the global instructions (concise reports; every question
  carries a recommendation or, failing that, an explanation; do only what the
  request needs; never ask what is already settled), as `CLAUDE.md` in both
  accounts.
- `codex/skills/commit/SKILL.md` — Codex. `codex/link-skills` links each skill
  under `codex/skills/` into `~/.agents/skills/`, prunes only its own broken
  links and refuses to replace another skill; rerun it after adding or
  removing one. Invoke with `$commit`.

Keep the Claude and Codex copies in step when changing a shared workflow;
retain each host's invocation syntax, metadata and tool instructions. Any new
skill that builds, reviews or asks carries two rules in its `Never` list: do
only what the request needs (a useful extra is named, not done), and never ask
what is already settled (read documents, answer logs and chat first).

- `commit` — `/commit` (`$commit` in Codex): stops if `user.name`/`user.email`
  is unset; commits what is staged, or stages everything when nothing is. One
  commit by default; several focused commits only where the changes separate
  cleanly (revert, pick and one-sentence tests; code with its tests, docs and
  wiring). With several it prints the plan and commits without asking (`plan`
  only prints; `now` is a no-op), then checks the final tree equals the
  starting index. In a new repository (no `HEAD`) it splits the whole project
  into granular commits in build order (repo basics, skeleton, foundations,
  one per feature with its tests, cross-feature tests, docs, CI/deploy),
  staging intermediate versions of shared wiring files through
  `git update-index --cacheinfo`, and stops first if dependency output or
  secrets are in scope; never one `initial commit`. Each message is a
  semantic subject plus two or more bullets; never a co-author or
  attribution trailer. The Cursor/Gemini copy is the Claude one without the
  advisor section.

OMP-only skills live in `omp/skills/<name>/SKILL.md` (grill-requirements,
grill-stack, grill-architecture, work, implement, draft-docs, issue-branch,
raise-pr, detox, design, build-ui, review-ui, ui-craft), with model-pinned
agents in `omp/agents/`. `omp/link-skills` links them into
`~/.omp/agent/skills/` and `~/.omp/agent/agents/`, pruning only its own broken
links and refusing to replace unrelated files; rerun it after adding or
removing one. Each SKILL.md is the source of truth for its workflow; `work`
and `implement` overlap and share `docs/implementation-plan.md`.

The design skills are distilled from ui-ux-pro-max and Emil Kowalski's skills,
neither of which is installed. `ui-craft` holds the shared rules (interface,
motion, platforms, worst-case data) that `design`, `build-ui`, `review-ui`,
`work` and `implement` read. `design` refuses to start until requirements,
stack and an architecture review (`Verified` or `Verified with risks`, newer
than the documents) exist, then draws directions, the design system and
screens in Paper and writes `docs/design.md`; `build-ui` implements a design
through `implement`; `review-ui` writes read-only findings to
`docs/ui-review.md` for `implement` to fix.

`archify` and `ponytail` are third-party and not vendored here: install with
`npx skills add tt-a1i/archify -g` and
`npx skills add DietrichGebert/ponytail -g --skill ponytail` (they land in
`~/.agents/skills/` and the installer owns updates).

## OMP rules

`omp/rules/*.md` are user-level OMP rules that `omp/link-skills` links into
`~/.omp/agent/rules/`; they reach task subagents, unlike
`~/.omp/agent/AGENTS.md`. Each rule file is its own documentation.

## Cursor skills

Cursor's built-in skills live in `~/.cursor/skills-cursor/`, which Cursor
keeps in sync itself; no copy is kept in this repo.
