# The Agent Workshop

**Covers:** the coding-assistant setup — rules, skills, agents, and connections

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
6. **Never write a document unless I asked for one through a skill.** Documents of any
   kind come only from the four skills that write them — documentation, diagrams, the
   design-file pin, and the implementation plan — and only where those skills put their
   output; report in chat instead of writing a file.
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

Six labelled drawers, each containing a step-by-step guide for a repeatable task:

| Drawer | What it does |
| --- | --- |
| `commit` | Write and create a semantic commit from whatever is already staged — it never stages for you |
| `docs` | Generate or check this repository's documentation: a technical set, a plain-English set, or both |
| `arc-design` | Build a set of diagrams for named parts of the tree, then commit them |
| `implementation-plan` | Turn a finished design conversation into a commit-by-commit plan, five commits per file |
| `follow-implementation-plan` | Execute that plan one commit at a time, marking each step with the commit it landed as |
| `paper-target` | Pin the relevant design file and page into this repository's context |

A seventh, `archify`, draws the diagrams `arc-design` directs. It comes from someone else's
installer and lives outside this repository, so it updates on its own schedule.

An earlier, larger set was cleared in September 2026; `SKILLS.md` at the top of the
repository describes what each of those did, so any of them can be brought back on purpose
rather than by habit.

---

## Three workbenches, one set of drawers

The drawers in `ohmypi/skills/` are linked into three coding assistants — Oh My Pi, Cursor,
and Antigravity (`agy`). One directory, three doors. Edit a drawer once and all three see
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
- **The rules on the wall take effect in the next session**, not the running one. Editing
  the rules file and saving does not change what the current session already loaded.
- **The links are hand-made.** Adding a drawer means adding it to the setup block in the
  top-level readme and running the link commands; nothing does it for you. The block
  currently still lists several drawers that were cleared.
- **The design-tool connection uses a home-directory placeholder.** Oh My Pi expands it;
  another host that does not will fail to start that server.
