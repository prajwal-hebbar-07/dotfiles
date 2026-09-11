---
name: docs-verify
description: >
  Audit this repository's documentation against the code in the reverse
  direction to docs-twins — instead of asking "what code changed?", it asks of
  every claim in the docs "does this still exist?". Finds dead paths, dead
  symbols, renamed modules, stale counts and vanished config keys, then fixes
  the documents that carry them. Use when the user says "check the docs against
  the code", "find outdated docs", "are the docs still true", "look for dead
  entries in the docs", "verify the documentation", or invokes /docs-verify.
argument-hint: "[report | fix | <doc numbers, e.g. 09 13>]"
---

# docs-verify: find what the docs claim and the code no longer has

`docs-twins` is diff-driven: code changed, so update the pairs that own it. It cannot
see a document that was **wrong the day it was written**, or one whose subject was
refactored before the docs existed. This skill closes that hole by walking the other
way — every checkable claim in `docs/` is held up against the code, and whatever fails
to resolve is either fixed or explained.

**Never commit.** Report and stop; the user runs `/skill:commit` when happy.

## What counts as a finding

| Kind | A doc says | And the code |
|---|---|---|
| dead path | `` `src/form/sectionAudit.ts` `` | has no such file, under any workspace root |
| dead symbol | `` `buildSectionAuditIndex` `` | contains that identifier nowhere |
| dead export | `` `@lyik/form-core/form/sectionAudit` `` | has no such entry and no file behind it |
| renamed thing | `` `RecordAuditDrawer` `` | calls it `RecordAuditDialog` |
| stale count | "38 Vitest files" | holds a different number |
| stale key | a `config.json` key | no longer reads it |
| orphan section | a whole §4.x flow | describes a design that was replaced |

The first three are mechanical and the script finds them. The last four need reading —
that is what the subagents are for.

**A stated absence is not a finding.** "There is no root `vitest.config.ts`", "**No
`AbortController` anywhere**", "**Dead code**: `buildCustomOtpCardbkp`" are documentation
doing its job. The script marks these `deliberate?`; never "fix" one by deleting it.

## Step 1 — run the extractor

```bash
python3 <skill>/scripts/check-claims.py .            # human-readable
python3 <skill>/scripts/check-claims.py . --json     # for handing to subagents
```

It reads every backticked token in `docs/**/*.md` and `README.md`, decides whether it is
a path, a symbol or a package subpath, and resolves it against tracked files, the
identifiers present in source and config, and every `package.json` exports map. Paths
resolve literally, under each workspace root, as a tail of a real path, and relative to
the citing document. Brace forms (`{fold,registry}.ts`) are expanded and each member
checked, so a dead half cannot hide behind a live one.

Exit code is `0` when every finding is a marked absence, `1` when something needs a
human. Flags: `--only <doc>` for one file, `--include-historical` to also check
`docs/v2-v3-gap-analysis.md` (skipped by default — it documents the *old* v2 repo on
purpose, so its paths are meant to be absent).

Deliberately skipped, because they are not claims about this repo: fenced code blocks,
placeholders (`@lyik/types/<name>`, `capture/.../x.test.ts`), exports patterns (`./*`),
third-party deep imports, generated output (`apps/web/docs/api/`), and anything git
ignores.

If you change the extractor, run its self-check first:

```bash
python3 <skill>/scripts/self_check.py     # 12 assertions, temp repo, no side effects
```

## Step 2 — the script is the floor, not the ceiling

Mechanical findings are the cheap half. Three classes of rot resolve fine and are still
false, so each pair's agent must read its own §2 inventory, §3 public surface and §4 flow
against the code:

- **A renamed thing whose old name still exists elsewhere.** The token resolves; the
  claim is wrong anyway.
- **A design replaced wholesale.** Every symbol in a §4 subsection may exist while the
  flow between them is fiction. This is what happened to the audit trail: the docs
  described an index being built, the code had folded that into a registry read through
  the form config.
- **Counts and negatives that drifted.** "38 Vitest files", "no test covers X", "granted
  to no persona" — each must be recounted or re-grepped, never carried forward.

Also worth one grep per pair: exports in that area's `package.json` that no document
mentions, and top-level source directories absent from every inventory. Missing
documentation is a finding too, though a milder one.

## Step 3 — group findings by pair and dispatch

Map each finding's file to its doc number — for architecture and plain-English docs the
number is in the filename, and `docs/README.md`, `docs/architecture/README.md`,
`docs/plain-english/README.md` and root `README.md` belong to the parent. Then fan out
one subagent per affected pair, in a single batch, each owning **both files of one
number** exactly as in `docs-twins`.

Batch `context`:

```
# Goal
Correct documentation that claims things the code no longer has.

# Constraints
- Verify against the real code before editing. A finding is a suspicion, not a verdict:
  the code is the authority, and the script has no opinion about intent.
- A stated absence ("there is no X", a §9 trap, a dead-code note) is correct
  documentation. Re-verify it and keep it. Never delete a trap that is still true.
- Fix the claim, not the sentence: if a symbol was renamed, say what it is now; if a
  design was replaced, rewrite the flow rather than swapping nouns.
- Touch ONLY your own two files. The parent owns docs/README.md,
  docs/architecture/README.md and docs/plain-english/README.md.
- Do not run prettier, eslint, or the test suite; the parent verifies once at the end.
- Do not commit.

# Contract
Architecture doc: ten-section skeleton, opening with a `> **Plain English:**` pointer.
Plain-English doc: opens with `**Twin of:** [<title>](../architecture/NN-<slug>.md)`,
no framework/library/type/function names, no source paths. Both wrap at 100 columns.
```

Per-pair `task`:

```
# Target
docs/architecture/NN-<slug>.md and docs/plain-english/NN-<slug>.md. Nothing else.

# Change
The claim checker could not resolve these against the code:
<findings for this pair: line, kind, token, context>

For each one, read the code and decide: renamed (say the new name), removed (delete the
claim, or state the absence if it is load-bearing), or a false positive (leave it, and
say why in your result). Then read your §2, §3 and §4 against the code and fix the
claims the script cannot see — a flow that no longer matches, a count that drifted, a
"not covered" that is now covered. Recount anything numeric.

# Acceptance
Every path, symbol and export named in both files exists, or is explicitly described as
absent. The plain-English twin names no framework API and no source paths.
```

## Step 4 — the parent's own pass

The parent fixes the four shared files itself, then re-runs the extractor. Everything
left must be a marked absence; if a real finding survives, say which and why it was left.

## Step 5 — verify

```bash
python3 <skill>/scripts/check-claims.py .        # expect: 0 not obviously deliberate

# twins still paired and linked
ls docs/architecture/[0-9][0-9]-*.md | wc -l
ls docs/plain-english/[0-9][0-9]-*.md | wc -l
grep -l 'plain-english/' docs/architecture/[0-9][0-9]-*.md | wc -l
grep -l '\.\./architecture/' docs/plain-english/[0-9][0-9]-*.md | wc -l

pnpm exec prettier --write "docs/**/*.md" README.md && pnpm run format:check
```

A full clean sweep is the one thing that earns a baseline stamp: every pair has now been
held against current code, which is exactly what `docs/README.md`'s `docs-baseline:`
marker asserts. Update it to `git rev-parse HEAD` — and skip it if the run was scoped to
some numbers, or if any pair was left knowingly wrong.

Then report: findings by kind, what was corrected, what was a false positive and why, and
that nothing is committed.

## Edge cases

- **A finding whose fix is a code change, not a doc change.** The doc is right and the
  code is wrong (a dead export the doc calls dead, a comment citing a deleted module).
  Report it; do not edit code unless the user asks.
- **A whole document with no surviving subject.** Propose deleting both twins and
  retiring the number, per `docs-twins`; never renumber.
- **The script's rules need widening.** A new claim shape (an endpoint, an env var) is a
  change to `scripts/check-claims.py`, plus an assertion in `scripts/self_check.py`. Do
  not paper over it with per-token exceptions in the docs.
- **Findings only in `docs/workflow.md`.** Standalone, not a pair; the parent fixes it.

## Not this skill's job

Committing, pushing, TypeDoc, writing code, or documenting new code — new areas belong to
`docs-twins`. This skill only makes existing documents true.
