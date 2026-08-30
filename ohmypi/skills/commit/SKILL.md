---
name: commit
description: Commit already-staged changes with a semantic message and pointer bullets, delegated to a cheap model. Use whenever the user asks to commit, or says "commit this", "/skill:commit".
---

# commit

Turn staged changes into one semantic commit **without spending main-session tokens on
the diff**. The diff is read by `committer`, which runs on `ollama-cloud/glm-5.3-flash`,
so it spends no Claude credits at all.

## Do this

Dispatch one task and stop. Do not run `git diff`, do not read the staged files, do not
draft the message yourself — that defeats the purpose of the skill.

```json
{
  "context": "Commit the staged changes in this repository.",
  "tasks": [
    {
      "agent": "committer",
      "name": "Commit",
      "task": "Commit the changes currently staged in this repository, following your instructions exactly: verify git identity, confirm something is staged, write a semantic subject plus pointer bullets, add no co-author or tool trailers. Report the short SHA and subject."
    }
  ]
}
```

Relay the agent's report — SHA, subject, file count — and nothing more.

## What the agent guarantees

1. `user.name` and `user.email` are set; if not, it stops and says which is missing
   rather than committing as the wrong author.
2. Something is actually staged; if not, it stops and lists what is unstaged. It never
   runs `git add` — staging stays the user's decision.
3. The message is `type(scope): imperative summary`, a blank line, then `- ` pointer
   bullets explaining what changed and why.
4. No `Co-Authored-By:` for Claude, Codex, omp, or Cursor, no "Generated with" line, no
   robot emoji. Git history stays free of harness attribution.

## Edge cases

- **Nothing staged** — relay the agent's report. Stage files yourself only if the user
  asked for that; otherwise ask what they want in the commit.
- **Missing identity** — relay the exact `git config --global` command. Do not set it.
- **Pre-commit hook fails** — relay the hook output. Never re-run with `--no-verify`.
- **`committer` unavailable** — dispatch the same task to `sonic`, whose instructions
  live here rather than in agent frontmatter, so paste the four guarantees above into
  the task text.
- **User wants a specific message** — pass their wording through in the task text; the
  agent still owns the trailer and format rules.

## Not this skill's job

Staging, amending, rebasing, pushing, tagging, or opening a PR. If the user asks for
those, do them directly.
