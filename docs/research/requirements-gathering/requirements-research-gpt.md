# Best AI Agent Skills for Requirement Gathering

A curated list of AI-agent skills for gathering software requirements, clarifying product ideas, identifying missing information, and generating implementation-ready specifications.

## 1. Recommended Skills

| # | Skill | Best For | Recommendation |
|---|---|---|---|
| 1 | [Superpowers – Brainstorming](https://github.com/obra/superpowers/tree/main/skills/brainstorming) | Exploring vague ideas, asking clarifying questions, and evaluating solutions | Best Overall |
| 2 | [Product Discovery](https://github.com/magnus919/agent-skills/tree/main/product-discovery) | Stakeholder interviews, missing requirements, and contradictions | Best for Discovery |
| 3 | [Product Grilling](https://github.com/Dengk3Li/product-manager-skill/tree/main/skills/product-grilling) | Challenging assumptions and identifying important product decisions | Best for Questioning |
| 4 | [Product Requirements](https://github.com/stellarlinkco/myclaude/tree/master/skills/product-requirements) | Generating structured PRDs and validating completeness | Best for PRD Generation |
| 5 | [Requirements Gathering](https://github.com/martincjarvis/development-skills/tree/main/skills/requirements-gathering) | Converting discussions into actionable development tickets | Best for Task Creation |
| 6 | [Product Requirements & Traceability](https://github.com/Dengk3Li/product-manager-skill/tree/main/skills/product-requirements) | Tracking requirements, implementation, testing, and acceptance criteria | Best for Complex Projects |

---

## 2. Detailed Skill Descriptions

### 2.1 Superpowers – Brainstorming

**Repository:** https://github.com/obra/superpowers

**Skill:** https://github.com/obra/superpowers/tree/main/skills/brainstorming

**Purpose:** Transform an initial product idea into an approved design through collaborative questioning and solution exploration.

**Key Capabilities:**
- Understand the initial idea and its objectives.
- Ask clarifying questions to uncover missing details.
- Explore alternative technical and product approaches.
- Discuss trade-offs before making decisions.
- Present proposed designs for review and approval.
- Establish agreement before proceeding to implementation.

**Best Used When:** Starting a new software project with an idea that needs refinement before technical planning.

### 2.2 Product Discovery

**Repository:** https://github.com/magnus919/agent-skills

**Skill:** https://github.com/magnus919/agent-skills/tree/main/product-discovery

**Purpose:** Perform structured product discovery to identify complete functional and business requirements.

**Key Capabilities:**
- Identify users, stakeholders, and their needs.
- Understand business problems and expected outcomes.
- Discover missing or implicit requirements.
- Identify inconsistencies and conflicting expectations.
- Explore user journeys and operational workflows.
- Define product boundaries, assumptions, and constraints.
- Convert discovery findings into structured requirements.

**Best Used When:** Gathering complete requirements from a rough product description or stakeholder discussions.

### 2.3 Product Grilling

**Repository:** https://github.com/Dengk3Li/product-manager-skill

**Skill:** https://github.com/Dengk3Li/product-manager-skill/tree/main/skills/product-grilling

**Purpose:** Critically examine product ideas through targeted questioning.

**Key Capabilities:**
- Challenge unclear or unsupported assumptions.
- Identify gaps in product reasoning.
- Ask difficult but relevant questions.
- Separate essential decisions from optional details.
- Expose potential edge cases and conflicting requirements.
- Prevent premature implementation decisions.
- Reduce ambiguity before finalizing specifications.

**Best Used When:** A product idea appears complete but requires deeper validation and more rigorous questioning.

### 2.4 Product Requirements

**Repository:** https://github.com/stellarlinkco/myclaude

**Skill:** https://github.com/stellarlinkco/myclaude/tree/master/skills/product-requirements

**Purpose:** Convert product discovery findings into a structured Product Requirements Document (PRD).

**Key Capabilities:**
- Organize functional and non-functional requirements.
- Document product goals and expected behavior.
- Structure features and acceptance criteria.
- Identify unclear or incomplete specifications.
- Establish requirements for technical planning.
- Improve documentation consistency.

**Best Used When:** Creating a formal PRD after completing the initial requirement-gathering process.

### 2.5 Requirements Gathering

**Repository:** https://github.com/martincjarvis/development-skills

**Skill:** https://github.com/martincjarvis/development-skills/tree/main/skills/requirements-gathering

**Purpose:** Translate requirements and discussions into actionable engineering work.

**Key Capabilities:**
- Structure requirements for development teams.
- Extract actionable tasks from discussions.
- Define implementation-oriented acceptance criteria.
- Identify dependencies and outstanding questions.
- Prepare requirements for issue-tracking workflows.

**Best Used When:** Moving from approved product specifications into development planning and task management.

### 2.6 Product Requirements & Traceability

**Repository:** https://github.com/Dengk3Li/product-manager-skill

**Skill:** https://github.com/Dengk3Li/product-manager-skill/tree/main/skills/product-requirements

**Purpose:** Maintain requirements and their relationship to implementation, validation, and acceptance.

**Key Capabilities:**
- Organize and structure product requirements.
- Establish requirement traceability.
- Connect requirements with implementation activities.
- Support acceptance and verification planning.
- Track requirement completeness and consistency.

**Best Used When:** Managing complex applications with numerous features, dependencies, or acceptance requirements.

---

## 3. Additional Tool: GitHub Spec Kit

**Repository:** https://github.com/github/spec-kit

**Purpose:** Specification-driven development, from product requirements to implementation planning.

**Relevant Workflow:**
- Define the feature specification.
- Identify ambiguous requirements.
- Use `/speckit.clarify` to resolve uncertainties.
- Establish a technical implementation plan.
- Break the specification into actionable tasks.
- Proceed with implementation based on the approved specification.

**Best Used When:** Moving from requirement gathering into a structured software development process.

**Note:** Spec Kit is a broader specification-driven development toolkit rather than a standalone requirement-gathering skill.

---

## 4. Recommended Combined Workflow

The following workflow combines complementary skills. It is a suggested process, not an automatically integrated feature of these repositories.

### Phase 1: Product Discovery

**Skill:** Product Discovery

**Objectives:**
- Understand the initial product idea.
- Identify intended users and stakeholders.
- Define the problem being solved.
- Gather functional and non-functional requirements.
- Identify missing information and constraints.

**Output:** Initial Requirements Document

### Phase 2: Requirements Validation

**Skill:** Product Grilling

**Objectives:**
- Challenge assumptions.
- Identify inconsistencies.
- Explore important edge cases.
- Resolve conflicting expectations.
- Identify decisions requiring user approval.

**Output:** Validated Requirements Document

### Phase 3: Solution Exploration

**Skill:** Superpowers – Brainstorming

**Objectives:**
- Explore possible solutions.
- Compare alternative approaches.
- Evaluate technical and product trade-offs.
- Define the expected system behavior.
- Obtain design approval.

**Output:** Approved Product Design

### Phase 4: Formal Specification

**Skill:** Product Requirements

**Objectives:**
- Generate a structured PRD.
- Define features, user stories, and acceptance criteria.
- Document functional and non-functional requirements.
- Identify dependencies and limitations.
- Ensure implementation readiness.

**Output:** Product Requirements Document (PRD)

### Phase 5: Development Preparation

**Skills:** Requirements Gathering + GitHub Spec Kit

**Objectives:**
- Translate approved specifications into tasks.
- Identify dependencies and milestones.
- Define development acceptance criteria.
- Prepare implementation planning.
- Ensure requirements can be traced through delivery.

**Output:** Implementation-Ready Specifications and Development Tasks

---

## 5. Installation Commands

For environments supporting the Skills CLI:

```bash
# Superpowers – Brainstorming
npx skills add obra/superpowers --skill brainstorming

# Product Discovery
npx skills add magnus919/agent-skills --skill product-discovery

# Product Grilling
npx skills add Dengk3Li/product-manager-skill --skill product-grilling

# Product Requirements & Traceability
npx skills add Dengk3Li/product-manager-skill --skill product-requirements
```

Installation and compatibility should be checked against each repository's current instructions.

---

## 6. Recommended Setup

### Minimal Setup

Use two skills:

1. **Product Discovery** — Gather requirements, uncover missing details, and establish product scope.
2. **Superpowers – Brainstorming** — Explore solutions and obtain approval before implementation.

### Comprehensive Setup

Use four skills:

1. **Product Discovery** — Requirements gathering.
2. **Product Grilling** — Requirements validation and assumption checking.
3. **Superpowers – Brainstorming** — Design and solution exploration.
4. **Product Requirements** — Formal PRD generation.

Optionally add **GitHub Spec Kit** to transition into specification-driven implementation.

## 7. Recommended Agent Behavior

Regardless of which skills are selected, the requirement-gathering agent should follow these principles:

- Never assume important product requirements without confirmation.
- Ask focused questions rather than presenting an overwhelming questionnaire.
- Identify functional requirements, non-functional requirements, edge cases, and constraints.
- Clearly distinguish confirmed requirements from assumptions and suggestions.
- Challenge requirements when potential contradictions or problems are identified.
- Avoid repeatedly asking questions that have already been answered.
- Maintain a structured record of decisions made during discovery.
- Organize requirements by feature, priority, and dependency.
- Define measurable acceptance criteria wherever possible.
- Obtain approval of the requirements and proposed design before implementation.
- Do not begin coding until explicitly instructed.

**Final Recommendation:** Begin with **Product Discovery + Superpowers – Brainstorming**. Add Product Grilling for deeper validation and Product Requirements for formal documentation.
