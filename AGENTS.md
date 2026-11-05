# dotfiles

## Skills

Every skill except `commit` was removed on 2026-11-05 (Claude Code, Codex,
Cursor and Gemini alike); git history holds the old sets, and `SKILLS.md`
describes the set cleared on 2026-09-19. The OMP-only
`grill-requirements` skill was added afterward. List new skills here as they
are added.

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

`grill-requirements` is OMP-only:

- `omp/skills/grill-requirements/SKILL.md` — invoke with
  `/skill:grill-requirements`. Haiku 5.5 high drafts the current question
  frontier; Sonnet 5.5 high answers from the request, repository and sources;
  Haiku challenges only Sonnet's answers. Unresolved decisions go to the user
  in chat. The accepted result is written to `docs/requirements.md`; the skill
  does not add unrequested features or make decisions for the user.
- `omp/agents/requirements-haiku-griller.md` and
  `omp/agents/requirements-sonnet-answerer.md` pin those model roles.
  `omp/link-skills` links the skill into `~/.omp/agent/skills/` and both agents into
  `~/.omp/agent/agents/`, pruning only its own broken links and refusing to
  replace unrelated files.

`archify` (tt-a1i/archify) and `ponytail` (DietrichGebert/ponytail) are
third-party and **not** vendored here. Install with
`npx skills add tt-a1i/archify -g` and
`npx skills add DietrichGebert/ponytail -g --skill ponytail`; they land in
`~/.agents/skills/` and the installer owns updates.

## Cursor skills

Cursor's built-in skills live in `~/.cursor/skills-cursor/`, which Cursor
keeps in sync itself; no copy is kept in this repo.
