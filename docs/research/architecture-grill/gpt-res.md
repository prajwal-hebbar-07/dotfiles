# AI Agent Skills for Architecture Grilling & Critical Design Review

A curated collection of AI Agent Skills designed to **interrogate, challenge, validate, and improve application architecture decisions** before implementation begins.

These skills help AI coding agents act as critical software architects rather than simply agreeing with proposed designs.

They can be used with compatible agents such as Claude Code, Cursor, OpenCode, and Oh My Pi.

---

## 1. Best Architecture Grilling Skills

### 1.1 Grilling — Matt Pocock (Best Overall)

- **Repository:** [mattpocock/skills](https://github.com/mattpocock/skills)
- **Skill:** [grilling](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling)
- **Purpose:** Systematically interrogate architectural decisions, assumptions, and unresolved questions.

**Capabilities:**
- Break complex decisions into a dependency tree.
- Identify architectural assumptions.
- Ask challenging questions in structured rounds.
- Question proposed technologies and approaches.
- Expose missing requirements and constraints.
- Recommend possible solutions with trade-offs.
- Track unresolved decisions.
- Continue questioning until important ambiguities are resolved.

**Best for:**
- New application architecture discussions.
- Challenging high-level technical decisions.
- Identifying missing architectural considerations.
- Preventing premature implementation.
- Conducting deep architecture interviews.

**Installation:**

`npx skills add mattpocock/skills --skill grilling`

### 1.2 Grill Me — vvanagas (Best for Deep Questioning)

- **Repository:** [vvanagas/agent-skills](https://github.com/vvanagas/agent-skills)
- **Skill:** [grill-me/SKILL.md](https://github.com/vvanagas/agent-skills/blob/main/skills/grill-me/SKILL.md)
- **Purpose:** Conduct an intensive interview by asking focused questions and challenging incomplete answers.

**Capabilities:**
- Ask one question at a time.
- Challenge vague or incomplete answers.
- Demand concrete explanations.
- Question architectural assumptions.
- Identify contradictions between decisions.
- Track unresolved questions.
- Explore edge cases and failure scenarios.
- Push for clarity before moving forward.

**Best for:**
- Intensive one-on-one architecture interviews.
- Deep investigation of individual decisions.
- Challenging incomplete technical explanations.
- Exploring overlooked architecture risks.

**Installation:**

`npx skills add vvanagas/agent-skills --skill grill-me`

### 1.3 Grill With Docs — Matt Pocock (Best for Documented Decisions)

- **Repository:** [mattpocock/skills](https://github.com/mattpocock/skills)
- **Skill:** [grill-with-docs](https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs)
- **Purpose:** Combine rigorous questioning with structured documentation of the resulting decisions.

**Capabilities:**
- Interview users about technical decisions.
- Challenge assumptions and missing context.
- Investigate existing application architecture.
- Capture domain terminology.
- Document decisions and their reasoning.
- Track architectural uncertainties.
- Build a reusable knowledge base.
- Preserve context for future implementation.

**Best for:**
- Existing applications.
- Architecture discussions requiring documentation.
- Long-running projects.
- Maintaining architectural decision history.
- Preparing architecture specifications.

**Installation:**

`npx skills add mattpocock/skills --skill grill-with-docs --skill grilling --skill domain-modeling`

**Note:** The workflow relies on the associated grilling and domain-modeling skills.

### 1.4 AI Architecture Toolkit — Grill Me (Best for Solution Architecture)

- **Repository:** [Future-CX/AI-Architecture-Toolkit](https://github.com/Future-CX/AI-Architecture-Toolkit)
- **Link:** https://github.com/Future-CX/AI-Architecture-Toolkit
- **Purpose:** Conduct structured solution architecture interviews focused on system-level decisions and responsibilities.

**Key areas:**
- Application scope and requirements.
- Business and technical constraints.
- System boundaries.
- Service responsibilities.
- Data ownership.
- Integration architecture.
- Authentication and authorization.
- Security boundaries.
- Deployment architecture.
- Operational responsibilities.
- Architectural risks and assumptions.

**Best for:**
- Enterprise and full-stack application architecture.
- Backend and service design.
- Architecture interviews involving multiple systems.
- Identifying responsibilities between application components.

**Installation:** Refer to the repository instructions for the supported installation method.

### 1.5 Grilling — Ghosteken (Best for Multiple Architectural Decisions)

- **Repository:** [Ghosteken/agent-harness](https://github.com/Ghosteken/agent-harness)
- **Skill:** [grilling/SKILL.md](https://github.com/Ghosteken/agent-harness/blob/main/skills/grilling/SKILL.md)
- **Purpose:** Question multiple related technical decisions in organized rounds.

**Capabilities:**
- Identify dependent architectural decisions.
- Group related questions.
- Challenge implementation assumptions.
- Investigate alternative approaches.
- Expose unresolved dependencies.
- Identify inconsistencies between decisions.
- Facilitate structured decision-making.

**Best for:**
- Large application architectures.
- Systems with multiple interdependent components.
- Architecture involving authentication, databases, APIs, and infrastructure.
- Reviewing complex technical proposals.

**Installation:**

`npx skills add Ghosteken/agent-harness --skill grilling`

---

## 2. Complementary Architecture Criticism Skills

### 2.1 Architecture Advisor (Best for Challenging Technology Choices)

- **Repository:** [me-cedric/agent-compass](https://github.com/me-cedric/agent-compass)
- **Skill:** [architecture-advisor/SKILL.md](https://github.com/me-cedric/agent-compass/blob/main/skills/architecture-advisor/SKILL.md)
- **Purpose:** Evaluate architecture and technology choices against actual application requirements rather than developer preferences.

**Capabilities:**
- Challenge technology stack assumptions.
- Evaluate architectural alternatives.
- Examine technical constraints.
- Identify unnecessary complexity.
- Compare maintainability and scalability.
- Analyze architectural trade-offs.
- Separate confirmed requirements from assumptions.
- Recommend architecture improvements.

**Best for:**
- Selecting frameworks and technologies.
- Evaluating monoliths versus microservices.
- Choosing databases and infrastructure.
- Avoiding overengineering.
- Identifying long-term architectural risks.

**Installation:**

`npx skills add me-cedric/agent-compass --skill architecture-advisor`

### 2.2 Architect Design Review (Best for Post-Interview Validation)

- **Repository:** [sirius-zuo/architect-skills](https://github.com/sirius-zuo/architect-skills)
- **Skill:** [architect-design-review/SKILL.md](https://github.com/sirius-zuo/architect-skills/blob/main/architect-design-review/SKILL.md)
- **Purpose:** Critically review an architecture after initial decisions have been documented.

**Capabilities:**
- Review proposed system architecture.
- Evaluate architectural consistency.
- Identify weaknesses and design risks.
- Validate dependencies and responsibilities.
- Review scalability and maintainability.
- Identify potential architectural anti-patterns.
- Generate structured architecture review reports.

**Best for:**
- Independent architecture review.
- Validation before implementation.
- Evaluating proposed technical designs.
- Detecting architectural issues.

**Installation:**

`npx skills add sirius-zuo/architect-skills --skill architect-design-review`

---

## 3. Comparison

| Skill | Primary Strength | Recommended Use |
|---|---|---|
| Grilling — Matt Pocock | Structured, rigorous interrogation | Overall architecture grilling |
| Grill Me — vvanagas | Deep, sequential questioning | Thorough one-on-one interview |
| Grill With Docs | Questioning and documenting decisions | Existing projects |
| AI Architecture Toolkit — Grill Me | Solution architecture considerations | System-level architecture interviews |
| Grilling — Ghosteken | Multiple interdependent decisions | Complex system design |
| Architecture Advisor | Challenging technology choices | Stack and architecture selection |
| Architect Design Review | Critical architecture validation | Final design review |

---

## 4. Recommended Skill Combinations

### Stack A — Complete Architecture Grilling (Recommended)

**Skills:**
1. Grilling — Matt Pocock
2. Architecture Advisor
3. Architect Design Review

**Workflow:**
1. Grilling interviews the developer.
2. Architecture Advisor challenges the proposed technical decisions.
3. The developer confirms or revises the decisions.
4. Architect Design Review evaluates the resulting architecture.
5. Outstanding risks and unresolved decisions are documented.

**Best for:** Designing a new application architecture before implementation.

### Stack B — Deep Interactive Architecture Interview

**Skills:**
1. Grill Me — vvanagas
2. Architecture Advisor

**Workflow:**
1. Ask one high-impact architecture question.
2. Analyze the answer.
3. Challenge vague assumptions.
4. Explore alternatives.
5. Resolve the decision or explicitly mark it as unresolved.
6. Move to the next question.

**Best for:** Developers who want intensive architecture discussions with detailed follow-up questions.

### Stack C — Architecture Grilling With Documentation

**Skills:**
1. Grill With Docs
2. Grilling — Matt Pocock
3. Domain Modeling
4. Architect Design Review

**Workflow:**
1. Examine the existing documentation and repository.
2. Interview the developer.
3. Challenge architectural assumptions.
4. Document accepted decisions.
5. Maintain unresolved questions.
6. Review the resulting architecture.

**Best for:** Long-running applications, existing repositories, and projects where architecture decisions must be preserved.

### Stack D — Complex or Distributed Architecture

**Skills:**
1. Grilling — Ghosteken
2. AI Architecture Toolkit — Grill Me
3. Architecture Advisor
4. Architect Design Review

**Workflow:**
1. Identify major architectural decision groups.
2. Question system boundaries.
3. Challenge service responsibilities.
4. Examine data ownership and consistency.
5. Investigate communication patterns.
6. Evaluate deployment and failure scenarios.
7. Review architectural risks.

**Best for:** Distributed systems, SaaS platforms, enterprise systems, and multi-service applications.

---

## 5. Architecture Grilling Checklist

An architecture interview should cover the relevant areas below rather than applying every question mechanically.

### 5.1 Requirements and Constraints

- What problem does the application solve?
- Who are the users?
- What are the primary workflows?
- What requirements are mandatory?
- What are the non-functional requirements?
- What are the expected usage patterns?
- What constraints cannot be changed?
- Which requirements are assumptions rather than confirmed facts?

### 5.2 Architecture Style

- Why was this architecture selected?
- Why not a simpler architecture?
- Is a modular monolith sufficient?
- Are microservices genuinely necessary?
- What are the module or service boundaries?
- Which decisions are expensive to reverse?
- What trade-offs are being accepted?

### 5.3 Frontend Architecture

- Why was the frontend framework selected?
- What is the component architecture?
- How will state be managed?
- How are API interactions handled?
- How is authentication state maintained?
- How are permissions enforced in the UI?
- How will the application handle complex workflows?

### 5.4 Backend Architecture

- What responsibilities belong to the backend?
- How is business logic organized?
- What are the module boundaries?
- How are dependencies managed?
- How is input validated?
- How are errors handled?
- What processes must run asynchronously?

### 5.5 Database Architecture

- Why was the database selected?
- What are the primary entities?
- What data relationships exist?
- Who owns each piece of data?
- What consistency guarantees are required?
- Which queries will be performance-critical?
- How will migrations work?
- How will backups and recovery work?

### 5.6 API Architecture

- Why was REST, GraphQL, or another approach selected?
- What are the API contracts?
- How will API compatibility be maintained?
- How will validation and errors be represented?
- How are authentication and authorization enforced?
- How will API changes affect existing clients?
- Which operations require idempotency?

### 5.7 Authentication and Security

- How are users authenticated?
- How are sessions managed?
- Where is authorization enforced?
- How are roles and permissions modeled?
- How is sensitive information stored?
- How are secrets managed?
- What are the major threat scenarios?
- Which security assumptions require verification?

### 5.8 Scalability and Performance

- What scale is realistically expected?
- Which components are likely to become bottlenecks?
- What should be cached?
- When is horizontal scaling necessary?
- Which operations may become expensive?
- Are background jobs required?
- What performance measurements should be collected?

### 5.9 Deployment and Infrastructure

- Where will the application run?
- Why was the hosting platform selected?
- How are environments separated?
- How are application configurations managed?
- How are deployments performed?
- What is the rollback strategy?
- How are failures monitored?
- What are the operational costs?

### 5.10 Reliability and Failure Handling

- What happens when the database becomes unavailable?
- What happens when an external API fails?
- Can requests be safely retried?
- How are partial failures handled?
- What happens when background jobs fail?
- What recovery mechanisms are required?
- How can the system be diagnosed when something goes wrong?

### 5.11 Maintainability and Evolution

- How easy is it to add a new feature?
- How tightly coupled are the modules?
- What parts are most difficult to replace?
- How are architectural boundaries enforced?
- How is technical debt tracked?
- How will architectural decisions be documented?
- What architectural complexity can be postponed?

---

## 6. Reusable Architecture Grilling Prompt

Use the following prompt with an architecture grilling skill.

### Principal Architect Interview Prompt

**Role:**

Act as a principal software architect conducting a rigorous application architecture design interview.

**Objective:**

Challenge my proposed application architecture until all important decisions are understood, justified, or explicitly deferred.

**Interview Rules:**

1. Ask one high-impact question at a time.
2. Challenge assumptions instead of automatically agreeing.
3. Do not accept vague answers without clarification.
4. Ask follow-up questions when an answer introduces uncertainty.
5. Inspect existing project files when available.
6. Avoid asking questions that can already be answered from available documentation.
7. Question my proposed technologies and frameworks.
8. Present meaningful alternatives and explain their trade-offs.
9. Explain your recommended option but let me make the final decision.
10. Prioritize decisions that are difficult or costly to reverse.
11. Identify unnecessary complexity and overengineering.
12. Evaluate architecture against actual application requirements.
13. Investigate security, data ownership, scalability, reliability, maintainability, and cost where relevant.
14. Track confirmed decisions, assumptions, rejected alternatives, risks, and unresolved questions.
15. Never invent requirements or silently finalize important decisions.
16. Do not start implementation until I explicitly approve the architecture.

**Interview Process:**

**Phase 1 — Understand the Application**
- Understand the product and primary workflows.
- Identify technical and business constraints.
- Review existing architecture and documentation, if available.

**Phase 2 — Challenge High-Level Architecture**
- Architecture style.
- Component boundaries.
- Technology choices.
- Data ownership.
- External integrations.

**Phase 3 — Challenge Detailed Architecture**
- Frontend and backend organization.
- APIs.
- Database.
- Authentication and authorization.
- Background jobs.
- Deployment and infrastructure.

**Phase 4 — Challenge Non-Functional Requirements**
- Performance.
- Scalability.
- Security.
- Reliability.
- Observability.
- Maintainability.
- Operational cost.

**Phase 5 — Resolve Decisions**
- Present unresolved questions.
- Compare alternatives.
- Highlight architectural risks.
- Record accepted decisions.

**Phase 6 — Produce Architecture Documentation**

Generate:
- Architecture overview.
- Component responsibilities.
- Technology selection rationale.
- Major architectural decisions.
- Rejected alternatives.
- Risks and mitigations.
- Unresolved assumptions.
- Mermaid architecture diagrams.
- Recommended implementation sequence.

**Expected Behavior:**

Be critical, thorough, practical, and constructive.

Do not confuse complexity with good architecture.

Recommend simpler solutions when they satisfy the requirements.

Do not proceed to implementation until I explicitly approve the architecture.

Start by asking me to describe the application, or analyze the existing project context if it is already available.

---

## 7. Recommended End-to-End Workflow

### Step 1 — Requirements Gathering

Collect and validate the application requirements.

**Output:**
- `requirements.md`
- `constraints.md`

### Step 2 — Architecture Grilling

**Skill:** Grilling / Grill Me

Challenge assumptions, identify architectural choices, and resolve fundamental design questions.

**Output:**
- `architecture-questions.md`
- `architecture-decisions.md`

### Step 3 — Architecture Advisory

**Skill:** Architecture Advisor

Evaluate technical choices, design alternatives, complexity, and long-term maintainability.

**Output:**
- `architecture-tradeoffs.md`

### Step 4 — Architecture Design

Use a general software architecture or system design skill to turn the agreed decisions into a coherent architecture specification.

**Output:**
- `architecture.md`
- `database-design.md`
- `api-design.md`
- `security-design.md`

### Step 5 — Architecture Review

**Skill:** Architect Design Review

Evaluate the proposed design for inconsistencies, risks, security concerns, scalability issues, and maintainability problems.

**Output:**
- `architecture-review.md`
- `risks-and-mitigations.md`

### Step 6 — Architecture Approval

Review:
- Important decisions.
- Alternatives rejected.
- Remaining assumptions.
- Known risks.
- Proposed implementation sequence.

**Output:**
- Approved architecture specification.
- Architecture Decision Records (ADRs).
- Implementation-ready technical plan.

---

## 8. Final Recommendations

| Requirement | Best Skill |
|---|---|
| Overall architecture grilling | Grilling — Matt Pocock |
| One-question-at-a-time interrogation | Grill Me — vvanagas |
| Architecture grilling with documentation | Grill With Docs |
| Structured solution architecture interview | AI Architecture Toolkit — Grill Me |
| Multiple interdependent decisions | Grilling — Ghosteken |
| Technology selection and trade-offs | Architecture Advisor |
| Independent architecture validation | Architect Design Review |

### Preferred Combination

For most application development projects:

1. **Grilling — Matt Pocock** for rigorous decision questioning.
2. **Architecture Advisor** for questioning technology and architecture choices.
3. **Architect Design Review** for independent validation.

For existing repositories, add **Grill With Docs** to capture the decisions and maintain architectural context.

### Key Principle

**The purpose of architecture grilling is not to make the architecture more complicated. It is to identify assumptions, challenge weak decisions, explore alternatives, and arrive at the simplest architecture that satisfies the application's actual requirements.**

An effective architecture grilling process should prevent the AI from jumping directly into implementation before critical design questions have been addressed.

---

## 9. References

- [Matt Pocock — Skills](https://github.com/mattpocock/skills)
- [Matt Pocock — Grilling](https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling)
- [Matt Pocock — Grill With Docs](https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs)
- [vvanagas — Grill Me](https://github.com/vvanagas/agent-skills/blob/main/skills/grill-me/SKILL.md)
- [Future-CX — AI Architecture Toolkit](https://github.com/Future-CX/AI-Architecture-Toolkit)
- [Ghosteken — Grilling](https://github.com/Ghosteken/agent-harness/blob/main/skills/grilling/SKILL.md)
- [Agent Compass — Architecture Advisor](https://github.com/me-cedric/agent-compass/blob/main/skills/architecture-advisor/SKILL.md)
- [Architect Skills — Design Review](https://github.com/sirius-zuo/architect-skills/blob/main/architect-design-review/SKILL.md)
- [Skills CLI](https://skills.sh/docs/cli)

*Note: Skill repositories, paths, and CLI availability may change. Review the linked source and installation instructions before installing or executing third-party skills.*