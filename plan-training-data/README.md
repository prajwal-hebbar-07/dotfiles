# Plan Training Data

A corpus of sample plans for training/testing an app that renders plans
beautifully. Every file follows the exact grammar the `/plan` skill emits
(see the skill's "AI-renderable layer"), so a renderer built against this
corpus handles real `plans/plan-<slug>.md` files unchanged.

## File anatomy (identical in every sample)

```markdown
---
plan: <Plan title>            # display title
slug: <kebab-slug>            # stable id
kind: <open vocabulary>       # feature|migration|refactor|experiment|travel|…
created: <YYYY-MM-DD>
horizon: <rough time span>    # "6 hours" … "9 months"
mood: <flavor, optional>      # extra key, safe to ignore
structure: <flavor, optional> # extra key, safe to ignore
---

<!-- plan-review guide … -->   # optional HTML comment; real files may open
                               # with it (sample 01 includes it) — skip it

# <Title>

Status: draft — <YYYY-MM-DD>   # plan lifecycle line, updated by review rounds

## Goal                        # 1-2 lines, what & scope
## Shape                       # ASCII diagrams, each fence followed by caption
## Plan                        # numbered checkbox entries, optionally ### phases
## Edge cases & risks          # ⚠️ RISK: lines
## Open questions              # unresolved decisions, one per line
## Review changelog            # appended by /plan-review, may be empty
```

## The renderer grammar (parse contract)

| Token | Meaning |
|-------|---------|
| ` ```text … ``` ` in `## Shape` | ASCII diagram (terminal-readable fallback) |
| `[DIAGRAM PROMPT: …]` directly after a fence | self-contained description of the visual to generate — type, named elements, labeled relationships, emphasis, mood; needs zero outside context |
| `- [ ] N. …` | plan step N, todo |
| `- [x]` / `- [~]` / `- [!]` | done / in progress / blocked |
| `(effort: S\|M\|L\|XL)` | size tag, optional |
| `needs: 1,2` | step depends on steps 1 and 2 → draw the dependency edge |
| `### heading` inside `## Plan` | phase / swimlane boundary |
| `⚠️ RISK:` line | risk callout |
| `🎉 MILESTONE:` line | celebration checkpoint at a phase boundary |
| `[new]` / `[existing]` | artifact does not exist yet / verified existing |

## What varies (on purpose)

| Axis | Coverage |
|------|----------|
| **Domain** | software feature, db migration, incident recovery, wedding, fitness, learning roadmap, product launch, travel, side-project rescue, A/B experiment |
| **Phase shape** | phased waterfall, T-minus countdown, milestone timeline, week-by-week acts, triage severity lanes, basecamps, parallel burners, day-by-day with branches, kanban weeks, hypothesis loop |
| **Time scale** | 6 hours → 9 months |
| **Voice** | quest, heist, mission control, montage, field hospital, trail guide, cooking show, choose-your-own-adventure, garage restoration, lab notebook |

Statuses are deliberately mixed across files (some `[x]`, `[~]`, `[!]`) so a
renderer must handle plans in flight, not just fresh ones. Non-software plans
use task phrasing where code plans use `path/to/file.ts:symbol — change`;
the surrounding grammar is identical.
