---
name: herdr-worktree
description: Create one git worktree per task and open each as a named tab in the current Herdr desktop space. Use when the user says "create worktrees", "worktree in herdr", "spin up branches in herdr" or "one worktree for X, one for Y".
---

# herdr-worktree

Turn task names ("hero section update", "clean up", "strapi") into one git
worktree each, and open each worktree as a named tab in the Herdr space this
agent runs in, so the user can start work at once.

## When to use

- The user lists one or more tasks or branches and wants a worktree for each:
  "create worktrees", "worktree in herdr", "spin up branches in herdr",
  "one worktree for X, one for Y".
- The current folder is inside a git repository (main checkout or linked
  worktree).

## Never

- Do only what the request needs: worktrees and tabs. A useful extra is named
  in one line, not done.
- Never ask what is already settled. Act without confirmation; ask only when a
  branch name is ambiguous or a requested name collides with something
  unrelated (step 5).
- Use `herdr` (`herdr worktree create/open`, `herdr server`, anything on
  `~/.config/herdr/herdr.sock`) or start that server. The Herdr desktop window
  is driven only by `herdr-app`; there is no herdr MCP.
- Trust a space's `folder` field or `active` flag to find the current space.
- Start the app, dev servers, installs, builds or tests, in the new tabs or
  anywhere else.
- Close, rename or reuse tabs or spaces this run did not create.
- Push, commit, or change any existing branch.

## Procedure

Run every git command against the main checkout with `git -C "$root"`.

1. **Find the main checkout and ignore `.worktrees/`.** This works the same
   from the main checkout and from a linked worktree:

   ```sh
   root=$(git worktree list --porcelain | sed -n '1s/^worktree //p')
   common=$(git rev-parse --path-format=absolute --git-common-dir)
   mkdir -p "$common/info"
   grep -qxF '.worktrees/' "$common/info/exclude" || echo '.worktrees/' >> "$common/info/exclude"
   ```

   If `git worktree list --porcelain` shows `bare` on its first entry, stop
   and ask where the worktrees should go.

2. **Refresh remote refs** so the existence checks below see current
   branches. Skip it when there is no `origin`; if it fails (offline), go on
   with the local refs and say so in the report.

   ```sh
   git -C "$root" remote get-url origin >/dev/null 2>&1 && git -C "$root" fetch --quiet --prune origin
   ```

3. **Pick the base.** The branch the user names, else the default branch from
   `origin/HEAD`, else `main`:

   ```sh
   base=$(git -C "$root" symbolic-ref --quiet --short refs/remotes/origin/HEAD || echo main)
   ```

4. **Name the branches.** Explicit branch names from the user are used
   exactly. Otherwise kebab-case each task: lowercase, every run of
   non-alphanumerics becomes one `-`, trim `-` at both ends. A two-word verb
   phrase that is normally one word is joined: "clean up" → `cleanup`,
   "set up" → `setup`, "log in" → `login`. Examples: "hero section update" →
   `hero-section-update`, "strapi" → `strapi`. The worktree folder is the
   branch with `/` replaced by `-`:

   ```sh
   path="$root/.worktrees/${branch//\//-}"
   ```

   If a name could reasonably be read two ways (one task or two, a typo of an
   existing branch), ask before step 5.

5. **Look for related remote branches.** List remote branches once:

   ```sh
   git -C "$root" branch -r --format='%(refname:short)'
   ```

   For each task, note any remote branch that is not an exact match but
   plainly covers the same work by name or meaning (task "strapi", remote
   `origin/CMS`). For each such branch, check whether it holds work missing
   from the base:

   ```sh
   git -C "$root" log --oneline "$base..origin/<x>"
   ```

   - No commits: keep the base; mention the branch in the report.
   - Commits, or the user asked to start from it: use `origin/<x>` as that
     task's base, and say so in the report.

6. **Create each worktree.** For each branch, take the first case that
   applies:

   ```sh
   if [ -e "$path" ]; then
     : # path exists: create nothing, open the tab (see Edge cases)
   elif git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
     git -C "$root" worktree add "$path" "$branch"
   elif git -C "$root" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
     git -C "$root" worktree add "$path" -b "$branch" --track "origin/$branch"
   else
     git -C "$root" worktree add "$path" -b "$branch" "$base"
   fi
   git -C "$path" log -1 --format='%h %s'   # base commit for the report
   ```

7. **Find the current Herdr space.** Only when `HC_TERMINAL_ID` is set
   (otherwise see "Non-Herdr terminal"). The current space is the one whose
   tabs contain this agent's terminal:

   ```sh
   space=$(herdr-app ls | jq -r --arg t "$HC_TERMINAL_ID" \
     '.spaces[] | select(any(.tabs[].terminals[]; .terminal == $t)) | .id')
   ```

   Exactly one id must come back. None (or `herdr-app ls` fails) → treat it
   as a non-Herdr terminal.

8. **Open one tab per worktree** in that space, named after the branch:

   ```sh
   herdr-app do tab.new --space "$space" --name "$branch" --folder "$path"
   ```

   It prints JSON `{space, tab, terminal}`. Tabs get a plain shell. Only when
   the user asks for an agent in each tab, add `--argv '["omp"]'` (or the
   agent they name) and `--task "<the task>"`.

9. **Confirm each tab** landed in its worktree:

   ```sh
   herdr-core get "$terminal" --json | jq -r .cwd
   ```

   The `cwd` must equal `$path` (compare `cd "$path" && pwd -P` if one side
   is a symlink). On a mismatch, leave the tab and report it as failed.

10. **Report.** One table, one row per tab:

    | Tab | Branch | Worktree | Base commit |
    | --- | --- | --- | --- |
    | `hero-section-update` | `hero-section-update` | `<root>/.worktrees/hero-section-update` | `a1b2c3d` (origin/main) |

    Then one bullet per skipped or reused item and why (existing branch,
    remote-only branch tracked, existing path, failed `cwd` check, fetch
    failed), and one per related remote branch from step 5 with whether it
    was used as the base.

## Edge cases

- **Existing local branch:** `git worktree add "$path" "$branch"`, no `-b`;
  the base commit is the branch's own tip, and the report says it was reused.
  If git refuses because the branch is already checked out in another
  worktree, create nothing and open the tab on that worktree's path (from
  `git worktree list --porcelain`), reported as reused.
- **Remote-only branch:** `origin/<branch>` exists, no local branch →
  `git worktree add "$path" -b "$branch" --track "origin/<branch>"`; the
  report says it tracks the remote.
- **Existing path:** create nothing. If `git -C "$path" rev-parse
  --show-toplevel` prints `$path` and `git -C "$root" worktree list` lists it,
  open the tab on it and report it as reused, naming the branch it is on if
  that differs. If the path is anything else (a plain folder, another
  repository), it is an unrelated collision: ask before touching it.
- **Inside a linked worktree:** step 1 resolves `root` to the main checkout,
  so new worktrees go to the main checkout's `.worktrees/`, never inside the
  current worktree or beside the repository.
- **Non-Herdr terminal** (`HC_TERMINAL_ID` unset, or no space found in step
  7): still create the worktrees, skip steps 7–9, and print the commands for
  the user to run from the Herdr window, with `<spaceId>` taken from
  `herdr-app ls`:

  ```sh
  herdr-app do tab.new --space <spaceId> --name <branch> --folder <abs worktree path>
  ```

  The report table then shows `not opened` in place of a confirmed tab.
- **A tab with the same name already exists** in the space: leave it, and
  open the new tab alongside it.
