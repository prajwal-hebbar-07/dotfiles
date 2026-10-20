# AI Agent Skills for Application Architecture & System Design

A curated collection of AI Agent Skills for designing, reviewing, documenting, and maintaining application architectures.

These skills can be used with compatible AI coding agents such as Claude Code, Cursor, OpenCode, and Oh My Pi.

---

## 1. Primary Architecture Skills

### 1.1 Software Architecture — Best Overall

- **Repository:** [magnus919/agent-skills](https://github.com/magnus919/agent-skills)
- **Skill:** [software-architecture/SKILL.md](https://github.com/magnus919/agent-skills/blob/main/software-architecture/SKILL.md)
- **Purpose:** End-to-end software architecture and high-level technical design.

**Capabilities:**
- Translate business requirements into application architecture.
- Design system boundaries and components.
- Evaluate monolithic, modular monolithic, and microservices architectures.
- Identify architectural trade-offs.
- Design for scalability, maintainability, and reliability.
- Plan application evolution and extensibility.
- Establish architectural principles and constraints.

**Best for:** Designing the overall architecture of new applications and making major architectural decisions.

### 1.2 System Design — Best for New Applications

- **Repository:** [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)
- **Skill:** [system-design/SKILL.md](https://github.com/anthropics/knowledge-work-plugins/blob/main/engineering/skills/system-design/SKILL.md)
- **Purpose:** Systematic application design from requirements to technical specifications.

**Capabilities:**
- Functional and non-functional requirements.
- High-level system architecture.
- Component and service decomposition.
- API contract design.
- Database and data modeling.
- Caching and message queues.
- Reliability, availability, and fault tolerance.
- Scalability and performance planning.
- Infrastructure and cost considerations.

**Best for:** Turning a product idea or requirements document into a complete system design before implementation.

### 1.3 Software Architect — Best for Architecture Governance

- **Repository:** [eligapris/software-architect](https://github.com/eligapris/software-architect)
- **Link:** https://github.com/eligapris/software-architect
- **Purpose:** Architecture design, validation, and consistency across the application lifecycle.

**Capabilities:**
- Architecture pattern selection.
- Architectural Decision Records (ADRs).
- Dependency and module boundary analysis.
- Architecture anti-pattern identification.
- Architecture validation.
- Technical documentation.
- Maintaining architectural consistency as applications evolve.

**Best for:** Existing applications, long-running projects, and enforcing consistent architectural practices.

---

## 2. Specialized Architecture Skills

### 2.1 Architecture Patterns

- **Repository:** [wshobson/agents](https://github.com/wshobson/agents)
- **Skill:** [architecture-patterns/SKILL.md](https://github.com/wshobson/agents/blob/main/plugins/backend-development/skills/architecture-patterns/SKILL.md)

**Capabilities:**
- Clean Architecture.
- Hexagonal Architecture.
- Domain-Driven Design (DDD).
- Layered Architecture.
- Dependency inversion.
- Separation of concerns.
- Application and domain boundaries.

**Best for:** Choosing appropriate software architecture patterns and designing maintainable backend systems.

### 2.2 Software Architecture Analysis

- **Repository:** [magnus919/agent-skills](https://github.com/magnus919/agent-skills)
- **Skill:** [software-architecture-analysis/SKILL.md](https://github.com/magnus919/agent-skills/blob/main/software-architecture-analysis/SKILL.md)

**Capabilities:**
- Analyze existing application architectures.
- Reverse-engineer architecture from source code.
- Identify module dependencies.
- Understand application data flows.
- Discover architectural issues.
- Evaluate maintainability and technical debt.
- Recommend architecture improvements.

**Best for:** Understanding an existing codebase before implementing changes or redesigning its architecture.

### 2.3 Architect Design Review

- **Repository:** [sirius-zuo/architect-skills](https://github.com/sirius-zuo/architect-skills)
- **Skill:** [architect-design-review/SKILL.md](https://github.com/sirius-zuo/architect-skills/blob/main/architect-design-review/SKILL.md)

**Capabilities:**
- Review proposed architectures.
- Identify architectural risks.
- Validate system design specifications.
- Detect design inconsistencies.
- Generate Mermaid architecture diagrams.
- Produce architecture review reports.
- Evaluate design decisions and trade-offs.

**Best for:** Reviewing an architecture before implementation begins.

### 2.4 C4 Diagramming

- **Repository:** [magnus919/agent-skills](https://github.com/magnus919/agent-skills)
- **Skill:** [c4-diagramming/SKILL.md](https://github.com/magnus919/agent-skills/blob/main/c4-diagramming/SKILL.md)

**Capabilities:**
- System Context diagrams.
- Container diagrams.
- Component diagrams.
- Code-level architecture diagrams.
- Documenting system interactions.
- Visualizing dependencies and boundaries.

**Best for:** Producing standardized, understandable application architecture diagrams.

### 2.5 ADR Authoring

- **Repository:** [magnus919/agent-skills](https://github.com/magnus919/agent-skills)
- **Skill:** [adr-authoring/SKILL.md](https://github.com/magnus919/agent-skills/blob/main/adr-authoring/SKILL.md)

**Capabilities:**
- Create Architecture Decision Records.
- Document architectural choices.
- Capture alternatives considered.
- Explain architectural trade-offs.
- Document constraints and consequences.
- Maintain an architecture decision history.

**Best for:** Recording why particular technologies and architectural approaches were selected.

### 2.6 API Design and Evolution

- **Repository:** [magnus919/agent-skills](https://github.com/magnus919/agent-skills)
- **Skill:** [api-design-and-evolution/SKILL.md](https://github.com/magnus919/agent-skills/blob/main/api-design-and-evolution/SKILL.md)

**Capabilities:**
- API design principles.
- API contracts and interface consistency.
- API versioning.
- Backward compatibility.
- API evolution strategies.
- Endpoint and resource modeling.
- Error handling conventions.

**Best for:** Designing APIs between frontend applications, backend services, and external integrations.

### 2.7 PostgreSQL Table Design

- **Repository:** [wshobson/agents](https://github.com/wshobson/agents)
- **Skill:** [postgresql-table-design/SKILL.md](https://github.com/wshobson/agents/blob/main/plugins/database-design/skills/postgresql-table-design/SKILL.md)

**Capabilities:**
- Relational database schema design.
- Tables and relationships.
- Primary and foreign keys.
- Database constraints.
- Indexing strategies.
- Query performance considerations.
- Data integrity and migrations.

**Best for:** Designing PostgreSQL schemas for production applications.

### 2.8 Secure Software Engineering

- **Repository:** [magnus919/agent-skills](https://github.com/magnus919/agent-skills)
- **Skill:** [secure-software-engineering/SKILL.md](https://github.com/magnus919/agent-skills/blob/main/secure-software-engineering/SKILL.md)

**Capabilities:**
- Secure application architecture.
- Authentication and authorization.
- Security boundaries.
- Threat modeling.
- Secure-by-design principles.
- Security risk identification.
- Defensive programming practices.

**Best for:** Incorporating security into application architecture from the beginning.

### 2.9 Multi-Tenant SaaS Architecture

- **Repository:** [magnus919/agent-skills](https://github.com/magnus919/agent-skills)
- **Skill:** [multi-tenant-saas-architecture/SKILL.md](https://github.com/magnus919/agent-skills/blob/main/multi-tenant-saas-architecture/SKILL.md)

**Capabilities:**
- Multi-tenant application architecture.
- Tenant data isolation.
- Shared infrastructure.
- Tenant-aware authentication and authorization.
- Tenant lifecycle management.
- SaaS scalability considerations.

**Best for:** Applications serving multiple organizations or customers with shared infrastructure.

### 2.10 Microservices Patterns

- **Repository:** [wshobson/agents](https://github.com/wshobson/agents)
- **Skill:** [microservices-patterns/SKILL.md](https://github.com/wshobson/agents/blob/main/plugins/backend-development/skills/microservices-patterns/SKILL.md)

**Capabilities:**
- Microservices decomposition.
- Service communication.
- Event-driven architecture.
- Distributed transactions.
- Messaging patterns.
- Retries and fault tolerance.
- Service resilience patterns.

**Best for:** Distributed applications that require independent services, deployments, and scaling.

---

## 3. Recommended Skill Combinations

### Stack A — General Full-Stack Application Architecture

**Recommended skills:**
1. Software Architecture
2. Architecture Patterns
3. API Design and Evolution
4. PostgreSQL Table Design
5. Secure Software Engineering
6. C4 Diagramming
7. ADR Authoring

**Use when:**
- Building a React or Next.js application.
- Building a Node.js backend.
- Designing a database-driven application.
- Creating authentication and authorization flows.
- Planning deployment and infrastructure.
- Building an application expected to evolve over time.

### Stack B — SaaS Application Architecture

**Recommended skills:**
1. Software Architecture
2. System Design
3. Architecture Patterns
4. Multi-Tenant SaaS Architecture
5. Secure Software Engineering
6. API Design and Evolution
7. PostgreSQL Table Design
8. ADR Authoring

**Use when:**
- Building multi-organization applications.
- Implementing RBAC and permissions.
- Designing tenant isolation.
- Supporting subscriptions or organization-level settings.
- Building shared backend services.

### Stack C — Existing Application Analysis and Refactoring

**Recommended skills:**
1. Software Architecture Analysis
2. Software Architect
3. Architect Design Review
4. Architecture Patterns
5. C4 Diagramming
6. ADR Authoring

**Use when:**
- Analyzing unfamiliar repositories.
- Planning major refactoring.
- Breaking down tightly coupled modules.
- Improving maintainability.
- Documenting an existing application.
- Modernizing a legacy architecture.

### Stack D — Distributed Systems and Microservices

**Recommended skills:**
1. System Design
2. Software Architecture
3. Microservices Patterns
4. API Design and Evolution
5. Secure Software Engineering
6. C4 Diagramming
7. Architect Design Review

**Use when:**
- Designing independently deployed services.
- Building event-driven applications.
- Handling background processing.
- Planning distributed communication.
- Designing high-availability systems.

---

## 4. Recommended Architecture Design Workflow

### Phase 1 — Requirements and Constraints

**Primary skill:** System Design

**Activities:**
- Understand product requirements.
- Identify actors and use cases.
- Define functional requirements.
- Define non-functional requirements.
- Identify technical and business constraints.
- Establish scalability and performance expectations.
- Identify unknowns and assumptions.

**Deliverables:**
- `requirements.md`
- `constraints.md`

### Phase 2 — High-Level System Architecture

**Primary skill:** Software Architecture

**Activities:**
- Identify major application components.
- Determine frontend and backend boundaries.
- Select architecture patterns.
- Establish module and service boundaries.
- Define major dependencies.
- Plan communication and data flows.
- Evaluate technology choices and trade-offs.

**Deliverables:**
- `architecture.md`
- `system-overview.md`

### Phase 3 — Detailed Architecture

**Primary skills:**
- Architecture Patterns
- API Design and Evolution
- PostgreSQL Table Design
- Secure Software Engineering

**Activities:**
- Design application modules.
- Define API contracts.
- Design database schemas.
- Define authentication and authorization.
- Establish data ownership.
- Plan background processing.
- Design validation and error handling.
- Establish security and observability requirements.

**Deliverables:**
- `backend-architecture.md`
- `frontend-architecture.md`
- `database-design.md`
- `api-contracts.md`
- `security-architecture.md`

### Phase 4 — Architecture Review

**Primary skill:** Architect Design Review

**Activities:**
- Validate architectural decisions.
- Identify scalability bottlenecks.
- Review coupling and dependencies.
- Identify security risks.
- Review maintainability.
- Evaluate failure scenarios.
- Identify potential overengineering.
- Recommend architectural improvements.

**Deliverables:**
- `architecture-review.md`
- `risks-and-mitigations.md`

### Phase 5 — Architecture Documentation

**Primary skills:**
- C4 Diagramming
- ADR Authoring

**Activities:**
- Generate system context diagrams.
- Generate container diagrams.
- Generate component diagrams.
- Create sequence diagrams for critical workflows.
- Record architectural decisions.
- Document rejected alternatives.
- Capture architectural constraints.

**Deliverables:**
- `diagrams.md`
- `adr/001-initial-architecture.md`
- `adr/002-database-selection.md`
- `adr/003-authentication-strategy.md`

### Phase 6 — Implementation Planning

**Primary skills:**
- Software Architecture
- Architecture Patterns

**Activities:**
- Break the architecture into implementation phases.
- Define module dependencies.
- Establish development sequence.
- Identify foundational infrastructure.
- Plan testing strategies.
- Define acceptance criteria.
- Create implementation milestones.

**Deliverables:**
- `implementation-plan.md`
- `development-guidelines.md`

---

## 5. Expected Architecture Deliverables

A complete application architecture specification should ideally contain:

### System Design
- System overview.
- Product requirements and constraints.
- Architecture style and rationale.
- Component and service boundaries.
- Technology stack decisions.

### Application Architecture
- Frontend architecture.
- Backend architecture.
- Module responsibilities.
- Dependency boundaries.
- Shared libraries and packages.
- State management strategy.

### Data Architecture
- Database schema.
- Entity relationships.
- Data ownership.
- Migration strategy.
- Caching strategy.
- Data consistency requirements.

### API Architecture
- API contracts.
- Endpoint definitions.
- Request and response schemas.
- Error-handling conventions.
- Authentication and authorization rules.
- Versioning strategy.

### Infrastructure and Operations
- Deployment architecture.
- Environment configuration.
- CI/CD strategy.
- Logging and observability.
- Performance considerations.
- Scalability and reliability.
- Backup and recovery considerations.

### Architecture Documentation
- C4 system context diagram.
- C4 container diagram.
- C4 component diagram.
- Critical sequence diagrams.
- Architecture Decision Records.
- Risk analysis.
- Implementation plan.

---

## 6. Installation

Skills using the Agent Skills format can be installed through the Skills CLI when the target agent is supported.

**Skills CLI documentation:** https://skills.sh/docs/cli

### Core Architecture Skills

```bash
npx skills add magnus919/agent-skills \
  --skill software-architecture \
  --skill c4-diagramming \
  --skill adr-authoring \
  --skill secure-software-engineering
```

### Backend and Database Architecture

```bash
npx skills add wshobson/agents \
  --skill architecture-patterns \
  --skill api-design-principles \
  --skill postgresql-table-design
```

### Architecture Review

```bash
npx skills add sirius-zuo/architect-skills \
  --skill architect-design-review
```

### General Syntax

```bash
npx skills add <github-owner/repository> --skill <skill-name>
```

Note: Skill availability, repository paths, CLI compatibility, and supported agents should be checked before installation. A skill may require agent-specific setup.

---

## 7. Final Recommendations

| Requirement | Recommended Skill |
|---|---|
| Overall application architecture | Software Architecture |
| Design from requirements | System Design |
| Architecture patterns | Architecture Patterns |
| Analyze existing repositories | Software Architecture Analysis |
| Architecture quality review | Architect Design Review |
| Architecture diagrams | C4 Diagramming |
| Architecture decisions | ADR Authoring |
| API architecture | API Design and Evolution |
| PostgreSQL design | PostgreSQL Table Design |
| Security architecture | Secure Software Engineering |
| Multi-tenant applications | Multi-Tenant SaaS Architecture |
| Distributed services | Microservices Patterns |
| Ongoing architecture governance | Software Architect |

### Preferred Core Stack

For most full-stack applications:

1. **Software Architecture** — Main architecture design.
2. **Architecture Patterns** — Internal application structure.
3. **C4 Diagramming** — Architecture visualization.
4. **ADR Authoring** — Architecture decision tracking.
5. **Secure Software Engineering** — Security integration.

Add database, API, system design, and architecture review skills when the project requires deeper specialization.

**Guiding principle:** Architecture should be designed and reviewed before implementation begins. AI agents should evaluate requirements, document decisions, justify trade-offs, identify risks, and produce an implementation-ready architecture instead of immediately generating application code.
