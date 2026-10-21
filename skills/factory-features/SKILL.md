---
name: factory-features
description: >
  Lists the features a project's code has (number, name, one line each) and
  nothing else. With `explain <feature>`, has the factory-explainer agent
  (GPT) write docs/features/<feature>.md: every code snippet on the
  feature's path, what each does line by line, and why it is written that
  way. Use when the user asks what features a project has, asks to explain
  a feature, or invokes /skill:factory-features.
argument-hint: "[explain <feature name or number>]"
---

# factory-features

Two modes, picked from the arguments:

| Arguments | Mode |
| --- | --- |
| none | **list** |
| `explain <name or number>` | **explain** |

Run from the target repo's root. Design: `SOFTWARE-FACTORY.md` §4.9 in the
dotfiles repo.

## Never

- Edit product code, `AGENTS.md`, or anything under `docs/factory/`.
- Write any file in **list** mode.
- Write anything in **explain** mode except `docs/features/<slug>.md`.
- `git add`, commit, or push. The user runs `commit` to keep a document.
- Write the explanation yourself. The `factory-explainer` agent writes it.
- Save a document whose snippets have not passed `scripts/check-snippets.py`.

## List

1. Find the source roots: top-level directories in `git ls-files` (or the
   tree, outside git) that hold code. Skip docs, assets, lockfiles,
   generated and vendored code, and CI config.
2. One `scout` per source root, all in one `task` batch (one scout total
   when the repo has fewer than ~50 code files). Each returns the
   **entry points** a user reaches: screens, HTTP routes, CLI commands,
   scheduled jobs, public library API, skills or plugins the project
   ships. For each: kind, `path:line`, and one line on what it lets the user
   do.
3. Group entry points into **features**: one feature is one thing a user can
   do. A screen and the route it calls are one feature. Drop internal
   helpers no user reaches.
4. Name each feature from `docs/factory/GLOSSARY.md`, else the requirement
   titles in `docs/factory/REQUIREMENTS.md`, else from the code. Plain words,
   from the user's side.
5. Print only this table, numbered in the order a user would meet the
   features:

   | # | Feature | What it does |
   | --- | --- | --- |
   | 1 | <name> | <one line, from the user's side> |

   No requirements, issues, status, modules, or paths. Keep each feature's
   entry points in mind for **explain**; do not print them.

## Explain

1. **Resolve the feature.** A number refers to the list shown in this
   session; with no list yet, run **List** steps 1–4 without printing. A
   name matches a feature when it names the same thing (case and wording
   may differ). No match, or more than one: print the list, ask which one,
   stop.
2. **Facts for the agent**, from the repo root:
   - `git rev-parse --short HEAD` → `<sha>`; outside git, `<sha>` is
     `no commit`.
   - `git status --porcelain -- . ':!docs/features'`: when it is not empty,
     the stamp becomes `<sha> plus uncommitted changes`. Earlier
     explanations under `docs/features/` do not count.
   - today's date, `YYYY-MM-DD`.
   - `<slug>`: the feature name, lowercased, every run of non-letters and
     non-digits replaced by `-`, trimmed of `-`.
3. **Spawn `factory-explainer`** (one `task` item, `agent:
   factory-explainer`). Its task gives: the feature name and its one line,
   its entry points (`path:line` each), the repo root, the stamp, the date,
   and the template path `skill://factory-features/template.md`. Its result
   is the whole document as markdown.
4. **Check it.** Write the result to `$TMPDIR/factory-features-<slug>.md`,
   then run, from the repo root:

   ```sh
   python3 <skill dir>/scripts/check-snippets.py "$TMPDIR/factory-features-<slug>.md" --root .
   ```

   - Exit 0: go to step 5.
   - Exit 1 or 2, first time: spawn `factory-explainer` again with the same
     task plus the checker's output and the rejected document, asking for
     the whole corrected document. Check again.
   - Exit 1 or 2, second time: delete the temp file, print the checker's
     output, stop. Nothing is saved.
5. **Model line.** If the header still reads `written by <model>`, replace
   `<model>` with `factory-explainer (@slow)`. Change nothing else in the
   document.
6. **Save.** `mkdir -p docs/features`, move the file to
   `docs/features/<slug>.md` (overwrite), and print exactly one line:

   ```text
   Saved docs/features/<slug>.md (explains commit <stamp>). Not committed.
   ```
