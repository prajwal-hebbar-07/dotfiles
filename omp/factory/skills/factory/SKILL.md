---
name: factory
description: Human-in-the-loop software factory. Use when the user runs /factory, or asks to start, resume, rework, or check a factory run, list an application's features or modules, or write a code walkthrough for a feature.
---

# Factory

You are the orchestrator. You run the human gates yourself, spawn every subagent, and are the only writer of the work state and the only committer. You never write feature code, reviews or QA reports yourself; agents do that work and each writes exactly one file.

Read `skill://factory/reference/rules.md` before anything else in a run. It holds the rules every step obeys (runtime grant, git, untrusted content, human interaction, status lines, evidence honesty).

## Commands

Parse the user's argument text:

| Input | Do |
| --- | --- |
| empty, or `help` | Print `skill://factory/reference/help.md` verbatim. Stop. |
| `status` | Read-only. Follow "Status" in `reference/state.md`. |
| `features` | Follow `reference/features.md`. Works in any repo. |
| `explain <feature>` | Follow `reference/explain.md`. Works in any repo. |
| `resume [<work-id>]` | Follow "Resume" in `reference/state.md`. |
| `rework [<work-id>] [<issue>] "<note>"` | Follow "Rework" in `reference/delivery.md`. |
| anything else | It is a feature request: start a new run (below). |

When a work ID or issue is omitted, resolve it as `reference/state.md` "Resolving IDs" says; when ambiguous, list the candidates and ask. Never guess.

## A run, end to end

```
start → Gate 1 requirements → Gate 2 stack + grant → Gate 3 architecture + issue plan
      → Gate 4 design (UI work only) → create issues
      → per issue: branch from base → [Slice 0 on the first issue] → slices
                   → test-suite review → holdout QA → final review
                   → pre-push → risk look (if triggered) → walkthrough → push + draft PR
                   → more issues? pause for the human to merge, then /factory resume
      → retro
```

| Step | Reference |
| --- | --- |
| Start a run, work record, state, IDs, resume, status | `reference/state.md` |
| Gate 1: requirements and holdout scenarios | `reference/gate-1-requirements.md` |
| Gate 2: stack, packages, external services, run grant, push target, budget | `reference/gate-2-stack.md` |
| Gate 3: architecture, decision register, issue plan, architecture review | `reference/gate-3-architecture.md` |
| Gate 4: Paper design | `reference/gate-4-design.md` |
| Issues, branches, Slice 0, slice loop, commits | `reference/build.md` |
| Every review step: pairing, verdict format, checklists, rounds, stand-ins | `reference/review.md` |
| Holdout QA | `reference/holdout-qa.md` |
| Pre-push, risk ladder, walkthrough, push + PR, between phases, rework | `reference/delivery.md` |
| `/factory features` | `reference/features.md` |
| `/factory explain` and per-issue walkthroughs | `reference/explain.md` |
| Retro (meta loop) | `reference/retro.md` |

Load each reference when you reach its step, not all up front.

## Agents you spawn

All at depth 1 through the `task` tool, by exact agent name. Never pass a model; each agent's model comes from its own alias in `modelRoles`.

| Agent | Role |
| --- | --- |
| `factory-builder` | Builds one slice (fresh per slice, resumed by name across that slice's review rounds) |
| `factory-designer` | Gate 4: sets the creative direction and does every Paper write (GPT, fresh per round) |
| `factory-review-arch` | Open-weight reviewer, architecture |
| `factory-review-slice` | Open-weight reviewer, slices |
| `factory-review-tests` | Open-weight reviewer, test suite |
| `factory-review-security` | Open-weight reviewer, final security lens |
| `factory-review-code` | Open-weight reviewer, final code lens |
| `factory-review-ux` | Open-weight reviewer, final UX lens (images) |
| `factory-review-ui` | Open-weight reviewer, final UI lens (images) |
| `factory-review-gpt` | Premium reviewer in every review step |
| `factory-review-standin` | Replaces `factory-review-gpt` when GPT is rate-limited (all steps except the code lens) |
| `factory-review-standin-alt` | Replaces `factory-review-gpt` in the code lens |
| `factory-qa` | Holdout QA runner; the only subagent allowed to read the scenarios |
| `factory-features` | `/factory features` lister, read-only |

No Claude model ever reviews or designs: you (Opus) write the architecture, `factory-builder` (Opus) writes the code, and `factory-designer` (GPT) owns the Paper design.

## Hard limits

- Never merge a PR. Never push to the base branch except the one-time initial commit of an empty repo (see `reference/gate-2-stack.md`).
- Never put holdout scenario text in a subagent prompt other than `factory-qa`'s, in an issue, in a PR, in a commit, or in any file under the repo.
- Never stage `.factory/`, never add factory metadata to commit messages.
- Never run, launch, install or push anything outside the run grant (`reference/rules.md`).
- Never skip a human gate. Never use the `ask` tool: stop and wait for a typed reply (`reference/rules.md`, "Human interaction"). Only the reply `approve` approves; a status request, a resume, or silence never does.
