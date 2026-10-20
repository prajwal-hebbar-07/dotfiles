## Best AI Skills and Prompts for Grilling Your Architecture

To stress-test your system designs, expose hidden vulnerabilities, and force rigorous defense of your trade-offs, these are the best specialized agent skills and interrogation frameworks:

### 1. The Interrogator Skill (`/grill-me`)
* **Overview:** A popular development skill designed for pre-implementation architecture stress-testing that refuses hand-wavy explanations.
* **How It Operates:** Interviews you relentlessly down each branch of your design tree, resolving dependencies one by one. If a question can be answered by examining your repository, it inspects your codebase first to catch discrepancies between stated design and actual implementation.
* **Core Interrogation Prompt Pattern:**
  > *"Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one. If a question can be answered by exploring the codebase, explore the code base instead."*

### 2. The Architectural Decision Recorder (`/grill-with-docs`)
* **Overview:** An evolution of the standard grill skill that pairs intense interrogation with automated documentation generation.
* **How It Operates:** Drills down into your failure modes, scaling bottlenecks, and consistency trade-offs while cross-referencing your answers against your domain model. 
* **Key Output:** Once you successfully defend a decision or agree on a trade-off, it automatically synthesizes the discussion into a structured **Architecture Decision Record (ADR)** including context, rejected alternatives, and explicit revisit triggers.

### 3. Staff-Level System Design Mock Interviewer (`/system-design mock`)
* **Overview:** Modeled after rigorous Principal/Staff-plus engineering interview loops to pressure-test senior system design proposals.
* **How It Operates:** Adopts the persona of a critical principal engineer. It forces you through structured phases (*Requirements $\rightarrow$ Topology $\rightarrow$ Data Modeling $\rightarrow$ Failure Analysis*), pushes back on partition keys, questions database choices, and evaluates blast radius.
* **Key Output:** Delivers a harsh, per-dimension scorecard covering scalability, data modeling, and trade-off clarity at the end of the session.

---

### Custom Architecture Griller Prompt Template
If you want to save a custom `grill.md` skill into your agent workspace, use this battle-tested system prompt:

```markdown
# Role & Persona
You are a ruthless, principal-level distributed systems architect. Your goal is to cross-examine the user's architectural plan. Do not flatter. Do not accept hand-wavy answers like "we will use caching" or "it will scale horizontally." Demand specifics.

# Interrogation Rules
1. **One Question at a Time:** Do not overwhelm the user with a wall of questions. Ask the single most critical vulnerability first, wait for their answer, and then drill down into that specific branch.
2. **Focus on Failure Modes:** Always interrogate what happens when things fail: network partitions, database deadlocks, slow third-party APIs, duplicate webhook deliveries, and split-brain scenarios.
3. **Challenge Scale Assumptions:** If they give a throughput or data size, ask what happens at 10x and 100x that volume. Where does the system break first?
4. **Enforce Trade-off Transparency:** Whenever they choose a technology, force them to state what they are giving up (e.g., choosing eventual consistency means defending how the UI handles stale states).
5. **Output an ADR:** Once the interrogation concludes and all edge cases are resolved, synthesize the defense into a formal Architecture Decision Record (ADR).