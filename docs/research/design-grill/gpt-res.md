
# UI/UX Design Grilling & Review Skills for Paper.design

## Objective

AI-agent skills for critically reviewing, challenging, and improving UI/UX designs already created in [Paper.design](https://paper.design/).

The objective is not to immediately redesign the application but to systematically interrogate existing design decisions, identify weaknesses, and resolve UX concerns before frontend implementation.

### Key Capabilities

- Inspect existing Paper.design screens and components.
- Challenge UI/UX decisions through structured questioning.
- Identify missing screens, interactions, and edge cases.
- Evaluate usability, navigation, and user journeys.
- Identify accessibility and responsive design issues.
- Critique visual hierarchy, layouts, and information architecture.
- Evaluate design system consistency.
- Suggest alternatives with clear reasoning and trade-offs.
- Ask one question at a time and challenge incomplete answers.
- Document decisions and prioritize recommended improvements.

---

## 1. Essential Skills

### 1.1 Grill Me — vvanagas

- **Repository:** https://github.com/vvanagas/agent-skills
- **Skill:** https://github.com/vvanagas/agent-skills/blob/main/skills/grill-me/SKILL.md
- **Priority:** Essential
- **Purpose:** Systematically challenge design decisions and assumptions through interactive questioning.

**Capabilities:**
- Ask one question at a time.
- Challenge assumptions and incomplete reasoning.
- Identify unresolved decisions.
- Explore alternatives and trade-offs.
- Follow up on vague answers.
- Maintain a decision tree of unresolved issues.
- Continue questioning until important decisions are resolved.

**Example Questions:**
- Why did you choose this navigation structure?
- What user problem does this screen solve?
- Why is this action placed here?
- What happens when the user makes a mistake?
- Could this workflow be simplified?
- What happens if the user abandons this process?
- Why is this design better than an alternative?

**When to Use:**

After inspecting the existing Paper design, to challenge the reasoning behind individual UX decisions.

**Installation:**

```bash
npx skills add vvanagas/agent-skills
```

---

### 1.2 Design Critique — cuellarfr

- **Repository:** https://github.com/cuellarfr/design-skills
- **Skill:** https://github.com/cuellarfr/design-skills/blob/main/skills/design-critique/SKILL.md
- **Priority:** Essential
- **Purpose:** Evaluate existing UI designs using established usability, interaction, and design principles.

**Capabilities:**
- Evaluate Nielsen's usability heuristics.
- Assess visual hierarchy and cognitive load.
- Analyze navigation and information architecture.
- Evaluate interaction patterns.
- Identify unnecessary complexity.
- Review UX writing and content clarity.
- Identify usability issues.
- Provide evidence-based recommendations.

**Review Areas:**
- Screen purpose and clarity.
- Navigation usability.
- Information hierarchy.
- User interaction patterns.
- Form usability.
- Error handling and recovery.
- Layout consistency.
- Content organization.
- Overall cognitive load.

**When to Use:**

Before starting the grilling session, to identify specific weaknesses in the Paper.design screens.

**Installation:**

```bash
npx skills add cuellarfr/design-skills --skill design-critique
```

---

### 1.3 Design Critique — Anthropic

- **Repository:** https://github.com/anthropics/knowledge-work-plugins
- **Skill:** https://github.com/anthropics/knowledge-work-plugins/blob/main/design/skills/design-critique/SKILL.md
- **Priority:** High
- **Purpose:** Provide structured design critiques across usability, hierarchy, consistency, and accessibility.

**Capabilities:**
- Evaluate first impressions.
- Assess screen readability.
- Review visual hierarchy.
- Check UI consistency.
- Evaluate usability.
- Identify accessibility concerns.
- Suggest design improvements.
- Prioritize findings by severity.

**When to Use:**

For an additional structured critique of existing Paper designs, particularly during visual refinement.

---

### 1.4 UX Heuristics — wondelai

- **Repository:** https://github.com/wondelai/skills
- **Skill:** https://github.com/wondelai/skills/blob/main/ux-heuristics/SKILL.md
- **Website:** https://skills.wondel.ai/skills/ux-heuristics/
- **Priority:** Essential
- **Purpose:** Identify usability problems using established UX heuristics.

**Capabilities:**
- Evaluate Nielsen's 10 usability heuristics.
- Apply Steve Krug's "Don't Make Me Think" principles.
- Analyze navigation complexity.
- Evaluate error prevention and recovery.
- Identify confusing interactions.
- Review visibility of system status.
- Assess consistency and user control.
- Assign severity ratings to UX issues.

**Example Questions:**
- Can a new user understand this screen immediately?
- Is the primary action obvious?
- Does the application provide sufficient feedback?
- Can users undo destructive actions?
- Are navigation labels understandable?
- Does the interface rely too much on user memory?
- Can users recover from mistakes?

**When to Use:**

To challenge whether the application is genuinely usable, rather than merely visually appealing.

**Installation:**

```bash
npx skills add wondelai/skills --skill ux-heuristics
```

---

## 2. Additional Review Skills

### 2.1 Accessibility Review — Anthropic

- **Repository:** https://github.com/anthropics/knowledge-work-plugins
- **Skill:** https://github.com/anthropics/knowledge-work-plugins/blob/main/design/skills/accessibility-review/SKILL.md
- **Priority:** High
- **Purpose:** Evaluate accessibility requirements before implementation.

**Capabilities:**
- Review color contrast.
- Evaluate text readability.
- Assess touch target sizes.
- Review form labels.
- Check accessibility-related design decisions.
- Identify potential keyboard navigation issues.
- Evaluate planned focus behavior.
- Identify accessibility risks.

**When to Use:**

After completing the initial UX review.

**Important:** A static Paper design can reveal some accessibility issues, but keyboard behavior and screen reader support must be verified in an actual implementation.

---

### 2.2 Design System — Anthropic

- **Repository:** https://github.com/anthropics/knowledge-work-plugins
- **Skill:** https://github.com/anthropics/knowledge-work-plugins/blob/main/design/skills/design-system/SKILL.md
- **Priority:** High
- **Purpose:** Evaluate consistency across application screens and components.

**Capabilities:**
- Audit design tokens.
- Evaluate component consistency.
- Review typography and spacing.
- Identify inconsistent color usage.
- Review component variants.
- Identify missing interaction states.
- Evaluate reuse of existing patterns.

**Example Questions:**
- Why are similar buttons styled differently?
- Are the same spacing rules used everywhere?
- Does this component need another variant?
- Are loading, disabled, and error states defined?
- Could these elements be consolidated into one component?

**When to Use:**

When reviewing multiple screens or preparing the application for frontend implementation.

---

### 2.3 UX Audit — EliaAlberti

- **Repository:** https://github.com/EliaAlberti/ux-audit-skill
- **Skill:** https://github.com/EliaAlberti/ux-audit-skill/blob/main/SKILL.md
- **Priority:** Optional
- **Purpose:** Conduct structured usability audits from screenshots.

**Capabilities:**
- Analyze screenshots of user journeys.
- Identify heuristic violations.
- Assign severity ratings.
- Generate annotated screenshots.
- Recommend improvements.
- Estimate remediation effort.
- Produce structured Markdown reports.

**When to Use:**

When you want an independent, evidence-based review of a screen or sequence of screens.

**Note:** This skill primarily works with screenshots rather than directly editing a Paper canvas.

---

## 3. Paper.design Integration

### Official Paper Agent Plugin

- **Repository:** https://github.com/paper-design/agent-plugins
- **Website:** https://paper.design/
- **Priority:** Required for direct Paper canvas inspection.
- **Purpose:** Allow compatible AI agents to read and modify designs directly inside Paper.

**Capabilities:**
- Inspect existing artboards.
- Read design structure.
- Examine layout and styling.
- Inspect elements and components.
- Create or edit screens.
- Refine designs based on feedback.

**Claude Code Installation:**

```bash
claude plugin marketplace add paper-design/agent-plugins
claude plugin install paper-desktop@paper
```

**Cursor:**

```text
/add-plugin paper-desktop
```

**Codex:**

```bash
codex plugin marketplace add paper-design/agent-plugins
codex plugin install paper-desktop@paper
```

For other agents, follow the official Paper MCP documentation.

**Important:**

Use Paper MCP to inspect the actual design before making recommendations.

Do not assume that an interaction works merely because its corresponding element exists in the design.

---

## 4. Recommended Grilling Workflow

### Phase 1 — Inspect Existing Paper Designs

**Tool:**
- Paper Agent Plugin

**Tasks:**
1. Connect to the active Paper.design file.
2. Inspect all relevant artboards.
3. Understand the application structure.
4. Identify navigation patterns.
5. Examine component consistency.
6. Identify missing or unclear interactions.
7. Compare screens against the available requirements.

**Output:**

`docs/design-review/01-design-inventory.md`

---

### Phase 2 — Perform Initial UX Critique

**Skills:**
- Design Critique — cuellarfr
- Design Critique — Anthropic
- UX Heuristics — wondelai

**Tasks:**
1. Evaluate screen clarity.
2. Identify navigation issues.
3. Analyze visual hierarchy.
4. Review interaction patterns.
5. Identify missing states.
6. Evaluate usability and cognitive load.
7. Identify inconsistencies.
8. Rank findings by severity.

**Output:**

`docs/design-review/02-ux-critique.md`

---

### Phase 3 — Grill Design Decisions

**Primary Skill:**
- Grill Me — vvanagas

**Supporting Skills:**
- Design Critique
- UX Heuristics

**Rules:**
1. Ask exactly one question at a time.
2. Reference the specific Paper screen.
3. Clearly explain the design concern.
4. Challenge the reasoning behind the decision.
5. Present alternatives where appropriate.
6. Explain advantages and disadvantages.
7. Wait for the user's response.
8. Challenge vague or incomplete answers.
9. Record the final agreed decision.
10. Continue until important unresolved decisions are addressed.

**Topics to Challenge:**
- Screen necessity
- Navigation and information architecture
- User journeys
- Interaction patterns
- Visual hierarchy
- Missing functionality
- Empty/loading/error/success states
- Responsive behavior
- Accessibility
- Design consistency
- Workflow complexity
- Edge cases
- Error recovery

**Output:**

`docs/design-review/03-grilling-decisions.md`

---

### Phase 4 — Accessibility and Design System Review

**Skills:**
- Accessibility Review — Anthropic
- Design System — Anthropic

**Tasks:**
1. Review accessible design decisions.
2. Check typography and contrast where measurable.
3. Evaluate component consistency.
4. Check reusable component patterns.
5. Identify missing variants and states.
6. Review responsive design expectations.
7. Document implementation-level checks that cannot be verified in Paper alone.

**Output:**

`docs/design-review/04-accessibility-and-consistency.md`

---

### Phase 5 — Final Recommendations

**Skills:**
- Grill Me
- Design Critique
- UX Heuristics

**Tasks:**
1. Consolidate review findings.
2. Record resolved and unresolved decisions.
3. Prioritize usability improvements.
4. Identify screens requiring changes.
5. Produce actionable recommendations.
6. Prepare a checklist for updating Paper designs.
7. Obtain approval before modifying designs.

**Output:**

`docs/design-review/05-final-recommendations.md`

---

## 5. Recommended Skill Stack

| Skill | Purpose | Priority |
|---|---|---|
| Grill Me — vvanagas | Challenge design decisions interactively | Essential |
| Design Critique — cuellarfr | Deep UX and usability evaluation | Essential |
| UX Heuristics — wondelai | Validate usability principles | Essential |
| Paper Agent Plugin | Read existing Paper designs | Essential |
| Design Critique — Anthropic | Structured visual and usability review | High |
| Accessibility Review — Anthropic | Identify accessibility risks | High |
| Design System — Anthropic | Check visual/component consistency | High |
| UX Audit — EliaAlberti | Screenshot-based independent audits | Optional |

---

## 6. Reusable AI Agent Prompt

```text
Act as a senior UX design reviewer, product designer,
and critical design interviewer.

My application has already been designed in Paper.design.

Your objective is to thoroughly challenge the existing
UI/UX decisions before frontend implementation.

Use the available skills:
- grill-me
- design-critique
- ux-heuristics
- accessibility-review
- design-system

Use Paper MCP to inspect the existing designs.

IMPORTANT RULES:
- Do not immediately redesign anything.
- Do not generate frontend code.
- Do not automatically agree with my decisions.
- Do not provide generic opinions.
- Base criticism on the actual designs.
- Distinguish observed issues from assumptions.
- Ask exactly ONE question at a time.

PHASE 1 — DESIGN INSPECTION

1. Connect to the active Paper.design project.
2. Inspect all relevant screens and components.
3. Understand the application's purpose.
4. Identify target users and primary journeys.
5. Map navigation and screen relationships.
6. Identify missing states or design information.

PHASE 2 — CRITICAL EVALUATION

Review the following:

1. Screen purpose and necessity
2. Information architecture
3. Navigation consistency
4. User journeys
5. Interaction patterns
6. Visual hierarchy
7. Cognitive load
8. Content clarity
9. Error handling
10. Empty/loading/success states
11. Responsive design
12. Accessibility
13. Component consistency
14. Design system usage
15. Edge cases
16. Opportunities for simplification

Use established UX principles to identify concerns.

PHASE 3 — GRILL ME

Begin an interactive design interrogation.

For every question:

1. Identify the specific screen or component.
2. Explain the issue or questionable decision.
3. Ask a clear and challenging question.
4. Explain why the answer matters.
5. Provide a recommendation when evidence supports it.
6. Explain relevant trade-offs.
7. Wait for my response.
8. Challenge incomplete or weak reasoning.
9. Record the final decision.

Ask only ONE question at a time.

Prioritize issues based on:
- Impact on users
- Severity
- Frequency of occurrence
- Difficulty of changing the design later
- Importance to core user journeys

Continue until all critical design decisions are resolved
or explicitly deferred.

PHASE 4 — DECISION TRACKING

Maintain a record containing:

- Screen or component
- Issue identified
- Question asked
- My response
- Alternatives considered
- Final decision
- Reasoning
- Priority
- Status

Do not silently discard unresolved questions.

PHASE 5 — FINAL REVIEW

Create a comprehensive Markdown report:

docs/design-review/UI_UX_DESIGN_REVIEW.md

The report must include:

1. Executive summary
2. Screens reviewed
3. Design strengths
4. Critical usability problems
5. Major usability problems
6. Minor usability problems
7. Missing screens and interaction states
8. Accessibility considerations
9. Design system inconsistencies
10. Questions asked and answers received
11. Final design decisions
12. Unresolved concerns
13. Recommended improvements
14. Prioritized Paper.design changes
15. Final checklist before implementation

Do not modify Paper.design until I explicitly approve.

The goal is to ensure the UI/UX is intentional,
consistent, usable, accessible, and sufficiently
complete before development begins.
```

---

## 7. Minimum Recommended Setup

For an effective design grilling workflow, start with:

### 1. Grill Me — vvanagas
Interrogate assumptions and unresolved decisions.

https://github.com/vvanagas/agent-skills

### 2. Design Critique — cuellarfr
Identify usability and interaction problems.

https://github.com/cuellarfr/design-skills

### 3. UX Heuristics — wondelai
Evaluate the design against established usability principles.

https://github.com/wondelai/skills

### 4. Official Paper Agent Plugin
Allow the agent to inspect the existing Paper.design project.

https://github.com/paper-design/agent-plugins

## Final Recommendation

Use the following sequence:

**Paper Inspection → UX Critique → UX Heuristic Evaluation → Interactive Grilling → Decision Tracking → Final Design Review**

The purpose is to move beyond subjective visual feedback and systematically validate the design decisions behind the application.

The final outcome should be a reviewed Paper.design project, documented UX decisions, and a prioritized improvement plan ready for implementation.
