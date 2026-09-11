---
name: repo-docs
description: Generate or refresh area documentation for any repository structure, not just monorepos. Uses a stored baseline to diff only what changed since docs were last generated. Never commits.
---

# repo-docs

Generate or refresh area documentation for **any** repository structure. Uses a stored baseline SHA to diff only what changed since the docs were last generated, then updates the affected area documents.

This skill is the generic sibling of `docs-twins`. It produces one document per area under `docs/areas/`, not paired architecture/plain-English docs.

## When to use

The user says "update the repo docs", "refresh docs", "generate docs for this repo", or invokes `/skill:repo-docs`.

## Do this

1. Capture `HEAD` SHA now.
2. Find or create `docs/README.md` with a `docs-baseline:` marker.
3. Diff changed files since that baseline.
4. Map changed files to areas using auto-detection.
5. Dispatch one `repo-docs-writer` per affected area.
6. Update the baseline marker to the captured SHA if every touched area was checked.
7. Verify counts and links.
8. Report and stop. Do not commit.

## Step 1 — capture HEAD

```bash
git rev-parse HEAD
```

Save this SHA. It is the baseline for the next run.

## Step 2 — find or create the baseline marker

```bash
grep 'docs-baseline:' docs/README.md
```

- If the marker exists, read the SHA.
- If `docs/README.md` does not exist or has no marker, create it with:

  ```markdown
  # Documentation

  Area docs live under `docs/areas/`.

  ## Freshness

  docs-baseline: <HEAD-sha-from-step-1>

  Last sweep: <date>
  ```

  In this bootstrap case, the next step diff will be empty because the baseline is the current HEAD. That is fine: the user can ask for a `full` sweep, or the next commit will trigger incremental work.

## Step 3 — find changed files

```bash
git diff --name-only <baseline-sha>..HEAD
```

- No output and not a `full` request → docs are current. Report that and stop.
- User asked for `full` or named specific areas → skip the diff and use that scope.

## Step 4 — map files to areas

Auto-detect areas using this ladder, applied to each changed path:

1. **Explicit mapping file** — if `docs/areas.yaml` or `docs/areas.json` exists, use it. Map paths by matching globs or directories listed there.
2. **Top-level directory** — `web/`, `api/`, `infra/`, `packages/foo/`, `src/`, etc. become `web`, `api`, `infra`, `foo`, `src`.
3. **Language/role heuristics** — group by extension or convention when there is no top-level directory:
   - `.py` → `python`
   - `.ts`, `.tsx`, `.js` → `typescript`
   - `.tf`, `.hcl` → `infrastructure`
   - `.md` outside `docs/` → `docs` (but do not include `docs/areas/*` itself)
   - `.sh`, `.zsh`, `.bash` → `shell`
   - `.yml`, `.yaml` (excluding lockfiles) → `config`
   - `Makefile`, `Dockerfile`, `.dockerignore` → `build`
4. **Fallback** — if a path matches none of the above, put it in `misc`.

A file can belong to only one area. If a mapping file conflicts with heuristics, the mapping file wins.

Extend `docs/areas.yaml` whenever a new top-level area appears. Example:

```yaml
areas:
  web:
    - apps/web/**
    - packages/ui/**
  api:
    - apps/api/**
    - packages/api/**
  infra:
    - terraform/**
    - "*.tf"
```

## Step 5 — dispatch one writer per area

For each affected area, build one `repo-docs-writer` task:

```json
{
  "context": "Refresh area documentation after code changes. Do not commit. Touch only the assigned document.",
  "tasks": [
    {
      "agent": "repo-docs-writer",
      "name": "Docs-<area>",
      "task": "AREA_NAME: <area>\nAREA_PATHS:\n<changed paths for this area, one per line>\nREPO_ROOT: <absolute repo root>\nDOC_PATH: docs/areas/<area>.md\nIS_NEW: <true|false>"
    }
  ]
}
```

`IS_NEW` is `true` if `docs/areas/<area>.md` does not exist.

Fan out all tasks in a single batch. Each writer owns exactly one document.

## Step 6 — update the baseline marker

If the run covered every area the diff touched (i.e., no writer failed and no area was skipped), update the marker:

```bash
sed -i '' "s/docs-baseline: [0-9a-f]\{7,40\}/docs-baseline: <sha-from-step-1>/" docs/README.md
```

Also update the human-readable "Last sweep" line.

Skip this step if:
- the run was scoped to specific areas,
- a writer failed,
- an area was left knowingly stale.

Say so in the report.

## Step 7 — verify

```bash
ls docs/areas/*.md | wc -l
```

Spot-check one older area per sweep by reading it against its code. A stored baseline only guarantees the docs were checked against code up to that point; it cannot catch a document that was wrong when written.

If `prettier` is available and there are markdown files under `docs/`:

```bash
pnpm exec prettier --write "docs/**/*.md" 2>/dev/null || npx prettier --write "docs/**/*.md" 2>/dev/null || true
```

Do not fail the skill if formatting is unavailable.

## Step 8 — report

Report:
- baseline old → new (or "bootstrap" / "unchanged")
- areas touched, and for each: created/refreshed/unchanged and the key change
- any failed or skipped areas
- whether the baseline was advanced
- reminder that the user runs `/skill:commit` when happy

## Edge cases

- **No `docs/` directory** → create it and the baseline README. Treat as bootstrap.
- **No diff and not `full`** → docs are current. Stop.
- **Writer fails** → do not advance the baseline. Report the failure and which area is stale.
- **Area deleted** → if every path mapped to an area was deleted, mark the doc with a note in the inventory and report it. Do not delete the doc silently.
- **New top-level directory appears** → add it as a new area doc, add a row to `docs/areas.yaml` if you created one, and include it in the report.

## Not this skill's job

- Committing, pushing, or opening PRs. The user runs `/skill:commit` when ready.
- Generating API reference docs (TypeDoc, JSDoc, Sphinx). Use the repo's own tooling for that.
- Paired plain-English docs. Use `docs-twins` for that.
