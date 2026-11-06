---
name: issue-branch
description: Take a GitHub issue link, create a local branch for it from the default branch, and summarize the issue's notes in a few short pointers. Implements nothing. Use when the user wants to start on an issue.
disable-model-invocation: true
---

# issue-branch

Create the working branch for a GitHub issue and say in a few pointers what
the issue is about. Nothing else.

Invoke explicitly as `/skill:issue-branch <issue URL>`.

## Never

- Do only what the request needs: create the branch and summarize. Never
  implement, plan, edit or create files, commit, push, comment on the issue,
  or assign it. A useful extra is named in one line, not done.
- Never ask what is already settled. The link and the repository answer
  everything this skill needs.
- Switch branches with uncommitted changes in the working tree.
- Exceed one page in the summary, or pad it with anything not in the issue.

## Step 1 — read the issue

```sh
gh issue view <URL> --json number,title,state,body,comments,url
```

If the link is not a GitHub issue, or `gh` cannot read it, stop and show the
error.

## Step 2 — check the repository

```sh
gh repo view --json nameWithOwner,defaultBranchRef
git status --short
```

- The issue's `owner/repo` (from its URL) must equal `nameWithOwner`.
  Otherwise stop: the branch would land in the wrong repository.
- If `git status --short` prints anything, stop and say the working tree has
  uncommitted changes.

## Step 3 — create the branch

Name it `<number>-<slug>`: the issue number, then the title lowercased, runs
of non-alphanumerics turned into one `-`, trimmed of `-`, cut at a word
boundary to 40 characters at most. Example: `#42 Fix login on Safari 17!` →
`42-fix-login-on-safari-17`.

```sh
git fetch origin <default>
git switch -c <name> origin/<default>
```

If the branch already exists locally, run `git switch <name>` instead and say
it already existed. Do not push it.

## Step 4 — summarize

Read the title, body and comments. Reply with:

```
Branch: <name> (from origin/<default>)
Issue: #<number> <title> — <state>

- <pointer>
- <pointer>
```

- Three to eight pointers, each one short line of about 15 words or fewer;
  never more than a page in total. Cover what is wrong or wanted, any steps,
  constraints or decisions the notes give, and any open question left in the
  comments. No text after the pointers.
- Plain words from the issue; no proposed fix, estimate, or plan.
- Skip comments that are only acknowledgements, `+1`s or bot noise.
- If the body and comments are empty, write `No notes in the issue.` instead
  of pointers.
