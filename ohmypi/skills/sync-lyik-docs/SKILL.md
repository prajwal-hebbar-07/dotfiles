---
name: sync-lyik-docs
description: >
  Mirrors the lyik_forms_v3 frontend docs (architecture and plain-English
  pages) into the lyik_docs MkDocs site under
  docs/lyik_enterprise/design/, refreshes the design README's sync line and
  chapter counts, then stages those files and runs the commit skill in the
  lyik_docs repo. Use when the user says "sync the lyik docs", "copy the
  docs to lyik_docs", "publish the design docs", or invokes /sync-lyik-docs
  or /skill:sync-lyik-docs.
argument-hint: "[force]"
disable-model-invocation: true
---

# sync-lyik-docs

One-way copy. The frontend repo owns the text; the docs site holds a mirror.

| Name | Path |
|---|---|
| `SRC` | `~/lyik/frontend/lyik_forms_v3` |
| `SRC_DOCS` | `$SRC/docs` |
| `DST` | `~/lyik/docs/lyik_docs` |
| `DST_DESIGN` | `$DST/docs/lyik_enterprise/design` |

Invoking this skill is permission to write under `DST_DESIGN/architecture/`,
`DST_DESIGN/plain-english/`, and the lines of `DST_DESIGN/README.md` named
below. Nothing else, in either repo.

## Where things go

| Source | Destination | Rule |
|---|---|---|
| `SRC_DOCS/architecture/*.md` (incl. `README.md`) | `DST_DESIGN/architecture/` | mirror |
| `SRC_DOCS/plain-english/*.md` (incl. `README.md`) | `DST_DESIGN/plain-english/` | mirror |
| `SRC_DOCS/README.md` | — | skip: the source repo's map and clock, not reader docs |
| `SRC_DOCS/architecture/diagrams/` | — | skip: Archify HTML/JSON, no page links to it, not in the MkDocs nav |
| `SRC_DOCS/implementation-plan/` | — | skip: scratch |
| — | `DST_DESIGN/extras/` | never touch: authored in lyik_docs |
| — | `DST_DESIGN/README.md` | edit only the sync line and chapter counts (step 4) |

Mirror means: the destination folder ends up with exactly the source's
`*.md` files. Pages retired in the source are deleted in the destination.
The folder layout is identical, so the relative links between
`architecture/`, `plain-english/`, and `../README.md` keep working.

## Never

- Edit the source repo, including `SRC_DOCS/README.md` or its
  `docs-baseline:`.
- Hand-edit or "fix" mirrored pages in the destination. Wrong text is fixed
  in the source (`/skill:docs`) and synced again.
- Copy `diagrams/`, `implementation-plan/`, or the source `docs/README.md`.
- Touch `DST_DESIGN/extras/`, `mkdocs.yml`, or anything outside
  `DST_DESIGN`.
- Run `mkdocs serve`/`build`, a browser, or any app.
- `git add` anything this run did not change. `git commit` yourself, or
  pass a subject to commit. Push.

## Steps

### 1. Preflight — stop on any failure

- `SRC_DOCS/architecture/` and `DST_DESIGN/` exist.
- `git -C $SRC status --porcelain -- docs` is empty. Uncommitted source
  docs would publish text no commit backs. Stop and say so.
- `git -C $DST status --porcelain` is empty and `git -C $DST diff --cached`
  is empty. Stop rather than mix the user's work into this commit.

### 2. Freshness gate

Read `<!-- docs-baseline: <sha> -->` from `SRC_DOCS/README.md`, then:

```sh
git -C $SRC diff --name-only <sha>..HEAD -- apps packages
```

Non-empty → the pages lag the code. Unless the user said `force`, stop,
list the count and the first few paths, and point at `/skill:docs`. The
design README promises the mirror was verified before every copy; do not
break that silently.

Also note each surface pin (`<!-- architecture: on|off -->`,
`<!-- plain-english: on|off -->`). An `off` surface is frozen, not deleted:
still mirror it, and say in the report it is frozen at an older sha.

### 3. Copy

```sh
rsync -a --delete --include='*.md' --exclude='*' \
  "$SRC_DOCS/architecture/" "$DST_DESIGN/architecture/"
rsync -a --delete --include='*.md' --exclude='*' \
  "$SRC_DOCS/plain-english/" "$DST_DESIGN/plain-english/"
```

`--exclude='*'` keeps `diagrams/` out; excluded destination files are not
deleted.

### 4. Update `DST_DESIGN/README.md`

Only these, nothing else in the file:

- **Sync line.** Replace the whole `**Synced from:** …` paragraph (it may
  wrap or carry a stray duplicated tail — replace through the paragraph's
  blank line) with one line built from
  `git -C $SRC log -1 --format='%h (%s, %ad)' --date=short`:
  `**Synced from:** frontend monorepo commit \`<h>\` (<subject>, <date>).`
- **Chapter counts.** Count `SRC_DOCS/architecture/[0-9][0-9]-*.md`. Update
  every "N-chapter" / "N chapters" in the file to that number.

### 5. Nav check

For every `lyik_enterprise/design/...` path in `$DST/mkdocs.yml` `nav:`,
confirm the file exists after the copy. Missing → report it; do not edit
`mkdocs.yml`.

### 6. Stage and commit — once

Skip when `git -C $DST status --porcelain` is empty: report "mirror already
current at `<h>`".

1. `git -C $DST add -- docs/lyik_enterprise/design/architecture
   docs/lyik_enterprise/design/plain-english
   docs/lyik_enterprise/design/README.md` (picks up deletions too).
2. Run the **commit** skill from `$DST`. No subject.
3. Hook failure or missing identity → stop and relay. No `--no-verify`.

## Report

- source commit synced, and baseline gate result (clean / forced / stopped)
- pages added, changed, deleted per folder (`git -C $DST show --stat HEAD`)
- surfaces frozen in the source, if any
- nav paths missing, if any
- commit SHA, or why commit was skipped
