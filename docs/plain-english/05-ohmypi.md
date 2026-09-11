# The Agent Workshop

**Twin of:** [Oh My Pi Harness and Skills](../architecture/05-ohmypi.md)

Think of `ohmypi/` as the workshop wing of the studio — a set of rules posted on the wall,
a handful of specialist apprentices you can call on, and a row of labelled tool drawers,
each containing step-by-step instructions for a specific task. The workshop is connected to
three different workbenches (Oh My Pi, Cursor, and Antigravity), and the same drawers are
available at each one.

---

## The rules on the wall (`RULES.md`)

Seven hard rules are posted at eye level and re-read at the start of every working session.
They override any other instruction, including instructions that come from the harness itself:

1. **Never start, stop, or restart an application.** Name what needs a restart — I do it.
2. **Never start a dev server or run the test/build suite** — not even to see what is
   happening. I start it, test it, and tell you what I saw.
3. **Never open or drive the browser tool** — including as "verification".
4. **Investigate only when asked.** Implement what is requested and nothing else until told.
5. **Never reach for the planning or delegation workflow** unless explicitly invoked.
6. **Never write documentation outside a docs skill.** Markdown documents come only from the
   documentation skills; report in chat instead of writing a file.
7. **Never amend a commit.** No `--amend`, rebase, or force-push — a fix is always a new
   commit on top.

Permission lifts a rule only for the specific action named in that request. "Go ahead" or
"make it work" is not permission.

What always stays allowed without asking: reading files, grepping for things, read-only git
commands, syntax checks on files just changed.

---

## The specialist apprentice (`committer` agent)

There is one task agent: the **committer**. When the commit skill is run in the main
session, it may delegate to this apprentice, who then:

1. Checks that your name and email are configured in git.
2. Checks that there are staged files (never stages anything itself).
3. Reads the diff and writes a semantic commit message.
4. Commits.
5. Verifies that no machine or tool attribution crept into the message.
6. Reports in at most five lines: the short hash, subject, file count, and anything
   left uncommitted.

The apprentice uses a lighter-weight model and the bash tool only. The diff never enters the
main session's context — it is read by the cheaper model instead.

---

## The tool drawers (skills)

Ten labelled drawers, each containing a step-by-step guide for a repeatable task:

| Drawer | What it does |
| --- | --- |
| `commit` | Write and create a semantic git commit from staged changes |
| `repo-docs` | Generate or refresh paired technical and plain-English docs for any repo |
| `docs-twins` | Same, but for repos with a fixed monorepo layout |
| `docs-verify` | Check every documentation claim against the code; find dead paths and stale names |
| `implementation-plan` | Write a commit-by-commit plan for a feature or refactor |
| `review-implementation-plan` | Review that plan: split, merge, reorder, clarify |
| `follow-implementation-plan` | Execute the next unfinished step of a plan |
| `implement-commit-prompt` | Extract one plan step as a prompt for a fresh chat session |
| `report-arc` | Write a step report, or save any such report as a permanent page |
| `paper-target` | Pin the relevant Paper.design file and page into this repository's context |

---

## Three workbenches, one set of drawers

The drawers in `ohmypi/skills/` are shared across three coding assistants:

| Workbench | Which drawers are available |
| --- | --- |
| Oh My Pi | All ten |
| Cursor | Eight (all except `commit` and `docs-twins`; Cursor has its own commit workflow) |
| Antigravity (agy) | Four: `commit`, `docs-twins`, `docs-verify`, `repo-docs` |

One directory, linked to three places. Edit a drawer once, and all three workbenches see
the new instructions the next time they restart.

---

## The Paper connection (`mcp.json`)

A single server entry connects the workshop to Paper Desktop, a design tool. It gives the
coding assistant three read-only tools for looking up files and pages in Paper. The
`paper-target` skill uses these tools to pin the right design file into context; it never
writes to Paper.

The server runs locally on this machine as a background command. It only works if Paper
Desktop is installed at the expected location (`~/.paper/bin/paper`).

---

## What to know when editing skills

- **Skill discovery is not automatic.** After adding or renaming a drawer, the coding
  assistant must be restarted before it can find the new instructions.
- **The `commit` drawer is not available in Cursor.** Cursor's own commit workflow covers
  that ground.
- **The rules on the wall take effect in the next session**, not the running one. Editing
  `RULES.md` and saving does not change what the current session already loaded.
- **The Paper server uses a literal home directory path.** If a different coding host
  handles path variables differently, the server may fail to start.
