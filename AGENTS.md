# dotfiles

## Skills

Every skill except `commit` was removed on 2026-11-05 (Claude Code, Codex,
Cursor and Gemini alike); git history holds the old sets, and `SKILLS.md`
describes the set cleared on 2026-09-19. OMP-only grilling skills were added
afterward. List new skills here as they are added.

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

`grill-stack` is OMP-only:

- `omp/skills/grill-stack/SKILL.md` — invoke with `/skill:grill-stack`.
  It reads requirements, the existing stack, manifests and lockfiles; researches
  current primary sources; and writes the evidence-backed assessment to
  `docs/stack.md`. Haiku 5.5 high drafts questions and challenges Sonnet 5.5
  high's research. Recommendations remain suggestions until the user decides.
- `omp/agents/stack-haiku-griller.md` and
  `omp/agents/stack-sonnet-researcher.md` pin those model roles. The shared
  `omp/link-skills` installs them with the other OMP skill and agents.

`grill-architecture` is OMP-only:

- `omp/skills/grill-architecture/SKILL.md` — invoke with
  `/skill:grill-architecture`. Sonnet 5.5 high asks the evidence-backed
  architecture questions; Opus 5.5 medium answers them from the implementation;
  Sonnet challenges once and Opus writes the conclusion to
  `docs/architecture-review.md`. The debate is bounded to those two specialists.
- `omp/agents/architecture-sonnet-griller.md` and
  `omp/agents/architecture-opus-reviewer.md` pin those model roles. The shared
  `omp/link-skills` installs them with the other OMP skills and agents.

`work` is OMP-only:

- `omp/skills/work/SKILL.md` — invoke with `/skill:work`. It writes an
  evidence-backed, developer-facing review document to
  `docs/implementation-plan.md` (a `Summary` of what changes and how, plus a
  `Reuse` section naming the existing code it builds on) and makes no
  implementation changes until the user explicitly approves that plan. Plan
  and code follow inlined ponytail-style YAGNI rules: the smallest complete
  change, reusing existing code, platform features and installed dependencies
  before writing new code, with skipped extras listed under `Not included`.
  After approval it implements only the accepted scope, verifies the changed
  behavior, and creates or updates `docs/codebase-guide.md` as the stable OMP
  navigation entry point. For larger repositories that entry point may link to
  focused pages under `docs/codebase-guide/`; a concise root `AGENTS.md`
  pointer makes the guide discoverable in later OMP sessions. The workflow
  records the result in the plan and never uses Claude Artifacts or generates
  an artifact prompt. The shared `omp/link-skills` installs it with the other
  OMP skills.

`implement` is OMP-only:

- `omp/skills/implement/SKILL.md` — invoke with `/skill:implement`. It turns
  a request or a user-supplied plan into a short developer-facing plan in
  `docs/implementation-plan.md` (summary, steps, files, reused code, extras
  left out, verification) and changes nothing else until the user explicitly
  approves it. Implementation loads the third-party `ponytail` skill (below)
  and stops if it is missing; the skill adds only implement-specific rules:
  reuse the map's helpers first, list skipped extras in the plan. It creates
  and keeps `docs/codebase-map.md` current (layout, entry points, files with
  their uses/used-by links, flows, reusable helpers) and adds one pointer to
  the repository's root `AGENTS.md` so every OMP session reads the map before
  working. It overlaps `work`, which uses the same plan path. The shared
  `omp/link-skills` installs it with the other OMP skills.

`archify` (tt-a1i/archify) and `ponytail` (DietrichGebert/ponytail) are
third-party and **not** vendored here. Install with
`npx skills add tt-a1i/archify -g` and
`npx skills add DietrichGebert/ponytail -g --skill ponytail`; they land in
`~/.agents/skills/` and the installer owns updates.

## Cursor skills

Cursor's built-in skills live in `~/.cursor/skills-cursor/`, which Cursor
keeps in sync itself; no copy is kept in this repo.
