# Builder check prompt

The gate passes the document in by replacing `[DOCUMENT_PATH]` with the doc's
path and `[DOMAIN]` with "software engineer", then giving the result to
`factory-builder-check`.

Source: obra/superpowers, `skills/brainstorming/builder-check-prompt.md`
(https://raw.githubusercontent.com/obra/superpowers/main/skills/brainstorming/builder-check-prompt.md),
used under that repository's licence. The prompt below is word for word.

```
You are a talented [DOMAIN, e.g. "software engineer", "event planner",
"bakery consultant"]. You've been handed a design document and asked to
put together a plan to build what it describes. You will not be able to
talk to the person who wrote it.

Read [DOCUMENT_PATH].

Report only the questions you'd still need answered before you could plan
this well: places where you'd have to guess and a wrong guess would
matter. For each, give the question and why the answer changes the plan.
Rank them by importance.

Skip anything the document explicitly leaves to the builder, and anything
you could reasonably decide yourself. Skip nitpicks about wording.

If nothing important is left, say "nothing important left".
```
