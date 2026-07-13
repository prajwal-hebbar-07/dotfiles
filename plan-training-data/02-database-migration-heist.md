---
plan: Operation Quiet Swap
slug: mysql-to-postgres
kind: migration
created: 2026-07-13
horizon: 6 hours (one maintenance window)
mood: heist-movie
structure: countdown
---

# Operation Quiet Swap 🕶️

Status: draft — 2026-07-13

## Goal
Move 40M rows from `users_legacy` (MySQL 5.7) to the new Postgres 16 cluster in
one 6-hour window. Zero data loss; nobody notices a thing.

## Shape

```text
             ┌──▶ MySQL 5.7  (old vault, becomes shadow)
app writes ──┤        │ checksum + row-count verify
             └──▶ Postgres 16 (new vault)
                       ▲
   backfill: 8 workers, 40M rows, oldest-first
app reads ── flag ──▶ MySQL ▸ flips to ▸ Postgres at T-0:45
```
[DIAGRAM PROMPT: heist corkboard with two bank blueprints — "MySQL 5.7, creaky
vault" and "Postgres 16, laser grid". App writes fan out to BOTH vaults
(dual-write); a conveyor of gold bars labeled "backfill: 8 workers, 40M rows"
runs old→new; a big lever labeled "read flag" points at MySQL then swings to
Postgres. Red string, analog countdown clock at T-6:00. Emphasize that writes
hit both vaults before reads ever move.]

```text
alarm ──▶ before read-swap (T-0:45)? ──yes──▶ kill backfill, drop dual-write, exit clean
                    │no
                    ▼
          flip reads back to MySQL (30s) ──▶ assess ──▶ retry next window
```
[DIAGRAM PROMPT: emergency escape-route map as a decision tree — root node
"alarm goes off"; branch "before the T-0:45 read swap?": yes-path = kill
backfill, disable dual-write, walk away clean; no-path = flip the read flag
back to MySQL (30 seconds), assess, retry next window. Every path ends at a
door labeled "everyone goes home safe". Emphasize the 30-second reversibility
of the read flag.]

## Plan

### Casing the joint (done, T-7 days)
- [x] 1. three full rehearsals on staging clone — best time 4h 12m (effort: L)
- [x] 2. checksum + row-count verification scripts tested (effort: M)
- [x] 3. rollback rehearsed twice — we do not skip rollback rehearsal, ever (effort: M)

### T-6:00 — doors lock
- [ ] 4. maintenance banner up, deploys frozen, pipeline is ours alone (effort: S)
- [ ] 5. Dana (DBA): go/no-go checkpoint #1 (effort: S) needs: 4

### T-5:45 — dual-write begins
- [ ] 6. flip the shim: every write lands in BOTH databases (effort: S) needs: 5
- [ ] 7. confirm write p99 < 40ms; abort clean if > 80ms (effort: S) needs: 6

### T-5:30 — moving the gold
- [ ] 8. bulk backfill, 8 parallel workers, oldest-first, ~10M rows/hour (effort: XL) needs: 7
- [ ] 9. progress checkpoint every 15 min against pace line (effort: S) needs: 8

### T-1:30 — verification (nobody breathes)
- [ ] 10. checksums across 12 table groups; row counts EXACT, not "close" (effort: M) needs: 8
- [ ] 11. spot-check 500 random users end-to-end through the API (effort: M) needs: 10
- [ ] 12. Dana: go/no-go checkpoint #2 — point of no return (effort: S) needs: 11

### T-0:45 — the swap
- [ ] 13. reads flip to Postgres via config flag; watch errors 15 min (effort: S) needs: 12
- [ ] 14. writes flip to Postgres-primary; MySQL becomes shadow (effort: S) needs: 13

### T-0:15 — the getaway
- [ ] 15. banner down; MySQL kept in dual-write shadow 7 days as insurance (effort: S) needs: 14
- 🎉 MILESTONE: users wake up, nothing looks different — that's how you know we nailed it

## Edge cases & risks
⚠️ RISK: dual-write doubles load — abort threshold is write p99 > 80ms, no exceptions, no heroics.
⚠️ RISK: backfill racing live dual-writes on the same rows — workers use upsert-if-older, never blind insert.
⚠️ RISK: peeking-style scope creep mid-window ("while we're down, let's also…") — the window does ONE job.

## Open questions
- Shadow-mode retention: 7 days or 14? (storage cost vs paranoia)
- Sequence/ID reconciliation for rows created during the swap minute itself — accept 1-min write pause instead?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
