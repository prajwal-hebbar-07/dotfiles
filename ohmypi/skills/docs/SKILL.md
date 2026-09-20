---
name: docs
description: >
  Generate or verify this repository's documentation. Generate refreshes
  pages for code changed since the stored docs-baseline. Verify checks the
  whole mapped tree against the docs (report by default, fix on request).
  Two surfaces, each independently optional: architecture pages via arch /
  no-arch or an architecture pin, plain-English pages via plain / no-plain
  or a plain-english pin, both pinned per repo in docs/README.md. Stages
  its docs files and runs the commit skill. Use when the user says "docs",
  "generate the docs", "plain English docs only", "verify the docs", "are
  the docs still true", or invokes /docs or /skill:docs.
argument-hint: "[generate | verify] [full | since <ref> | <NN> ...] [arch | no-arch] [plain | no-plain] [report | fix]"
disable-model-invocation: true
---

# docs

Keep this repo's docs true to the code. Two surfaces, each switched on or
off per repo: technical pages under `docs/architecture/` and plain-English
pages under `docs/plain-english/`.

Invoking this skill is permission to write under `docs/` as this skill
directs. Product code is out of bounds.

Read [generate.md](generate.md) or [verify.md](verify.md) after you know
the mode. Read [architecture-template.md](architecture-template.md) when
writing an architecture page.

## Never

- Write product code, `AGENTS.md`, `CLAUDE.md`, or `ohmypi/RULES.md`.
- Write `docs/architecture/diagrams/` (that is `arc-design`).
- Write `docs/implementation-plan/` (that is `implementation-plan`).
- Restore `docs-twins`, `repo-docs`, or `check-claims.py`.
- Diff `HEAD~1` as the generate clock. The clock is `docs-baseline:`.
- Stamp `docs-baseline:` unless every page this run was required to
  check was actually checked.
- Delete `docs/architecture/` or `docs/plain-english/` because a toggle
  is off. Freeze what is already there.
- Write anything when both toggles are off. Stop and say so.
- Open new `NN` numbers in **verify**. New areas belong to generate.
- Run apps, servers, the browser, or the test/build suite.
- `git add` anything this run did not create or change under `docs/`
  (plus `docs/README.md` / the two index READMEs when this run edited
  them).
- `git commit` yourself. Do not pass a subject to commit.
- Format markdown with prettier/pnpm unless this repo already does that.
- Invent edges, inventories, or flows. `[INFERENCE]` or omit.

If asked to do any of those, refuse.

## Modes

| Mode | When | Writes? | Commit? |
|---|---|---|---|
| **generate** | default; "generate the docs"; no `verify` | yes, if pages are stale | yes, if files changed |
| **verify** `report` | `verify` with no `fix` | no | no |
| **verify** `fix` | `verify fix` | yes, existing pages only | yes, if files changed |

`full`, `since <ref>`, and numbered `01 04` are generate scopes (verify
may take numbers too: only those pages). They are not a mode.

## Toggles — what gets written

Two independent switches. Same precedence, resolved separately. Neither
implies the other: plain English alone is a valid repo.

| Toggle | On this invoke | Pin in `docs/README.md` | Directory |
|---|---|---|---|
| architecture | `arch` / `no-arch` | `architecture: on\|off` | `docs/architecture/` |
| plain English | `plain` / `no-plain` | `plain-english: on\|off` | `docs/plain-english/` |

For each toggle, first match wins:

1. User said the on word on this invoke → **on** for this run.
2. User said the off word on this invoke → **off** for this run.
3. That toggle's pin says `on` or `off` → that.
4. Bootstrap (no pin, no docs of either kind yet) → **ask once** which
   surfaces this repo wants, write both pins, then continue.
5. Pin missing but docs already exist → **on** if that toggle's
   `NN-*.md` files exist, else **off**. Write the pin to match. Say so
   in the report.

Both off → write nothing. Report that both surfaces are off and how to
turn one on. Do not stamp the baseline.

### Both on — the twin pair

Each architecture `NN` has a same-numbered plain-English page. Counts
must match. Architecture opens with `> **Plain English:**` pointing at
the twin. The plain-English page opens with `**Twin of:**`. Parent
updates both index READMEs.

### Architecture on, plain English off

Architecture only. Do not create plain-English pages. Do not require
matching counts. Omit the Plain English pointer from the template.
Leave existing plain-English files on disk.

### Plain English on, architecture off

Plain-English pages only, written from the code itself — not summarised
from an architecture page that does not exist. Read the real files the
same way an architecture page would, then write only ordinary words.

These pages are not twins: no `**Twin of:**` line, no link into
`docs/architecture/`. Open with `**Covers:**` and the area in plain
words. Numbering still comes from `## Mapping`, so turning architecture
back on later fills in the missing halves under the numbers already in
use. Do not create `docs/architecture/README.md`. Leave existing
architecture files on disk.

## Mapping and baseline

`docs/README.md` is this repo's only map and clock:

- `architecture: on|off`
- `plain-english: on|off`
- `docs-baseline: <sha>` under `## Freshness`
- `## Mapping` — path glob → `NN` (a path may list several numbers)

Never re-derive the baseline from `git log -- docs/`. A docs typo must
not bury undocumented code.

Numbers are append-only. Never renumber. Deleted area: delete the
files, drop the rows, retire the number, do not reuse it.

## Stage and commit — once, at the end

Skip this whole section for verify **report**, for generate when the
diff was empty, and when you stopped before a write.

1. `git add` **only** the markdown this run created or changed under
   `docs/` (architecture pages if on, plain-English pages if on, the
   index READMEs this run edited). Leave every other dirty file alone.
2. If the index already contains files this run did not change:
   **stop**. Do not unstage the user's other work. Do not commit a
   mixed index.
3. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself.
4. If commit reports nothing staged: add those files once more, run
   commit once. Still empty → stop.
5. Identity missing or hook failed → stop. Relay. No `--no-verify`.

One commit for the whole run. Not one commit per page.

## Report

- mode (`generate` / `verify report` / `verify fix`)
- which surfaces ran (architecture, plain English, or both) and where
  each toggle came from (this invoke, the pin, or inferred)
- pages touched, or "docs current vs `<sha>`"
- baseline old → new, or skipped (and why)
- commit SHA, or that commit was skipped
