# generate

Refresh architecture pages (and twins if on) for code that changed since
the stored baseline. Then stage and commit per SKILL.md.

## Step 1 — HEAD, pin, baseline

```sh
git rev-parse HEAD
```

Capture that sha **now**. That is what this sweep covers. Uncommitted
files are out of scope. If the tree is dirty, say so; do not document
the dirty files.

Read `docs/README.md`: `plain-english:`, `docs-baseline:`, `## Mapping`.
Resolve the twins toggle per SKILL.md.

```sh
git diff --name-only <baseline-sha>..HEAD \
  -- . ':(exclude)docs/' ':(exclude)*.lock' ':(exclude)package-lock.json' \
  ':(exclude)pnpm-lock.yaml' ':(exclude)Cargo.lock' ':(exclude)go.sum' \
  ':(exclude)poetry.lock' ':(exclude)uv.lock' ':(exclude)yarn.lock'
```

- No marker and no `docs/architecture/NN-*.md` → **bootstrap**. Full
  sweep. There is no baseline to diff against.
- Marker missing but pages exist → derive with
  `git log -1 --format='%h' -- docs/architecture`, say it is a guess,
  then diff.
- Diff empty and not `full` / not named numbers → docs are current.
  Stop. Do not rewrite. Do not commit.
- User said `full` or named numbers → skip the diff; use that scope.
- User said `since <ref>` → diff that ref instead of the stored
  baseline. Do not stamp the stored baseline unless `<ref>` **is** that
  baseline (or this is a full sweep that covered every mapped page).

Glance at `git log --oneline <sha>..HEAD` when the diff is large.

## Step 2 — map paths to numbers

Read `## Mapping`. A file may feed several numbers.

No mapping (bootstrap, or a new kind of tree) → **discover**, write the
table, then continue.

Ignore: `.git`, `node_modules`, `target`, `dist`, `build`, `vendor`,
`.venv`, `venv`, `__pycache__`, coverage, generated bundles.

Carve **few** areas (prefer 3–8):

1. Root manifests and layout README → usually `01`.
2. Each significant top-level source directory → one number, unless two
   dirs are clearly one concern.
3. Build/CI — own number if there is real content; else fold into `01`.
4. Tests — own number if they are a layer; else the owner page's Tests
   section.
5. Config a human edits — fold into the area that reads it unless the
   config **is** the product.

Tiny tree: merge. Do not invent twelve pages for a small CLI.

A path no row claims: add it to an existing number, or open the next
number (append-only). Write that into `## Mapping`. Do not ignore it
and stamp anyway.

## Step 3 — write each stale page

Walk the stale numbers yourself (one number at a time). Do not spawn
`planner` / `hand`. Do not require subagents.

Each number:

- Read the real files at **HEAD** before writing.
- Architecture: `docs/architecture/NN-<slug>.md` from
  [architecture-template.md](architecture-template.md). Ten sections in
  that order. Empty section = one honest line, not padding. Cite
  repo-relative paths. Symbols beat line numbers. `[INFERENCE]` on
  unobserved claims. Wrap at 100 columns.
- Twins **on**: also `docs/plain-english/NN-<slug>.md`. Ordinary words.
  Banned: framework/library names, hooks, type names, function names,
  paths under `src/`, `internal/`, `pkg/`, `crates/`. Kept: rc files,
  config keys, ports, names a non-engineer may edit. One metaphor,
  held. Honest about missing tests. Roughly 60–100 lines. Opens with
  `**Twin of:**`.
- Twins **off**: do not write or refresh PE files.
- `IS_NEW` on bootstrap: fill the template. Architecture slug stays the
  area name.

Delete claims that are no longer true. Keep structure and voice on
edits.

## Step 4 — parent owns the indexes

Only this generate run edits:

- `docs/README.md` — area table, blurbs, `## Mapping`, `plain-english:`,
  `docs-baseline:` under `## Freshness`
- `docs/architecture/README.md` — document table
- `docs/plain-english/README.md` — only if twins are on this run

On bootstrap, create the indexes if missing. Seed `docs/README.md` from
[readme-seed.md](readme-seed.md), then fill the area table and mapping.

When twins are off, the area table is architecture-only (no PE column).

## Step 5 — check, then stamp

Run:

```sh
python3 <this-skill>/scripts/check-paths.py .
python3 <this-skill>/scripts/self_check.py
```

Self-check is for when you changed the script. If you did not, skip it.

If twins are on, architecture `NN-*.md` count must equal PE `NN-*.md`
count, and each architecture file must point at its twin.

Stamp `docs-baseline:` with the sha from step 1 **only** when every
number the diff (or the bootstrap, or `full`) required was actually
written. Skip the stamp — and say so — on a numbered/scoped run, a
failed page, or a path left unmapped.

Then stage and commit per SKILL.md.

## Edge cases

- Area deleted → delete architecture (and twin if it exists), drop rows,
  retire the number.
- Only tests changed → usually that area's Tests section, plus a tests
  number if the map has one.
- Standalone docs (`docs/workflow.md`, product specs) are not numbered
  pages. Leave them unless the user named them.
- Subject drifted (one number now covers two things) → say so and
  propose a split. Do not silently renumber.
