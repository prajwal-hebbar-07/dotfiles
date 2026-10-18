# verify

Ask of the docs: does this still exist in the code? The reverse of
generate, which only follows a diff. Checks whichever surfaces this repo
has on — resolve both toggles per SKILL.md first.

Default **report**: write nothing, stage nothing, do not run commit.

## Step 1 — mechanical floor

```sh
python3 <this-skill>/scripts/check-paths.py .
```

Findings are suspicion, not verdict. A stated absence ("there is no
X", a debt/trap note, "removed") is documentation doing its job. Never
"fix" one by deleting it.

Skip `docs/architecture/diagrams/` and `docs/implementation-plan/`.

## Step 2 — coverage the script cannot see

Against **HEAD**, for every mapped number (or the numbers the user
named), on every surface that is on this run:

- Every `## Mapping` glob still matches at least one tracked path, or
  the row should go.
- Every significant top-level source directory is in the map. Missing
  documentation is a finding. Do not open a new `NN` here — list it
  and say "run generate".
- Inventory vs the files in that area: dead paths and unlisted files.
- Counts ("N test files") recounted.
- Flows: still the real path, or `[INFERENCE]` / omit. A renamed thing
  whose old name still exists elsewhere is a miss the script will not
  see.

A surface that is **off** is not a finding: do not flag its missing
pages, do not rewrite its frozen files, do not flag the absent twin
pointer. Both surfaces on → both files of a number stay true to each
other and to the code. Both off → report that and stop.

## Step 3 — report or fix

**report** (default): print findings by kind (dead path, missing doc,
stale flow, stale count, deliberate absence). Stop. No commit.

**fix**: edit existing pages on the surfaces that are on this run.
Fix the claim, not the sentence: renamed → say the new name; replaced
flow → rewrite the flow. Re-verify stated absences and keep them if
still true. Parent edits the README indexes when rows must change.

Then re-run `check-paths.py`. Leftover hard findings: say which and
why they were left.

A full clean **fix** of every mapped number may stamp `docs-baseline:`
to the step-1 HEAD. `report` never stamps. Numbered/scoped `fix` never
stamps.

Then stage and commit per SKILL.md (fix only).

## Edge cases

- Finding whose fix is a code change: report it. Do not edit code.
- A whole page with no surviving subject: propose delete + retire the
  number; do it only on `fix` after the proposal is in the report for
  this run if the user already said `fix` and the subject is gone.
- Standalone `docs/*.md` not in the numbering scheme: parent may fix
  path claims there on `fix`; do not invent a number.
