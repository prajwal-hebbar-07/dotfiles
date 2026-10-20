
# UI/UX Design Skills for Paper.design

## Objective

AI-agent skills for designing modern web and mobile application interfaces using [Paper.design](https://paper.design/).

The goal is to transform product requirements into structured UI/UX designs without immediately generating frontend code.

### Key Capabilities

- Convert PRDs and requirements into detailed UI/UX design briefs.
- Challenge and refine UX requirements before designing.
- Define user journeys, navigation, and information architecture.
- Generate screen inventories, wireframes, and layouts.
- Create and modify editable designs directly inside Paper.design.
- Establish design systems, typography, colors, and spacing.
- Generate multiple design directions for comparison.
- Review existing designs for usability, consistency, and accessibility.
- Refine approved designs before frontend implementation.

---

## 1. Essential Skills

### 1.1 Paper Agent Plugin (Official)

- **Repository:** https://github.com/paper-design/agent-plugins
- **Website:** https://paper.design/
- **Priority:** Essential
- **Purpose:** Allow AI coding agents to interact directly with Paper.design.

**Capabilities:**
- Read existing designs from Paper.
- Create new screens and artboards.
- Edit existing designs.
- Work with reusable design elements.
- Iterate on layouts and styling.
- Translate designs into frontend code when required.

**Installation — Claude Code:**

```bash
claude plugin marketplace add paper-design/agent-plugins
claude plugin install paper-desktop@paper
```

**Cursor:**

```text
/add-plugin paper-desktop
```

**Other agents:**

Use the Paper MCP integration documented in the official repository.

**When to use:**

Whenever the agent needs to create, inspect, or modify an actual design within Paper.design.

---

### 1.2 Design Brief

- **Repository:** https://github.com/julianoczkowski/designer-skills
- **Skill:** https://github.com/julianoczkowski/designer-skills/blob/main/design-brief/SKILL.md
- **Priority:** Essential
- **Purpose:** Convert rough application ideas and requirements into structured UI/UX design briefs.

**Capabilities:**
- Understand product objectives.
- Identify target users.
- Define UX goals and design constraints.
- Establish visual direction.
- Describe required screens and interactions.
- Produce implementation-independent design specifications.

**When to use:**

Before opening Paper.design to create a new application's UI.

---

### 1.3 Information Architecture

- **Repository:** https://github.com/julianoczkowski/designer-skills
- **Skill:** https://github.com/julianoczkowski/designer-skills/blob/main/information-architecture/SKILL.md
- **Priority:** Essential
- **Purpose:** Define how application screens, features, navigation, and content should be organized.

**Capabilities:**
- Define application navigation.
- Create screen hierarchies.
- Organize features into logical sections.
- Plan user navigation paths.
- Establish page and content hierarchy.
- Identify missing screens and flows.

**When to use:**

After requirement gathering and before creating layouts.

---

### 1.4 Paper Design Skills (Community)

- **Repository:** https://github.com/jaikathuria/paper-design-skills
- **Priority:** High
- **Purpose:** Provide specialized workflows for manipulating designs inside Paper.

**Included skills:**
- `paper-create-design` — Create new designs.
- `paper-edit-design` — Modify existing designs.
- `paper-create-design-system` — Establish reusable design systems.
- `paper-design-to-code` — Translate designs into code.
- `paper-import-figma` — Work with Figma imports.

**When to use:**

When you want repeatable, structured agent workflows for working with Paper's canvas.

**Note:** Community-maintained, unofficial skills. Start with the official Paper integration.

---

## 2. UX Planning and Review Skills

### 2.1 Grill Me

- **Repository:** https://github.com/julianoczkowski/designer-skills
- **Skill:** https://github.com/julianoczkowski/designer-skills/blob/main/grill-me/SKILL.md
- **Priority:** High
- **Purpose:** Challenge incomplete or unclear UX requirements through structured questioning.

**Capabilities:**
- Identify missing requirements.
- Challenge assumptions.
- Question unnecessary interactions.
- Explore alternative UX approaches.
- Identify possible usability problems.
- Clarify navigation and workflow decisions.

**When to use:**

Before finalizing the design brief or whenever the UX direction is unclear.

---

### 2.2 Design Tokens

- **Repository:** https://github.com/julianoczkowski/designer-skills
- **Skill:** https://github.com/julianoczkowski/designer-skills/blob/main/design-tokens/SKILL.md
- **Priority:** High
- **Purpose:** Establish a consistent visual foundation for application designs.

**Capabilities:**
- Define color palettes.
- Create typography scales.
- Establish spacing systems.
- Define border radii and shadows.
- Maintain consistent visual styling.
- Support reusable design components.

**When to use:**

Before creating a large collection of screens in Paper.design.

---

### 2.3 Design Review

- **Repository:** https://github.com/julianoczkowski/designer-skills
- **Skill:** https://github.com/julianoczkowski/designer-skills/blob/main/design-review/SKILL.md
- **Priority:** High
- **Purpose:** Evaluate designs and identify opportunities for improvement.

**Capabilities:**
- Review visual hierarchy.
- Identify inconsistent layouts.
- Evaluate typography and spacing.
- Check accessibility considerations.
- Review navigation and usability.
- Suggest improvements.

**When to use:**

After generating initial screens and before finalizing a design.

---

## 3. Additional Recommended Skills

### 3.1 UI/UX Pro Max

- **Repository:** https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- **Priority:** High
- **Purpose:** Help AI agents select suitable visual styles, layouts, typography, and UI patterns.

**Capabilities:**
- Explore design styles and patterns.
- Recommend typography and color combinations.
- Guide dashboard and SaaS interface design.
- Provide layout and component guidance.
- Improve visual consistency.
- Consider responsive behavior and accessibility.

**When to use:**

When deciding how an application should look or when exploring multiple visual directions.

---

### 3.2 UXCraft

- **Repository:** https://github.com/Seance1723/UXCraft
- **Priority:** Optional
- **Purpose:** Support detailed UX planning across multi-screen products.

**Capabilities:**
- Product discovery.
- User journeys.
- Screen inventories.
- Wireframe planning.
- Interaction states.
- Accessibility considerations.
- Design handoff preparation.

**When to use:**

For complex applications with multiple user roles, screens, and workflows.

---

### 3.3 Anthropic Frontend Design

- **Repository:** https://github.com/anthropics/skills/tree/main/skills/frontend-design
- **Priority:** Optional
- **Purpose:** Improve visual design quality and encourage deliberate design decisions.

**Capabilities:**
- Create distinctive visual directions.
- Improve typography and composition.
- Establish coherent design aesthetics.
- Refine layout and visual hierarchy.
- Produce polished frontend interfaces.

**When to use:**

During visual refinement or frontend implementation.

**Note:** Primarily an implementation-oriented skill, not a replacement for Paper MCP or UX planning skills.

---

## 4. Installation

### Designer Skills Collection

```bash
npx skills add julianoczkowski/designer-skills
```

Includes:
- Grill Me
- Design Brief
- Information Architecture
- Design Tokens
- Design Review
- Additional design workflow skills

### Paper Official Integration

```bash
claude plugin marketplace add paper-design/agent-plugins
claude plugin install paper-desktop@paper
```

For other supported agents, configure the official Paper MCP integration.

---

## 5. Recommended Workflow

### Phase 1 — Requirement Understanding

**Skills:**
- Grill Me
- Design Brief

**Input:**
- PRD
- Application description
- Feature list
- Target users
- Business requirements

**Tasks:**
1. Analyze the product requirements.
2. Identify missing information.
3. Challenge UX assumptions.
4. Understand users and their goals.
5. Establish design constraints.
6. Generate a comprehensive design brief.

**Output:**

`docs/design/01-design-brief.md`

### Phase 2 — UX Architecture

**Skills:**
- Information Architecture
- UXCraft

**Tasks:**
1. Define application navigation.
2. Identify all required screens.
3. Map user journeys.
4. Define screen relationships.
5. Identify interaction states.
6. Establish content hierarchy.
7. Define responsive requirements.

**Outputs:**

- `docs/design/02-information-architecture.md`
- `docs/design/03-user-flows.md`
- `docs/design/04-screen-inventory.md`

### Phase 3 — Visual Direction

**Skills:**
- UI/UX Pro Max
- Design Tokens

**Tasks:**
1. Propose three visual design directions.
2. Determine application layout patterns.
3. Define typography.
4. Define color systems.
5. Define spacing and sizing.
6. Identify reusable components.
7. Establish the design system.

**Outputs:**

- `docs/design/05-visual-direction.md`
- `docs/design/06-design-system.md`

### Phase 4 — Design in Paper

**Skills:**
- Paper Agent Plugin
- Paper Design Skills

**Tasks:**
1. Connect to Paper.design.
2. Inspect the current design file.
3. Create initial artboards.
4. Generate multiple layout alternatives.
5. Design primary application screens.
6. Apply the design system consistently.
7. Create additional screens and states.
8. Review layouts for responsiveness.
9. Refine designs based on feedback.

**Output:**

Editable UI/UX designs inside Paper.design.

### Phase 5 — Design Review

**Skills:**
- Design Review
- Grill Me
- UI/UX Pro Max

**Tasks:**
1. Review the generated screens.
2. Compare designs against the requirements.
3. Check navigation and usability.
4. Identify visual inconsistencies.
5. Evaluate accessibility.
6. Identify missing interaction states.
7. Recommend and apply refinements.

**Output:**

`docs/design/07-design-review.md`

---

## 6. Reusable Agent Prompt

```text
Act as a senior product designer and UX architect.

You are responsible for designing the complete UI/UX
of my application using Paper.design.

Use the installed UX/design skills and Paper MCP.

IMPORTANT:
Do not immediately generate frontend code.
Focus on designing the application in Paper.

PHASE 1 — DISCOVERY

1. Analyze the application requirements.
2. Identify the target users and their needs.
3. Challenge unclear UX requirements.
4. Ask questions where critical information is missing.
5. Generate a comprehensive design brief.

PHASE 2 — UX ARCHITECTURE

1. Define the application navigation.
2. Identify all required screens.
3. Create a screen inventory.
4. Map primary and secondary user journeys.
5. Establish content hierarchy.
6. Define screen-level interactions.
7. Consider loading, empty, error, and success states.

PHASE 3 — DESIGN DIRECTION

1. Propose three distinct visual directions.
2. Explain the reasoning behind each direction.
3. Recommend suitable layouts and UI patterns.
4. Define colors, typography, and spacing.
5. Establish reusable design components.
6. Consider responsive layouts and accessibility.

PHASE 4 — PAPER DESIGN

1. Connect to the active Paper.design project.
2. Read the existing canvas before modifying it.
3. Create actual editable designs inside Paper.
4. Generate initial designs for key screens.
5. Present multiple design directions where appropriate.
6. Use realistic content instead of generic placeholders.
7. Maintain consistency with the design system.
8. Include relevant interaction states.
9. Expand the approved direction to remaining screens.

PHASE 5 — REVIEW

1. Evaluate the designs against the design brief.
2. Identify UX and visual inconsistencies.
3. Check accessibility and responsive considerations.
4. Recommend improvements.
5. Refine the designs inside Paper.
6. Document unresolved design decisions.

FINAL EXPECTATIONS

Deliver:
- Comprehensive design brief
- Information architecture
- Screen inventory
- User journeys
- Design system specification
- Editable Paper.design screens
- Design review findings

Do not implement frontend code unless explicitly requested.

Prefer intentional, consistent, production-ready
application designs over generic AI-generated layouts.
```

---

## 7. Recommended Skill Stack

| Stage | Recommended Skill | Priority |
|---|---|---|
| Requirement clarification | Grill Me | Essential |
| Design brief generation | Design Brief | Essential |
| Screen and navigation planning | Information Architecture | Essential |
| Complex UX flows | UXCraft | Optional |
| Visual design exploration | UI/UX Pro Max | High |
| Design system definition | Design Tokens | High |
| Direct Paper integration | Paper Agent Plugin | Essential |
| Paper canvas workflows | Paper Design Skills | High |
| Design quality assessment | Design Review | High |
| Frontend implementation | Anthropic Frontend Design | Optional |

### Recommended Minimum Setup

Start with:

1. **Designer Skills**
   - Grill Me
   - Design Brief
   - Information Architecture
   - Design Tokens
   - Design Review

2. **Official Paper Agent Plugin**
   - Direct interaction with the Paper canvas.

3. **UI/UX Pro Max**
   - Additional visual design guidance.

4. **Paper Design Skills**
   - Specialized Paper workflows when needed.

### Overall Recommendation

Use design skills to determine **what should be designed and why**.

Use Paper MCP to create **the actual UI designs**.

Use design-review skills to determine **what should be improved**.

Only move to frontend implementation once the UX direction and designs have been approved.
