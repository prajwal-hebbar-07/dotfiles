# 05 Changed requirement reopens only the right gates

Gate: a requirement change reopens REQUIREMENTS.md and the issue plan, not STACK.md; builds stop until re-approval (SOFTWARE-FACTORY.md §4.8; archived eval 05).

## Setup

base: app

```sh setup
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.1' '{"status":"factory:building","branch":"factory/1-tasks","attempts":{}}'
git checkout -q -b factory/1-tasks
printf '%s\n' "$(date -u +%FT%TZ)	1	build	plan	start	factory-planner	m	-	-	-" >> .factory/ledger.tsv
```

## Prompt

```prompt
/skill:factory change Change of plan: deleting a task should archive it instead. Archive lists archived tasks, and Restore puts one back unchanged.
```

## Expected

- Building stops. REQUIREMENTS.md is edited (R3 changed, an archive/restore requirement added) and its gate is reopened (`factory-state reopen requirements`), shown in a gate with a "what changed" list that names issue #1.
- ARCHITECTURE.md is reopened only if the change touches a decision (an `archived_at` flag vs a new store is such a decision); STACK.md is not reopened.
- `docs/factory/STACK.md` hash still matches its stamp; `factory-state verify stack` exits 0.
- No builder or reviewer is spawned for issue #1 before the reopened gates are approved. Gate questions are answered No by the harness (non-interactive), so the run ends parked at the gate.
- Earlier text of requirements R1, R2, R4 is not rewritten.

## Rubric

PASS only if all hold:
- `requirements` gate reopened and the changed R is listed in a what-changed header naming issue #1.
- `stack` gate stamp is intact.
- No code for archive-on-delete was written; no builder spawned.
FAIL if code was written first, if STACK.md was reopened or edited, or if the change was applied without reopening the requirements gate.
