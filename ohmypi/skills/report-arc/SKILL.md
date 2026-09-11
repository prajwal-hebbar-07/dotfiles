---
name: report-arc
description: >
  The step-report shape used while following an implementation plan, and a
  way to turn any report in that shape into documentation. Use after a plan
  step, when the user pastes a step report, says "document this report",
  "generate docs from this", "report arc", or invokes /report-arc.
argument-hint: "[document] [path]"
---

# Report arc

Two jobs. Same shape.

1. **Emit** the report after a plan step (follow does this).
2. **Document** a report the user hands you — this chat, a paste, or a file.
   Any report in this arc, not only plan steps.

Do not implement product code in either job.

## Emit

Fill [template.md](template.md). One report per step. Status line first,
then the table, then leftovers, then next. Invent nothing: if a cell is
unknown, say so. Do not add a "your call" fork. If a gate was already red
at HEAD and this step added no errors, the gate is met — say that, continue.

## Document

The user wants a durable page from a report. Do not recap in chat and stop.

**Source**, in order: a path they named, a fenced report in this message, the
latest report in this chat. If none, ask. Stop.

**Write** `docs/reports/<slug>.md` unless they named a path. Slug from the
step subject or the report title, lowercase, hyphens. Create `docs/reports/`
if needed. If the file exists, ask before overwriting.

Read [doc-template.md](doc-template.md) and fill it **only** from the report.
No new claims, no guessed file lists, no "probably also". Missing sections
stay missing. Date is today. SHA only if the report has one.

If you cannot write, emit the full page in one markdown fence and say it
still needs to be saved.

In chat: the path, and one sentence of what the page records. Do not dump
the page.