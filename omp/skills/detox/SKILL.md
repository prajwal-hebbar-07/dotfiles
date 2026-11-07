---
name: detox
description: Audit the OMP setup in five parts (sessions and storage, memory and context files, skills and agents, MCP servers, scheduled jobs and models) with five read-only subagents, serve one local HTML checklist of suggested fixes with token savings, and change nothing until the user ticks items, clicks Begin optimizing, types go and confirms.
disable-model-invocation: true
---

# detox

Invoke explicitly:

- `/skill:detox [active folders]` — audit, serve the checklist, apply what the
  user approves, then offer a two-weekly audit.
- `/skill:detox audit` — unattended audit only: writes the findings and a
  notification, serves nothing, changes nothing. The schedule runs this.
- `/skill:detox review` — serve the newest unreviewed findings and continue
  from Step 4.

## Never

- Do only what the request needs. Apply only ticked items, with the chosen
  action, within that item's target. A comment refines how its item is done;
  a comment asking for something beyond the item is named in the report, not
  done.
- Never ask what is already settled: active folders given in the invocation
  or saved in `state.json`, a schedule already installed or declined, and
  anything the files, settings or session history answer.
- Change, move or delete anything before the user has submitted decisions,
  typed `go` and confirmed the listed changes. The audit is read-only.
- Delete permanently unless the ticked action is `delete`. Every other
  removal is a move into the run's `archive/`; every edited file is copied to
  the run's `backup/` first.
- Print, copy into findings, or log secret values (tokens, keys, cookies in
  MCP or settings files). Name the file and key only.
- Commit or push. Changes inside a git repository are left uncommitted.
- Use `cfg://` writes; settings change through `omp config set`.

## Paths

- `<agentDir>`: `$PI_CODING_AGENT_DIR`, else `~/.omp/profiles/<profile>/agent`
  under an active profile, else `~/.omp/agent`.
- `<detox>` = `<agentDir>/detox/`:
  - `state.json` — `{"activeFolders": [...], "mainFolder": "...", "schedule":
    "launchd" | "cron" | "declined" | null, "pendingReview": "<run>" | null}`
  - `<run>/` = `<detox>/<YYYY-MM-DD>/` (suffix `-2`, `-3` if it exists):
    `findings.json`, `decisions.json`, `applied.md`, `archive/`, `backup/`.
    `archive/` and `backup/` mirror absolute paths
    (`<run>/archive/Users/me/.omp/agent/skills/foo/`).
- `<skill dir>`: this skill's directory (the `[Skill directory: …]` line of
  the invocation, else `realpath skill://detox` in bash). It holds
  `serve.py` and `checklist.html`.

## Step 1 — scope

1. Active folders: from the invocation, else `state.json`, else ask once:
   "Which folders are your active ones?" (offer the five most recent projects
   from `archive.projects(limit=10)` in Eval as options). The main folder is
   the current working directory unless the answer names one. Save both to
   `state.json`.
2. `audit` mode with no saved folders: stop and say to run `/skill:detox`
   once interactively.
3. `review` mode: take `pendingReview` from `state.json`, else the newest run
   with `findings.json` and no `applied.md`. None: say so and stop. Otherwise
   go to Step 3, item 3.

## Step 2 — audit with five subagents

Spawn the five sections below in one `task` batch. Each subagent is read-only:
it may run read-only commands and read files, never edit, move, install or
log in. Pass in shared context: today's date, `<agentDir>`, active folders,
the main folder, the 30-day window, and the rules below. Each returns one
section object as JSON in its final answer.

Section object:

```json
{
  "id": "skills",
  "title": "Skills and agents",
  "summary": "one sentence on what was checked and the overall state",
  "unavailable": "optional: what could not be checked and why",
  "items": [
    {
      "id": "skills-1",
      "title": "short imperative: Hide commit from the model catalog",
      "detail": "evidence: counts, dates, paths, and why it matters; ≤ 2 sentences",
      "target": "absolute path, setting key, server or job name",
      "actions": ["hide", "archive", "delete"],
      "action": "hide",
      "change": "exact edit or command the action performs",
      "tokens": 212,
      "risk": "low",
      "manual": false
    }
  ]
}
```

Rules for every subagent:

- Every item carries evidence observed this run. No evidence, no item. At
  most 15 items per section, worst first; group similar targets (all temp-dir
  sessions of one project) into one item.
- `tokens`: tokens the change removes from every new session's context,
  measured with `omp toks <file-or-text> --json` (`claude-v5` encoding).
  Content that is not loaded into context (session files, disk) is `0`; put
  sizes in `detail`.
- `risk`: `high` when the change can lose work or break a workflow, `medium`
  when it changes behavior, `low` otherwise. `manual: true` when only the user
  can do it (a login, an OAuth reauth); `change` then holds the steps.
- Usage counts come from session history: Eval `archive.sessions`,
  `archive.prompts` and `archive.recaps` with `project="*"`, and counted
  matches in session files `<agentDir>/sessions/<cwd-slug>/*.jsonl` (first
  records: `title`, then `session` with `cwd`; subagent transcripts sit in
  the sibling directory of the same name). Count matches mechanically; never
  read whole transcripts into context.
- A target that is a symlink: report the link and its real path. If the real
  path is in a git repository, say so in `detail`; actions then change the
  repository copy.
- Secrets: name the file and key, never the value.

### sessions — Sessions and storage

- Test and one-off sessions (≤ 2 user turns, test-like titles), sessions whose
  `cwd` is a temporary directory or no longer exists, untitled sessions, and
  projects outside the active folders with no session in 90 days. Actions:
  `archive`, `delete`.
- Storage: `omp gc --json` (dry run) for unreferenced blobs, cold sessions,
  WAL size; sizes of `blobs/`, `terminal-sessions/`, `logs/`, `cache/`.
  Action `gc` with `change` naming the `omp gc --apply` flags.
- Customizations: plugins (`omp plugin list`), extensions and hooks in
  `<agentDir>` and the active folders' `.omp/`, theme and keybinding files;
  flag broken, unused or duplicated ones. Extensions that add tools cost
  tokens. Actions: `disable`, `archive`, `delete`.

### context — Memory and context files

- User level: `<agentDir>/AGENTS.md`, `RULES.md`, `rules/*.md`, `SYSTEM.md`,
  `APPEND_SYSTEM.md`, `contextFiles.extra` names, and foreign user context
  files only when `omp config get enabledProviders` opts them in. Memory:
  `omp config get memory.backend`; with `local`, read `memory://root` and
  `memory://root/learned.md`.
- Active folders: `AGENTS.md`, `CLAUDE.md`, `.omp/AGENTS.md`,
  `.omp/RULES.md`, `.claude/CLAUDE.md`, their `@` imports and local links.
- Check against the last 30 days of prompts and recaps: rules the user keeps
  overriding (outdated or conflicting), instructions the user keeps typing
  (missing rule), rules naming paths, commands, skills or tools that no
  longer exist (outdated), the same rule in two files that both load
  (duplicate), contradictory rules (conflicting), broken `@` imports or links,
  and active git repositories with no context file (missing). `RULES.md` and
  always-apply rules ride on every request; flag bulk there.
- Actions: `edit` (`change` = exact text removed or replaced), `move` (to
  another file or a conditional rule), `create` (`change` = a short outline
  from the repository's manifests and layout), `delete`.

### skills — Skills and agents

- Every discovered skill: `omp skill list --json` (name, path, source,
  hidden). Task agents: `<agentDir>/agents/*.md`, the active folders'
  `.omp/agents/`.
- Usage in 30 and 90 days: `/skill:<name>` and `skill://<name>` in session
  files; agents: `"agent":"<name>"` in task calls.
- Flags: unused, overlapping (two skills or agents doing the same job),
  likely to fire by accident (model-invocable with a broad description, or
  read in sessions whose prompt did not ask for it), catalog cost (the
  description of each non-hidden skill is in every session's prompt; hidden
  ones cost 0), collisions and namespaced duplicates, broken links, missing
  descriptions.
- Actions: `hide` (add to `skills.manualSkills`: stays invocable, leaves the
  catalog), `disable` (add to `skills.ignoredSkills`), `edit-description`,
  `archive`, `delete`.

### mcp — MCP servers

- Sources: `<agentDir>/mcp.json`, the active folders' `.omp/mcp.json`,
  `mcp.json` and `.mcp.json`, and the other tools' configs OMP imports (see
  `omp://mcp-config.md`), minus `disabledServers`.
- Usage in 30 days: calls to `mcp__<server>_*` tools and writes to
  `xd://mcp__<server>_*` in session files.
- Flags: unused, duplicates (same command or URL under two names or
  sources), failing or expired logins (errors per server in
  `<agentDir>/../logs` and `<agentDir>/logs` in 30 days), risky write access
  (tools that delete, send, publish or pay; broad filesystem roots; secrets
  stored inline), a CLI already on `PATH` that covers the same job, and the
  context cost of server instructions and tool schemas (estimate from what
  the server exposes; say it is an estimate).
- Actions: `disable` (`enabled: false` in an OMP-owned file, else add to the
  user `disabledServers`), `instructions-off` (`"instructions": false`),
  `remove`, `reauth` (manual: `/mcp reauth <name>`), `move-secret` (to an
  environment variable reference).

### jobs — Scheduled jobs and models

- Scheduled: `~/Library/LaunchAgents/*.plist` and `launchctl list` (macOS),
  `crontab -l`, `systemctl --user list-timers` (Linux), and `omp ps --all
  --json`; keep the ones that run `omp`, `claude`, `codex`, `gemini`,
  `cursor-agent` or a script that does. Failing ones first (non-zero last
  exit status, errors in their log files), then ones nobody needs (missing
  script or folder, folder outside the active folders, duplicates).
- Models: `omp config get modelRoles`, `model:` in task agents, `--model` in
  scheduled jobs. Flag Opus-class models on mechanical work (summaries,
  scouting, formatting) where a Sonnet- or Haiku-class model fits. A model
  pinned on purpose (documented next to it) is flagged only with evidence of
  failure.
- Actions: `remove` (unload and archive the job), `fix` (`change` = exact
  edit), `switch-model`, `stop` (`omp ps stop <name>`).

## Step 3 — build and serve the checklist

1. Create `<run>/`. Merge the five sections in the order above into
   `<run>/findings.json`: `{"generated": "<ISO time>", "activeFolders": [...],
   "sections": [...]}`. A failed subagent becomes its section with
   `unavailable` set and no items. Check it parses
   (`python3 -m json.tool <run>/findings.json`).
2. `audit` mode: set `pendingReview` to `<run>` in `state.json`, notify
   (`osascript -e 'display notification "Run /skill:detox review" with title
   "omp detox: checklist ready"'` on macOS, `notify-send` on Linux when
   present), print the run path and the item count per section, and stop.
3. Start the server as a named bash service `detox-checklist`:
   `python3 <skill dir>/serve.py <run>` with ready log `Serving http`.
4. Reply with the URL, the item count and possible tokens per section, and:
   "Tick what you want, pick the action, add comments, click Begin
   optimizing, then type go here." Stop.

## Step 4 — go

On `go` (or an equally explicit instruction to apply):

1. Read `<run>/decisions.json`. Missing: say to click Begin optimizing first
   and stop. Empty `items`: say nothing was ticked, stop the service, and
   skip to Step 6.
2. List every decision grouped by section: `id — title → action`, the
   comment if any, `manual` items marked. Then ask once with `ask`: apply
   these N changes, or cancel. Anything but an explicit yes changes nothing.

## Step 5 — apply

For each decision, in section order:

1. Re-check the item's evidence (the target exists and is unchanged since
   the audit). If it changed, skip it and say why.
2. Before editing a file, copy it to `<run>/backup/<absolute path>`.
   `archive` and `remove` move the target to `<run>/archive/<absolute path>`;
   for a symlinked skill or rule, move the repository source and delete the
   link. `delete` removes it.
3. Settings: read the current value with `omp config get <key> --json`, merge
   (arrays replace, never append implicitly), then `omp config set <key>
   <value>`. MCP enable, disable and instructions changes edit the OMP-owned
   `mcp.json` that defines the server, or the user `disabledServers`.
   Scheduled jobs: `launchctl bootout gui/$(id -u) <plist>` before moving the
   plist; cron edits go through `crontab -l` and `crontab -`.
4. `manual` items are not done; collect their steps.
5. If a changed source sits in a repository with a link script that installs
   it (for example this dotfiles repo's `omp/link-skills`), rerun that script
   so stale links are pruned.

Then write `<run>/applied.md`: one line per decision (`done`, `skipped:
<reason>` or `failed: <error>`), the tokens per session saved by the done
items, the manual steps, and how to restore (move back from `archive/`,
copy back from `backup/`). Clear `pendingReview`, and stop the
`detox-checklist` service.

Reply with the counts done/skipped/failed, tokens per session saved, the
manual steps, and the `applied.md` path. Note that context and skill changes
take effect in new sessions.

## Step 6 — schedule

Skip when `state.json` has `schedule` set. Otherwise ask once: "Run the audit
every two weeks? You then only review the checklist when it is ready."

- No: save `"schedule": "declined"`.
- Yes on macOS: write `~/Library/LaunchAgents/com.omp.detox.plist` with
  `ProgramArguments` = [absolute `omp` path, `-p`, `Read skill://detox and
  follow it with the argument: audit`], `WorkingDirectory` = main folder,
  `StartInterval` = `1209600`, `EnvironmentVariables` `PATH` = the current
  `PATH`, and `StandardOutPath`/`StandardErrorPath` = `<detox>/schedule.log`;
  `plutil -lint` it, then `launchctl bootstrap gui/$(id -u) <plist>`. Save
  `"schedule": "launchd"`.
- Yes on Linux: add `0 9 1,15 * * cd <main folder> && <omp path> -p "Read
  skill://detox and follow it with the argument: audit" >> <detox>/schedule.log
  2>&1` to the crontab. Save `"schedule": "cron"`.
