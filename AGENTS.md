# Oh My Pi harness config

This repo hosts multiple Oh My Pi modules under `ohmypi/`.

## Skills

Skills live under `ohmypi/skills/`:

- `repo-docs` — paired architecture + plain-English twin docs for any repo.
- `docs-twins` — generate or refresh twin docs (architecture + plain-English) for monorepo layouts.
- `docs-verify` — audit documentation claims against code for dead paths and stale symbols.
- `implementation-plan` — build a commit-by-commit implementation plan, five commits per file (gitignored).
- `review-implementation-plan` — review an implementation plan (one file per window).
- `follow-implementation-plan` — implement the plan; delete each finished file and chain the next in a new agent.
- `implement-commit-prompt` — build a copy-pasteable prompt to implement one commit.
- `report-arc` — step reports and durable report pages.
- `commit` — create a semantic commit from staged changes.
- `paper-target` — pin a Paper.design file/page for this repo.
- `twitter-campaign` — coordinated Twitter/X + Reddit launch campaign from a
  project directory; incremental refresh from the stored generation commit.

## Agents

Agents live under `ohmypi/agents/`:

- `committer` — creates semantic commits.
