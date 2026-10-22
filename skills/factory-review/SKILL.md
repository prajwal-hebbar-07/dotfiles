---
name: factory-review
description: >
  Shared rubric for the factory's reviewer agents: each reviewer's fixed
  verdict vocabulary and severity scale, the evidence rules, patch-id
  pinning, the Simpler axis, the json reply block, and how the main session
  sorts findings into Act on / Consider / Noted / Dismissed. Autoloaded by
  every factory reviewer agent; the main session reads it before it
  synthesises reviews.
disable-model-invocation: true
---

# Factory review rubric

Two readers use this file. A **reviewer agent** (autoloaded) follows
"Reviewer rules" and answers in its row of the vocabulary table. The **main
session** follows "Synthesis". Agent files carry the procedure; this file
carries what they share.

## Verdict vocabulary

Each agent uses its own words, exactly as written, and no others.

| Agent | Verdict | Severity scale on findings |
| --- | --- | --- |
| `reviewer` (bundled) | `overall_correctness`: correct / incorrect | P0 blocks release, P1 fix next cycle, P2 fix eventually, P3 nice to have |
| `factory-spec-review` | `APPROVE` / `REQUEST CHANGES` | `Critical` / `Required` / `Optional` / `Nit` |
| `factory-test-review` | `PASS` / `FAIL` | `Critical` / `Required` / `Optional` / `Nit` |
| `factory-qa-review` | `PASS` / `PASS+NOTES` / `FAIL` | `Critical` / `Required` / `Optional` / `Nit` |
| `factory-design-review` | `PASS` / `FAIL`, plus a score out of 10 | 0 not a problem, 1 cosmetic, 2 minor, 3 major, 4 catastrophic |
| `factory-ui-review` | `PASS` / `FAIL` | `Critical` / `Required` / `Optional` / `Nit` |

Severity meaning (addyosmani `code-reviewer` labels):

- **Critical**: wrong behaviour, data loss, security hole, or a violated
  acceptance criterion. Blocks.
- **Required**: must change before merge. Includes every Simpler finding
  and a missing test for an acceptance criterion. Blocks.
- **Optional**: worth doing, may be declined with a reason.
- **Nit**: taste. Never blocks.

`REQUEST CHANGES` / `FAIL` is returned when there is at least one Critical
or Required finding; design review fails on any severity 3 or 4 and puts
`score: N/10` first in `notes`. A reviewer that cannot run its checks (a
tool, Paper, or an input is missing, or the mode does not apply) returns
`BLOCKED`, never a pass.
`APPROVE` / `PASS` may carry Optional and Nit items. Approve a change that
improves code health even if it is not how you would write it
(addyosmani `code-review-and-quality`).

## Reviewer rules

- Read-only. Never edit, write, or commit. `bash` only for `git diff`,
  `git log`, `git show`, `git patch-id`, and running tests where the agent's
  file says so.
- **Evidence.** Every finding has `file`, `line`, and `evidence` (the
  quoted line, a command and its output, or a spec line). The line must
  overlap the diff under review; a finding outside the diff is pre-existing
  and is not reported (it may go in `notes`). A finding with no evidence is
  not a finding. No "should", "probably", "seems to" (superpowers
  `verification-before-completion`).
- **Review the diff against the work item**, not against your taste. The
  work item is the issue plus approved docs (app mode) or
  `.factory/feature/<slug>.md` (feature mode).
- **Declined to judge.** List what you did not or could not check (no
  tool, out of scope, unreadable). Silence is not approval.
- **Never read holdout scenarios** (`~/.omp/factory/`). Never ask the
  user; if a requirement is ambiguous, return a `questions` entry and stop.
- **Pin the patch.** Record `git rev-parse HEAD` and `git patch-id --stable`
  of the diff you reviewed in `notes` (pstack `shipping`).
- Do not edit a finding's severity to reach a verdict. Do not pre-judge:
  report what you find; the main session sorts it.

## The Simpler axis

Used by `factory-spec-review` (and by the main session when it checks any
other reviewer's output for over-building). An abstraction, wrapper, option,
config, dependency, or "for later" code that no `R` (app mode) or acceptance
criterion (feature mode) asks for is **Required**; so is new code where
something already in the codebase, the standard library, or the platform
does the job. Name the smaller option in the finding. Never flag removal of
validation at a trust boundary, error handling that prevents data loss,
security, or accessibility as "simpler" (ponytail).

## Patch-id pinning

A verdict covers a patch, not a SHA. Before trusting an older verdict,
compare `git diff <base>...<verdict-sha> | git patch-id --stable` with the
same at the current head. Equal: the verdict stands (a rebase moved it).
Different: every reviewer the change invalidates runs again. The main
session records the patch-id in the ledger `evidence` column
(`factory-state ledger verdict ... --sha <sha> --evidence patch-id:<id>`).
A verdict given on a fallback model is marked `fallback` in the ledger.

## Reply block

Every agent ends its reply with exactly one fenced `json` block, last in the
message:

```json
{
  "verdict": "<one value from the table above>",
  "findings": [ {"severity": "Required", "file": "src/a.ts", "line": 12, "text": "…", "evidence": "…"} ],
  "questions": [ {"id": "q1", "question": "…", "options": [{"label": "…", "description": "…"}], "recommended": 0} ],
  "notes": "patch-id, declined-to-judge list, risks, what was not checked"
}
```

`questions` appears only when the agent stopped instead of guessing.
Prose above the block is allowed (the human-readable report); the block is
what the main session parses.

## Synthesis (main session)

After reviewers return, merge findings that describe the same issue and note
which reviewers raised it. Two reviewers raising it independently is the
strongest signal. Then sort every finding into one bucket with a one-line
reason (pstack `interrogate`, adapted):

| Bucket | Rule | What happens |
| --- | --- | --- |
| **Act on** | Critical or Required with evidence on the diff; reviewer P0/P1; any FAIL cause; every Simpler finding | Goes back to the builder, with the finding's file:line and evidence |
| **Consider** | Optional, reviewer P2, or a trade-off the author may reasonably decline | Listed in the PR body as known trade-offs; not sent to the builder |
| **Noted** | Valid but not actionable now: Nit, reviewer P3, context-dependent | One line in the ledger; no action |
| **Dismissed** | Wrong, no evidence, outside the diff, or contradicted by an approved doc | Reason recorded in the ledger |

Rules: only "Act on" items go back to the builder. A reviewer that returns
`REQUEST CHANGES` / `FAIL` with no Critical or Required finding is a
malformed reply: send it back to the same agent (`write agent://<id>`). Do
not dismiss a finding because the builder disagrees; an unresolved dispute
goes to the user through `ask`. At most 3 review rounds per issue (feature
mode: 3 rounds, then stop and flag the user).

Sources credited above: pstack `interrogate`, `shipping`; addyosmani
`code-reviewer` and `code-review-and-quality`; superpowers
`verification-before-completion`; wondelai `ux-heuristics` (severity scale);
DietrichGebert `ponytail`.
