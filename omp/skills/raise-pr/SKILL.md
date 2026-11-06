---
name: raise-pr
description: Push the current branch and open a GitHub pull request from it into the destination branch the user names, with a short title and summary written from the branch's commits. Use when the user wants to raise or open a PR.
disable-model-invocation: true
---

# raise-pr

Open a pull request from the current branch into the branch the user names.

Invoke explicitly as `/skill:raise-pr <destination branch> [draft]`.

## Never

- Do only what the request needs: push the branch and open the PR. Never
  edit files, commit, rebase, merge, request reviewers, add labels, or link
  issues. A useful extra is named in one line, not done.
- Never ask what is already settled. Ask only for the destination branch,
  and only when the invocation does not give one.
- Force-push, or push anything but the current branch.
- Open a second PR for a branch pair that already has an open one.
- Claim the change is tested in the PR body unless you ran something that
  showed it.
- Add `Co-authored-by`, `Generated with`, `Made with`, a robot emoji, or any
  tool advertisement to the title or body.

## Step 1 — check

```sh
git branch --show-current
git status --short
git fetch origin <destination>
git log --oneline origin/<destination>..HEAD
gh pr list --head <branch> --base <destination> --state open --json url
```

Stop, saying why, when:

- no branch is checked out (detached `HEAD`), or it is the destination;
- `git status --short` prints anything: list it, since uncommitted changes
  would not be in the PR;
- the fetch fails: the destination does not exist on `origin`;
- the log is empty: the branch has nothing the destination lacks;
- an open PR already exists: print its URL.

## Step 2 — push

```sh
git push -u origin HEAD
```

If the push is rejected, show the error and stop.

## Step 3 — write the title and body

Read only what the PR contains:

```sh
git log --format='%s%n%b' origin/<destination>..HEAD
git diff --stat origin/<destination>...HEAD
```

- Title: with one commit, its subject. With several, one line in the same
  style as the commit subjects, 72 characters or fewer.
- Body:

  ```markdown
  ## Summary

  - <what changed, and why when the commits say>
  ```

  Two to six one-line bullets. No file lists, no section for anything the
  commits do not say.

## Step 4 — open the PR

```sh
gh pr create --base <destination> --head <branch> --title '<title>' --body-file - <<'BODY'
<body>
BODY
```

Add `--draft` only when the invocation says `draft`.

Reply in three lines at most: the PR URL, `<destination> ← <branch>` with the
commit count, and draft or ready.
