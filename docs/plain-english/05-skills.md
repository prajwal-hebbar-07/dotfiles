# The Tool Drawers

**Covers:** the shared coding-assistant skills, where they are linked, and the Oh My Pi
settings

Think of `skills/` as a row of labelled tool drawers, each containing step-by-step
instructions for a specific task. The drawers are connected to three different workbenches
(Cursor, Antigravity, and Claude Code), and the same drawers are available at each one.
`omp/` is the setup sheet for a fourth workbench, Oh My Pi.

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

The drawers in `skills/` are linked into three coding assistants — Cursor, Antigravity
(`agy`), and Claude Code. One directory, three doors. Edit a drawer once and all three see
the new instructions the next time they restart. Claude Code sees the documentation
drawer under the name `pdocs`, because it already has a drawer called `docs`.

---

## The Oh My Pi setup sheet (`omp/`)

Oh My Pi is the coding assistant this repository is mostly edited with. Its folder holds:

- **Settings** — which model handles which kind of work, plus the colour theme. Oh My Pi
  also saves changes into this file itself.
- **The design-tool connection** — one entry that lets the assistant talk to Paper, the
  design app.
- **A standing rule** — never start an app, a server, or a test run unless asked for that
  in the current request.
- **The factory** — a skill and a matching `/factory` command that walk a feature or fix
  through review gates, saving a checkpoint commit at each one.

Each file is linked back to where Oh My Pi looks for it, the same way the drawers are.

---

## What to know when editing skills

- **Skill discovery is not automatic.** After adding or renaming a drawer, the coding
  assistant must be restarted before it can find the new instructions.
- **The links are hand-made.** Adding a drawer means adding it to the setup block in the
  top-level readme and running the link commands; nothing does it for you. The block
  currently still lists several drawers that were cleared.
