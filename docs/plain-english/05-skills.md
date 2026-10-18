# The Tool Drawers

**Covers:** the shared coding-assistant skills and where they are linked

Think of `skills/` as a row of labelled tool drawers, each containing step-by-step
instructions for a specific task. The drawers are connected to two different workbenches
(Cursor and Antigravity), and the same drawers are available at each one.

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

## Two workbenches, one set of drawers

The drawers in `skills/` are linked into two coding assistants — Cursor and Antigravity
(`agy`). One directory, two doors. Edit a drawer once and both see the new instructions
the next time they restart.

---

## What to know when editing skills

- **Skill discovery is not automatic.** After adding or renaming a drawer, the coding
  assistant must be restarted before it can find the new instructions.
- **The links are hand-made.** Adding a drawer means adding it to the setup block in the
  top-level readme and running the link commands; nothing does it for you. The block
  currently still lists several drawers that were cleared.
