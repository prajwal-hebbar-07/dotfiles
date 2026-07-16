<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Japan — 12-day itinerary with branches

Status: draft — 2026-07-13

## Summary
A 12-day trip built as a fixed spine of booked commitments — Tokyo (4 days) →
Kyoto (4 days) → one chosen branch city (3 days) → Osaka fly-out — with
deliberate branch points for weather and energy so the plan bends without
breaking. The design caps activity density to avoid burnout and defers the
biggest choice (the days 9–11 city) until day 7, since all three options are
rail-pass covered and cost nothing to defer.

## Context and current state
- Rail pass covers intercity travel, so the choice of branch city carries no
  incremental transport cost.
- Fixed bookings anchor the spine: teamLab (Tokyo, day 2, 10am), an izakaya
  reunion dinner (day 4), and a kaiseki dinner (Kyoto, day 8).
- Two reversible branch points are built in: a day-3 weather branch (Nikko if
  sunny, Ghibli Museum if raining — the Ghibli slot is pre-booked as rain
  insurance) and a day-7 energy branch (Arashiyama bikes if high-energy, a
  garden and tea ceremony if low).
- Travel is near a golden-week-adjacent period, so Shinkansen seats should be
  reserved a day ahead.

## Goals
- See Tokyo, Kyoto, one chosen region, and Osaka over 12 days without
  over-scheduling.
- Keep flexibility for weather and energy while protecting the booked anchors.
- Decide the days 9–11 city on day 7 with full information and no cost penalty.

## Non-goals
- Maximizing sights per day — density is deliberately capped at ~4 activities.
- Pre-committing the branch city before day 7.

## Proposed design
The itinerary is a spine with dotted branches. Days 1–4 are Tokyo, opening with
a jet-lag day (no schedule) and capping density to avoid a burned-out day 6.
Days 5–8 are Kyoto, including an early Fushimi Inari start for empty photos.
The day-3 and day-7 branches resolve on the day based on weather and energy; the
rain option is pre-booked so choosing it is free.

The days 9–11 branch chooses one of three regions, decided over dinner on day 7:
Hiroshima + Miyajima (reflective, ~2h by rail), Kanazawa (gardens and gold leaf,
~2h15), or Koya-san (temple stay, unplugged, ~3h). Day 12 is an Osaka send-off
before the 6:30pm KIX flight.

## Change inventory
| Segment | Days | Anchor / branch |
| --- | --- | --- |
| Tokyo | 1–4 | teamLab (d2), izakaya (d4); d3 weather branch |
| Kyoto | 5–8 | Fushimi Inari (d6), kaiseki (d8); d7 energy branch |
| Chosen city | 9–11 | Branch A/B/C, decided day 7 |
| Osaka | 12 | Dōtonbori, 6:30pm KIX flight |

## Implementation plan

### Days 1–4 — Tokyo
- [x] 1. Day 1: jet-lag protocol — no schedule; Yanaka streets; early night.
- [ ] 2. Day 2: Tsukiji outer market → teamLab (booked 10am) → Shibuya at dusk.
  Depends on 1.
- [ ] 3. Day 3: weather branch — Nikko day trip if sunny, else Ghibli Museum
  (pre-booked) + Kichijoji.
- [ ] 4. Day 4: split up on purpose (Akihabara vs. Meiji shrine); reunite 7pm
  izakaya (booked).

### Days 5–8 — Kyoto
- [ ] 5. Day 5: Shinkansen morning (right-side seat for Fuji) → Gion evening
  walk. Depends on 4.
- [ ] 6. Day 6: Fushimi Inari at 7am for empty photos. Depends on 5.
- [ ] 7. Day 7: energy branch — Arashiyama bikes if high-energy, else Ryōan-ji +
  tea ceremony + nap.
- [ ] 8. Day 8: Nara half-day → kaiseki dinner (booked). Depends on 7.

### Days 9–11 — chosen branch (decide day 7)
- [ ] 9. Branch A: Peace Museum morning → island ryokan → floating torii at high
  tide.
- [ ] 10. Branch B: Kenroku-en garden → samurai district → fish-market
  breakfast.
- [ ] 11. Branch C: temple lodging → 6am meditation → shojin-ryori dinner
  (phones off).

### Day 12 — Osaka
- [ ] 12. Dōtonbori food crawl (takoyaki → kushikatsu → takoyaki). Depends on 9.
- [ ] 13. KIX flight, 6:30pm.

## Verification
- All fixed anchors (teamLab, izakaya, kaiseki) hold booked times.
- Shinkansen seats reserved the day before each intercity leg.
- The day-3 rain option remains pre-booked so the weather branch stays free.
- Branch-city lodging booked as soon as the day-7 decision is made.

## Rollout and rollback
The branches are the rollback mechanism: weather or fatigue on the day selects
the lighter option without disrupting the booked spine. The day-9–11 city
decision is deferred to day 7 precisely because deferring is free under the
rail pass. An unbooked buffer day absorbs overruns; if the suitcase won't close,
a konbini duffel is the fallback.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Over-scheduling Tokyo | Burnout by day 6 | Cap density at ~4 activities/day |
| Skipping the day-6 early start | Crowded Fushimi Inari, no re-roll | Keep the 6:15 alarm; it's worth it |
| Golden-week-adjacent crowds on the Shinkansen | No seats at the platform | Reserve seats a day ahead |

## Open questions
- Branch A/B/C — reflective, luxurious, or unplugged (decide day 7 at dinner)?
- The unbooked buffer day: spend it in Kyoto or hold it for the branch city?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
