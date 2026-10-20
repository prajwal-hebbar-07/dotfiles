## Claude Skills for Getting Grilled About Architecture

### Interview-style (one question at a time)

- **[grill-me – mattpocock/skills](https://github.com/mattpocock/skills)**
  The original and most popular. Interviews you relentlessly about a plan, walking each branch of the decision tree and resolving dependent decisions in order. It suggests a recommended answer for every question, and reads your codebase instead of asking when it can.
  Install: `npx skills add https://github.com/mattpocock/skills --skill grill-me`

- **[grill-with-docs – mattpocock/skills](https://github.com/mattpocock/skills)**
  The architecture-focused sibling. Reads your existing ADRs and project context first, then challenges your plan against decisions already made. Best choice when you're working inside an existing project.
  Install: `npx skills add https://github.com/mattpocock/skills --skill grill-with-docs`

- **[grill-me – akillness/jeo-skills](https://claudeskills.info/skills/akillness/jeo-skills/grill-me/)**
  A more structured variant meant for use before committing to architectural decisions. Focuses on which decisions are load-bearing and hard to reverse, and documents open questions at the end.
  Install: `npx skills add akillness/jeo-skills --skill grill-me --agent claude-code`

### Adversarial / devil's advocate

- **[the-fool – jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills)**
  Stress-tests plans and architectures through five critical-reasoning modes: Socratic questioning, falsification, pre-mortem, red teaming and steel-manning. You pick the mode, e.g. "expose my assumptions" or "test the evidence".
  Install: `npx skills add jeffallan/claude-skills --skill the-fool --agent claude-code`

### Iterative critique (build your own)

- **[replan – PhotoStructure](https://photostructure.com/coding/claude-code-replan/)**
  A custom skill you create yourself. It asks clarifying questions first, then runs critique-and-refine loops on high-switching-cost decisions like data models and API surfaces. Easy to tailor to your own architecture docs.

### Suggested workflow

1. Start with **grill-with-docs** (or **grill-me** for greenfield work) to pin down requirements and decisions.
2. Run **the-fool** in pre-mortem or red-team mode on the resulting design.
3. Record the outcomes as ADRs so the next grilling session builds on them.

> **Note:** These are community skills. Read each `SKILL.md` before installing.