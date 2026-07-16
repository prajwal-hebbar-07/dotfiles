<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Couch to 10K — 16-week running program

Status: draft — 2026-07-13

## Summary
Go from unable to jog 60 seconds to running a 10K in 16 weeks, training three
times per week. The program builds continuous-run duration gradually with a
recovery week every fourth week, treats the recovery weeks as non-negotiable
injury insurance, and ends with a taper and a target race. The largest risk is
attrition around week 3 and injury from skipping recovery.

## Context and current state
- Starting fitness: roughly 60 seconds of continuous jogging before needing to
  walk.
- Schedule: three runs per week, with recovery weeks at weeks 4, 8, and 12.
- Progression is measured by longest continuous run, climbing from ~8 minutes
  in week 1 toward 60+ minutes (10K) by week 16.
- Equipment: one pair of running shoes; cushioning degrades around 500km,
  which matters for the longer runs late in the program.

## Goals
- Complete a 10K (60+ minutes continuous) in week 16.
- Sustain three runs per week without an injury layoff.
- Build the identity of "a person who runs," which is what makes the habit
  stick past week 3.

## Non-goals
- Speed or pace targets — this is a distance/completion program.
- Adding daily runs or doubling up; three runs a week is the whole plan.

## Proposed design
The program runs in three phases. Phase 1 (weeks 1–4) uses run/walk intervals
to build the base and survive the early attrition point. Phase 2 (weeks 5–10)
extends continuous blocks and long runs until 5K falls naturally. Phase 3
(weeks 11–16) builds the long run to 8K, then tapers into race day.

Recovery weeks (4, 8, 12) deliberately drop volume; they are scheduled as part
of the ascent, not as pauses. Race-day pacing is planned conservatively: the
first 5km easy, km 6–8 as work, km 9–10 as the finish, with nothing new on the
day (same shoes, breakfast, and playlist used in training).

## Change inventory
| Phase | Focus | Target by end of phase |
| --- | --- | --- |
| Act I (w1–4) | Run/walk base | Consistent 3x/week habit |
| Act II (w5–10) | Continuous blocks | First unbroken 5K |
| Act III (w11–16) | Long run + taper | 10K on race day |

## Implementation plan

### Act I — base building (weeks 1–4)
- [x] 1. Week 1: jog 1 min / walk 2 min × 8, three times.
- [~] 2. Week 2: jog 2 / walk 2 × 7.
- [ ] 3. Week 3: jog 4 / walk 2 × 5 — the attrition week; run with a friend
  (see risks). Depends on 2.
- [ ] 4. Week 4: recovery — walk 30 min × 3, plus stretching.

### Act II — continuous running (weeks 5–10)
- [ ] 5. Weeks 5–6: jog 8–12 min blocks; weekend long run 25→30 min.
  Depends on 4.
- [ ] 6. Week 7: first 20 min continuous. Depends on 5.
- [ ] 7. Week 8: recovery — easy 15 min × 3.
- [ ] 8. Weeks 9–10: run 25→30 min; long run 40→45 min (5K falls here).
  Depends on 7.

### Act III — long run and taper (weeks 11–16)
- [ ] 9. Weeks 11–13: weekday 30 min; long run 50→60→70 min; week 12 recovery.
  Depends on 8.
- [ ] 10. Week 14: long run reaches 8K — replace shoes if near 500km (see
  risks). Depends on 9.
- [ ] 11. Week 15: taper — reduce volume; trust the taper. Depends on 10.
- [ ] 12. Week 16: race day — nothing new (same shoes, breakfast, playlist).
  Depends on 11.

## Verification
- Talk test on every run: if you can't speak a full sentence, the pace is too
  fast — slow down.
- Each phase gates on completing its target continuous run before advancing.
- The week-14 8K is the checkpoint that race distance is achievable.

## Rollout and rollback
If a run feels injurious (sharp pain, not soreness), the fallback is to repeat
the prior week rather than push forward — the schedule has slack because
recovery weeks can absorb a repeated week. Missing a single run is recovered by
resuming the schedule, not by doubling up.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Week 3 attrition (novelty gone, fitness not yet arrived) | Quitting the program | Schedule week-3 runs with a friend; accountability over motivation |
| Skipping recovery weeks | Shin splints, injury layoff | Recovery weeks are non-negotiable, part of the plan |
| Dead shoe cushioning (~500km) on late long runs | Injury during week-14 8K | Shoe checkpoint at week 14; replace if worn |
| Pace too fast (fails talk test) | Overtraining, burnout | Slow to conversational pace on every run |

## Open questions
- Which race: a local park 10K in week 16, or a city run in week 17 (bigger
  crowds, more adrenaline)?
- Add strength cross-training on off days during Act II, or keep it simple?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
