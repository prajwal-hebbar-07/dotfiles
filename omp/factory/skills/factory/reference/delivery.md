# Final review, pre-push, risk look, walkthrough, push, between phases, rework

## Final review

After holdout QA passes, spawn all eight reviewers in one message (`review.md`): `factory-review-security`, `factory-review-code`, `factory-review-ux`, `factory-review-ui`, each paired with its own `factory-review-gpt` instance (name them `factory-review-gpt-<lens>`). Each writes `.factory/<id>/issues/<n>/final/r<N>/<lens>-<agent>.md`. UX and UI on an issue with no UI: still spawned; they write `VERDICT: PASS` and say "no user-facing change".

Any CHANGES → fixes through the owning slices (`build.md`), then slice review of the fix, then a full new final round (all eight). Max 3 rounds; then queue the open findings for the human.

## Pre-push

1. Check at least one acceptance criterion yourself: run its check from the grant or read the code path end to end, and record what you saw.
2. `git fetch` and `git merge-tree --write-tree origin/<base> HEAD`: conflicts → stop and ask.
3. Autosquash fixups if this branch has never been pushed: `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`. Then rerun the granted test command once; it must pass.

## Risk look

If the issue's diff touches any of these, show the human a short evidence summary for that area (what changed, file list, review findings, QA result) and wait for OK before pushing:

- auth, permissions or identity; payments; data migrations; secrets;
- deploy, CI, hosting or build scripts;
- a package not approved at Gate 2;
- sending email or writing production data;
- a product decision you or an agent made that Gate 1 did not settle.

Concerns → back through the owning slices. No trigger → continue.

## Walkthrough

Write `docs/walkthroughs/<feature>.md` for the issue's feature (`explain.md`) and commit it alone: `docs(<feature>): add walkthrough`. It is the only commit besides the slice commits.

## Push and draft PR

```bash
git push -u origin <branch>
gh pr create --draft --base <base> --head <branch> --title "<issue title>" --body-file .factory/<id>/issues/<n>/evidence.md
```

`evidence.md` (the PR body):

```markdown
Closes #<n>

## Requirements → evidence
| Req | Test / check | QA | Result |
| R1 | `tests/auth.test.ts` sign-up rejects duplicate email | passed | ✅ |

## Checks run
- `<cmd>` → <counts>
## Reviews
| Step | Reviewers | Rounds | Result |
| slice 1–3 | glm-5.3-flash + gpt-6.1-sol | 1, 2, 1 | PASS |
## Stand-ins used
- <none, or step and reason>
## Not verified
- <anything the grant did not cover>
## Known limits
- <…>
## Walkthrough
docs/walkthroughs/<feature>.md
```

Never put scenario text in the PR. Record the PR number in `state.json`.

## Between phases

More issues left → `stage: "waiting_merge"`, `waiting_on: "PR #<pr> merge"`, and tell the human: `<id>: PR #<pr> (closes #<n>) is ready. Merge it on GitHub, then /factory resume <id>.` Stop. `resume` handles the rest (`state.md`).

Last issue delivered → `stage: "retro"` (`retro.md`).

## Rework

`/factory rework [<work-id>] [<issue>] "<note>"` is for an **open** PR. A merged PR's feedback becomes a new issue: create it, add it to the issue plan, and build it like any other.

1. The run must not be mid-build on another issue; if it is, queue the note and say when it will be picked up.
2. Renew the run grant if this conversation has not granted it (`rules.md`).
3. Tree clean, `git switch <issue branch>`, `git pull --ff-only`.
4. Write the note verbatim to `.factory/<id>/issues/<n>/rework-<k>.md`.
5. Spawn a fresh builder `factory-builder-<n>-rework<k>` with the note, the issue's requirements and decisions. Then slice review; then the final-review lenses the change touches; then every scenario in scope.
6. Commit as new commits on top (never rewrite a pushed branch), push, and comment on the PR with what changed and the new evidence.
