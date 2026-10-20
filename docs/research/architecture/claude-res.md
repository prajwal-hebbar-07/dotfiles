## Claude / Agent Skills for Application Architecture Design

### General System Architecture

- **[tomas-u/claude-skills – Technical Architecture skill](https://github.com/tomas-u/claude-skills)**
  An all-round skill for system architecture, API design (REST & GraphQL) and security architecture. It also includes reference files for database design and deployment systems. Good for greenfield design.

- **[ruvnet – agent-arch-system-design (Ruflo / claude-flow)](https://skillselion.com/skills/ruvnet/ruflo/agent-arch-system-design)**
  Designs scalable architectures, writes ADRs and produces diagrams while treating production code as read-only. It only writes into `docs/architecture` and `docs/design`.
  Install: `npx skills add https://github.com/ruvnet/ruflo --skill agent-arch-system-design`

- **[Software Architecture Design – ClaudSkills registry](https://claudskills.com/skills/software-architecture-design/)**
  A single-file community skill that installs to `~/.claude/skills/software-architecture-design/`. The simplest to drop in.

### Patterns & Principles

- **[itzcull/software-skills](https://github.com/itzcull/software-skills)**
  A stack-agnostic collection covering system design trade-offs, domain-driven design and a design-patterns skill (GoF + architectural patterns, 22 reference files).
  Install: `/plugin marketplace add itzcull/software-skills` then `/plugin install software-skills@software-skills`

- **[kayaman/skills](https://github.com/kayaman/skills)**
  - `clean-architecture`: enforces the dependency rule, layer separation and component design.
  - `oop-design-patterns`: covers SOLID, all 23 GoF patterns, refactoring and OOAD.

### Reviewing Existing Architecture

- **[nobelk/claude-tools](https://github.com/nobelk/claude-tools)**
  `architecture-review`, `design-doc-review` and `prd-to-design-doc` skills, with Mermaid diagram output. Good for turning a PRD into a design doc and critiquing it.

- **[1ikeadragon – architecture-review & agent-system-design (skillsmp)](https://skillsmp.com/creators/1ikeadragon)**
  - `architecture-review`: maps entrypoints, data/control flow, boundaries and failure modes before proposing a design.
  - `agent-system-design`: for LLM agent architectures (tools, memory, subagents, guardrails, evals).

### Recommended Combo

For most application design work, use **itzcull/software-skills** for depth on patterns and DDD. Pair it with **nobelk/claude-tools** (`architecture-review` + `design-doc-review`) for the review loop.

> **Note:** These are community-made skills. Read each `SKILL.md` before installing, since some include hooks that run shell commands (e.g. Ruflo's skill runs `find .` on your project at startup).