# Plan Training Data

A corpus of sample plans for training/testing an app that renders plans
beautifully. Every file follows the format the current `/plan` skill emits — a
self-contained senior-engineering implementation document written in ordinary
Markdown (see the skill's "Document standard" and "Plan file format"). A
renderer built against this corpus handles real `plans/plan-<slug>.md` files
unchanged.

## File anatomy (identical in every sample)

```markdown
<!-- plan-review guide … -->     # HTML comment header; real files open with it

# <Title>

Status: <lifecycle> — <YYYY-MM-DD>   # updated by /plan-review rounds

## Summary                       # problem, outcome, direction, scope
## Context and current state     # verified current behavior + evidence
## Goals                         # observable outcomes
## Non-goals                     # explicit scope boundaries
## Proposed design               # target behavior + material decisions
## Change inventory              # table: area → current artifact → planned change
## Implementation plan           # numbered checkbox steps, optionally ### phases
## Verification                  # tests, commands, and manual/operational checks
## Rollout and rollback          # deploy order, reversibility, recovery
## Risks and mitigations         # table: risk → impact → mitigation
## Open questions                # unsettled decisions
## Review changelog              # appended by /plan-review, may be empty
```

## The renderer grammar (parse contract)

Plans are ordinary Markdown — there is no machine-only formatting layer to
decode. A renderer works with standard constructs:

| Token | Meaning |
|-------|---------|
| `# <Title>` | plan title (one per file) |
| `Status: … — <date>` line | plan lifecycle (draft / reviewed / ready) |
| `## <Section>` headings | the sections listed above, in order |
| `\| … \| … \|` tables | Change inventory and Risks and mitigations |
| `- [ ] N. …` | plan step N, todo |
| `- [x]` / `- [~]` / `- [!]` | done / in progress / blocked |
| `### heading` inside `## Implementation plan` | phase / grouping boundary |
| `[new]` | planned artifact that does not exist yet |
| `Depends on N.` in a step | ordering dependency on step N |

Dependencies are expressed in prose ("Depends on 3.") rather than a token, and
effort/risk/milestone metadata lives in the relevant section (Risks and
mitigations, Verification) rather than inline tags.

## What varies (on purpose)

| Axis | Coverage |
|------|----------|
| **Domain** | software feature, db migration, incident recovery, wedding, fitness, learning roadmap, product launch, travel, side-project rescue, A/B experiment |
| **Structure** | phased waterfall, T-minus countdown, milestone timeline, week-by-week phases, triage severity lanes, checkpoint gates, parallel workstreams, day-by-day with branches, kanban weeks, hypothesis loop |
| **Time scale** | 6 hours → 9 months |
| **Change inventory shape** | code plans use `path/to/file.ts:symbol`; non-software plans adapt the columns (workstream → current state → target state) while keeping the table |

Statuses are deliberately mixed across files (some `[x]`, `[~]`, `[!]`) so a
renderer must handle plans in flight, not just fresh ones. Sample 01 also
carries a populated `## Review changelog` so renderers exercise the reviewed
state. Non-software plans use task phrasing where code plans use
`path/to/file.ts:symbol — change`; the surrounding document structure is
identical.
