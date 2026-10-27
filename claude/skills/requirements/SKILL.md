---
name: requirements
description: >
  Captures the requirements for an application the user wants to build into
  docs/requirements.md, and tracks the whole project in docs/project.md so a
  new chat can pick up exactly where the last one stopped. Records what the
  user says, numbered and in their own words; does not interview, design, or
  pick a stack. Use when the user says "/requirements", wants to note down
  what an app should do, or wants to resume that.
argument-hint: "[requirements text | status | approve]"
disable-model-invocation: true
---

# requirements

Turn what the user says about an app into `docs/requirements.md`, and keep
`docs/project.md` current as the one place that says where the project is.
Both live in the app repo (the git root, else the current directory). All
state is in those two files, so any chat can stop and any later chat can
continue. Templates: `project-template.md` and `requirements-template.md`
in this skill's directory.

## Never

- Invent, infer, or "improve" a requirement. No acceptance criteria, user
  stories, priorities, or tech choices the user did not state.
- Soften, round, or reword a number, limit, name, or a "must" / "never" /
  "always". Keep it exactly as said.
- Renumber or reuse an ID. A removed item keeps its ID.
- Interview or grill. Something unclear is recorded as said, plus an open
  question; the grill is a separate step.
- Choose a stack or architecture, or start those stages. A technology the
  user names is recorded as a constraint.
- Stage, commit, or push. Tell the user the files are uncommitted when done.
- Rely on earlier chat. Anything that matters is written to the files before
  you reply.
- Edit any file other than `docs/project.md` and `docs/requirements.md`.

## Step 1 — find the state

```sh
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
date +%F
```

Read `$root/docs/project.md` and `$root/docs/requirements.md` if they exist.

| Found | Do |
| --- | --- |
| Neither | New project: Step 2 |
| `project.md` only | Recreate `requirements.md` from the template, log it, Step 3 |
| `requirements.md` only | Create `project.md` from the template with the requirements row set from the file's `Status:` line, log it, Step 3 |
| Both | Resume: Step 3 |

## Step 2 — start (new project)

Take the project name and one-line description from what the user said. If
they gave nothing yet, ask once: "What are you building? Tell me the
requirements in any order." Do not ask for a name; use the directory name if
none was said.

Create both files from the templates, set the requirements row to
`capturing`, and add the first log line. Then capture what the user said
(Step 4).

## Step 3 — resume

Count from `requirements.md` (never store counts in the tracker, so they
cannot drift): live items per prefix `R`, `N`, `C`, `X`, `A`, and open `Q`.
Print at most six lines:

```
<project> — requirements: <status>
R<n> functional · N<n> non-functional · C<n> constraints · X<n> out of scope · A<n> accepted unknowns · Q<n> open questions
Next: <Next action from project.md>
Last: <last log line>
```

If the argument is `status`, stop here and change nothing. If it is
`approve`: only when the status is `grilled`; otherwise say what is missing
and stop. Set `Status: approved` in `requirements.md` and the tracker row,
set **Next action** `Run /stack`, and log
`Approved, requirements.md <shasum -a 256 docs/requirements.md | cut -c1-12>`.
Typing the command is the user's approval. If the argument holds requirement
text, capture it (Step 4). Otherwise follow the Next action; for `capturing`
that is "What else?".

## Step 4 — capture

For each thing the user says, in this order:

1. **Split** it into single-idea items. Do not merge two statements, and do
   not add one they did not make.
2. **File** each item under its section, with the next free ID:
   `R` functional (what it does), `N` non-functional (speed, size, security,
   availability), `C` constraint (platform, budget, deadline, a named
   technology, compliance), `X` out of scope (said not to do). Who it is
   for goes in **Users**; why it exists goes in **Overview**.
3. **Keep the words.** When an item holds a number, limit, name, or a
   "must" / "never" / "always", add a `Said:` line with the user's exact
   phrase under it.
4. **Park doubt.** If a statement is ambiguous, conflicts with another, or
   leaves something obvious unsaid, record it as said and add a `Q` item
   saying what is unclear. Do not ask it now.
5. **Change or remove.** "Change R3 to …" rewrites it in place. "Drop R5"
   replaces its text with `dropped <date>: <reason if given>`. Never delete
   the line.

Write the file first, then update `project.md` in the same turn: the
requirements row's `Updated`, **Next action**, and one log line (what was
added, changed, or dropped, by ID).

Reply with only what changed, one short line per item, then "Keep going, or
say done.":

```
Added R4 users can reset a password by email · N2 pages load in 2 s
Changed R1 · Dropped R3
Parked Q3: "fast" has no number
```

## Step 5 — done

When the user says they are finished ("done", "that's all"):

1. `requirements.md`: `Status: captured`. `project.md`: requirements row
   `captured`, **Next action** `Run /grill-requirements on
   docs/requirements.md (<n> open questions)`, one log line.
2. Reply: the final counts, the open questions in full, and that both files
   are uncommitted.

Do not grill, approve, or move on to the stack.

## Reopening

If the user adds or changes something while the status is `captured`,
`grilling`, `grilled`, or `approved`: set it back to `capturing`, log
`Reopened from <status>`, and capture as usual. Rounds already ingested stay
as they are; `/grill-requirements` picks up from the changed file, and a
fresh-eyes check recorded against an older file no longer counts. If the stack or
architecture row is past `not started`, say it may need rechecking against
the change. Do not touch those rows yourself.

## Advisor

If an advisor is on (`/advisor`), consult it once, in Step 5 before setting
`captured`: ask it to read `requirements.md` against what the user said in
this chat and find anything invented, softened, merged, split wrongly,
renumbered, or filed in the wrong section. Fix what it finds that the user's
own words support. Do not consult on each message; capture stays quick.

Claude decides when the advisor is called, so name the point in the
consultation. If the advisor is off, unavailable, or declines, say so in one
line and carry on; this skill never stops on it. Its answer is advice: where
the files or the user's words contradict a claim, follow them and say so. It
never answers a question for the user or supplies a requirement.
