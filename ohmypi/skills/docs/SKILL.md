---
name: docs
description: >
  Generate or verify this repository's architecture documentation. Generate
  refreshes pages for code changed since the stored docs-baseline. Verify
  checks the whole mapped tree against the docs (report by default, fix on
  request). Plain-English twins are optional via plain / no-plain or a
  plain-english pin in docs/README.md. Stages its docs files and runs the
  commit skill. Use when the user says "docs", "generate the docs",
  "verify the docs", "are the docs still true", or invokes /docs or
  /skill:docs.
argument-hint: "[generate | verify] [full | since <ref> | <NN> ...] [plain | no-plain] [report | fix]"
disable-model-invocation: true
---

# docs

Keep `docs/architecture/` true to the code. Plain-English twins under
`docs/plain-english/` only when the toggle is on.

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
- Delete `docs/plain-english/` because the toggle is off. Freeze them.
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

## Toggle — plain English

On this invoke, first match wins:

1. User said `plain` → twins **on** for this run.
2. User said `no-plain` → twins **off** for this run.
3. `docs/README.md` has `plain-english: on` or `off` → that.
4. Bootstrap (no pin, no architecture docs yet) → **ask once**, write
   the pin into `docs/README.md`, then continue.
5. Pin missing but architecture docs already exist → treat as **on** if
   `docs/plain-english/NN-*.md` files exist, else **off**. Write the pin
   to match. Say so in the report.

`on`: each architecture `NN` has a same-numbered twin. Counts must match.
Architecture opens with `> **Plain English:**` pointing at the twin.
Twin opens with `**Twin of:**`. Parent updates `docs/plain-english/README.md`.

`off`: architecture only. Do not create twins. Do not require matching
counts. Omit the Plain English pointer. Leave existing twins on disk.

## Mapping and baseline

`docs/README.md` is this repo's only map and clock:

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
   `docs/` (architecture pages, twins if on, the README indexes). Leave
   every other dirty file alone.
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
- twins on or off this run
- pages touched, or "docs current vs `<sha>`"
- baseline old → new, or skipped (and why)
- commit SHA, or that commit was skipped
