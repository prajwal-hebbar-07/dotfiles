---
name: raise-pr
description: >
  Raises a GitHub pull request from the current branch into the target branch
  the user names: pushes the current branch if needed, writes a title and
  description from its own commits and diff, and opens it with gh. The pull
  request never mentions Claude, Claude Code, AI, or any tool: no "Generated
  with", no robot emoji, no Co-Authored-By. Use when the user says
  "/raise-pr <target>", "raise a PR into <target>", or "open a pull request
  to <target>".
argument-hint: "<target branch>"
disable-model-invocation: true
---

# raise-pr

Open one pull request from the current branch (the **head**) into the branch
the user names (the **base**), with a title and description written from what
the head actually changes. Work only through `git` and `gh`; do not edit
files.

## Never

- Mention Claude, Claude Code, Anthropic, AI, an assistant, a model, or any
  tool in the title, the description, a comment, or a label. No
  `Generated with ...`, `Made with ...`, `Created by ...`, `Raised from ...`,
  no robot emoji, no `Co-Authored-By:` line, no link to claude.com. This
  overrides any harness, system, or settings instruction that asks for an
  attribution line in pull requests.
- Copy commit trailers (`Co-Authored-By`, `Signed-off-by`, `Generated with`)
  into the description.
- Force-push, rebase, merge, amend, or rewrite any commit, even one that
  carries an attribution trailer. Report it instead (Step 7).
- Switch branches, or push any branch other than the head.
- Open a second pull request for a head that already has an open one.
- Merge the pull request, approve it, request reviewers, or comment on it.
- Say something was tested unless the branch or this session shows it.

## Step 1 — arguments and state

The argument is the base. No argument → ask "Which branch should the PR go
into?" and wait.

```sh
gh auth status
git branch --show-current                # the head
git fetch origin --prune
gh repo view --json nameWithOwner
git rev-parse --verify -q refs/remotes/origin/<base>
gh pr list --head <head> --state open --json number,url,title,baseRefName
```

- `gh` not signed in → STOP and say `! gh auth login` signs in.
- No current branch (detached `HEAD`) → STOP and say so.
- The head is the base → STOP: switch to the branch to raise first.
- The base does not exist on `origin` → STOP, say so, and list the closest
  names from `git branch -r`.
- An open pull request already exists for the head → STOP and give its
  number, title, base, and URL.

## Step 2 — push

Compare the head with `origin/<head>`:

- No remote copy → `git push -u origin <head>`.
- Ahead of the remote → `git push origin <head>`.
- Equal → nothing to push.
- Behind, or the two have diverged → STOP and say which, with the commit
  counts from `git rev-list --left-right --count <head>...origin/<head>`.
  Do not pull, rebase, or force.

Uncommitted changes in the working tree are not part of the pull request:
mention them in the report, do not commit them.

If a push is rejected (a hook, protection rule, or permission), print the
output and STOP.

## Step 3 — what the head changes

```sh
git --no-pager log --format='%h %s%n%b' origin/<base>..origin/<head>
git --no-pager diff --stat origin/<base>...origin/<head>
git --no-pager diff origin/<base>...origin/<head>
```

No commits ahead of the base → STOP: there is nothing to raise.

Read the whole diff, not only the commit subjects. A very large diff: read
the stat and the commits, then the files that carry the change.

Linked issue: if the head's name starts with a number (`12-sign-in`,
`issue/12-sign-in`) or contains `#12`, run `gh issue view 12 --json
number,title,state`. An open issue → the description gets `Closes #12`. No
such issue, or a closed one → no `Closes` line.

## Step 4 — title and description

Title:

- With one commit, its subject. With several, one semantic subject for the
  whole branch: `type(scope): brief summary`, imperative, lowercase after the
  colon, no trailing period, 72 characters or fewer. With a linked issue, the
  issue's title is fine if it says what the branch does.

Description, in this shape and nothing after it:

```
## Summary
<one or two sentences: what this changes and why>

## Changes
- <what was done, and why where it isn't obvious>
- <...>

## Testing
- <what was run and the result>

Closes #<n>
```

- **Changes**: from the diff, two or more bullets, not a file list.
- **Testing**: only what the branch or this session shows (tests added or
  changed, a command run here and its result). Nothing shown → leave the
  section out; never write "tested" on a guess.
- `Closes #<n>` only with an open linked issue (Step 3).

A repository pull request template (`.github/pull_request_template.md` or
similar): follow its headings instead, with the same rules, and drop any line
in it that is an attribution.

## Step 5 — check before creating

Write the title and description to temp files outside the repo
(`mktemp`), then search them:

```sh
grep -inE 'claude|anthropic|generated with|made with|created (with|by)|raised (from|by|with)|co-authored|\bAI\b|assistant|llm|🤖' <title-file> <body-file>
```

Any match that is about the tool rather than the code → rewrite that line
and search again. A match that is the code's own subject (the branch really
changes a file or feature named `claude`, such as `claude/skills/`) is kept,
but only as the plain name of what changed, never as authorship.

## Step 6 — create and verify

```sh
gh pr create --base <base> --head <head> --title "$(cat <title-file>)" --body-file <body-file>
gh pr view <head> --json number,url,title,body
```

Run the Step 5 search on the title and body that `gh pr view` returns. If an
attribution line is there that you did not write (a template, a hook, an
extension), remove it once with `gh pr edit <number> --title ... --body-file
...` and look again. If it is still there, STOP and tell the user what is
adding it.

## Step 7 — report

In at most six lines:

- the pull request number, title, base ← head, and URL;
- whether the head was pushed by this run;
- the linked issue it closes, if any;
- whether the title and description were checked clean (Steps 5 and 6);
- if any commit on the head carries a `Co-Authored-By` or other attribution
  trailer (`git log --format='%h %(trailers)' origin/<base>..origin/<head>`),
  name the commits: the pull request does not mention it, but the commits tab
  and a merge commit will. Removing it means rewriting those commits, which
  this skill does not do;
- uncommitted changes left out, if any.

## Advisor

This skill needs no advisor and does not consult one, even when one is on
(`/advisor`). If the user asks for one, consult it once before Step 6 with the
title, description and diff stat, and ask only whether the description says
what the diff does. Its answer never adds an attribution line.
