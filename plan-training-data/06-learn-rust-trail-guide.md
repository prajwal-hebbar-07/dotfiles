---
plan: Learning Rust, A Trail Guide
slug: learn-rust
kind: learning
created: 2026-07-13
horizon: 6 months
mood: trail-guide
structure: territory-map-with-basecamps
---

# Learning Rust: A Trail Guide 🦀🥾

Status: draft — 2026-07-13

## Goal
From comfortable-in-Python to shipping Rust in production in 26 weeks at 5
hrs/week, with a build project at every basecamp. The borrow checker is a
strict but fair park ranger, not a wall.

## Shape

```text
Pythonista Village ──▶ 🏕️1 Foothills ──▶ ⛰️ Borrow Checker Pass
      ──▶ 🏕️2 Structures Ridge ──▶ 🏕️3 Concurrency Col ──▶ 🏔️ SUMMIT
side trails: Async Ridge (tokio, +3wk) · Unsafe Caverns (permit) · WASM Lookout
```
[DIAGRAM PROMPT: national-park trail map — trailhead "Pythonista Village" at
bottom, main trail winding up through Basecamp 1 "Foothills" (green circle),
"Borrow Checker Pass" (blue square, friendly ranger station icon — NOT a
danger icon), Basecamp 2 "Structures Ridge" (blue square), Basecamp 3
"Concurrency Col" (black diamond), summit flag "Shipping Rust in Production".
Dotted side trails: "Async Ridge (tokio)", "Unsafe Caverns (permit required)",
"WASM Lookout". Difficulty legend with green circle / blue square / black
diamond. Emphasize the pass is guarded, not blocked.]

```text
morale
high ┤ ▔▔▔╲                        ╱▔▔▔▔ "I have become the checker"
     │     ╲    the trough      ╱
low  ┤       ╲▁▁▁▁w6▁▁▁▁▁▁▁▁▁╱
     └──w1──────w6────w12────w20────w26
```
[DIAGRAM PROMPT: elevation cross-section of learner morale weeks 1–26 — high
at the trailhead, deep valley labeled "The Borrow Checker Trough" around week
6, rising ridge with small dips, cresting at "it compiles first try and I felt
nothing (I have become the checker)". Emphasize the trough is expected
terrain, marked on the map in advance.]

## Plan

### 🏕️ Basecamp 1 — the foothills (weeks 1–4)
- [x] 1. Rust Book ch. 1–9 — skip nothing, ESPECIALLY ch. 4 (effort: M)
- [~] 2. Rustlings through move_semantics (effort: M)
- [ ] 3. build: CLI todo app with file persistence (effort: M) needs: 1
- 🎉 MILESTONE: cargo build runs clean and you knew WHY each error happened

### ⛰️ Borrow Checker Pass (weeks 5–7)
- [ ] 4. ownership chapter again, slower; errors read like ranger signs — they literally tell you the way around (effort: M) needs: 3
- [ ] 5. build: in-memory key-value store with a borrow-heavy API (effort: L) needs: 4

### 🏕️ Basecamp 2 — structures ridge (weeks 8–12)
- [ ] 6. traits, generics, error handling done right: Result, thiserror, anyhow (effort: L) needs: 5
- [ ] 7. iterators & closures until for-loops look quaint (effort: M) needs: 6
- [ ] 8. build: streaming JSON log parser, 2GB file, flat memory — measure it, frame the number (effort: L) needs: 7

### 🏕️ Basecamp 3 — concurrency col (weeks 13–18)
- [ ] 9. threads, channels, Arc<Mutex<T>> and when NOT to reach for it (effort: L) needs: 8
- [ ] 10. optional side trail: Async Ridge (tokio) — only if goals include network services; +3 weeks (effort: L)
- [ ] 11. build: parallel website checker — 500 URLs, worker pool, graceful Ctrl-C (effort: L) needs: 9

### 🏔️ Summit push (weeks 19–26)
- [ ] 12. pick ONE route and commit: (A) axum HTTP API deployed somewhere real, (B) CLI tool on crates.io with actual users, or (C) 3 merged PRs to a Rust OSS project (effort: XL) needs: 11
- [ ] 13. trip report blog post: "Six months of Rust: what the brochure didn't say" (effort: M) needs: 12
- 🎉 MILESTONE: summit — you now say "the borrow checker is your friend" at parties; there is no cure

## Edge cases & risks
⚠️ RISK: weeks 5–7 are the quit point — symptom: "I could've built this in Python in an hour." True, and the wrong trail metric; you're here for the app after next.
⚠️ RISK: tutorial loops (reading about hiking instead of hiking) — every basecamp gates on its build project, no exceptions.
⚠️ RISK: taking every side trail — Async Ridge alone adds 3 weeks; unsampled trails remain legal to visit later.

## Open questions
- Summit route A/B/C — decide at basecamp 3 based on what week 11's project felt like?
- Pair with a Rust study buddy or solo hike with community check-ins?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->
