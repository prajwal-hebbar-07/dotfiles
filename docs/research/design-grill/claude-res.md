# Skills for Getting Grilled on Your Paper.design UI/UX

> **Setup first:** Install the Paper Desktop plugin so Claude can read your actual frames (structure, styles, text) instead of relying on a screenshot or your description.
>
> ```
> /plugin marketplace add paper-design/agent-plugins
> /plugin install paper-desktop@paper
> ```
>
> Then try: *"Read the selected frame in Paper and critique it."*
> Plugin: https://skillselion.com/skills/paper-design/agent-plugins/plugins/paper-desktop

---

## 1. Interrogation: Claude asks, you defend

### grill-me (Matt Pocock) ⭐ the original
Makes Claude interview you relentlessly, one question at a time, until there are no gaps in shared understanding. It's built for plans, but works well for design decisions: *"Grill me on the onboarding flow in Paper."*
- It's a tiny skill, essentially a short prompt, so it's easy to customize for design.
- Pairs with `/to-spec`, which turns your answers into a spec.

```
npx skills@latest add mattpocock/skills
```
(Select `grill-me` during setup.)
- https://lertechnotes.substack.com/p/stop-letting-claude-code-guess-what
- https://openclawdatabase.com/news/videos/2026-06-04-grill-me-skill-claude-code-knowledge-extraction/

### grill-me (satya-janghu): with session logs
Same idea, but it logs each session to a markdown file in `.grill/`, which is handy for keeping a record of your design rationale.

```
npx -y skills add satya-janghu/agent-skills --skill grill-me --agent claude-code
```
- https://claudemarketplaces.com/skills/satya-janghu/agent-skills/grill-me

---

## 2. Critique: Claude finds the problems

### Impeccable `/critique` (pbakaus) ⭐ most rigorous
A multi-phase UX critique with scoring and persona-based evaluation. It's a design-director-style review rather than a vague "review this" prompt.
- Run `/teach-impeccable` first so it learns your design context.
- Install from the **original pbakaus repo**, since some forks on skills.sh have security warnings.

```
npx skills add pbakaus/impeccable --skill critique
```
- https://agentskillsfinder.com/skills/critique

### design-critique (mohitagw15856/pm-claude-skills)
Scores your screen against Nielsen's 10 heuristics (pass / partial / fail), then applies Jobs-to-be-Done and Gestalt principles and gives prioritized fixes.

```
npx skills add mohitagw15856/pm-claude-skills --skill design-critique --agent claude-code
```
- https://claudeskills.info/zh/skills/mohitagw15856/pm-claude-skills/design-critique/

### design-critiquer (NickCrew/Claude-Cortex)
Connects each issue to its user and business impact rather than taste. It works on both lo-fi wireframes and polished mockups, and checks accessibility (contrast ratios, 44×44px touch targets, focus order).

```
npx skills add NickCrew/Claude-Cortex --skill design-critiquer --agent claude-code
```
- https://www.skills.sh/nickcrew/claude-ctx-plugin/design-critiquer

### UX Heuristic Review / Design Critique Partner (UX Planet)
Ready-to-copy SKILL.md examples for a Nielsen heuristic review and a senior-level critique partner. A good base for writing your own.
- https://uxplanet.org/top-10-claude-skills-you-should-try-in-product-design-32451994862e

---

## Suggested loop

1. Open your design in Paper Desktop, with Claude Code connected.
2. Run `/critique` (Impeccable) or `design-critique`. It reads the frame and lists the issues.
3. Run `/grill-me`. Claude questions you on *why* you made each decision.
4. Fix it in Paper, by hand or by asking Claude, then critique again.
5. Optional: run `/to-spec` to save the agreed decisions.

> Note: none of these skills is Paper-specific. They work on Paper designs through the Paper Desktop plugin's ability to read frames.