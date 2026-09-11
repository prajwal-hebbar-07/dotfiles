---
name: docs-twins
description: >
  Generate or refresh this repository's twin documentation — one technical
  document under docs/architecture/ and one plain-English companion with the
  same number under docs/plain-english/. Works incrementally by default (only
  the pairs whose code changed since the docs were last updated) or as a full
  sweep. Use when the user says "update the docs", "refresh the architecture
  docs", "the docs are stale", "document what changed", "redo the docs", or
  invokes /docs-twins.
argument-hint: "[full | since <ref> | <doc numbers, e.g. 04 13>]"
---

# docs-twins: keep the paired docs true

Every numbered document exists twice:

|Where|For|
|---|---|
|`docs/architecture/NN-<slug>.md`|engineers — exact, cited, blunt about debt|
|`docs/plain-english/NN-<slug>.md`|everyone else — same subject, everyday words|

Same number = same subject. Neither is a summary of the other; they are two
readings of one area. This skill's only job is to keep both true to the code and
true to each other.

**Never commit.** Report and stop; the user runs `/skill:commit` when happy.

## Step 1 — find the baseline and what changed

```bash
grep -o 'docs-baseline: [0-9a-f]\{7,40\}' docs/README.md          # the stored baseline
git diff --name-only <that-sha>..HEAD -- apps packages .github Dockerfile nginx-conf.conf \
  Makefile turbo.json pnpm-workspace.yaml package.json .npmrc
```

The baseline is **stored**, in a `docs-baseline:` marker under `## Freshness` in `docs/README.md`.
It records the code the pairs were last read against. Never re-derive it from
`git log -- docs/architecture docs/plain-english`: that returns the last commit that *touched*
the docs, which a typo fix moves forward, silently burying every undocumented code change behind
it. It also cannot see docs that were authored against already-stale code.

- No marker in `docs/README.md` → either the docs predate this scheme or nothing has ever
  documented the repo. Fall back to
  `git log -1 --format='%h %ad %s' --date=short -- docs/architecture docs/plain-english`, say in
  the report that the baseline was derived and is therefore a guess, and treat a repo with no
  docs at all as a **bootstrap** full sweep.
- No output from the diff → the docs are current. Say so and stop. Do not rewrite prose for its
  own sake.
- The user said `full`, or asked for specific numbers → skip the diff and use their scope
  directly.

Also worth a glance when the diff is large:
`git log --oneline <sha>..HEAD` — commit subjects tell you the *intent* behind
the file churn, which is what the docs need to capture.

Capture `git rev-parse HEAD` **now**, before dispatching anything. That sha, not the one you
find later, is what the pairs get read against; code committed mid-sweep is not covered by it.

## Step 2 — map changed files to doc numbers

Read down this table; a file can feed several pairs (a verify endpoint is both
the API layer and verification). Extend the table when a new area appears — it
is the mapping's only home.

|Changed path|Pairs|
|---|---|
|`pnpm-workspace.yaml`, `turbo.json`, `.npmrc`, any `package.json` exports|01|
|`Dockerfile`, `nginx-conf.conf`, `Makefile`, `.github/workflows/`, `apps/web/vite.config.ts`|02|
|`apps/web/package.json` (version)|01, 02|
|`apps/web/public/config/config.json`, `api-host.ts`, `config-cache.ts`, `ConfigContext.tsx`|03|
|`public/config/{layout,theme,whitelist,workflow,dashboard,history,navbar.config}.json`|03 + the owning pair below|
|`packages/api/src/{host,api-client,end-points,logger,toaster,saveForm}.ts`, `forms/`, `hooks/forms/`|04|
|`packages/api/src/config.ts`, `whitelist.json`|05|
|`packages/auth/` (except the permission checker and `GuardRail`), `auth-host.ts`, `pages/auth/`, `context/auth/`|06|
|`permissions.ts`, `usePermissions.ts`, `GuardRail.tsx`, `config/permissions.config.ts`, `FormAccessGuard.tsx`|07|
|`packages/types/`|08|
|`packages/form-core/`, `hooks/form/`, `context/form/`, `utils/form/`|09|
|`packages/transformer/`|10|
|`packages/web-components/`|11|
|`main.tsx`, `App.tsx`, `router.ts`, `routes/`, `components/{common,layout}/`, `layoutComponentMap.ts`, `hooks/` (shared)|12|
|`pages/forms/`, `components/form/`|13|
|`pages/` (dashboard, users, settings, errors — any routed area without its own pair)|14|
|`verifyForm.ts`, `trustedApi.ts`, `trusted-lov.ts`, `VerificationContext.tsx`, `trustedOcrIntervener.ts`, `LyikOVSE/`, `TrustedLovDropdown.tsx`|15|
|`digilocker.ts`, `esign/`, `pages/{digilocker,esign}/`, `components/capture/`, `capture/eSignCam/`, `useDigilockerResult.ts`|16|
|`ThemeContext.tsx`, `components/theme/`, `googleFonts.ts`, `web-components/src/styles/`, `theme.json`|17|
|`DevToolsContext.tsx`, `components/devtools/`, `utils/devtools/`, `monaco.ts`, the visualizer and config-viewer pages|18|
|any `*.test.ts(x)`, `__tests__/`, `packages/web-e2e/`, `.env.test`|19|

A changed file no row claims is a decision, and you must state which you made:

- it belongs to an existing area → add it to the row and to that pair's inventory;
- it is a genuinely new area → open the next number (20, 21, …), add a row here,
  and add rows to all three indexes. **Numbers are append-only** — renumbering
  breaks every inbound link.

## Step 3 — dispatch one subagent per pair

Each pair is independent. Fan out in a single batch; do not walk them yourself.
One agent owns **both files of one number**, so the twins cannot drift apart.

Batch `context`:

```
# Goal
Refresh twin documentation after code changes.

# Constraints
- Read the real code before writing. Mark anything not directly observed [INFERENCE].
- Touch ONLY your own two files. Never edit docs/README.md,
  docs/architecture/README.md or docs/plain-english/README.md — the parent owns
  shared files.
- Do not run prettier, eslint, or the test suite; the parent verifies once at the end.
- Do not commit.

# Contract
Architecture doc: docs/architecture/NN-<slug>.md — ten-section skeleton, opening
with a `> **Plain English:**` pointer at its twin.
Plain-English doc: docs/plain-english/NN-<slug>.md — opens with
`**Twin of:** [<title>](../architecture/NN-<slug>.md)`.
Both wrap at 100 columns.
```

Per-task `task`, one per affected number:

```
# Target
docs/architecture/04-api-layer.md and docs/plain-english/04-the-mailroom.md. Nothing else.

# Change
These files changed since the docs were last updated: <paths from step 2>.
Read them and the modules around them, then bring both documents back in line
with reality: inventory rows, flows, contracts, config keys, the tests section,
and the debt list. Delete claims that are no longer true. Keep the existing
structure and voice.

# Acceptance
Both files describe the current code. Every path and symbol named exists. The
plain-English twin names no framework API and no source paths — only config
files a non-engineer may edit.
```

Ten affected pairs = ten tasks in one `tasks[]` array, not ten rounds.

## Step 4 — the parent owns the shared files

Only the parent edits:

- `docs/README.md` — the area table, the two section blurbs, and the `docs-baseline:` marker
  under `## Freshness`;
- `docs/architecture/README.md` — document tables, the system paragraph, the
  mermaid map, the reading paths;
- `docs/plain-english/README.md` — the twin mapping table.

## Step 5 — verify

```bash
# every architecture doc has a same-numbered twin, and both counts match
ls docs/architecture/[0-9][0-9]-*.md | wc -l
ls docs/plain-english/[0-9][0-9]-*.md | wc -l

# every architecture doc points at its twin (count must equal the above)
grep -l 'plain-english/' docs/architecture/[0-9][0-9]-*.md | wc -l
grep -l '\.\./architecture/' docs/plain-english/[0-9][0-9]-*.md | wc -l

# every relative link resolves
python3 - <<'EOF'
import os, re
bad = 0
for d in ('.', 'docs', 'docs/architecture', 'docs/plain-english'):
    for f in (['README.md'] if d == '.' else sorted(os.listdir(d))):
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

pnpm exec prettier --write "docs/**/*.md" README.md && pnpm run format:check
```

Then stamp the baseline — the sha captured in step 1, not a fresh `HEAD`, and only when this
sweep re-checked every pair the diff touched:

```bash
# advance the stored baseline; also update the human-readable sha and date beside it
sed -i '' "s/docs-baseline: [0-9a-f]\{7,40\}/docs-baseline: $(git rev-parse HEAD)/" docs/README.md
```

Skip the stamp, and say so in the report, when the run was scoped to specific numbers, when a
pair was left knowingly stale, or when a subagent failed — a baseline that claims more than was
checked is the one bug this scheme exists to prevent. It is also worth spot-checking one older
pair per sweep against its code: a stored baseline inherits whatever was wrong before it, so
nothing but reading finds a document that was untrue the day it was written.

Then report: pairs touched, what changed in each, and that nothing is committed.

## The architecture document

Ten sections, in this order, so knowing one document is knowing all of them:

1. Purpose 2. Inventory 3. Public surface 4. Flow 5. Contracts and invariants
6. Configuration 7. Boundaries and dependencies 8. Tests 9. Debt and traps
10. Change guide

- Cite source as a repo-relative path, with a line number only where it helps.
  Symbol names are authoritative; line numbers drift.
- §9 is deliberately blunt: stubs that read as live code, silent failure modes,
  dead exports, duplicated logic, security shortcuts. **Never soften or drop a
  trap that is still true** — re-verify it instead.
- §8 states what is *not* covered as plainly as what is.
- Mark unobserved claims `[INFERENCE]`. Use mermaid where a diagram beats a
  paragraph.

## The plain-English twin

- Opens with `**Twin of:** [<Architecture title>](../architecture/NN-<slug>.md)`.
- Explains **that document's subject** in ordinary words, for someone who does
  not write code. Not a product brochure, not a sales sheet, not a tutorial.
- Banned: framework and library names, hooks, type names, function names, paths
  under `src/`, "how to use this document", "why documentation matters",
  audience-routing tables.
- Kept: what a non-engineer may actually touch or discuss — `config.json`,
  `theme.json`, `workflow.json`, persona codes like `MKR`/`CKR`, record states,
  port numbers.
- One plain metaphor per document, held consistently (the mailroom, the seal, the
  paint set). Do not stack metaphors.
- Carry the honest parts across. If the architecture doc says a transport is
  mocked or that CI runs no tests, the twin says so too, in plain words. A twin
  that reads like marketing has failed.
- Roughly 60–100 lines. Needing far more usually means the architecture doc is
  two areas wearing one number.

## Edge cases

- **An area was deleted** → delete both files, remove the rows from all three
  indexes and from the table above. Retire the number; never reuse it.
- **Only tests changed** → that is pair 19, and usually only pair 19.
- **`docs/workflow.md` and `docs/v2-v3-gap-analysis.md`** are standalone, not
  pairs. A `workflow.json` change touches `workflow.md` plus pairs 03 and 10.
- **A pair's subject has drifted** (one doc now covers two things) → say so and
  propose the split; do not silently renumber.

## Not this skill's job

Committing, pushing, generating the TypeDoc API reference (`pnpm docs`, which
cleans its own output directory), or writing code. If the user asks for those,
do them directly.

Nor auditing existing prose for claims the code no longer has: this skill only looks
at what *changed*, so it cannot see a document that was wrong when written. That is
`docs-verify`, which walks every claim in `docs/` back to the code.

---

[Skill directory: /Users/hebbar/.omp/agent/skills/docs-twins]
Resolve relative paths in this skill (e.g. `scripts/foo.js`, `templates/config.yaml`) against this absolute directory; read referenced assets and templates; run scripts with the terminal tool when skill instructions call for it.