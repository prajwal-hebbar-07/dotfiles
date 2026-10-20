# Requirement Gathering: Best AI Agent Skills & Engineering Practices

The strongest requirement-gathering workflows—whether executed by an AI coding agent via a `SKILL.md` package or led by a senior engineer—share one primary objective: **blocking premature implementation until hidden assumptions, edge cases, and non-goals are exposed.**

---

## 1. Best AI Agent Skills (`SKILL.md`) for Requirement Gathering

In the agentic coding ecosystem (Claude Code, OpenClaw, Cursor, Codex, Pi), dedicated requirement-gathering skills prevent agents from jumping straight into generating half-baked code when given an ambiguous prompt.

| Skill / Framework | Direct Links | Install / Setup | Core Mechanism & Why It Stands Out | 
| ----- | ----- | ----- | ----- | 
| **`obra/superpowers` (`brainstorming` skill)** | [GitHub Repo](https://github.com/obra/superpowers) • [SKILL.md Source](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md) • [Skillselion Page](https://skillselion.com/skills/obra/superpowers/brainstorming) | `npx skills add https://github.com/obra/superpowers --skill brainstorming` or `/plugin install superpowers@claude-plugins-official` | **Hard-Gate Discovery:** Blocks the agent from writing any code until it inspects the repository ("recon"), classifies the task (`spike`, `bounded`, or `architectural`), asks one-at-a-time clarifying questions, aligns on goals and anti-goals, and commits a spec (`docs/superpowers/specs/`) that passes a review check. | 
| **`claude-requirements-gathering`** | [AwesomeSkills Page](https://awesomeskill.ai/skill/claude-requirements-gathering) • [Related CLI Builder Repo](https://github.com/rizethereum/claude-code-requirements-builder) | Extract to `.claude/skills/` | **Domain-Aware Triage:** Classifies the request type (new feature, enhancement, or integration), runs pre-investigation on existing codebase patterns, asks universal discovery questions, and branches into targeted checklists (auth, CRUD, permissions, error handling). | 
| **`prd` (Product Requirements Document)** | [ClawHub Registry](https://github.com/openclaw/clawhub) • [OpenClaw Skill Page](https://openclaw-easy.com/skills/prd.html) • [AgentSkillsList](https://agentskillslist.com/skills/prd/) | `openclaw skills add prd` or `clawhub install prd` | **Structured Spec Generation:** Converts rough feature ideas into engineering-ready PRDs complete with problem statements, MoSCoW prioritization, user stories, and Gherkin (`Given/When/Then`) acceptance criteria. | 
| **Analyst Validation Pattern (`Confirmed / Assumption / Open`)** | [r/ClaudeWorkflows Guide](https://www.reddit.com/r/ClaudeWorkflows/comments/1vzoqtj/workflow_claude_as_a_requirements_analyst/) • [Discuss Open Question Skill](https://www.skillsdirectory.com/skills/uhappylogic-discuss-open-question-cairn) | Custom `SKILL.md` / Prompt Workflow | **Anti-Hallucination Audit:** Forces the agent to extract requirements from meeting notes or rough prompts and explicitly tag every item as `[Confirmed]`, `[Assumption]`, or `[Open Question]` before drafting architecture or tasks. | 

### Detailed Reference Links (General Discovery)

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

```text
Given an authenticated user with an expired billing method
When they attempt to trigger a manual data export
Then the system blocks the job and prompts a billing update modal within 200ms
```

---

## 3. Best AI Agent Skills for Requirement Interrogation ("Grilling")

Skills built specifically to **grill** you flip default AI behavior: instead of politely guessing missing details to please you, they act like a skeptical Staff Engineer—challenging vague hand-waving, exposing blind spots, and refusing to write code until you defend your data models, edge cases, and failure modes.

| Skill / Framework | Direct Links | Install / Command | Grilling Style & Mechanism |
| :--- | :--- | :--- | :--- |
| **`obra/superpowers` (`brainstorming` skill)** | [GitHub Repo](https://github.com/obra/superpowers) • [SKILL.md Source](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md) | `npx skills add https://github.com/obra/superpowers --skill brainstorming` | **Socratic Hard-Gate:** Inspects your codebase silently first, then grills you **one question at a time**. Pushes back on over-engineering (YAGNI) and blocks all code generation until a written spec is signed off. |
| **`github/spec-kit` (`/speckit.clarify`)** | [GitHub Repo](https://github.com/github/spec-kit) | `uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT_NAME>` | **Taxonomy Ambiguity Hunter:** Scans your rough feature prompt across 10+ engineering categories (data model, edge cases, NFRs, auth, state transitions) and runs an interactive interrogation loop (`/speckit.clarify`) until zero ambiguities remain. |
| **`get-shit-done` (`/gsd:discuss-phase`)** | [GitHub Repo](https://github.com/glittercowboy/get-shit-done) | `npx get-shit-done-cc@latest` | **Gray-Area Pinpoint Grilling:** Before generating a plan, `/gsd:discuss-phase` isolates hidden implementation gray areas (UX behavior, API contracts, error recovery) and forces you to make concrete trade-off decisions. |
| **BMAD Method (`analyst` + `pm` agents)** | [GitHub Repo](https://github.com/bmad-code-org/BMAD-METHOD) | `npx bmad-method install` | **Adversarial Role-Play:** Splits interrogation into stages—first grilling your business logic and user flows, then cross-examining your technical architecture, state mutations, and scale constraints. |

### Detailed Reference Links ("Griller" Frameworks)

* **Superpowers (`obra/superpowers`):** https://github.com/obra/superpowers
* **GitHub Spec Kit (`github/spec-kit`):** https://github.com/github/spec-kit
* **Get Shit Done (`glittercowboy/get-shit-done`):** https://github.com/glittercowboy/get-shit-done
* **BMAD Method (`bmad-code-org/BMAD-METHOD`):** https://github.com/bmad-code-org/BMAD-METHOD

---

## 4. What Makes a Skill Actually "Grill" You (Core Mechanics)

Most generic requirement skills fail because they dump 15 surface-level questions in a single message and accept lazy answers. The best interrogation skills enforce four strict rules:

1. **Codebase Recon Before Question 1:** The agent must read your existing schema, routes, and patterns *before* speaking. It should never ask you a question it can answer via `grep` or file inspection.
2. **Strict One-to-Two Questions Per Turn:** Adaptive grilling requires follow-ups. When you answer Question 1, the agent should spot the flaw in your answer and drill deeper on *that exact point* before moving to a new topic.
3. **Anti-Hand-Waving Pushback:** If you answer *"just do standard error handling"* or *"we'll figure out permissions later,"* the skill must reject the answer and force a concrete decision (*"Does a failed webhook retry with exponential backoff, land in a dead-letter queue, or fail silently?"*).
4. **Pre-Mortem Framing:** Instead of asking *"How should this work?"*, it asks *"It is 3:00 AM in production and this feature just corrupted user state—how did that happen?"*

---

## 5. Drop-In `SKILL.md` Template: The "Ruthless Spec Griller"

Save this template to `.claude/skills/grill-me/SKILL.md` or `.agents/skills/grill-me/SKILL.md` to create a dedicated adversarial Staff Engineer skill:

```markdown
---
name: grill-me
description: Use when the user asks to be grilled, interrogated, or challenged on a feature idea, architecture, or requirement before writing code. Acts as a skeptical Staff Engineer that exposes blind spots one question at a time.
---

# Ruthless Requirement & Architecture Griller

You are a skeptical, battle-hardened Staff Engineer conducting a high-stakes design review. Your job is to find every hole, unstated assumption, race condition, and scope trap in the user's idea BEFORE a single line of implementation code is written.

## Hard Rules (Non-Negotiable)

1. **NO CODE GENERATION:** Do not write implementation code, scaffolding, or PRDs until the interrogation phase is explicitly completed and the user passes the review.
2. **SILENT RECON FIRST:** If inside a repository, inspect existing schemas, API patterns, auth middleware, and directory structure BEFORE asking your first question. Reference actual files when challenging the user.
3. **ONE QUESTION AT A TIME:** Ask at most 1 (or 2 tightly coupled) questions per turn. Never dump a checklist of 10 questions. Wait for the user's answer, evaluate it critically, and drill deeper if the answer is vague.
4. **PUNISH HAND-WAVING:** If the user says "handle it normally," "standard auth," "keep it simple," or "we'll do that later," push back immediately. Force them to choose a concrete behavior or explicitly log it as a risky debt item.
5. **PROPOSE CONCRETE TRADE-OFFS:** When grilling, frame questions with sharp architectural trade-offs (e.g., "If a user submits this twice in 200ms, do we enforce an idempotency key at the API layer, lock the DB row, or allow duplicate records?").

## The 5 Grilling Pillars (Work Through Sequentially)

### Phase 1: Problem Reality & Anti-Goals
- Challenge whether this feature actually needs to be built or if a simpler workflow solves the root problem.
- Force the user to define **3 explicit Non-Goals** (what we are strictly NOT building in v1).

### Phase 2: Data Model, State & Boundaries
- Grill on source of truth: What tables/collections mutate? What is the exact lifecycle/state machine of the entity?
- What happens on partial updates, orphan records, or schema migrations?

### Phase 3: Concurrency, Failure Modes & Edge Cases
- Assume every external API, webhook, LLM call, or database transaction will time out or fail halfway through.
- Grill on: idempotency, retries, rate limits, empty states, and payload size ceilings.

### Phase 4: Security, Permissions & Abuse
- Who can read, mutate, or delete this? How can a malicious user abuse this endpoint or UI flow?
- Are there tenant isolation, PII leakage, or quota exhaustion risks?

### Phase 5: Verification & Definition of Done
- How will we prove this works without manual clicking? Force concrete `Given / When / Then` acceptance criteria.

## Exiting the Grill

Only when all 5 pillars are satisfied (or when the user says "wrap up the grill"), output a clean **Battle-Tested Spec** in Markdown containing:
- **Summary & Explicit Non-Goals**
- **Architecture & Data Flow Decisions**
- **Edge Case & Failure Matrix**
- **Requirement Ledger** (Every item tagged as `[Confirmed]`, `[Assumption - Needs Validation]`, or `[Deferred to v2]`)
- **Binary Acceptance Criteria (`Given / When / Then`)**
```

---

## 6. Quick Ad-Hoc "Grill Me" Trigger Prompt

Use this snippet in any chat session when you want to be interrogated without invoking a saved skill file:

```text
Before writing any code or drafting a plan, act as a skeptical Staff Engineer and grill me ruthlessly about this idea. 
Rules:
1. Inspect the codebase first so you don't ask questions the repo already answers.
2. Ask me ONLY ONE tough question at a time.
3. Challenge vague answers, expose edge cases (concurrency, partial failures, auth, state mutations), and push back on over-engineering.
4. Do not write a spec or code until you've poked holes across data models, failure modes, and non-goals.

Here is what I want to build: [INSERT IDEA]
```
