## Agent Skills for Getting Grilled on Requirements

### 1. mattpocock/skills: `grill-me`
- **Best for:** Getting your plan stress-tested hard
- **What it does:** Interviews you relentlessly about a plan or design until you reach shared understanding, resolving each branch of the decision tree.
  - Gives its own recommended answer for each question
  - Asks one question at a time
  - Checks the codebase instead of asking you when the code can answer it
- **Note:** The original and most installed grill skill (~990K installs). The whole skill is only a few lines.
- **Install:** `npx skills add https://github.com/mattpocock/skills --skill grill-me`
- **Usage:** Describe your plan, feature or architecture decision, then type `/grill-me`
- **Links:** [mattpocock/skills](https://github.com/mattpocock/skills) · [Guide](https://skillselion.com/guide/grill-me-skill-claude-code-guide) · [SKILL.md text](https://www.skills.sh/petekp/claude-skills/grill-me)

### 2. mattpocock/skills: `grill-with-docs`
- **Best for:** When you have existing docs or a codebase to check against
- **What it does:** Grounds every question in documentation you provide, so you get pushback against your actual domain model rather than generic questions.
- **Workflow tip:** Chain `/grill-me` → `/to-prd` → `/to-issues` to turn the grilling session into a PRD and then tickets.
- **Links:** [mattpocock/skills](https://github.com/mattpocock/skills) · [Workflow write-up (QuestionPro Engineering)](https://www.questionpro.com/engineering/engineering/developer%20tools/ai%20&%20machine%20learning/stop-asking-claude-to-agree-with-you/)

### 3. jscraik: `interview-me`
- **Best for:** Ending up with a clean, execution-ready spec
- **What it does:** Runs an interactive, multiple-choice interview for requirements discovery. Turns an underspecified idea or draft spec into a spec with decisions and assumptions.
- **Note:** More structured and less adversarial than `grill-me`.
- **Link:** [interview-me (Smithery)](https://smithery.ai/skills/jscraik/interview-me)

### 4. satya-janghu/agent-skills: `grill-me`
- **Best for:** Keeping a record of every decision
- **What it does:** A `grill-me` fork that logs the session to a markdown file in `.grill/` before moving to implementation.
- **Install:** `npx -y skills add satya-janghu/agent-skills --skill grill-me --agent claude-code`
- **Link:** [satya-janghu grill-me](https://claudemarketplaces.com/skills/satya-janghu/agent-skills/grill-me)

---

### Quick Pick
| Situation | Use |
|---|---|
| Want to be stress-tested hard | mattpocock `grill-me` |
| Have docs or a codebase to check against | `grill-with-docs` |
| Want a polished spec at the end | `interview-me` |
| Want a written log of decisions | satya-janghu `grill-me` |

> These are written for Claude Code, but the core instructions are short enough to add as a skill in Claude or paste straight into a chat. All are third-party community skills. Review each SKILL.md before installing.
