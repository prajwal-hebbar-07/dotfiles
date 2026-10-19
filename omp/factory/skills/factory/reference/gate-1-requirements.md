# Gate 1: requirements (human confirms)

## Do

1. If the repo has code, read what the request touches (entry points, data, existing tests, `AGENTS.md`, prior decisions) before asking anything. Cite paths; never guess names.
2. Settle what you can from the request and the code. What you cannot settle becomes an open question in `requirements.md`, each with your recommended answer and why; draft the requirements as if every recommendation is accepted. Raise only what you cannot settle yourself.
3. Apply this readiness checklist silently; only failures become questions:
   - every requirement has an observable outcome and a trigger → outcome pair;
   - no unmeasurable adjectives ("fast", "nice") without a number or example;
   - no `etc.`, `TBD`, "and so on";
   - one feature per requirement, not bundles;
   - two readings possible → an open question;
   - every fake or stub the requirement allows has an owner for the real implementation;
   - an expensive or irreversible design choice hidden inside a requirement → note it for Gate 3.
4. Write `requirements.md`:

```markdown
# Requirements — <work-id>

## Requirements
- **R1** <trigger> → <observable outcome>. Accept: <how it is checked>.

## Out of scope
- <what a reasonable builder might do but must not>

## Open questions
- **Q1** <question> — recommend: <answer> — why: <reason> — otherwise: <what changes>

## Assumptions
- <decision taken where the request was ambiguous> — <one-line reason>. Product decision? yes/no

## Glossary
- <term>: <meaning in this product>

## Revision log
### R1 — requirements r1 — awaiting decision
Responds to: first presentation
```

5. Write the holdout scenarios to `~/.omp/factory/<repo>/<work-id>/scenarios.md`, never into the repo:

```markdown
## S1 (covers R1, R2)
Who: <kind of user, signed in or not>
Steps: 1. … 2. … 3. …
Expect: <what the user sees or what changes>
```

   One or more per requirement. Cover the failure paths the requirements name (wrong password, empty list, network error), not only the happy path.

6. Stop for the human (`rules.md`, "Human interaction"), pointing at `requirements.md` and the scenarios file. Flag every product decision among the assumptions.

## Exit

`approve` → move each open question, answered with its recommendation, into Assumptions, and set `stage: "gate2"`. Any other reply → apply the corrections and answers, append a revision-log entry, show the delta only, and stop again.

Any later change to a requirement or scenario reopens this gate, then every later gate the change touches.
