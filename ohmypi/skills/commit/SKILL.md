---
name: commit
description: >
  Commits already-staged changes with a semantic message invented from the
  staged diff. Never stages, never takes a subject from the caller, never
  pushes, never rebases, never opens a PR. Amends only to strip a
  Co-authored-by / attribution trailer from the commit this skill just
  created. Use when the user says "commit", "commit this", "/commit",
  "/skill:commit", or when another skill has staged its files and needs a
  commit.
---

# commit

Turn **already-staged** changes into one semantic commit. That is the whole
skill.

Work only through `git`. Do not edit files. Do not invent a subject from the
user or from another skill — always write the message from `git diff --cached`.

## Never

- `git add` / `add -A` / `add -u` / `add -p` — never stage
- push, pull, fetch-to-update, tag, stash, rebase, cherry-pick
- switch / checkout / restore / reset
- `git commit --amend` except Step 6 (strip co-author from HEAD this skill just created)
- `--no-verify`, `--allow-empty`, `-i`
- open a PR
- set `user.name` or `user.email`
- take a commit subject from the user or from a calling skill

If asked to do any of those, refuse. This skill only commits the index.

## Called by other skills

Callers `git add` their own files, then run this skill. This skill never
receives a subject. It always writes the message from the staged diff.

## Step 1 — staged files

```sh
git diff --cached --stat
git status --short
```

If nothing is staged, STOP. Report that there is nothing to commit and list
what is unstaged. Do not `git add`. Do not continue.

## Step 2 — local identity

```sh
git config --local user.name
git config --local user.email
```

Use **`--local` only**. Do not read the effective/global value. This repo
uses a per-repo account; global would commit as the wrong person.

If either is empty, STOP. Report which one is missing and the commands to
fix it (`git config --local user.name "..."` / `git config --local user.email
"..."`). Never set them. Never guess.

## Step 3 — message from the staged diff only

```sh
git diff --cached
```

Do not read `git diff` (unstaged). Unstaged files are not in this commit.

Shape:

```
type(scope): imperative summary

- why this change exists
- one bullet per important point
```

Subject:

- `type` from what the **whole staged diff** does:
  - `feat` — adds a file, capability, binding, or option. Mixed code + docs is still `feat`.
  - `fix` — corrects broken behavior.
  - `docs` — only when **every** staged file is prose. README-plus-code is never `docs`.
  - `refactor` — same behavior, different structure. `perf`, `test`, `style`, `build`, `ci`, `chore`, `revert` for their obvious cases.
- `scope` is optional: the top-level directory that changed (`tmux`, `zsh`, `ohmypi`). Drop it when the change is repo-wide.
- Imperative ("add", not "added"/"adds"), no trailing period, 72 characters or fewer.

Bullets:

- 1–10. Floor is 1 (even a one-file change gets one why-bullet). Cap is 10, not a target. Do not pad.
- Only important points: what changed and why, not a restatement of the diff.
- One line each, starting with `- `. 80 characters or fewer including the `- `. Split or shorten anything longer.

Never append, in any form:

- `Co-Authored-By:` / `Co-authored-by:` for anyone (Claude, Cursor, Codex, Gemini, the user, any tool)
- `Generated with ...`, `Made with ...`, robot emoji, or any tool advertisement
- `Signed-off-by:` unless the user asked for it

The message ends at the last bullet.

## Step 4 — commit

Record `HEAD` first so Step 6 can prove this skill created the next commit:

```sh
git rev-parse HEAD
git commit -m 'type(scope): summary' -m '- first pointer
- second pointer'
```

If a pre-commit or commit-msg hook rejects the commit, print the hook output
verbatim and STOP. Never retry with `--no-verify`. A failing hook must stay a
failure; do not move it to deploy.

## Step 5 — verify the message

```sh
git --no-pager log -1 --format='%h %s'
git --no-pager log -1 --format='%B'
```

## Step 6 — strip co-author (the only amend)

If the new `HEAD` message contains `Co-authored-by`, `Co-Authored-By`,
`Generated with`, `Made with`, or a robot/tool advertisement:

Amend is allowed **only if all of these are true**:

- `HEAD` is the commit this skill just created (the parent was the SHA from Step 4)
- the only edit is deleting those trailers; the tree does not change
- you have not already amended this commit

Then amend **once**, message only, no `--no-verify`:

```sh
git commit --amend -m 'type(scope): summary' -m '- first pointer
- second pointer'
```

Read `git log -1` again.

- Trailers gone → continue.
- Trailers still there → STOP. A hook is re-injecting them. Do not amend again.
  Do not `--no-verify`. Tell the user the hook is the problem.

If there were no trailers, amend is **not available**. Do not amend to tidy
the subject, add a file, or fix a hook failure.

## Step 7 — report

```sh
git --no-pager log -1 --format='%h %s'
git status --short
```

At most five lines: short SHA and subject, number of files committed, anything
still uncommitted. No preamble. No recap of these instructions.

## Stops

| Situation | Action |
|---|---|
| Nothing staged | Stop. Show `git status --short`. Do not add. |
| Local `user.name` or `user.email` missing | Stop. Print the `--local` commands. Do not set them. |
| Pre-commit / commit-msg hook fails | Stop. Print the hook output. No `--no-verify`. |
| Trailer still present after one strip-amend | Stop. Name the hook. No second amend. |
