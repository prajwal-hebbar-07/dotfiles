<!-- plan-review guide (delete when done):
  - Leave notes for Claude as HTML comments beginning with @me, e.g.:
        @me: use Postgres, not Redis
    In nvim, Space+pc inserts one under the cursor.
  - Save, then press Space+pr to send your notes to Claude.
  - Claude edits this file in place; the split reloads automatically.
  - Close this pane (:q) when the Status line says ready to implement.
  - /plan-detail <question> for follow-up analysis; /plan-done after implementation.
-->

# Learning Rust — 26-week roadmap

Status: reviewed (round 1) — 2026-07-15

## Summary
Go from early-stage programmer (some Python, not yet fluent) to shipping Rust in
production in 26 weeks at ~5 hours/week. Because Rust is effectively the first
language the learner will get truly comfortable in, the roadmap builds general
programming fundamentals alongside Rust rather than assuming they transfer in
from Python — expect the early checkpoints to carry more weight and possibly run
long. It is organized around four checkpoints, each gated by a build project
rather than reading, so progress is verified by working code. It plans
explicitly for the weeks 5–7 ownership/borrow-checker slump, which is the usual
quit point, and defers optional side topics (async, unsafe, WASM) so scope stays
contained.

## Context and current state
- Starting point: some Python exposure but not yet fluent in any language; new
  to Rust and to systems-level ownership/borrowing concepts. Rust is effectively
  the first language the learner will get comfortable in, so general programming
  fundamentals (control flow, functions, collections, testing, reading
  compiler/runtime errors) are being learned alongside Rust-specific material
  rather than transferring in.
- Budget: ~5 hours/week for 26 weeks.
- Known difficulty: the ownership and borrow-checker material (around weeks
  5–7) is where most learners stall; the value only appears "an app or two
  later," not immediately.
- Optional detours (async/tokio, unsafe, WASM) each add time; async alone adds
  ~3 weeks.

## Goals
- Ship one real Rust artifact by week 26 (deployed service, published crate, or
  merged OSS contributions).
- A working build project completed at each of the four checkpoints.
- Genuine comfort with ownership, borrowing, traits, error handling, and basic
  concurrency.
- General programming fluency — Rust as the first language the learner is
  comfortable in, not just the Rust-specific concepts layered on top.

## Non-goals
- Depth in async, unsafe, or WASM this cycle — they are optional side trails.
- Mastering macros or advanced type-level programming.

## Proposed design
The roadmap has four checkpoints, each ending in a build project that gates
advancement.

Checkpoint 1 (weeks 1–4): the Rust Book chapters 1–9 and Rustlings, capped by a
CLI todo app with file persistence. The borrow-checker pass (weeks 5–7)
re-reads ownership more slowly and builds a borrow-heavy in-memory key-value
store. Checkpoint 2 (weeks 8–12): traits, generics, idiomatic error handling
(`Result`, `thiserror`, `anyhow`), and iterators, capped by a streaming JSON
log parser that stays flat in memory on a 2GB file. Checkpoint 3 (weeks 13–18):
threads, channels, `Arc<Mutex<T>>`, capped by a parallel website checker with a
worker pool and graceful Ctrl-C. The summit (weeks 19–26): commit to one route
— a deployed axum API, a published crate with users, or three merged OSS PRs —
and write a retrospective.

## Change inventory
| Checkpoint | Focus | Build project (gate) |
| --- | --- | --- |
| 1 (w1–4) | Book ch. 1–9, Rustlings | CLI todo with file persistence |
| Pass (w5–7) | Ownership & borrowing | Borrow-heavy KV store |
| 2 (w8–12) | Traits, errors, iterators | Streaming JSON log parser (2GB, flat mem) |
| 3 (w13–18) | Concurrency | Parallel website checker |
| Summit (w19–26) | One real deliverable | axum API / published crate / 3 OSS PRs |

## Implementation plan

### Checkpoint 1 — foundations (weeks 1–4)
This checkpoint doubles as the general-programming on-ramp, so it may run past
week 4 — that is expected, not a failure. Do not rush ch. 1–9 or skip Rustlings
to "catch up."
- [x] 1. Rust Book ch. 1–9, skipping nothing (especially ch. 4).
- [~] 2. Rustlings through `move_semantics`.
- [ ] 3. Build: CLI todo app with file persistence. Depends on 1.

### Borrow-checker pass (weeks 5–7)
- [ ] 4. Re-read the ownership chapter slowly; read compiler errors as
  guidance. Depends on 3.
- [ ] 5. Build: in-memory key-value store with a borrow-heavy API. Depends on 4.

### Checkpoint 2 — structures (weeks 8–12)
- [ ] 6. Traits, generics, error handling (`Result`, `thiserror`, `anyhow`).
  Depends on 5.
- [ ] 7. Iterators and closures until they feel natural. Depends on 6.
- [ ] 8. Build: streaming JSON log parser, 2GB file, flat memory — measure it.
  Depends on 7.

### Checkpoint 3 — concurrency (weeks 13–18)
- [ ] 9. Threads, channels, `Arc<Mutex<T>>`, and when not to use them.
  Depends on 8.
- [ ] 10. Optional side trail: async/tokio — only if goals include network
  services; adds ~3 weeks.
- [ ] 11. Build: parallel website checker — 500 URLs, worker pool, graceful
  Ctrl-C. Depends on 9.

### Summit (weeks 19–26)
- [ ] 12. Pick one route and commit: (A) deployed axum HTTP API, (B) CLI tool
  on crates.io with users, or (C) three merged PRs to a Rust OSS project.
  Depends on 11.
- [ ] 13. Write a retrospective on the six months. Depends on 12.

## Verification
- Each checkpoint gates on its build project compiling and running, not on
  chapters read.
- The week-8 log parser is verified by measuring memory stays flat on a 2GB
  input.
- The summit deliverable is verified by it being real: deployed, published, or
  merged.

## Rollout and rollback
Because Checkpoint 1 now carries the general-programming fundamentals too, it is
acceptable for it to overrun weeks 1–4; the 26-week timeline is a target, not a
gate. Better to extend the on-ramp than to reach the ownership pass without solid
programming basics. If the weeks 5–7 slump stalls progress, the fallback is to
repeat the pass with
a smaller borrow-heavy project rather than skipping ahead — later checkpoints
depend on ownership fluency. Optional side trails can be dropped entirely
without affecting the summit; they are additive, not prerequisites.

## Risks and mitigations
| Risk | Impact | Mitigation |
| --- | --- | --- |
| Learning general programming and Rust's ownership model at the same time | Slower early progress, compounding confusion | Treat Checkpoint 1 as an on-ramp: don't rush ch. 1–9, do every Rustling, let it run past week 4 if needed before the ownership pass |
| Weeks 5–7 slump ("I could've done this some other way") | Quitting | Reframe: the payoff is the app after next; gate on the build project |
| Tutorial loops (reading instead of building) | No real progress | Every checkpoint gates on a build project |
| Taking every side trail | Timeline blowout | Defer async/unsafe/WASM; they remain available later |

## Open questions
- Summit route A/B/C — decide at checkpoint 3 based on how week-11's project
  felt?
- Pair with a study buddy or go solo with community check-ins?

## Review changelog
<!-- /plan-review appends a dated round entry here each pass -->

### Round 1 — 2026-07-15
- Summary / Context / Goals: corrected the premise — you're not fluent in Python
  either, so the roadmap now builds general programming fundamentals alongside
  Rust instead of assuming they transfer in. Assumed "some Python exposure, not
  yet fluent" rather than never-written-code; flag if you're a total beginner and
  we'll add a pre-week-1 programming primer.
- Checkpoint 1 / Rollout / Risks: reframed Checkpoint 1 as a general-programming
  on-ramp that may run past week 4 (timeline is a target, not a gate), and added
  a risk for learning fundamentals and ownership at the same time.
- Weeks 5–7 slump risk: dropped the "could've done this in Python" framing since
  Python isn't a fallback you're fluent in.
