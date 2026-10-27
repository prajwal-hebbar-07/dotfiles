# dotfiles

## Skills

Skills live under `skills/<name>/SKILL.md`, linked into `~/.cursor/skills/`
and `~/.gemini/config/skills/`. None of them are used by Claude Code.

Claude Code skills live separately under `claude/skills/<name>/SKILL.md`,
started from scratch on 2026-10-26 and empty until the user adds one.
`claude/link-skills` links each into both accounts, `~/.claude/skills/`
(`cc`) and `~/.claude-work/skills/` (`ccw`); rerun it after adding or
removing one. List them here as they are added.

Codex counterparts live under `codex/skills/<name>/SKILL.md`:
`commit`, `design`, `grill-design`, `review-requirements`,
`review-stack`, `review-architecture`, `review-design`, `review-code`, `qa`. Requirements, stack
and architecture authoring and grilling stay in Claude Code; Codex can review
their output files.
`codex/link-skills` links them into `~/.agents/skills/`, Codex's user skill
directory; rerun it after adding or removing one. It prunes only its own
broken links and refuses to replace another skill. Invoke with `$name`
(for example `$commit plan` or `$design build`). The workflows below also
describe these nine Codex versions. Keep both hosts in step when changing a
shared workflow, including templates and probes; retain each host's invocation
syntax, metadata and tool instructions. Claude's explicit-only skills use
`policy.allow_implicit_invocation: false` in Codex's `agents/openai.yaml`.

- `commit` — `/commit`: stops if `user.name`/`user.email` is unset; commits
  what is staged, or stages everything when nothing is. One commit by
  default; several focused commits only where the changes separate cleanly
  (revert, pick and one-sentence tests; code with its tests, docs and
  wiring). With several it shows the plan and waits for a yes (`now` skips,
  `plan` only prints), then checks the final tree equals the starting index.
  Each message is a semantic subject plus two or more bullets; never a
  co-author or attribution trailer. This one skill replaced `commit` and
  `split-commit` on 2026-10-27, in both Claude Code and Codex.
- `requirements` — `/requirements`: records what the user says about an app
  into `docs/requirements.md` (numbered R/N/C/X/Q items, exact wording kept)
  and tracks the project in `docs/project.md` in the app repo, so a new chat
  resumes from the files. Does not interview, design, or commit.
  `/requirements approve` sets `approved` once the grill has set `grilled`.
- `grill-requirements` — `/grill-requirements`: grills `docs/requirements.md`
  in rounds asked in chat. Each round and answer is logged to
  `docs/grill/requirements-log.md` before the reply, so a new chat resumes
  from the open questions. Ends only when `requirements-coverage.md`, a
  pre-mortem, a no-chat fresh-eyes check and the user's confirm all pass; then
  sets `grilled`, never `approved`. Based on Matt Pocock's `grilling` and
  `domain-modeling`.
- `stack` — `/stack`: proposes the tech stack from the grilled requirements
  into `docs/stack.md` (one choice per decision, a real alternative, sourced
  facts, each tied to R/N/C IDs) and applies the user's changes. Tracked in
  `docs/project.md`; `/stack approve` sets `approved`. Never edits the
  requirements.
- `grill-stack` — `/grill-stack`: grills `docs/stack.md` the same way as
  `grill-requirements` (chat rounds, logged to `docs/grill/stack-log.md`,
  coverage list, simplicity sweep, pre-mortem, no-chat fresh-eyes check,
  confirm). Settles each decision only on the user's yes, writes ADRs under
  `docs/adr/` for hard-to-reverse choices, and logs requirement gaps instead
  of editing the requirements.
- `architecture` — `/architecture`: proposes the architecture from the
  requirements and the stack into `docs/architecture.md` (shape with a
  structurally different alternative, deep modules and their interfaces and
  seams, data model, flows with failures, cross-cutting concerns, abuse cases
  with verification, mermaid diagrams, a requirement-to-item traceability
  table) and applies the user's changes. Uses Matt Pocock's `codebase-design`
  vocabulary. `/architecture approve` sets `approved`. Never edits the
  requirements or the stack.
- `grill-architecture` — `/grill-architecture`: grills `docs/architecture.md`
  the same way (logged to `docs/grill/architecture-log.md`). Per-module
  deletion test, per-entity lifecycle, per-flow failure attacks; checks the
  module graph has no cycle and every entity one owner; adds settled domain
  terms to the glossary and ADRs to `docs/adr/`; logs requirement and stack
  gaps instead of editing them.

- `design` — `/design`: works out the design from the requirements,
  architecture, stack, glossary and any brief the user adds
  (`/design brief <text>`, kept verbatim as `BR` items) into
  `docs/design.md` (idea with a structurally different alternative, moments of
  use, journeys, screens with every state, shared patterns, a visual
  direction, traceability), applies the user's changes, and `/design build`
  draws it in Paper through the Paper MCP (design system board, then the
  screens). `/design approve` needs `grilled` and every screen built. Never
  edits the requirements, stack or architecture, and never writes app code.
- `grill-design` — `/grill-design`: grills `docs/design.md` the same way
  (chat rounds, logged to `docs/grill/design-log.md`) but to clear the idea,
  not the look: say-it-back, the one thing, who and when, journeys, screens
  and states, with feel words turned into checkable rules. Never asks about
  colour, type or styling (those are reviewed in Paper). Fresh-eyes check is
  a designer sub-agent; logs requirement, stack and architecture gaps instead
  of editing them.

`grill-requirements`, `grill-stack`, `grill-architecture` and `grill-design`
share mechanics (round format, log handling, exit loop) and are each
self-contained on purpose; change one, change the other three.

- `review-requirements`, `review-stack`, `review-architecture`,
  `review-design` — `/review-<stage>`: an independent reviewer for a stage
  document that another model built. Reads the document cold (and for design
  the Paper boards, read-only), runs a stage checklist, re-checks sourced
  facts, and appends ranked findings (blocker, major, minor, nit, each with
  evidence and a confirmed or likely label) with a verdict (`blocked`,
  `changes needed`, `approve-ready`) to `docs/review/<stage>-review.md`. Each
  finding carries the `/requirements`, `/stack`, `/architecture` or `/design`
  command that would fix it, and the report ends in a paste-ready fix list.
  Running it again after the fixes marks each finding resolved, still open or
  new. Never edits the document, never changes a `Status:`, never approves;
  only `docs/project.md`'s **Next action** and log change. It does not
  replace the grill. Available in both Claude Code and Codex. Codex uses
  `$review-<stage>` and `$design`; fix commands for requirements, stack and
  architecture are labeled Claude Code handoffs in the report and reply.

`review-requirements`, `review-stack`, `review-architecture` and
`review-design` share mechanics (report format, re-review, severity) and are
each self-contained on purpose; change one, change the other three.

- `issues` — `/issues`: runs straight from the decided stages to GitHub, with
  no approval or confirmation. Cuts the whole app into vertical-slice issues
  (issue 0 bootstraps the project) and writes the plan to `docs/issues.md`
  (approach, build waves, coverage of every requirement, module, flow,
  entity, screen and stack decision) with one self-contained issue per file in
  `docs/issues/<key>.md`. Each issue copies in, word for word, every item it
  needs (requirements, architecture, stack, design with all screen states,
  glossary, ADRs), plus acceptance criteria with falsifiers, required tests,
  out of scope, assumptions, and the build rules in `principles.md` (YAGNI,
  use what exists, no speculative layers or options, no dead code), so the
  implementer asks nothing and builds only what is asked. A YAGNI sweep applies
  the same rules to the plan, and both the sweep and every issue call for the
  third-party `ponytail` skill when it is installed (not vendored; link
  `~/.agents/skills/ponytail` into `~/.claude/skills` and `~/.claude-work/skills`
  to make it available to Claude Code), and a sub-agent given only the issue files must
  find nothing left to ask. It then creates them on GitHub with `gh` (an
  epic, sub-issues, native blocked-by links, a hidden key marker so a re-run
  never duplicates). Gaps are built to the simplest assumption and reported at
  the end. `/issues sync` carries a later document change to open issues.
  `/issues qa` files the open `/qa` findings the same way (labels `qa`, and
  `needs-decision` for a finding that is a gap in a document: a stub issue
  that `/issues sync` completes once the stage is grilled). Every QA issue
  opens with a **Raised by QA** section: the run, finding, kind (missing test,
  weak test, defect, flake, skipped test, document gap), where, and whether to
  build it or decide it first. `/issues` adds each issue's row to
  `docs/progress.md`.
  Writes no code and edits no other stage's file. Claude Code only.

- `implement` — `/implement`: builds the GitHub issues one at a time in plan
  order (`docs/issues.md`): picks the first open issue whose blockers are
  done, branches `issue/<n>-<slug>` from `origin/<default>`, builds it test
  first, criterion by criterion, in small commits through `commit`, runs the
  tests, lint and build, checks its own diff against the issue (scope, YAGNI
  rules, architecture), and stops with a hand-off and a ready PR description.
  It never pushes, opens the PR, merges or starts the next issue: the user
  reviews, raises the PR and merges by hand, then runs `/implement` again.
  With review findings on the branch (`/implement fix`) it fixes them and
  stops again. State is tracked in `docs/progress.md` (key, GitHub number,
  kind, state, branch, PR), read first on every run: `done` rows are final and
  cost no GitHub call; only in-flight rows are checked against git and GitHub,
  since the user merges by hand; a lost file is rebuilt from them. Local
  state, never staged. An issue labelled `needs-decision` (a QA finding that
  is a gap in a document) is never built: when it comes up in plan order
  `/implement` asks the user the questions itself, then hands over the
  pre-filled `/<stage>` command with their answers, `/grill-<stage>`, and
  `/issues sync`. Claude Code only.
- `review-code` — `/review-code` (Claude Code) and `$review-code` (Codex):
  an independent review of an issue branch, by a different model from the one
  that wrote it. Checks the diff against the issue's acceptance criteria,
  scope, build rules, architecture, stack, design, tests, correctness and
  security, runs the issue's own test, lint and build commands, and appends
  ranked findings (same severities and verdicts as the stage reviews, prefix
  `CR`) to `docs/review/code/<key>-review.md`. Reviews from several models
  share one report, with `Also found by` and `Disputed by` lines. Never edits
  code, pushes or comments on a PR; `/implement` fixes the findings. Same
  mechanics as the stage reviews; change one, change the other four.
- `qa` — `/qa`: a whole-app test audit on the merged default branch, after
  some or all issues are done. Builds a coverage matrix (every `R`, `C`, `N`,
  `F` failure step, `B`, `J` across issues, screen state, entity, concern and
  assumption against the test that covers it, read for whether it could fail),
  runs the project's own test command twice (flakes), lint, type check and
  build, and appends ranked findings (prefix `QA`, same severities and
  verdicts as `review-code`) to `docs/review/qa-report.md`. Each finding names
  its route: `issue`, a stage command, or `manual`. Items whose
  issues are not done are `not yet built`, so it doubles as a progress check.
  Never starts the app, a server or a browser (so screens and live requests
  are `not judged`, with the manual check to do), never edits code. Reports
  from several models share one report (`Also found by`, `Disputed by`). Same
  mechanics as `review-code`; change one, change the other. Available in both
  Claude Code and Codex (`$qa`); Codex labels `/issues qa` and `/implement`
  as Claude Code handoffs and files no issues.
- `release` — `/release [version]`: the last gate, from files and GitHub only.
  Checks every issue done, everything in the coverage table built, `/qa`
  ready on the current default-branch commit, code reviews clear, stage
  documents settled and unstale, CI green on the commit, the suite, build and
  audit passing, no secrets. Rewrites `docs/release.md` with the verdict
  (`ready`, `ready with warnings`, `not ready`), what the user is accepting
  (not built, assumed, open points, known limits), a manual-check list, the
  deploy steps issue 0 recorded, draft release notes, and the tag and
  `gh release` commands for the user to run. Never tags, pushes, deploys or
  publishes. Claude Code only.

Every Claude Code skill above ends in an `## Advisor` section: where, if an
advisor is on (`/advisor`), the skill consults it (the reviews before writing
the verdict; the proposals before writing the document; the grills before the
first round and the confirm round; `commit` only when it splits). The advisor is set
with `/advisor claude-opus-5-5` or `"advisorModel": "claude-opus-5-5"` in each
account's `settings.json`, which this repo does not hold. It is picked by model
only, so there is no advisor effort setting, and Claude decides when to call it:
the skills can name the point but not force the call. The Codex counterparts
have no advisor and need none.

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
`ponytail` (third-party, DietrichGebert/ponytail) is installed like `archify`
(`npx skills add DietrichGebert/ponytail -g --skill ponytail`) and linked from
`~/.agents/skills/ponytail` into `~/.claude/skills` and `~/.claude-work/skills`
for the `issues` skill; do not vendor it.

`archify` (third-party, tt-a1i/archify) is **not** vendored here. Install it
with `npx skills add tt-a1i/archify -g`; it lands in `~/.agents/skills/archify`
and is symlinked into the Cursor, Gemini, and Claude Code skill dirs. Do not copy its Node
sources into `skills/` — the installer owns updates.

The skill directory was otherwise cleared on 2026-09-19 to start over; the old
set is described in `SKILLS.md` at the repo root (also in git history). List
new skills here.

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
