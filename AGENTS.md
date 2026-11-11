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
grill-stack, blueprint, design, raise-issues, issue-branch, implement, work,
review-ui, feature, draft-docs, raise-pr, detox, ui-craft, manual,
herdr-worktree), with model-pinned agents in `omp/agents/`.
`omp/link-skills` links them into `~/.omp/agent/skills/` and
`~/.omp/agent/agents/`, pruning only its own broken links and refusing to
replace unrelated files; rerun it after adding or removing one. Each SKILL.md
is the source of truth for its workflow. `omp/guide.html` is a static,
illustrated user guide to all of them (paths, examples, approvals, files);
update it when a skill's invocation, approvals or files change.

A new app runs: `grill-requirements` → `grill-stack` → `blueprint` →
`design` (wireframes, then the Paper design) → `raise-issues`, then stops.
Each issue is worked with `issue-branch`, the user's architecture for it and
`implement` (or `work`); `review-ui` compares the built UI with the design
and its gaps go back through `raise-issues`; `commit` and `raise-pr` finish
the branch. There is no architecture grill or architecture document: the
requirements and stack settle what it would, and the user gives the
structure per issue. `draft-docs` writes a starting requirements or stack
document from what the user said.

The two grill skills run the same format with the same models: a Haiku 5.5
griller and a Sonnet 5.5 answerer (stack: researcher), falling back to GPT
6.1 Terra and Sol together when either is unavailable or hits a limit. In
one session the answerer settles everything it can from evidence or its own
expertise, the griller challenges it (one rebuttal and one rejoinder per
challenge), and low-impact choices are recorded as `Defaults`
(requirements) or `Origin: Default` (stack). Only decisions that move
scope, change core behaviour, are costly to reverse (stored data, public
interfaces, auth, platform foundations), commit money or carry legal or
security exposure reach the user, through an interview in the same session
(`ask` forms; recommendations labelled, never preselected; defaults listed
for override); there are no questions files. Once nothing is left for the
user, a final round runs with a fresh pair, Sonnet 5.5 asking and
challenging and Opus 5.5 answering and writing the final document, by the
same rules; it has no fallback and resumes with `final`. Nothing is left
ambiguous: a decision is answered or deferred by the user in their own
words, never by a model. The requirements grill also covers roles, kept
data and outside systems; the stack grill must name a choice or deferral
for every area the requirements need (runtime, framework, datastore, auth,
hosting, and for a UI the component library and styling).

Each grill document carries `Status: Grilling` until its final round
closes, listing whatever is still open (a contradiction, a line open to two
readings, an unanswered decision, a stack `Conflict` or `Needs proof`)
under `Unresolved`; only the close writes `Settled`. `blueprint`, `design`
and `raise-issues` refuse to start until both documents are `Settled`. The
interview's `Not sure — decide when implementing` answer is the way out:
the decision is recorded under `Open questions` (requirements) or
`Decisions for you` (stack) with the user's words, no longer blocks, and
`raise-issues` puts it under `Decide first` in each issue that needs it.
`implement` asks it in that issue's plan and, once answered, moves it into
the requirements or the stack choice.

`blueprint` turns the settled requirements and stack into
`docs/blueprint/`: five short linked pages (overview, stack, setup,
structure, build) that a senior engineer reads in 15–30 minutes. Each page
opens with an inline SVG diagram (system map, build map, stack layers,
setup strip, folder map, size chart) and stays within a reading budget;
one shared `style.css` gives every colour one meaning, and detail such as
quoted requirement lines stays folded. The pages link each choice's
official docs (checked, for the pinned version), the component library,
the setup steps with their commands, the project structure, and the build
cut into chunks with issue candidates, plus the review steps that lead to
`design`; `skill://blueprint/page.md` holds the page rules. New
apps only. An Opus 5.5 (high) orchestrator agent does the work: one
parallel wave of Sonnet 5.5 (medium) workers researches the stack's
official docs and setup commands, the orchestrator cuts the chunks, and a
second wave drafts each chunk's issue candidates and screens; the
orchestrator checks coverage and returns the page, which the parent
writes. When either model is unavailable or hits a limit, the whole pair
switches to GPT 6.1 Sol (high) and Terra (medium); pairs never mix.

`raise-issues` turns the settled documents into GitHub issues in the
blueprint's chunk order: a walking skeleton first when no app runs yet,
then vertical slices (never one per layer) and shared prefactors, linked
with native `--blocked-by` (gh 2.94.0 or later); it also takes a feature
spec or `docs/ui-review.md` as its source. Acceptance restates source
lines; nothing is invented. It drafts `docs/issues.md`, raises only on
`/skill:raise-issues approve`, records each number as it goes so a rerun
never duplicates, and skips what the code already does and what an
existing issue covers.

`implement` and `work` are one workflow: both take an issue URL, a request
or a plan, take the architecture from the user (or the code's existing
structure), plan in `docs/implementation-plan.md` with an `Architecture`
section, implement after explicit approval, build a designed screen from
Paper and `docs/design.md` when the issue has one, and update existing
documents the change makes stale. Only `implement` keeps the AI navigation
map `docs/codebase-map.md` (and its `AGENTS.md` pointer), read first in
every session; `work` runs `implement` with every map step removed.

`feature` is the same pipeline for one feature on an app that already
exists: the requirements grill (same agents, gate plus two tests: changing
shipped behaviour, or contradicting the stack or bringing in a gated
technology) into `docs/features/<branch>/spec.md`, `grill-stack` only when
the spec brings in new technology, `design` only when it changes the UI, no
blueprint, then `raise-issues` with the draft in
`docs/features/<branch>/issues.md`. Once raised, it folds the spec into
`docs/requirements.md` and deletes the folder. Per-branch folders keep
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
motion, platforms, worst-case data) that `design`, `review-ui`, `work` and
`implement` read. `design` needs the requirements, stack and (for a new
app) blueprint, draws grey wireframes and a flow board on their own page
of the Paper file for the user to approve, then the direction, design
system and screens with every state on a design page of the same file,
and writes `docs/design.md`. `review-ui` reads the code against
`docs/design.md` and the Paper page the user names before the review:
which screens and states are built, partial or missing, where they drift,
and ui-craft findings, written read-only to `docs/ui-review.md` for
`raise-issues`.

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
