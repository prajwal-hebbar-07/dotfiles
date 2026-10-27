---
name: commit
description: >
  Commits changes with a semantic message: a brief type(scope) subject and
  two or more bullets on what was done. Stops if user.name or user.email is
  not set. Commits what is staged; if nothing is staged, stages everything
  first. Never adds a Co-Authored-By or any other attribution trailer. Use
  when the user says "commit", "commit this", or "$commit".
---

# commit

Turn the current changes into one semantic commit. Work only through `git`;
do not edit files.

## Never

- Add `Co-Authored-By:` / `Co-authored-by:` for anyone — Codex, any other
  model or tool, the user, anyone. There are no co-authors, ever. This
  keeps the commit message free of tool attribution.
- Add `Generated with ...`, `Made with ...`, a robot emoji, or any tool
  advertisement.
- Add `Signed-off-by:` unless the user asks for it.
- Set `user.name` or `user.email`.
- Push, pull, rebase, reset, stash, tag, or switch branches.
- Use `--no-verify` or `--allow-empty`.
- Amend, except Step 6.

## Step 1 — identity

```sh
git config user.name
git config user.email
```

If either is empty, STOP. Say which one is not set, and that it can be set
with `git config user.name "..."` / `git config user.email "..."`. Do not set
it. Do not continue.

## Step 2 — staging

```sh
git diff --cached --stat
```

- Something staged → commit only that. Do not stage anything else.
- Nothing staged → stage everything:

  ```sh
  git add -A
  git diff --cached --stat
  ```

  If still nothing is staged, STOP: there is nothing to commit.

## Step 3 — message

Read the staged diff, and only the staged diff:

```sh
git diff --cached
```

Shape:

```
type(scope): brief summary

- what was done, and why
- what was done, and why
- ...
```

Subject:

- `type` is what the whole diff does: `feat`, `fix`, `docs`, `refactor`,
  `perf`, `test`, `style`, `build`, `ci`, `chore`, or `revert`. `docs` only
  when every staged file is prose.
- `scope` is optional: the top-level directory that changed (`zsh`, `codex`).
  Drop it when the change spans the repo.
- Imperative ("add", not "added"), lowercase after the colon, no trailing
  period, 72 characters or fewer.

Bullets:

- At least two; more when the diff has more worth saying. Do not pad.
- Each says what was done and, where it isn't obvious, why — not a file list.
- One line each, starting with `- `, 80 characters or fewer.

The message ends at the last bullet. Nothing after it.

## Step 4 — commit

Record `HEAD` (empty in a new repo), then commit with the message on stdin:

```sh
git rev-parse --verify -q HEAD
git commit -F - <<'MSG'
type(scope): brief summary

- first point
- second point
MSG
```

If a hook rejects the commit, print its output and STOP. Do not retry with
`--no-verify`.

## Step 5 — check the message

```sh
git --no-pager log -1 --format='%B'
```

## Step 6 — strip trailers (the only amend)

If the message contains `Co-authored-by` (any case), `Generated with`,
`Made with`, or any tool advertisement, amend once, message only, with the
Step 3 message:

```sh
git commit --amend -F - <<'MSG'
...
MSG
```

Only when `HEAD`'s parent is the SHA recorded in Step 4 (or `HEAD` has no
parent and none was recorded), so the commit is the one just made. Read the
message again. If the trailer is still there, STOP and tell the user a hook
is adding it. Do not amend a second time.

## Step 7 — report

```sh
git --no-pager log -1 --format='%h %s'
git status --short
```

At most five lines: short SHA and subject, how many files were committed,
whether everything was staged by this skill, and anything left uncommitted.
