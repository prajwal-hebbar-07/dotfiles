<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Nimbus — public launch plan

Status: draft — 2026-07-13

## Summary
Take Nimbus from private beta to a public launch targeting ~5,000 week-one
signups over 8 weeks. Four workstreams — Product, Story, Distribution, and
Kitchen Ops — run in parallel and converge on a single launch day in week 8.
The launch scope is fixed at week 1; new ideas go to a "second course" backlog
rather than delaying the date.

## Context and current state
- Product is in private beta with a known feedback corpus.
- No public positioning statement, pricing page, or launch assets exist yet.
- Infrastructure has not been load-tested for public traffic.
- Team can commit to a fixed launch date once it is stated openly.

## Goals
- Public launch in week 8 serving ~5,000 week-one signups.
- A clear one-sentence positioning statement, live pricing, and a sub-3-minute
  first-run-to-value onboarding.
- Coordinated launch-day distribution (Product Hunt, warm list, founder post,
  press/newsletter pitches).
- Infrastructure that holds at 20× expected traffic with a graceful
  degradation path.

## Non-goals
- Feature additions during the launch window beyond the fixed scope.
- International or enterprise motions — this is the public self-serve launch.

## Proposed design
Week 1 is preparation: lock the one-sentence positioning, state the launch date
to the whole team, and assemble inputs (beta feedback, competitor teardown,
pricing draft). Weeks 2–7 run four parallel workstreams:

- Product (w2–6): fix the top-3 recurring beta bugs, get first-run-to-value
  under 3 minutes (timed on a real stranger), wire the pricing page to billing.
- Story (w2–5): landing headline validated on 5 target users, a 90-second demo
  video, and an honest founder launch post.
- Distribution (w3–7): warm the 400-user beta list, line up a Product Hunt
  hunter for a 12:01am PT go-live, pitch 10 podcasts/newsletters (expect ~2
  yeses), and seed helpfully in 5 communities.
- Kitchen Ops (w5–7): load-test at 20×, define a support rota, and prepare a
  status page with a pre-written degradation banner.

Week 8 is launch: a T-1 dress rehearsal, launch day with founders in the
comments answering within 30 minutes, a visible day-2/3 improvement, and a
results readout against the 5,000 target.

## Change inventory
| Workstream | Weeks | Deliverable |
| --- | --- | --- |
| Product | 2–6 | Bug kill-list, <3min onboarding, billing wired |
| Story | 2–5 | Validated headline, demo video, launch post |
| Distribution | 3–7 | Warm list, Product Hunt, press pitches, seeding |
| Kitchen Ops | 5–7 | 20× load test, support rota, status page |
| Launch | 8 | Rehearsal, launch day, day-2 ship, readout |

## Implementation plan

### Preparation (week 1)
- [x] 1. Lock the one-sentence positioning ("Nimbus is ___ for ___ who are
  tired of ___").
- [~] 2. State the launch date openly to the whole team.
- [ ] 3. Assemble inputs: beta feedback corpus, competitor teardown, pricing
  draft.

### Product (weeks 2–6)
- [ ] 4. Fix the top 3 recurring beta bugs. Depends on 3.
- [ ] 5. First-run-to-value under 3 minutes, timed on a real stranger.
- [ ] 6. Pricing page wired to real billing. Depends on 3.

### Story (weeks 2–5)
- [ ] 7. Landing headline validated on 5 target users. Depends on 1.
- [ ] 8. 90-second demo video of the real product.
- [ ] 9. Founder launch post with an honest origin story. Depends on 1.

### Distribution (weeks 3–7)
- [ ] 10. Warm-list email to 400 beta users.
- [ ] 11. Product Hunt: hunter lined up, assets prepped, 12:01am PT.
  Depends on 8.
- [ ] 12. 10 podcast/newsletter pitches by week 5 (expect ~2 yeses).
  Depends on 9.
- [ ] 13. Helpful community seeding in 5 forums.

### Kitchen Ops (weeks 5–7)
- [ ] 14. Load-test at 20× expected traffic. Depends on 6.
- [ ] 15. Launch-week support rota with escalation path.
- [ ] 16. Status page plus a pre-written degradation banner.

### Launch (week 8)
- [ ] 17. T-1 dress rehearsal: click every link as an unfamiliar user.
  Depends on 4, 5, 6, 7, 8, 9, 10, 11, 14.
- [ ] 18. Launch day: founders in the comments, every question answered within
  30 minutes. Depends on 17.
- [ ] 19. Day 2–3: ship one visible improvement from launch feedback.
  Depends on 18.
- [ ] 20. Results readout: signups/activation/conversion vs. the 5,000 target.
  Depends on 18.

## Verification
- Onboarding timed under 3 minutes on a real first-time user.
- Load test sustains 20× expected traffic without errors.
- T-1 rehearsal confirms every link and flow works end-to-end.
- Launch-day metrics measured against the 5,000-signup target.

## Rollout and rollback
Launch day starts at 12:01am PT on Product Hunt with the warm-list email as the
first owned channel. If infrastructure is overwhelmed, the pre-written
degradation banner and status page communicate rather than the site simply
failing; the load test at 20× is the guard that this is a "slammed," not
"down," scenario. There is no rollback of a public launch, so the T-1
rehearsal is the gate.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Feature-stuffing before launch | Slipped date, unstable build | Scope fixed at week 1; new ideas go to a backlog |
| Community seeding reads as astroturf | Reputation damage | Help first; mention Nimbus only when it truly answers |
| Traffic estimate (20×) is a guess | Overload on launch day | Degradation banner + status page + load test |

## Open questions
- Pricing: launch with an annual discount, or monthly-only for cleaner
  week-one data?
- Product Hunt day: Tuesday (more traffic) or Sunday (less competition)?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
