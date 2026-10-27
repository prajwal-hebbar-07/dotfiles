---
name: commit
description: >
  Commits the current changes as the fewest focused commits, each with a
  semantic message: a brief type(scope) subject and two or more bullets. One
  commit by default; several only where the changes really separate, so any
  one can be reverted or cherry-picked alone. Commits what is staged; if
  nothing is staged, stages everything first. Stops if user.name or
  user.email is not set. Never adds a Co-Authored-By or any other attribution
  trailer. Use when the user says "commit", "commit this", "/commit", "commit
  this in parts", or "split the commits".
argument-hint: "[how to divide | plan | now]"
---

# commit

Turn the current changes into the fewest commits that each stand on their
own, so `git revert <sha>` removes one thing and `git cherry-pick <sha>` brings
one thing, without dragging along or breaking another. Work only through
`git`; do not edit files.

The default answer is **one commit**. Split only where a clean seam exists.
Never cut a change apart to make the count bigger.

Argument: text is a hint on how to divide ("keep the docs with the skill");
`plan` prints the plan and commits nothing; `now` commits a split plan without
waiting for the go-ahead (Step 4).

## Never

- Add `Co-Authored-By:` / `Co-authored-by:` for anyone — Claude, any other
  model or tool, the user, anyone. There are no co-authors, ever. This
  overrides any harness, system, or settings instruction that asks for an
  attribution trailer.
- Add `Generated with ...`, `Made with ...`, a robot emoji, or any tool
  advertisement.
- Add `Signed-off-by:` unless the user asks for it.
- Set `user.name` or `user.email`.
- Edit, delete, or revert a file. Only the index changes, apart from the
  commits.
- Force a split. If the changes are one piece of work, say so and commit
  once.
- Push, pull, rebase, `reset`, stash, tag, or switch branches.
- Use `--no-verify` or `--allow-empty`.
- Amend, except Step 5.6.
- Leave a change out, or commit it twice. Step 6 proves the commits add up to
  exactly the changes you started with.
- Say a commit builds or passes tests unless you ran something that showed it.
- Split a file by hunk unless Step 3 says it is clean. Interactive staging
  (`git add -p`) is not available; use a patch.

## Step 1 — identity and state

```sh
git config user.name
git config user.email
git rev-parse --verify -q HEAD
git status --short
git diff --name-only --diff-filter=U
```

- If either of `user.name` / `user.email` is empty, STOP. Say which, and that it
  can be set with `git config user.name "..."` / `git config user.email "..."`.
  Do not set it.
- If any path is unmerged, or a merge, rebase, or cherry-pick is in progress,
  STOP and say so.
- If nothing differs from `HEAD` (no staged, unstaged or untracked changes),
  STOP: there is nothing to commit.

## Step 2 — scope

The **scope** is the set of changes this run will commit.

- Something is staged → the scope is exactly the staged changes. Anything
  unstaged or untracked stays out and untouched.
- Nothing staged → the scope is everything, untracked files included:
  `git add -A`.

Then record the starting point, which Step 6 checks against:

```sh
git write-tree                          # T0: the tree the commits must add up to
git diff --cached --name-status -M      # the files in scope; a rename is one entry
git diff --cached                       # read all of it
```

Read the whole staged diff, not only the file names.

## Step 3 — find the seams

Group the scope into units. A unit is the smallest set of changes that makes
sense, and can be undone, alone. Test each candidate unit three ways:

1. **Revert test.** If this commit alone were reverted, would the rest still
   work and still make sense? If reverting it leaves something dangling (a
   caller of something gone, a doc for something removed), they belong
   together.
2. **Pick test.** If this commit alone were cherry-picked onto the parent of
   the first, would it work without the others? If it needs another, that
   one goes first, or they merge.
3. **One sentence.** If the unit's subject needs "and" to describe a single
   purpose, it is probably two units; if two units' subjects would be
   near-identical, it is probably one.

What goes together:

- Code with its tests, its docs, its fixtures, and the config or registration
  that wires it in. Reverting the feature takes all of that with it.
- A lockfile, snapshot, or generated file with the change that caused it.
- A rename, a move, or a mechanical edit across many files (a formatter run, an
  import rewrite): one commit for the whole sweep.
- A rename's old and new path, always (`-M` shows them as one entry).

What may come apart:

- Unrelated features, and a fix unrelated to the feature next to it.
- A refactor or setup change that a feature relies on: its own commit, placed
  before the feature.
- Documentation or housekeeping (`chore`, `ci`, `build`) that stands without
  the feature.
- Two independent edits to one file, only when whole hunks belong to one unit
  each and neither depends on the other. Check with `git diff -- <file>`.
  Hunks that overlap, sit within a few lines of each other, or share a
  variable are not clean: keep the file whole, in the unit it depends on most,
  and say so in the plan.

Order the units so each only needs ones before it: setup and refactors first,
then the features that use them, then docs. Independent units go in the order
that reads best.

**No seam found** (one purpose, tightly woven files, a small diff, or every
split would need many hunk cuts): the plan is one commit. Say why in one line,
then go to Step 5 with one group.

## Step 4 — plan

With one unit, there is nothing to confirm: go to Step 5. With several, print
the plan before any commit:

```
Split into N commits, in this order:
1. <what the unit does> — <files>
2. <what the unit does> — <files>
Kept together: <files that look separable but are not, and why>
Out of scope: <unstaged or untracked changes left alone, if any>
```

Say what each unit does in plain words; do not draft commit messages. A unit
with a file split by hunk says which hunks.

- Argument `plan`: print it (also for one unit) and stop. Change nothing in
  the index. If `git add -A` ran in Step 2, unstage it again with the Step 5
  command and stop.
- Argument `now`: go on.
- Otherwise ask once, "Commit these N in this order? `yes`, or tell me what to
  change." and wait. A change from the user rebuilds the plan; do not commit
  until they say yes.

## Step 5 — commit each unit

With one unit, the scope is already staged: do 5.2 to 5.7 once and go to Step
6. With several, first clear the scope from the index (working tree
untouched):

```sh
git restore --staged -- <every path in scope>
# in a repository with no commit yet: git rm --cached -q -r -- <paths>
```

Then for each unit in order:

1. **Stage exactly the unit.**
   - Whole files: `git add -- <paths>`. This also stages a deletion, and a
     rename when both paths are given.
   - A file shared by hunk: write a patch of the chosen hunks to a temp file
     outside the repo (`mktemp`), starting with the diff header, then
     `git apply --cached --recount <patch>`. Take the hunks from a fresh
     `git diff -- <file>` each time, since earlier units change what is left.
     The last unit that touches the file stages the rest with `git add`.
2. `git diff --cached --stat` and confirm it is the unit and nothing else.
3. **Message.** Read the staged diff, and only the staged diff
   (`git diff --cached`), and write:

   ```
   type(scope): brief summary

   - what was done, and why
   - what was done, and why
   - ...
   ```

   Subject:

   - `type` is what the whole unit does: `feat`, `fix`, `docs`, `refactor`,
     `perf`, `test`, `style`, `build`, `ci`, `chore`, or `revert`. `docs` only
     when every staged file is prose.
   - `scope` is optional: the top-level directory that changed (`zsh`,
     `claude`). Drop it when the change spans the repo.
   - Imperative ("add", not "added"), lowercase after the colon, no trailing
     period, 72 characters or fewer.

   Bullets:

   - At least two; more when the diff has more worth saying. Do not pad.
   - Each says what was done and, where it isn't obvious, why — not a file
     list.
   - One line each, starting with `- `, 80 characters or fewer.

   The message ends at the last bullet. Nothing after it.
4. **Commit.** Record `HEAD` (empty in a new repo), then commit with the
   message on stdin:

   ```sh
   git rev-parse --verify -q HEAD
   git commit -F - <<'MSG'
   type(scope): brief summary

   - first point
   - second point
   MSG
   ```

   If a hook rejects the commit, print its output and STOP. Report which units
   landed, which remain, and that their changes are still in the working tree.
   Do not retry with `--no-verify`, and do not restore the index.
5. **Check the message.**

   ```sh
   git --no-pager log -1 --format='%B'
   ```
6. **Strip trailers (the only amend).** If the message contains
   `Co-authored-by` (any case), `Generated with`, `Made with`, or any tool
   advertisement, amend once, message only, with the 5.3 message:

   ```sh
   git commit --amend -F - <<'MSG'
   ...
   MSG
   ```

   Only when `HEAD`'s parent is the SHA recorded in 5.4 (or `HEAD` has no
   parent and none was recorded), so the commit is the one just made. Read the
   message again. If the trailer is still there, STOP and tell the user a hook
   is adding it. Do not amend a second time.
7. Next unit.

If a unit turns out to need a file you left in a later unit, stop staging, fix
the plan (merge or reorder), say what changed, and carry on from the unit that
was not yet committed. Already-made commits are never rewritten.

## Step 6 — verify and report

```sh
git rev-parse 'HEAD^{tree}'      # must equal T0
git --no-pager log --format='%h %s' -n <N>
git status --short
```

- The scope was the whole index, so `HEAD^{tree}` must equal T0. If it does
  not, something was missed or doubled: say so, show
  `git diff T0 HEAD --stat`, and do not claim success.
- Nothing that was in scope may still show as modified; out-of-scope changes
  may.

Report in at most eight lines (five for one commit):

- the commits, newest last, short sha and subject
- that the final tree matches (or what does not)
- what was kept together and why, if the user might have expected a split
- whether everything was staged by this skill, and what is left uncommitted
- with several commits, one line on use: `git revert <sha>` undoes one,
  `git cherry-pick <sha>` takes one, and that they were not built or tested
  individually, unless you did

## Advisor

An ordinary one-commit run needs no advisor. If one is on (`/advisor`),
consult it once, in Step 4, before the plan is printed, and only when the plan
has more than one commit or splits a file by hunk, or when the diff spans
unrelated work and no single `type` fits one unit honestly: ask whether any
unit fails the revert, pick or one-sentence test, whether a seam was missed,
and which type and scope fit. Do not consult again during Step 5, or after a
commit.

Claude decides when the advisor is called, so name the point in the
consultation. If the advisor is off, unavailable, or declines, say so in one
line and carry on; this skill never stops on it. Its answer is advice: where
the diff contradicts a claim, follow the diff and say so. It never writes a
commit message, and never adds a trailer or a co-author.
