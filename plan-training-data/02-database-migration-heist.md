<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Operation Quiet Swap — MySQL to Postgres migration

Status: draft — 2026-07-13

## Summary
Move 40M rows from `users_legacy` (MySQL 5.7) to a new Postgres 16 cluster
inside a single 6-hour maintenance window, with zero data loss and no
user-visible disruption. The approach is dual-write to both databases,
oldest-first backfill, exact checksum verification, then an atomic read-flag
flip followed by a write-primary flip. MySQL is retained as a dual-write
shadow for 7 days as insurance.

## Context and current state
- Source is `users_legacy` on MySQL 5.7, ~40M rows across 12 table groups,
  fronted by a write shim the application already routes through.
- Target is a provisioned Postgres 16 cluster with the schema created and
  validated on a staging clone.
- Three full rehearsals on a staging clone have completed; best end-to-end
  time was 4h 12m against the 6h window.
- Checksum and row-count verification scripts, and the rollback procedure,
  have been tested. Rollback was rehearsed twice.
- The application read/write path is controlled by a config flag, enabling a
  ~30-second reversible read swap.

## Goals
- All 40M rows present in Postgres with checksums and row counts matching
  exactly, not approximately.
- Reads and writes cut over to Postgres within the 6-hour window.
- Full reversibility until the point of no return (the write-primary flip).
- No user-visible errors or downtime beyond the maintenance banner.

## Non-goals
- Any schema redesign or "while we're down" side work — the window does one
  job.
- Migrating databases other than `users_legacy`.
- Retiring MySQL during this window; it stays as a shadow.

## Proposed design
The migration runs on a T-minus countdown within the window.

Writes are dual-written to both databases via the existing shim before any read
moves, so Postgres is continuously current during backfill. The bulk backfill
runs 8 parallel workers oldest-first at ~10M rows/hour, using upsert-if-older
semantics so a worker never overwrites a fresher dual-written row. Verification
compares checksums across all 12 table groups and requires exact row counts,
plus an end-to-end API spot-check of 500 random users.

Cutover is two steps. First the read flag flips to Postgres (reversible in ~30
seconds); errors are watched for 15 minutes. Then the write path flips to
Postgres-primary and MySQL becomes the shadow — this is the point of no return.

Abort thresholds are fixed in advance: dual-write roughly doubles write load,
so if write p99 exceeds 80ms the migration aborts cleanly by dropping
dual-write and backfill.

## Change inventory
| Area | Current artifact | Planned change |
| --- | --- | --- |
| Write shim | dual-write config | enable writes to both DBs |
| Backfill | rehearsed script | run 8 workers, oldest-first, upsert-if-older |
| Verification | checksum + row-count scripts | run across 12 table groups + 500-user API spot-check |
| Read path | config flag → MySQL | flip to Postgres, then flip write-primary |
| Shadow | — | keep MySQL in dual-write shadow for 7 days |

## Implementation plan

### Casing (complete, T-7 days)
- [x] 1. Three full staging-clone rehearsals; best time 4h 12m.
- [x] 2. Checksum and row-count verification scripts tested.
- [x] 3. Rollback rehearsed twice — never skipped.

### T-6:00 — window opens
- [ ] 4. Maintenance banner up, deploys frozen, pipeline reserved.
- [ ] 5. DBA go/no-go checkpoint #1. Depends on 4.

### T-5:45 — dual-write
- [ ] 6. Flip the shim so every write lands in both databases. Depends on 5.
- [ ] 7. Confirm write p99 < 40ms; abort cleanly if > 80ms. Depends on 6.

### T-5:30 — backfill
- [ ] 8. Bulk backfill, 8 parallel workers, oldest-first, ~10M rows/hour.
  Depends on 7.
- [ ] 9. Progress checkpoint every 15 min against the pace line. Depends on 8.

### T-1:30 — verification
- [ ] 10. Checksums across 12 table groups; row counts exact. Depends on 8.
- [ ] 11. End-to-end API spot-check of 500 random users. Depends on 10.
- [ ] 12. DBA go/no-go checkpoint #2 — point of no return. Depends on 11.

### T-0:45 — cutover
- [ ] 13. Flip reads to Postgres via config flag; watch errors 15 min.
  Depends on 12.
- [ ] 14. Flip writes to Postgres-primary; MySQL becomes shadow. Depends on 13.

### T-0:15 — close out
- [ ] 15. Banner down; keep MySQL in dual-write shadow 7 days. Depends on 14.

## Verification
- Checksum equality across all 12 table groups is the gating pass/fail signal.
- Row counts must match exactly, not within tolerance.
- 500-user end-to-end API spot-check confirms application-level correctness.
- Write p99 monitored continuously against the 80ms abort threshold.

## Rollout and rollback
Cutover is staged for reversibility. Before the read swap (T-0:45), abort is
clean: kill backfill and disable dual-write, leaving MySQL authoritative. After
the read swap but before the write-primary flip, reverting is a ~30-second read
flag flip back to MySQL. After the write-primary flip (step 14) the migration
is committed; recovery would come from the 7-day MySQL shadow. Retry, if
aborted, is scheduled for the next maintenance window.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Dual-write doubles load | Latency spike, user impact | Hard abort at write p99 > 80ms, no exceptions |
| Backfill races live dual-writes on the same row | Stale overwrite / data loss | Workers use upsert-if-older, never blind insert |
| Scope creep mid-window | Window overruns, correctness risk | The window does one job; extra work is out of scope |

## Open questions
- Shadow-mode retention: 7 days or 14 (storage cost vs. insurance)?
- Sequence/ID reconciliation for rows created during the swap minute — accept a
  1-minute write pause to avoid it, or reconcile after?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
