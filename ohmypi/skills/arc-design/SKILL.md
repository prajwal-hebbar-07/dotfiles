---
name: arc-design
description: >
  Builds a set of Archify diagrams from named files, folders, modules, or
  features in the current tree: always one overview of how the pieces
  connect, plus one diagram per piece (and flows when they are verified).
  Writes HTML under docs/architecture/diagrams/, then stages those files
  and runs the commit skill once. Use when the user says "arc design",
  "architecture diagrams", "diagram this module", "archify this", "diagram
  this feature", or invokes /arc-design or /skill:arc-design.
argument-hint: "[files | folders | modules | features]"
---

# arc-design

Director for **archify**. This skill decides what to draw and how to slice
it. Archify renders it. Do not hand-build SVG or HTML.

Invoking this skill is permission to write under
`docs/architecture/diagrams/` only.

## Never

- Reimplement Archify. Do not hand-place SVG into a template unless
  `node …/bin/archify.mjs` cannot run at all, and then say so and stop.
- Invent runtime edges from folder proximity or naming. No import, call,
  config, or documented contract → no edge. Omit it or ask. Do not draw a
  pretty lie.
- Write `docs/architecture/NN-*.md`, `docs/plain-english/`, or any
  markdown index. HTML (and the Archify JSON next to it) only.
- Overwrite prose twins. Diagrams live only in
  `docs/architecture/diagrams/`.
- `visual-check`, `preview`, `deliver --open`, or any browser. Host rules
  forbid starting apps and driving the browser. Success is `deliver` exit 0.
- `git commit` yourself. Do not pass a subject to commit.
- `git add` anything outside this run's files under
  `docs/architecture/diagrams/`.
- Start Paper, servers, or the browser.
- Pick among zero or several module/feature matches. List them and ask.
- Wander the whole repo unless the user said the whole repo (or named
  nothing after you asked and they confirmed whole repo).

## Inputs

The user may name any mix of:

- **files** — repo-relative paths
- **folders** — directories of source
- **modules** — a name that may not match a folder (package, area, skill,
  tool). Resolve against the tree and against `docs/README.md` `## Mapping`
  if that table exists.
- **features** — a named behaviour. Meaning: **whatever is in the working
  tree now**, not a historic commit range.

Exact match after lowercasing for module/feature names, not substring.
Zero or several hits → list paths/ids and ask. Never pick.

If they named nothing, ask what to diagram. Do not default to the whole
repo.

## Archify location

Resolve the Archify skill directory, in order:

1. `~/.agents/skills/archify`
2. `~/.omp/agent/skills/archify`
3. `~/.cursor/skills/archify`

Need `SKILL.md` and `bin/archify.mjs`. If missing, STOP. Tell the user to
install Archify (`npx skills add tt-a1i/archify -g` or their usual path).
Do not vendor it.

Read that `SKILL.md` and the one schema + one example for each type you
will emit. Then run:

```sh
node "$ARCHIFY/bin/archify.mjs" doctor
```

Non-zero → STOP.

## What a set is

Every invoke produces:

1. **`00-overview`** — always. How the pieces in *this* set connect.
   Neighbours outside scope appear only if a verified edge exists; draw
   them `external` / dashed. Do not sneak-in the rest of the repo.
2. **One piece diagram per resolved module / folder / feature** (files in
   the same area fold into that piece).
3. **Flow diagrams** only when you verified a cross-piece sequence, data
   path, or state machine. Skip if you would have to invent it.

Archify showcase: **at most 12 primary nodes**, one obvious main path.
If a piece is still over 12 after grouping, split again. Do not cram.

Type router (do not force everything into `architecture`):

| Kind | Archify type |
|---|---|
| boxes, boundaries, who talks to whom | `architecture` |
| ordered process, gates, runbook | `workflow` (schema_version 2) |
| call chain, request/response | `sequence` |
| pipeline, ETL, lineage | `dataflow` |
| states, retries, terminal | `lifecycle` |

Overview is almost always `architecture`.

## Read

Working tree, not a past SHA, for what is true. In scope only:

- the named files/folders
- files that mapping / name resolution said belong to that module
- `docs/` except `docs/plain-english/` and except `docs/implementation-plan/`

Do not run the test/build suite. Do not start apps.

Record only evidence you opened. Mark unverified claims; prefer omit.

## Write

Directory: `docs/architecture/diagrams/` (create it).

For each diagram, two files with the same slug:

- `<slug>.json` — Archify candidate (required to validate/deliver later)
- `<slug>.html` — published artifact

Slugs:

- `00-overview`
- `01-<piece>`, `02-<piece>`, … pieces then flows

`<piece>` is lowercase hyphens from the module/feature/folder name.

No `README.md`. The overview HTML is how a human reads the set.

`--repo-root` is architecture-only. Pin `meta.repository.revision` to
`git rev-parse HEAD` when origin exists. `sources[]` only for paths that
**exist as blobs at HEAD**. A dirty or new working-tree file may appear
in the diagram with no `sources[]`; say that in the report. No origin →
omit `meta.repository` (or `link_mode: "local-only"` if Archify requires
a url and origin exists but is not GitHub/Gitee). Never invent a URL.

`meta.quality_profile`: `"showcase"`. Do not set `meta.subtitle` or
`meta.visual_preset` unless the user asked. No `meta.animation` unless
they asked for a demo.

For each diagram, in order:

1. Write the candidate JSON.
2. `node "$ARCHIFY/bin/archify.mjs" validate <type> <slug>.json --quality showcase --json`
3. Repair from diagnostics only (one geometry control per pass). Two
   consecutive rounds with no improvement → STOP that diagram, report,
   do not commit the set.
4. Freeze on a passing validate. Then
   `node "$ARCHIFY/bin/archify.mjs" deliver <type> <slug>.json <slug>.html --quality showcase --json`
5. Non-zero deliver → STOP. Do not `visual-check`. Do not commit.

Deliver pieces (and flows) first, **overview last**, so the overview can
name the pieces you actually produced.

If any diagram fails, leave whatever HTML/JSON already landed on disk.
Do **not** run commit. Report which slug failed.

## Stage and commit — once, at the end

Only after **every** diagram in this set delivered, including overview.

1. `git add` **only** the JSON and HTML this run created or changed under
   `docs/architecture/diagrams/`. Leave unrelated dirty files alone.
2. If the index already contains files this run did not change: **stop**.
   Do not unstage the user's other work. Do not commit a mixed index.
3. Run the **commit** skill. Do not pass a subject. Do not `git commit`
   yourself.
4. If commit reports nothing staged: add those files once more, run
   commit once. Still empty → stop.
5. Identity missing or hook failed → stop. Relay. No `--no-verify`.

One commit for the whole set. Not one commit per diagram.

## Report

- scope resolved (paths / modules)
- slugs produced (overview first in the list)
- Archify types used
- deliver receipts (or the failing slug)
- whether evidence links are HEAD-only while the drawing includes dirty files
- commit SHA, or that commit was skipped
