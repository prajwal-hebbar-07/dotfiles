# Requirement Gathering: Best AI Agent Skills & Engineering Practices

The strongest requirement-gathering workflows—whether executed by an AI coding agent via a `SKILL.md` package or led by a senior engineer—share one primary objective: **blocking premature implementation until hidden assumptions, edge cases, and non-goals are exposed.**

---

## 1. Best AI Agent Skills (`SKILL.md`) for Requirement Gathering

In the agentic coding ecosystem (Claude Code, OpenClaw, Cursor, Codex, Pi), dedicated requirement-gathering skills prevent agents from jumping straight into generating half-baked code when given an ambiguous prompt.

| Skill / Framework | Direct Links | Install / Setup | Core Mechanism & Why It Stands Out |
| :--- | :--- | :--- | :--- |
| **`obra/superpowers` (`brainstorming` skill)** | [GitHub Repo](https://github.com/obra/superpowers) • [SKILL.md Source](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md) • [Skillselion Page](https://skillselion.com/skills/obra/superpowers/brainstorming) | `npx skills add https://github.com/obra/superpowers --skill brainstorming` or `/plugin install superpowers@claude-plugins-official` | **Hard-Gate Discovery:** Blocks the agent from writing any code until it inspects the repository ("recon"), classifies the task (`spike`, `bounded`, or `architectural`), asks one-at-a-time clarifying questions, aligns on goals and anti-goals, and commits a spec (`docs/superpowers/specs/`) that passes a review check. |
| **`claude-requirements-gathering`** | [AwesomeSkills Page](https://awesomeskill.ai/skill/claude-requirements-gathering) • [Related CLI Builder Repo](https://github.com/rizethereum/claude-code-requirements-builder) | Extract to `.claude/skills/` | **Domain-Aware Triage:** Classifies the request type (new feature, enhancement, or integration), runs pre-investigation on existing codebase patterns, asks universal discovery questions, and branches into targeted checklists (auth, CRUD, permissions, error handling). |
| **`prd` (Product Requirements Document)** | [ClawHub Registry](https://github.com/openclaw/clawhub) • [OpenClaw Skill Page](https://openclaw-easy.com/skills/prd.html) • [AgentSkillsList](https://agentskillslist.com/skills/prd/) | `openclaw skills add prd` or `clawhub install prd` | **Structured Spec Generation:** Converts rough feature ideas into engineering-ready PRDs complete with problem statements, MoSCoW prioritization, user stories, and Gherkin (`Given/When/Then`) acceptance criteria. |
| **Analyst Validation Pattern (`Confirmed / Assumption / Open`)** | [r/ClaudeWorkflows Guide](https://www.reddit.com/r/ClaudeWorkflows/comments/1vzoqtj/workflow_claude_as_a_requirements_analyst/) • [Discuss Open Question Skill](https://www.skillsdirectory.com/skills/uhappylogic-discuss-open-question-cairn) | Custom `SKILL.md` / Prompt Workflow | **Anti-Hallucination Audit:** Forces the agent to extract requirements from meeting notes or rough prompts and explicitly tag every item as `[Confirmed]`, `[Assumption]`, or `[Open Question]` before drafting architecture or tasks. |

### Detailed Reference Links
* **Superpowers Framework (`obra/superpowers`):** https://github.com/obra/superpowers
* **Superpowers `brainstorming` `SKILL.md`:** https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md
* **Gathering Requirements (AwesomeSkills):** https://awesomeskill.ai/skill/claude-requirements-gathering
* **Claude Code Requirements Builder (`rizethereum`):** https://github.com/rizethereum/claude-code-requirements-builder
* **OpenClaw `prd` Skill:** https://openclaw-easy.com/skills/prd.html
* **ClawHub Registry (`openclaw/clawhub`):** https://github.com/openclaw/clawhub
* **Claude as a Requirements Analyst Workflow:** https://www.reddit.com/r/ClaudeWorkflows/comments/1vzoqtj/workflow_claude_as_a_requirements_analyst/
* **Discuss Open Question Skill (`SkillsDirectory`):** https://www.skillsdirectory.com/skills/uhappylogic-discuss-open-question-cairn

---

## 2. Core Engineering & Product Skills for Requirement Elicitation

When gathering requirements directly from clients, stakeholders, or product teams, these six competencies separate senior engineers from order-takers:

### 1. Root-Cause Interrogation (The "Five Whys" over Solution Requests)
Stakeholders almost always ask for a specific implementation (*"add a CSV export button"*) rather than stating their underlying problem. Drilling down to the actual workflow bottleneck (*"we need to reconcile weekly payouts in another tool"*) often reveals a simpler or more automated architectural solution.

### 2. Explicit Non-Goals & Anti-Goals
Defining what the system will **not** do in `v1` is just as critical as listing features. Locking down non-goals early prevents mid-sprint scope creep and keeps architecture focused.

### 3. Boundary & Failure-Mode Probing
Stakeholders naturally describe only the "happy path." Strong requirement gathering systematically probes state transitions and edge cases:
* What happens on empty states, duplicate submissions, or partial network failures?
* Who has permission to view, mutate, or delete this resource?
* What are the rate limits, concurrency risks, or third-party API fallback behaviors?

### 4. Non-Functional Requirement (NFR) Scoping
Capturing operational constraints up front—latency targets, expected payload sizes, data privacy/retention rules, audit logging, and deployment environments—ensures architectural decisions aren't invalidated late in development.

### 5. Visual & Prototype Validation
Prose hides ambiguity. Translating verbal requirements into quick state diagrams, data flow sketches, wireframes, or throwaway spikes forces stakeholders to confront edge cases immediately and confirm shared understanding before production code is written.

### 6. Binary Acceptance Criteria (`Given / When / Then`)
Replacing vague adjectives (*"fast," "intuitive," "secure"*) with verifiable Definition of Done criteria so engineering and QA know the exact conditions required to ship:
```gherkin
Given an authenticated user with an expired billing method
When they attempt to trigger a manual data export
Then the system blocks the job and prompts a billing update modal within 200ms
```
