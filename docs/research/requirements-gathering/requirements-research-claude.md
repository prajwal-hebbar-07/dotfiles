## Agent Skills for Requirements Gathering

### 1. obra/superpowers: `brainstorming`
- **Best for:** Software projects in Claude Code
- **What it does:** Runs a structured questioning-and-design process before any code is written. It asks clarifying questions one at a time (multiple-choice where possible) to pin down purpose, constraints and success criteria, then hands off to the `writing-plans` skill.
- **Install:** `npx skills add obra/superpowers --skill brainstorming`
- **Link:** [obra/superpowers](https://skills.sh/obra/superpowers) · [Usage guide](https://mcp.directory/blog/claude-brainstorming-skill-guide)

### 2. pablasso/skills: `prd` + `prd-review`
- **Best for:** PMs who want a lightweight create-then-critique workflow
- **What it does:** `prd` asks about the problem, users and constraints, then drafts a structured PRD. `prd-review` checks the PRD for problem clarity, user needs, requirements, UX states and scope before technical design.
- **Note:** Deliberately open-ended. It outlines areas to consider rather than giving exhaustive checklists.
- **Link:** [pablasso/skills](https://github.com/pablasso/skills)

### 3. idnotbe/prd-creator
- **Best for:** PMs who think in Epic / Feature / Story structure
- **What it does:** Builds a PRD through interactive conversation and focuses only on user-perspective requirements (what users need, not how to build it).
- **Install (Claude Code):**
  - `/plugin marketplace add idnotbe/claude-plugins`
  - `/plugin install prd-creator@idnotbe`
- **Note:** The README says to invoke it as `/prd-creator`, but the SKILL.md names it `creating-prds`.
- **Link:** [idnotbe/prd-creator](https://github.com/idnotbe/prd-creator)

### 4. github/awesome-copilot: `prd`
- **Best for:** Heavier, enterprise-style specs
- **What it does:** Guides you through structured discovery, then produces a PRD with an executive summary, user stories, technical architecture and risk analysis.
- **Install:** `npx skills add https://github.com/github/awesome-copilot --skill prd`
- **Link:** [awesome-copilot prd skill](https://claudemarketplaces.com/skills/github/awesome-copilot/prd)

---

### Quick Pick
| Situation | Use |
|---|---|
| Building software | superpowers `brainstorming` |
| Writing PM specs | pablasso `prd` + `prd-review` |
| Need a full formal PRD | awesome-copilot `prd` |

### Recommendation
Use one of these as a base and build a custom skill in your team's PRD format, so outputs stay consistent across the team. See [Claude skills for product managers (Composio)](https://composio.dev/blog/claude-skills-for-product-managers-prds-roadmaps-and-research-synthesis).

> All of these are third-party community skills. Review each SKILL.md before installing.
