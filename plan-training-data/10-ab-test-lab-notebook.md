<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Onboarding A/B test — shorten the signup form

Status: draft — 2026-07-13

## Summary
Run a pre-registered A/B test of whether cutting the signup form from 9 fields
to 2 lifts setup completion from 32% to 45%+, while guarding sales-lead quality
(day-7 profile completion). The plan follows experiment discipline: fix the
instrumentation, prove the splitter with an A/A test, run for a fixed duration
with no peeking, and apply verdict rules decided in advance.

## Context and current state
- Current funnel: landing 100% → signup started 61% → form completed 32% →
  first action 19%. The 61%→32% drop is the target leak.
- The 9-field form is the prime suspect: 71% of abandoners stall on the same 3
  fields.
- Instrumentation was unreliable — two events were double-firing, overstating
  the funnel by ~4 points; this is being fixed first.
- Sales routes leads using company-size data collected in the current form, so
  shortening it risks lead quality if that data isn't recovered later.

## Goals
- Determine whether variant B (email + password only) lifts setup completion to
  45%+ with statistical confidence.
- Protect the guardrail metric: day-7 profile completion stays ≥ 50%.
- Produce a durable, honest write-up of the result regardless of outcome.

## Non-goals
- Shipping variant B before the verdict rules are met.
- Post-hoc segment fishing beyond the three pre-registered cuts.
- Redesigning onboarding beyond the field-count change under test.

## Proposed design
The experiment is pre-registered: primary metric (setup completion %),
guardrail (day-7 profile completion ≥ 50%), sample size (2,100 per arm for 80%
power), minimum duration (two full weekends), and the three permitted segments
(mobile/desktop, weekday/weekend, organic/paid) are all fixed before data
arrives. Verdict rules are also fixed in advance:

- B wins and guardrails hold → ship to 100%.
- B wins but day-7 profile completion craters → ship B plus a day-3
  complete-your-profile nudge, then re-measure.
- Inconclusive → extend one week maximum, else keep A (ties go to the
  incumbent).
- A wins → keep A, run a session-recording autopsy, form a new hypothesis.

Instrumentation is fixed first, then an A/A test proves the splitter is
unbiased before the real A/B runs. During the run the signup flow is frozen and
the results dashboard is treated as read-only until the pre-set analysis date.

## Change inventory
| Area | Current state | Planned change |
| --- | --- | --- |
| Instrumentation | Two events double-firing | Fix; funnel reads true |
| Variant B | — | `[new]` 2-field signup (email + password) |
| Splitter | Untested | A/A test proves no bias |
| Analysis | Ad hoc | Pre-registered primary + guardrail + 3 segments |
| Verdict | — | Decision rules fixed before data |

## Implementation plan

### Week 0 — preparation
- [x] 1. Instrument every funnel step; fixed two double-firing events.
- [~] 2. Build variant B: email + password only, remaining fields deferred.
  Depends on 1.
- [ ] 3. A/A test for 3 days to prove the splitter isn't biased. Depends on 1.

### Weeks 1–2 — run
- [ ] 4. Launch A/B: 50/50, sticky by device, 2,100/arm for 80% power, minimum
  two full weekends. Depends on 2, 3.
- [ ] 5. Freeze the signup flow — no changes mid-experiment. Depends on 4.
- [ ] 6. Day-7 checkpoint: sample-size pace only, not results. Depends on 4.

### Week 3 — analysis
- [ ] 7. Primary metric (setup completion %) with confidence intervals, using
  the pre-registered method. Depends on 4.
- [ ] 8. Guardrails: week-1 retention and day-7 profile completion ≥ 50%.
  Depends on 7.
- [ ] 9. Only the three pre-registered segments. Depends on 7.

### Week 4 — decide and record
- [ ] 10. Apply the pre-decided verdict rule; no relitigating. Depends on 8, 9.
- [ ] 11. Write up the result — win or lose. Depends on 10.

## Verification
- The A/A test must show no significant difference before the A/B is trusted.
- The run must span at least two full weekends and reach 2,100 per arm.
- The primary metric is evaluated only with the pre-registered method and only
  after the analysis date.
- Guardrail (day-7 profile completion) checked before declaring B a winner.

## Rollout and rollback
If B wins cleanly, roll it out to 100%. If B wins but the guardrail craters, the
rollout is B plus a day-3 profile nudge, then re-measure before committing. If A
wins or the result is inconclusive, keep A — the incumbent is the safe default.
No mid-experiment rollout occurs; the flow is frozen for the duration.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Peeking and stopping at first "significance" | False positive | Results dashboard read-only until the analysis date |
| Day-7 profile completion craters | Sales lead routing breaks | Guardrail metric gates B's win; add day-3 nudge if needed |
| Post-hoc segment fishing | "Wins" that are noise | Only three pre-registered segments |
| Run doesn't span two full weekends | Weekend-user skew | Minimum-duration rule invalidates short runs |

## Open questions
- Deferred-field collection: day-3 email nudge, in-app banner, or both?
- If B ships, is the next hypothesis (defer the password via magic links) the
  same funnel or a new experiment?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
