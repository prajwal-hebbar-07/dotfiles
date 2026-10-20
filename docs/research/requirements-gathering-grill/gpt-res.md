# Best AI Agent Skills for Requirements Grilling

A curated list of AI-agent skills designed to aggressively question software requirements, challenge assumptions, identify missing information, explore edge cases, and ensure specifications are complete before implementation.

Unlike traditional requirement-gathering skills, these focus on **deep questioning, ambiguity elimination, and validating product decisions**.

## 1. Recommended Skills

| Rank | Skill | Best For | Questioning Style |
|---|---|---|---|
| 1 | [Grilling – Matt Pocock](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md) | Deep requirement interviews and decision-tree questioning | Relentless, structured |
| 2 | [Grill Me – max4c](https://github.com/max4c/skills/blob/main/skills/grill-me/SKILL.md) | Making requirements implementation-ready | Strict, ambiguity-focused |
| 3 | [Product Grilling](https://github.com/Dengk3Li/product-manager-skill/blob/main/skills/product-grilling/SKILL.md) | Challenging business assumptions and product decisions | Critical, product-focused |
| 4 | [Grill With Docs – Matt Pocock](https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md) | Questioning requirements within existing repositories | Documentation-driven |
| 5 | [Requirements Interview](https://github.com/SuperCorks/agent-skills/blob/main/requirements-interview/SKILL.md) | Structured requirement clarification | Socratic, evidence-driven |
| 6 | [Superpowers – Brainstorming](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md) | Early product discovery and design exploration | Collaborative, iterative |

**Note:** Rankings represent a qualitative assessment of their workflows, not benchmarked performance.

---

## 2. Detailed Skill Descriptions

### 2.1 Grilling – Matt Pocock

**Repository:** https://github.com/mattpocock/skills

**Skill:** https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md

**Purpose:** Conduct deep, structured interviews that progressively uncover missing requirements and resolve product decisions.

**Key Capabilities:**
- Ask questions in logical, dependency-aware rounds.
- Identify unclear or incomplete requirements.
- Explore different decision paths.
- Provide recommendations and possible answers.
- Ask follow-up questions based on previous responses.
- Challenge assumptions before accepting decisions.
- Continue questioning until important ambiguities are resolved.

**Best Used When:** Starting a new application with an incomplete idea that requires extensive questioning before requirements can be finalized.

**Recommendation:** Best overall skill for interactive requirement grilling.

### 2.2 Grill Me – max4c

**Repository:** https://github.com/max4c/skills

**Skill:** https://github.com/max4c/skills/blob/main/skills/grill-me/SKILL.md

**Purpose:** Eliminate ambiguity and ensure requirements are sufficiently clear for implementation.

**Key Capabilities:**
- Ask focused questions one at a time.
- Examine requirements across five dimensions:
  - Goals
  - Acceptance criteria
  - Boundaries
  - Alternatives
  - Assumptions
- Identify vague statements and incomplete specifications.
- Challenge missing decisions and implied behavior.
- Explore alternative interpretations.
- Continue until requirements are sufficiently precise.

**Best Used When:** Reviewing requirements before handing them to an AI coding agent.

**Recommendation:** Best for strict, implementation-readiness grilling.

### 2.3 Product Grilling

**Repository:** https://github.com/Dengk3Li/product-manager-skill

**Skill:** https://github.com/Dengk3Li/product-manager-skill/blob/main/skills/product-grilling/SKILL.md

**Purpose:** Challenge product decisions from a product-management and business-value perspective.

**Key Capabilities:**
- Question whether proposed features are necessary.
- Identify the underlying problem each feature solves.
- Challenge unsupported product assumptions.
- Clarify target users and their needs.
- Distinguish essential features from optional enhancements.
- Explore product scope and MVP boundaries.
- Identify conflicting requirements and priorities.

**Best Used When:** Evaluating whether the requested features and product direction make sense before designing the solution.

**Recommendation:** Best for business logic, feature prioritization, and product decisions.

### 2.4 Grill With Docs – Matt Pocock

**Repository:** https://github.com/mattpocock/skills

**Skill:** https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md

**Purpose:** Combine requirement questioning with existing project documentation and domain knowledge.

**Key Capabilities:**
- Examine existing documentation.
- Ask questions based on project context.
- Identify gaps in documented requirements.
- Challenge assumptions about existing system behavior.
- Clarify domain concepts.
- Improve documentation through interactive questioning.

**Dependencies:** The `domain-modeling` skill is also required.

**Best Used When:** Extending an existing application or validating requirements against an established architecture.

**Recommendation:** Best for existing repositories and documentation-heavy projects.

### 2.5 Requirements Interview

**Repository:** https://github.com/SuperCorks/agent-skills

**Skill:** https://github.com/SuperCorks/agent-skills/blob/main/requirements-interview/SKILL.md

**Purpose:** Conduct focused interviews to clarify requirements and discover missing information.

**Key Capabilities:**
- Ask targeted clarification questions.
- Identify incomplete requirements.
- Explore intended system behavior.
- Establish clear product expectations.
- Reduce ambiguity through follow-up questioning.
- Organize information gathered during interviews.

**Best Used When:** Conducting structured requirement interviews without necessarily using aggressive questioning.

**Recommendation:** Best for controlled, conversational requirements discovery.

### 2.6 Superpowers – Brainstorming

**Repository:** https://github.com/obra/superpowers

**Skill:** https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md

**Purpose:** Transform incomplete product ideas into approved designs through collaborative questioning.

**Key Capabilities:**
- Ask clarifying questions.
- Explore the problem being solved.
- Evaluate alternative solutions.
- Discuss design and technical trade-offs.
- Present proposed approaches.
- Obtain approval before implementation.

**Best Used When:** Beginning with a rough application idea and collaboratively designing a solution.

**Recommendation:** Best complementary skill for exploration and design, rather than aggressive grilling alone.

---

## 3. Installation Commands

The following commands use the Skills CLI in compatible agent environments.

```bash
# 1. Matt Pocock – Grilling
npx skills add mattpocock/skills --skill grilling

# 2. max4c – Grill Me
npx skills add max4c/skills --skill grill-me

# 3. Product Grilling
npx skills add Dengk3Li/product-manager-skill --skill product-grilling

# 4. Matt Pocock – Grill With Docs
# Install its dependency first
npx skills add mattpocock/skills --skill domain-modeling
npx skills add mattpocock/skills --skill grill-with-docs

# 5. Requirements Interview
npx skills add SuperCorks/agent-skills --skill requirements-interview

# 6. Superpowers – Brainstorming
npx skills add obra/superpowers --skill brainstorming
```

**Note:** Verify the current skill paths and installation instructions in each repository before installing.

---

## 4. Recommended Grilling Workflow

### Phase 1: Initial Requirements Grilling

**Skill:** Grilling – Matt Pocock

**Objectives:**
- Understand the initial product idea.
- Identify users, problems, and goals.
- Ask detailed follow-up questions.
- Explore different scenarios and workflows.
- Challenge incomplete assumptions.
- Resolve major product decisions.

**Output:** Detailed Initial Requirements

### Phase 2: Product Validation

**Skill:** Product Grilling

**Objectives:**
- Challenge the business value of features.
- Identify unnecessary complexity.
- Define MVP boundaries.
- Validate user needs.
- Clarify product priorities.
- Identify missing use cases.

**Output:** Validated Product Requirements

### Phase 3: Ambiguity Elimination

**Skill:** Grill Me – max4c

**Objectives:**
- Identify ambiguous specifications.
- Verify goals and expected outcomes.
- Define explicit acceptance criteria.
- Clarify edge cases and system boundaries.
- Resolve conflicting interpretations.
- Confirm implementation readiness.

**Output:** Implementation-Ready Requirements

### Phase 4: Design Exploration

**Skill:** Superpowers – Brainstorming

**Objectives:**
- Explore technical approaches.
- Compare solution alternatives.
- Discuss trade-offs.
- Establish system behavior.
- Finalize design decisions.
- Obtain approval before implementation.

**Output:** Approved Product Design

---

## 5. Recommended Agent Grilling Instructions

The following prompt can be used alongside the installed grilling skill.

### Prompt

> Use the installed requirements-grilling skill to interview me thoroughly about my software application idea.
>
> Act as a demanding senior product manager, business analyst, and software architect.
>
> Your objective is to eliminate ambiguity and identify every material requirement needed to design and implement the application correctly.
>
> **Questioning Rules:**
>
> 1. Understand my initial idea before exploring solutions.
> 2. Ask focused questions in logical, dependency-aware rounds.
> 3. Challenge vague statements, assumptions, and contradictory requirements.
> 4. Provide recommended answers or options where appropriate, explaining their trade-offs.
> 5. Ask follow-up questions based on my previous responses.
> 6. Never silently invent important product decisions.
> 7. Avoid asking questions that have already been answered.
> 8. Research information that can be independently established instead of asking me unnecessarily.
> 9. Keep track of confirmed decisions, assumptions, and unresolved questions.
> 10. Continue until all material ambiguities are resolved.
>
> **Areas to Investigate:**
>
> - Product purpose and expected outcomes
> - Target users and personas
> - Business requirements
> - Functional requirements
> - Non-functional requirements
> - User journeys and workflows
> - Roles, permissions, and authorization
> - Data requirements and data models
> - Validation rules
> - Error handling and recovery
> - Edge cases and exceptional scenarios
> - Security and privacy
> - Integrations and external dependencies
> - Performance and scalability
> - Deployment and operational constraints
> - MVP scope and future enhancements
> - Acceptance criteria and testing expectations
>
> **Expected Output:**
>
> Produce a comprehensive, structured requirements document containing:
>
> - Product overview
> - Goals and success criteria
> - User personas
> - Functional requirements
> - Non-functional requirements
> - Feature descriptions
> - User stories and workflows
> - Business rules
> - Edge cases
> - Acceptance criteria
> - Constraints and dependencies
> - Assumptions
> - Explicit out-of-scope items
> - Unresolved questions, if any
>
> Do not begin implementation or write code until I explicitly approve the requirements.

---

## 6. Final Recommendations

### Best Single Skill

**Grilling – Matt Pocock**

https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md

Recommended for interactive questioning that explores a product idea in depth.

### Best for Strict Requirements Validation

**Grill Me – max4c**

https://github.com/max4c/skills/blob/main/skills/grill-me/SKILL.md

Recommended when requirements must be unambiguous before AI-assisted development begins.

### Best for Product Decisions

**Product Grilling**

https://github.com/Dengk3Li/product-manager-skill/blob/main/skills/product-grilling/SKILL.md

Recommended for challenging features, priorities, business assumptions, and product scope.

### Best Combination

1. **Grilling – Matt Pocock:** Initial requirements discovery.
2. **Product Grilling:** Business and product validation.
3. **Grill Me – max4c:** Final ambiguity elimination.
4. **Superpowers – Brainstorming:** Technical solution exploration and design approval.

**Overall Recommendation:** Start with **Matt Pocock's Grilling** and finish with **max4c's Grill Me**. This provides deep requirement discovery followed by rigorous implementation-readiness checks without unnecessarily running multiple overlapping skills at once.
