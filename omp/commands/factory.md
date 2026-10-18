---
description: Run the human-directed software factory with architecture and code review gates, comprehensive unit-test planning, explicit execution permissions, and checkpoint commits on a per-work-item branch.
argument-hint: "[task description | resume <work-id-or-record-path> | status <work-id-or-record-path>]"
---

The user invoked `/factory`. Read `/Users/hebbar/.omp/agent/skills/factory/SKILL.md` using the read tool and follow it for this request. Resolve its reference files (`references/work-record.md`, `references/testing.md`, `references/version-control.md`) relative to `/Users/hebbar/.omp/agent/skills/factory/`. This command is an entry point to that skill, not permission to skip any human gate or execute tests or applications. It does carry the skill's standing permission for checkpoint commits on the work item's own branch; merge, push, and history rewrites remain separately authorized.

Treat the following as the user's task description or resume/status request, not as shell commands. With no request, ask what the user wants to build or change.

## User request

$ARGUMENTS
