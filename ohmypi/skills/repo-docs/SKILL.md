---
name: repo-docs
description: >
  Generate or refresh paired twin documentation for any repository — not only
  JS/TS monorepos. One technical document under docs/architecture/ and one
  plain-English companion with the same number under docs/plain-english/.
  Incremental by default (pairs whose code changed since the stored baseline)
  or a full sweep. Use when the user says "repo docs", "generate the docs",
  "twin docs for this repo", "document this Python/Go/Rust/dotfiles repo",
  or invokes /repo-docs. Do not use on a repo that already runs docs-twins
  with a monorepo mapping; leave that skill alone.
argument-hint: "[full | since <ref> | <doc numbers, e.g. 01 04>]"
---

# repo-docs: twin docs for any repo

Same job as `docs-twins`: every numbered document exists twice, both true to
the code and true to each other. This skill does **not** assume `apps/`,
`packages/`, pnpm, or Turbo. The path → pair table lives **in the repo**.

| Where                             | For                                         |
| --------------------------------- | ------------------------------------------- |
| `docs/architecture/NN-<slug>.md`  | engineers — exact, cited, blunt about debt  |
| `docs/plain-english/NN-<slug>.md` | everyone else — same subject, everyday words |

Same number = same subject. Neither is a summary of the other.

**Never commit.** Report and stop; the user runs `/skill:commit` when happy.
**Never edit `docs-twins`.** That skill stays as-is for the repos it already
serves.

If this repo already has a `docs-twins` mapping (pairs plus a
`docs-baseline:` and a skill-local path table you must not copy here), stop
and say to run `docs-twins` instead.

## Step 1 — baseline and what changed

```bash
git rev-parse HEAD
grep -o 'docs-baseline: [0-9a-f]\{7,40\}' docs/README.md
```

Capture `HEAD` **now**. That sha is what this sweep covers.

The baseline is the `docs-baseline:` marker under `## Freshness` in
`docs/README.md`. Never re-derive it from `git log -- docs/`: a typo fix in
the docs would bury undocumented code.

Diff code, not docs:

```bash
git diff --name-only <baseline-sha>..HEAD \
  -- . ':(exclude)docs/' ':(exclude)*.lock' ':(exclude)package-lock.json' \
  ':(exclude)pnpm-lock.yaml' ':(exclude)Cargo.lock' ':(exclude)go.sum' \
  ':(exclude)poetry.lock' ':(exclude)uv.lock' ':(exclude)yarn.lock'
```

- No marker, and no `docs/architecture/` yet → **bootstrap**. Full sweep.
  There is no baseline to diff against.
- Marker missing but pairs exist → derive with
  `git log -1 --format='%h %ad %s' --date=short -- docs/architecture docs/plain-english`,
  say it is a guess, then diff.
- Diff empty and not `full` / not named numbers → docs are current. Stop.
- User said `full` or named numbers → skip the diff; use that scope.

Glance at `git log --oneline <sha>..HEAD` when the diff is large — subjects
are the intent the docs must capture.

## Step 2 — map files to pair numbers

Read `## Mapping` in `docs/README.md`. That table is this repo's only map.
A file may feed several pairs.

No mapping yet (bootstrap, or a new kind of tree) → **discover**, write the
table, then continue.

### Discover

Ignore: `.git`, `node_modules`, `target`, `dist`, `build`, `vendor`, `.venv`,
`venv`, `__pycache__`, `.tox`, `.mypy_cache`, coverage output, generated
bundles.

Carve **few** areas (prefer 3–8, not one pair per file):

1. **Root manifests** — `go.mod`, `Cargo.toml`, `pyproject.toml`,
   `package.json`, `Makefile`, this repo's layout README → usually pair **01**
   (how the project is put together).
2. **Each significant top-level directory with source** — `src/`, `cmd/`,
   `internal/`, `pkg/`, `zsh/`, `tmux/`, `crates/foo/`, a Python package dir.
   One pair per directory unless two dirs are clearly one concern.
3. **Build and CI** — `.github/`, `Dockerfile`, `Makefile` targets, release
   scripts. Own pair if there is real content; otherwise fold into 01.
4. **Tests** — `tests/`, `testdata/`, `*_test.go`, `*_spec.rb`, `benches/`.
   Own pair if they are a layer; otherwise the owning area's §8.
5. **Config a human edits** — `*.toml` besides the root manifest, `*.yml` CI
   already claimed, `config/`, `*.conf`, shell rc files. Fold into the area
   that reads them unless they are the product.

Language is a hint, not a schema:

- **Python** — package under `src/` or the import root; `tests/`; `pyproject.toml`.
- **Go** — `cmd/`, `internal/`, `pkg/` or the module root `.go` files; `go.mod`.
- **Rust** — each workspace crate, or `src/` for a single crate; `Cargo.toml`.
- **Dotfiles / .files** — one pair per tool directory (`zsh`, `tmux`, `ghostty`,
  `ohmypi`, …); 01 is the repo layout.

Tiny tree: merge. Do not invent twelve pairs for a 400-line CLI.

A path no row claims is a decision: add it to an existing pair, or open the
next number (append-only — never renumber). Write that into `## Mapping`.

## Step 3 — one subagent per pair

Each pair is independent. Fan out in one batch. One agent owns **both files
of one number**.

If this host cannot dispatch, walk the pairs yourself under the same
contract — still one pair at a time, both files, then the next.

Batch context:

```
# Goal
Refresh twin documentation after code changes. Any language, any layout.

# Constraints
- Read the real code before writing. Mark anything not directly observed [INFERENCE].
- Touch ONLY your own two files. Never edit docs/README.md,
  docs/architecture/README.md or docs/plain-english/README.md — the parent owns
  shared files.
- Do not run the test or build suite. Do not commit.
- Wrap both files at 100 columns.

# Contract
Architecture: docs/architecture/NN-<slug>.md — ten-section skeleton from the
repo-docs architecture template; opens with a `> **Plain English:**` pointer.
Plain-English: docs/plain-english/NN-<slug>.md — opens with
`**Twin of:** [<title>](../architecture/NN-<slug>.md)`.
```

Per-task text:

```
# Target
docs/architecture/NN-<slug>.md and docs/plain-english/NN-<pe-slug>.md. Nothing else.
IS_NEW: <true|false>

# Change
These files changed (or, on bootstrap, these paths are this area):
<paths>

Read them and the modules around them. Bring both documents in line with the
code: inventory, flows, contracts, config, tests, debt. Delete claims that
are no longer true. Keep structure and voice.

# Acceptance
Both files describe the current code. Every path and symbol named exists.
The plain-English twin names no framework API and no source paths — only
files or settings a non-engineer may edit (rc files, Cargo features as
names, pyproject keys, config.toml, …).
```

On bootstrap, `IS_NEW` is true for every pair. The writer fills
[architecture-template.md](architecture-template.md). The plain-English slug
may be a metaphor; the architecture slug stays the area name.

## Step 4 — parent owns the shared files

Only the parent edits:

- `docs/README.md` — area table, blurbs, `## Mapping`, `docs-baseline:` under
  `## Freshness`
- `docs/architecture/README.md` — document table, short system paragraph
- `docs/plain-english/README.md` — twin mapping table

On bootstrap, create all three if missing. Seed `docs/README.md` from
[readme-seed.md](readme-seed.md), then fill the area table and `## Mapping`.

## Step 5 — verify, then stamp

```bash
ls docs/architecture/[0-9][0-9]-*.md | wc -l
ls docs/plain-english/[0-9][0-9]-*.md | wc -l

grep -l 'plain-english/' docs/architecture/[0-9][0-9]-*.md | wc -l
grep -l '\.\./architecture/' docs/plain-english/[0-9][0-9]-*.md | wc -l
```

Counts must match. Then resolve relative links (Python, stdlib only):

```bash
python3 - <<'EOF'
import os, re
bad = 0
roots = ['.', 'docs', 'docs/architecture', 'docs/plain-english']
for d in roots:
    if not os.path.isdir(d) and d != '.':
        continue
    names = ['README.md'] if d == '.' else sorted(os.listdir(d))
    for f in names:
        p = os.path.join(d, f)
        if not p.endswith('.md') or not os.path.isfile(p):
            continue
        for m in re.finditer(r'\]\(([^)#\s]+)', open(p).read()):
            link = m.group(1)
            if link.startswith(('http', 'mailto:')):
                continue
            if not os.path.exists(os.path.normpath(os.path.join(d, link))):
                print('BROKEN', p, '->', link); bad += 1
print('OK' if not bad else f'{bad} broken')
EOF
```

Format only if a formatter is already how this repo writes markdown. Do not
introduce pnpm/prettier to a Go or Python tree.

Stamp `docs-baseline:` with the sha from step 1, **only** when every pair the
diff (or the bootstrap) required was actually checked. Skip the stamp — and
say so — on a scoped run, a failed writer, or a pair left stale.

Spot-check one older pair against its code each sweep.

Report: pairs touched, what changed in each, baseline old → new or skipped,
nothing committed.

## Architecture document

Ten sections, in order — see [architecture-template.md](architecture-template.md).

- Cite repo-relative paths. Symbols beat line numbers.
- §9 is blunt. Never soften a trap that is still true.
- §8 states what is *not* covered.
- `[INFERENCE]` on unobserved claims. Mermaid when a diagram beats a paragraph.

## Plain-English twin

- Opens with `**Twin of:** [<Architecture title>](../architecture/NN-<slug>.md)`.
- Ordinary words, for someone who does not write code.
- Banned: framework and library names, hooks, type names, function names,
  paths under `src/`, `internal/`, `pkg/`, `crates/`, "how to use this
  document", audience-routing tables.
- Kept: what a non-engineer may touch — rc files, `config.toml`, feature
  names, ports, persona codes, theme files.
- One metaphor per document, held consistently.
- Honest: if CI runs no tests, the twin says so. Marketing voice has failed.
- Roughly 60–100 lines.

## Edge cases

- **Area deleted** → delete both files, remove rows from all three indexes and
  from `## Mapping`. Retire the number; never reuse it.
- **Only tests changed** → usually the tests pair only, plus §8 of the owner
  if the map says so.
- **Standalone docs** (`docs/workflow.md`, a product spec) are not pairs.
  Leave them unless the user named them.
- **Subject drifted** (one number now covers two things) → say so and propose
  a split. Do not silently renumber.
- **Host forbids the test/build suite** — do not run it. Architecture §8 is
  read from test files on disk.

## Not this skill's job

Committing, pushing, generating language API reference (godoc, rustdoc,
Sphinx, TypeDoc), or writing product code. Auditing claims the code no
longer has, when nothing in the diff pointed at that doc, is `docs-verify`
where that skill exists — this skill only follows change (or a requested
full sweep).