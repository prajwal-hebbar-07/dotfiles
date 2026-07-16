<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Wedding — April 18, botanical garden

Status: draft — 2026-07-13

## Summary
Plan and execute a 140-guest wedding at the botanical garden on April 18, over
a 9-month horizon, organized as five workstreams (Venue, People, Food, Style,
Paperwork) that must all be complete by the day. The plan front-loads the
hard-deadline decisions (band booking, marriage license window) and ends with a
day-of run sheet handed to a coordinator so the couple are passengers on the
day itself.

## Context and current state
- Venue is booked: botanical garden with a contractually confirmed covered
  pavilion as rain backup.
- Guest list is frozen at 140 (down from an initial 162).
- Photographer is down to two finalists, decision pending by Friday.
- Budget by workstream: Venue $8,000, People $500, Food $6,500, Style $3,000,
  Paperwork $200. Owners: Asha (Venue, Food), Rohan (People, Style), both
  (Paperwork).
- Two hard external constraints: the preferred band books ~6 months out, and
  the marriage license is valid only within a 90-day window before the date.

## Goals
- Both people married on April 18 with all five workstreams complete.
- 140 guests hosted; food, seating, and logistics confirmed in advance.
- Day-of execution driven by a run sheet, with no improvisation required from
  the couple.

## Non-goals
- Expanding the guest list beyond 140.
- Day-of decision-making by the couple — those decisions are made in advance
  and delegated to the coordinator.

## Proposed design
The 9 months run as a milestone timeline. The two deadline-bound decisions are
scheduled first: the band-vs-DJ call by the 6-month mark (or the band is lost),
and the marriage-license appointment inside the 90-day window (too early voids
it, too late misses it). Invitations go out at 10 weeks with RSVPs tracked in a
shared sheet; the final RSVP count feeds the caterer's number and the seating
chart. The final week is a terminal count: confirm every vendor by phone,
hand the run sheet to the day-of coordinator, and prepare an emergency kit.

## Change inventory
| Workstream | Current state | Target state |
| --- | --- | --- |
| Venue | Booked, rain backup confirmed | Re-verify pavilion at T-1 month |
| People | Guest list frozen at 140 | Save-the-dates → invites → RSVPs tracked |
| Food | Caterer tasting pending | Menu locked after tasting #2 |
| Style | Not started | Photographer chosen; 3 fitting rounds |
| Paperwork | Not started | License obtained inside 90-day window |

## Implementation plan

### T-9 to T-7 months — foundation
- [x] 1. Book venue with rain backup.
- [x] 2. Freeze guest list at 140.
- [~] 3. Choose photographer from two finalists (decide by Friday).
- [ ] 4. Caterer tasting #1 (venue-approved). Depends on 1.

### T-6 to T-4 months — commitments
- [ ] 5. Save-the-dates out. Depends on 2.
- [ ] 6. Band vs. DJ decision — hard deadline at T-6 (band books 6 months out).
- [ ] 7. Outfit fittings, round 1 of 3.
- [ ] 8. Registry live; hotel room blocks for out-of-town guests.

### T-3 to T-1 months — lock-in
- [ ] 9. Invitations out at T-10 weeks; RSVPs tracked. Depends on 5.
- [ ] 10. Menu locked after tasting #2. Depends on 4.
- [ ] 11. Seating chart v1. Depends on 9.
- [ ] 12. Marriage license inside the 90-day window.
- [ ] 13. Day-of run sheet: every vendor, phone number, and time from 7am to
  midnight. Depends on 10, 11.

### T-1 week — terminal count
- [ ] 14. Confirm every vendor by phone, not text. Depends on 13.
- [ ] 15. Hand run sheet to the day-of coordinator. Depends on 13.
- [ ] 16. Break in shoes; assemble emergency kit (needle, stain pen, backup
  ring, snacks).

### Day of
- [ ] 17. Eat breakfast.
- [ ] 18. Phones off at 3pm; get married.

## Verification
- Every vendor confirmed by a live phone call in the final week.
- Final RSVP count reconciled against the caterer's headcount and the seating
  chart.
- Run sheet reviewed end-to-end with the coordinator before the day.
- Pavilion rain backup re-verified in writing at T-1 month.

## Rollout and rollback
Rain contingency: the covered pavilion is the confirmed fallback and needs no
day-of decision. If a vendor drops out before the final week, the shared
tracker surfaces it in time to rebook; after the final-week confirmation calls
there is no rollback, which is why those calls are the gate.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Preferred band books out ~6 months ahead | Lose the band | Decide by the hard T-6 deadline, not by preference |
| License is a 90-day validity window | Booking too early voids it | Schedule the appointment inside the window, not before |
| April rain | Outdoor ceremony disrupted | Confirmed covered pavilion; re-verify at T-1 month |

## Open questions
- Kids at the reception: full invite, ceremony-only, or a staffed sitter room?
- Is table distance enough to separate the two uncles, or is a dedicated
  seating zone needed?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
