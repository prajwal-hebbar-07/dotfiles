# Oh My Pi Harness and Skills

> **Plain English:** [The Agent Workshop](../plain-english/05-ohmypi.md)

## Purpose

Provides the Oh My Pi coding harness configuration for this repository: five absolute hard
rules (sticky-injected on every agent turn), a lightweight `committer` task agent, a Paper
MCP server entry, and ten modular skills that are symlinked into three different agent
hosts (Oh My Pi, Cursor, Antigravity/agy).

## Inventory

| Path | Role |
| --- | --- |
| `ohmypi/RULES.md` | Seven hard rules, loaded as a sticky rule (`~/.omp/agent/RULES.md`). Re-injected near every turn; overrides harness-default verification workflows. |
| `ohmypi/agents/committer.md` | Task agent definition. Runs `anthropic/claude-haiku-4-5` (declared as `ollama-cloud/glm-5.3-flash` in the file; [INFERENCE] may reflect a deprecated alias), `thinking-level: minimal`, `bash` only. Writes a semantic commit from staged changes. Never stages, pushes, or appends trailers. |
| `ohmypi/mcp.json` | MCP server map. One server: `paper` — stdio, `~/.paper/bin/paper mcp`. |
| `ohmypi/skills/commit/SKILL.md` | In-session semantic commit skill. Same logic as `committer` but runs in-session without delegation. Guards identity, staged index, and trailer policy. |
| `ohmypi/skills/docs-twins/SKILL.md` | Twin documentation for monorepo layouts with a fixed `apps/`/`packages/` path table. |
| `ohmypi/skills/docs-verify/SKILL.md` | Audits doc claims against code. Delegates to `check-claims.py`. |
| `ohmypi/skills/docs-verify/scripts/check-claims.py` | 426-line Python script. Extracts backtick-cited paths, symbols, and package exports from docs; checks each against tracked files and source identifiers. Reports broken links as `BROKEN`, unknown symbols with `deliberate?` if context looks intentional. |
| `ohmypi/skills/docs-verify/scripts/self_check.py` | Self-check script for the verify skill itself. [INFERENCE: exact role not read] |
| `ohmypi/skills/follow-implementation-plan/SKILL.md` | Executes the next unfinished step of the plan, stages only that step's files, then calls `/skill:commit`. Deletes a finished plan file and starts the next remaining file in a new agent with empty history (Cursor Task, or omp `task` agent). |
| `ohmypi/skills/implement-commit-prompt/SKILL.md` | Extracts one step from the plan into a copy-pasteable prompt for a fresh chat. |
| `ohmypi/skills/implementation-plan/SKILL.md` | Writes numbered plan files under `docs/implementation-plan/` (gitignored): at most five commits each, after an architecture conversation. |
| `ohmypi/skills/implementation-plan/template.md` | Template for one five-commit plan file. |
| `ohmypi/skills/paper-target/SKILL.md` | Pins a Paper.design file/page reference into `AGENTS.md` / `CLAUDE.md` between marker comments. Uses MCP tools only; never guesses page IDs. |
| `ohmypi/skills/repo-docs/SKILL.md` | Twin documentation for any repo (not only monorepos). Reads path → pair mapping from the target repo's `docs/README.md`. Drives this very sweep. |
| `ohmypi/skills/repo-docs/architecture-template.md` | Ten-section skeleton for architecture documents. |
| `ohmypi/skills/repo-docs/readme-seed.md` | Seed content for `docs/README.md` on first bootstrap. |
| `ohmypi/skills/report-arc/SKILL.md` | Step report shape (status, done-when table, changed files, leftover unstaged, verification, next) plus a second mode to persist any such report as a page under `docs/reports/`. |
| `ohmypi/skills/report-arc/template.md` | Step report template. |
| `ohmypi/skills/report-arc/doc-template.md` | Persisted report page template. |
| `ohmypi/skills/review-implementation-plan/SKILL.md` | Reviews one plan file: splits or merges steps, reorders, strips how-to, adds missing outcomes, re-chunks past five commits. Does not implement. |

## Public surface

### Slash commands (via skill invocation)

| Command | Skill | What it does |
| --- | --- | --- |
| `/skill:commit` | `commit` | Semantic commit from staged changes, in-session |
| `/skill:repo-docs` | `repo-docs` | Twin docs bootstrap or incremental refresh |
| `/skill:docs-twins` | `docs-twins` | Twin docs for monorepo layout |
| `/skill:docs-verify` | `docs-verify` | Audit doc claims against code |
| `/skill:implementation-plan` | `implementation-plan` | Write plan files, five commits each |
| `/skill:review-implementation-plan` | `review-implementation-plan` | Review one plan file |
| `/skill:follow-implementation-plan` | `follow-implementation-plan` | Execute the plan; chain remaining files |
| `/skill:implement-commit-prompt` | `implement-commit-prompt` | Extract one plan step as a prompt |
| `/skill:report-arc` | `report-arc` | Step report or persisted report page |
| `/skill:paper-target` | `paper-target` | Pin Paper file/page in AGENTS.md |

### MCP tools (Paper Desktop)

The `paper` MCP server exposes tools for reading Paper.design documents:
`list_files`, `open_file`, `get_basic_info` — all read-only.

### RULES.md hard rules

The seven rules are enforced by sticky injection and override any harness-default instruction:

1. **No start/stop/restart of any application** — includes `open -a`, signals, window reloads.
2. **No starting the server, app, or dev command** — includes `npm run dev`, watchers, test
   suite, build suite.
3. **No opening or driving the browser tool** — including for "verification".
4. **Investigate only when asked** — implement the request and nothing else until told.
5. **No reaching for `planner` or `hand` subagents** — those run only on `/delegate`.
6. **No documents outside a skill I invoked** — creating a document in any format is
   reserved for `repo-docs`, `docs-twins`, `docs-verify`, `design-sync`, and
   `twitter-campaign`; updating an existing doc stays allowed.
7. **Never amend** — no `--amend`, rebase, reset onto an existing commit, fixup/squash, or
   force-push; corrections land as a new commit.

Permission lifts a rule only for the action explicitly named in that turn.

## Flow

```
Agent turn start
  → RULES.md injected near the top of the context (sticky rule behaviour)
  → User invokes /skill:commit
      → skill reads SKILL.md
      → checks git identity and staged index
      → reads git diff --cached
      → writes commit message (type(scope): subject + bullets)
      → git commit
      → verifies no trailer leaked
      → reports SHA, files, leftover unstaged

  → User invokes /skill:repo-docs
      → reads docs/README.md for baseline sha and mapping
      → diffs code since baseline (or full sweep on bootstrap)
      → fans out one subagent per pair
      → parent writes shared files (docs/README.md, architecture/README.md,
        plain-english/README.md)
      → verifies cross-link counts
      → stamps docs-baseline: <new sha>

  → User invokes /skill:commit → commit skill delegates to committer agent
      (alternative path — commit skill may run in-session or via task agent)
```

## Contracts and invariants

- **Hard rules override everything.** `RULES.md` is a sticky rule: it is re-attached near
  every turn, not just the first. The seven prohibitions outrank harness verification prompts.
- **No Co-Authored-By trailers.** Neither the `commit` skill nor the `committer` agent appends
  any agent/model attribution to commit messages. The `committer` agent explicitly greps for
  trailer leaks before reporting done.
- **Staged-only commits.** Neither skill ever calls `git add`. Staging is always the user's
  decision.
- **Cross-host compatible.** Skills are plain directories with a `SKILL.md`. They are
  discovered identically by Oh My Pi, Cursor (user-scope skills dir), and Antigravity (global
  skills dir). No host-specific syntax in skill content.
- **`check-claims.py` is stdlib-only.** The docs-verify script imports only `json`, `os`, `re`,
  `subprocess`, `sys` — no `pip install` required.
- **Paper MCP is read-only.** The `paper-target` skill uses `list_files`, `open_file`,
  `get_basic_info` only; it never calls a write tool.

## Configuration

| File | Location | Loaded by |
| --- | --- | --- |
| `ohmypi/RULES.md` | `~/.omp/agent/RULES.md` | Oh My Pi (sticky rule) |
| `ohmypi/mcp.json` | `~/.omp/agent/mcp.json` | Oh My Pi at startup |
| `ohmypi/skills/*/SKILL.md` | `~/.omp/agent/skills/` | Oh My Pi at dispatch |
| `ohmypi/skills/<7>/SKILL.md` | `~/.cursor/skills/` | Cursor at window reload |
| `ohmypi/skills/<5>/SKILL.md` | `~/.gemini/config/skills/` | Antigravity at startup |
| `ohmypi/agents/committer.md` | `~/.omp/agent/agents/committer.md` | Oh My Pi on dispatch |

**mcp.json schema:** `$schema` points to the Oh My Pi MCP schema. The `paper` server uses
`type: "stdio"`, `command: "${HOME}/.paper/bin/paper"`, `args: ["mcp"]`. Oh My Pi expands
`${HOME}`; other hosts require `${userHome}` or an absolute path.

**Skill host matrix:**

| Skill | omp | Cursor | agy |
| --- | --- | --- | --- |
| `commit` | ✓ | — | ✓ |
| `docs-twins` | ✓ | — | ✓ |
| `docs-verify` | ✓ | — | ✓ |
| `repo-docs` | ✓ | ✓ | ✓ |
| `implementation-plan` | ✓ | ✓ | — |
| `review-implementation-plan` | ✓ | ✓ | — |
| `follow-implementation-plan` | ✓ | ✓ | ✓ |
| `implement-commit-prompt` | ✓ | ✓ | — |
| `report-arc` | ✓ | ✓ | — |
| `paper-target` | ✓ | ✓ | — |

## Boundaries and dependencies

| Dependency | Required for |
| --- | --- |
| Oh My Pi CLI (`omp`) | Sticky rules, skill dispatch, `committer` task agent, MCP |
| Paper Desktop (`~/.paper/bin/paper`) | `paper` MCP server; `paper-target` skill |
| `anthropic/claude-haiku-4-5` (or `ollama-cloud/glm-5.3-flash`) | `committer` task agent model |
| `python3` (stdlib) | `docs-verify/scripts/check-claims.py` |
| `git` | All commit skills, docs-verify |
| Cursor | Skills linked to `~/.cursor/skills/` |
| Antigravity CLI (`agy`) | Skills linked to `~/.gemini/config/skills/` |

## Tests

`ohmypi/skills/docs-verify/scripts/check-claims.py` — run against any doc directory:

```sh
python3 ohmypi/skills/docs-verify/scripts/check-claims.py [--json] [repo-root]
```

`ohmypi/skills/docs-verify/scripts/self_check.py` — [INFERENCE: verifies the verify script
itself or its test data].

No CI pipeline. Skills are validated by invoking them manually and checking the output.

## Debt and traps

- **`${HOME}` vs `${userHome}` in `mcp.json`.** Oh My Pi expands `${HOME}`; the upstream
  Paper plugin used `${userHome}` and failed with `ENOENT … posix_spawn '${HOME}/…'`. Any
  other host that does not expand `${HOME}` will get the same error. The fix is host-specific;
  no universal form exists today.
- **Skill discovery requires restarts.** New or renamed skills are not hot-reloaded. Oh My Pi
  requires an omp restart; Cursor requires **Developer: Reload Window**; Antigravity requires
  agy restart.
- **Sticky rules block agent self-verification.** Rule 2 prevents the agent from running the
  test suite or dev server even to verify its own changes. The agent must state what is
  unverified, the command the user would run, and what success looks like.
- **`committer` model field.** The file declares `model: ollama-cloud/glm-5.3-flash`; the
  README describes it as `anthropic/claude-haiku-4-5`. At least one is inaccurate; the
  `committer.md` file value is authoritative for what omp actually sends. [INFERENCE: the
  README was written against an older version.]
- **`ponytail` plugin is not in this repo.** It is installed from the marketplace
  (`~/.omp/plugins`). Its hook format (`hooks/claude-codex-hooks.json`) is Claude/Codex
  event names that omp does not use — those hooks never run.
- **`commit` skill not linked to Cursor.** The skill dispatches an omp task agent; there is
  no equivalent in Cursor. Anyone expecting `/skill:commit` in Cursor chat will not find it.

## Change guide

- **Adding a new skill:** create `ohmypi/skills/<name>/SKILL.md`, add symlinks to the
  relevant host directories, update `AGENTS.md` skill list, and restart the affected hosts.
- **Modifying the Paper MCP entry:** edit `ohmypi/mcp.json`. Changes take effect at the
  next omp startup.
- **Modifying hard rules:** edit `ohmypi/RULES.md`. The new rules take effect in the next
  agent session (sticky rules are re-read at turn start, not once at session start —
  [INFERENCE: verify with omp release notes]).
- **Adding a new MCP server:** add an entry to `ohmypi/mcp.json` following the same `stdio`
  pattern. Update the Boundaries and dependencies section of this document.
