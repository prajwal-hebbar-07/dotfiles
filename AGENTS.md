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
grill-stack, grill-architecture, work, implement, feature, draft-docs,
raise-issues, issue-branch, raise-pr, detox, design, build-ui, review-ui,
ui-craft, manual, herdr-worktree), with model-pinned agents in `omp/agents/`.
`omp/link-skills` links them into `~/.omp/agent/skills/` and
`~/.omp/agent/agents/`, pruning only its own broken links and refusing to
replace unrelated files; rerun it after adding or removing one. Each SKILL.md
is the source of truth for its workflow. `implement` and `work` are one
workflow: both take an issue URL, a request or a plan, plan in
`docs/implementation-plan.md` after explicit approval, stay inside the
architecture in place (a new component, technology or trust boundary goes
back to the grills) and update existing documents the change makes stale.
Only `implement` keeps the AI navigation map `docs/codebase-map.md` (and its
`AGENTS.md` pointer); `work` runs `implement` with every map step removed.

The three grill skills (requirements, stack, architecture) share an impact
gate: the models research facts and settle low-impact choices themselves,
recorded as `Defaults` (requirements), `Origin: Default` (stack) or
`Assumptions` (architecture), listed at the foot of each round's questions
file where the user can override them. Only decisions that move scope,
change core behaviour, are costly to reverse (stored data, public
interfaces, auth, platform foundations), commit money or carry legal or
security exposure reach the user.

`raise-issues` turns the settled documents into GitHub issues: a walking
skeleton first when no app runs yet, then vertical slices (never one per
layer), shared prefactors, and unaccepted architecture-review corrections,
linked with native `--blocked-by` (gh 2.94.0 or later). Acceptance restates
requirement lines; nothing is invented. It drafts `docs/issues.md`, raises
only on `/skill:raise-issues approve`, records each number as it goes so a
rerun never duplicates, and skips what the code already does, what an
existing issue covers and what waits on an open question. Each raised issue
is then worked with `issue-branch` and `implement` (or `work`); `feature` is
for asks not yet in `docs/requirements.md`.

`feature` is the loop for one feature on an app the greenfield pipeline
already built. It runs the requirements grill (same agents, gate plus two
tests: changing shipped behaviour, contradicting the architecture review or
bringing in a gated technology) into `docs/features/<branch>/spec.md`, stops
for `grill-stack` or `design` when the spec's `Impact` needs them, runs
`implement` (or `build-ui`) with the plan in `docs/features/<branch>/plan.md`,
and on `/skill:feature close` folds the spec into `docs/requirements.md` (and
new dependencies or components into `docs/stack.md` and
`docs/architecture.md`), then deletes the folder. Per-branch folders keep
parallel worktrees from colliding on shared planning files.

`manual` (`/skill:manual`) creates an empty `manual.md` at the project root if
missing and adds it to `.gitignore`, never reading the file. Afterwards the
`manual-guard` extension blocks every OMP tool call that names a `manual.md`,
in the main session and subagents, and the `omp/rules/manual-md.md` rule
forbids reaching it any other way (a shell glob or `grep -r` the extension
cannot see).

`herdr-worktree` turns task names into one git worktree each under the main
checkout's `.worktrees/` and opens each as a named tab in the current Herdr
desktop space through `herdr-app` (never `herdr`, whose server is normally
off); outside Herdr it prints the `herdr-app do tab.new` commands instead.

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

## OMP extensions

`omp/extensions/*.ts` are OMP extensions that `omp/link-skills` links into
`~/.omp/agent/extensions/`; OMP loads them at startup, so restart it after
adding or changing one. `manual-guard.ts` blocks tool calls that name
`manual.md`; to let an agent at the file on purpose, add
`extension-module:manual-guard` to `disabledExtensions` in
`~/.omp/agent/config.yml` for that session.

## Cursor skills

Cursor's built-in skills live in `~/.cursor/skills-cursor/`, which Cursor
keeps in sync itself; no copy is kept in this repo.
