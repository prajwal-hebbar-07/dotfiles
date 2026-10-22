# Requirements: <product name>

<!-- Header, only while the gate is open. Delete this block after approval.
What changed since the last review (revisions and §4.8 changes):
- Added: R<n> ...
- Changed: R<n> ... (was: ...)
- Removed: R<n> ...
- Cited by: #<issue> / PR #<n> -> what will happen to it (rewritten, requeued, follow-up, closed "not planned")
Factory's calls (decided without you, minor): <list, or "none">
-->

Sections follow mattpocock `to-spec`, plus numbered requirements with
Given / When / Then (github/spec-kit `spec-template.md`), tech-choice
ownership (superpowers `brainstorming`), and addyosmani's Boundaries block.

## Problem

The problem the user faces, from the user's side. Outcome, who it is for,
why now, how we know it worked.

## Solution

What the product does about it, from the user's side. No modules, no files.

## User Stories

1. As a <actor>, I want <feature>, so that <benefit>.
2. ...

Extensive. Every requirement below is traceable to at least one story.

## Requirements

One block per requirement. `R` numbers are never reused or renumbered;
issues cite them and QA writes its scenarios from them. A removed
requirement keeps its number and reads `R7 (removed)`.

### R1. <short title>

<One or two sentences: what the product must do.>

- **Given** <state> **When** <action> **Then** <observable result>
- **Given** <state> **When** <action> **Then** <observable result>

Include the failure and edge paths, not only the happy path. Every criterion
is something a test or a QA scenario can check without asking anyone.

### R2. <short title>

...

## Non-functional requirements

Numbered `N1`, `N2`, ... Each has a number or a check, never "fast" or
"secure" alone.

- **N1. <area>:** <measurable target, and the load or condition it holds under>

Cover, where they apply: performance, accessibility (WCAG 2.2 AA by
default), security and privacy (personal data, accounts, payments, which
raises the ASVS level at the architecture gate), availability, data
retention, supported platforms.

## Out of Scope

Things not being built, each with why and what would bring it back.

- <thing> — <why not now; what would change that>

## Tech choices

Who decides each choice. The stack stage grills only the ones marked
**Mine**.

| Choice | Decided by | Value or constraint |
| --- | --- | --- |
| Language / runtime | Mine / Factory's | <value, or "none"> |
| Framework | Mine / Factory's | |
| Data store | Mine / Factory's | |
| Hosting / deploy target | Mine / Factory's | |
| Other (auth provider, payments, ...) | Mine / Factory's | |

## Open Questions

Only questions the user could not answer yet and that do not block the
gate. Each says who answers it and what depends on it. Empty is a valid
state at the gate; a blocking question is not "open", it is a grilling
question.

- <question> — <who answers> — <which R it affects>

## Boundaries

What every agent in the later stages may, may not, and must ask about
(addyosmani `spec-driven-development`).

- **Always:** <for example: run the check scripts before a commit; validate input at trust boundaries; cite the R number in the issue and the test>
- **Ask first:** <for example: adding a runtime dependency; changing the data model; changing CI config; touching anything under Out of Scope>
- **Never:** <for example: commit secrets; remove or skip a failing test without a reason; edit approved docs without reopening the gate>
