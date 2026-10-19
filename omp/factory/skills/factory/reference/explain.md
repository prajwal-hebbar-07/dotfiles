# Walkthroughs: /factory explain <feature>

You (Opus) write it: you hold the decision record the "why" depends on. Works in any repo.

## When

- Automatically for every delivered issue, just before the push (`delivery.md`).
- On demand: `/factory explain <feature>`. The feature name is matched against `/factory features` output; ambiguous → ask. On demand outside a run, the result is committed only if the human approves the commit (it is a docs change on the current branch); otherwise it is left as an uncommitted file and you say so.

## Gather

1. The feature's files and entry points (from `/factory features` or by reading the code).
2. If the factory built it: `requirements.md`, `architecture.md` (decision register), `design.md`, the issue and PR.
3. Otherwise: code comments, `git log --follow` on the main files, linked issues or ADRs. Every "why" from these is labelled **inferred**.

## Write `docs/walkthroughs/<feature>.md`

~~~markdown
# <Feature> — walkthrough

Commit: <full sha> · Generated: <date> · Requirements: R1, R2 · Decisions: D1, D4

## What this feature does
<two or three sentences>

## How a request flows
<entry point → core logic → storage → side effects, one line each, with file paths>

## 1. <Snippet title>
`src/auth/signup.ts:12-34` @ <short sha>
```ts
<code quoted exactly from that file at that commit>
```
- **What it does / why it's here:** …
- **Takes:** … **Returns:** … (including errors)
- **How it's built:** …
- **Why it's built this way:** follows D3 (<decision>) — <reason>. | No recorded decision. | Inferred: <reason>.
- **Tested by:** `tests/auth/signup.test.ts` — "<test name>"

## Where to look next
<files not covered, with one line each>
~~~

Rules:

- Quote code exactly (read the file at the commit; never retype or "clean up" a snippet).
- Order follows a request through the feature: entry point first, then core logic, then storage and side effects.
- Cover every exported function and every handler of the feature; group trivial ones.
- A rerun after the code changed refreshes every snippet to the new commit and adds a "Changed since <old sha>" line under each snippet that changed.
