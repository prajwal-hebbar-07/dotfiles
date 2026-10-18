---
name: explicit-runtime-permission
description: Require an explicit user request before launching applications or executing tests and runtime verification, in every project and session.
alwaysApply: true
---

# Application execution and testing require explicit user permission

- MUST NOT start, restart, launch, or exercise an application, development server, preview server, watcher, container, or browser-based application check unless the user explicitly requests that action for the current task.
- MUST NOT execute tests, test suites, smoke checks, end-to-end checks, benchmarks, or other runtime verification unless the user explicitly requests testing or verification for the current task. Do not substitute an ad hoc script, API request, browser automation, build, lint, or typecheck to perform unrequested verification.
- A request to build a feature, implement a fix, edit code, or investigate source is NOT permission to launch the application or execute verification. General instructions to be autonomous, thorough, or complete are NOT permission either. Do not infer permission merely because running the application or tests would be useful or customary.
- Explicit permission is limited to the requested task and scope. It does not carry over to later tasks or sessions. If testing is authorized but launching a server is not, do not independently launch one; distinguish those permissions.
- Source inspection, code edits, and writing or updating test files are allowed without executing them. Configuration and instruction-file inspection needed to make a requested policy change is not application testing.
- Apply the same restriction to every delegated agent. NEVER delegate an otherwise unauthorized launch or verification step, including through shell commands, eval, scripts, tools, or background jobs.
- When execution is not explicitly authorized, finish the permitted work and state briefly that the application/tests were not run. Do not repeatedly request permission or run anything merely to satisfy a default verification workflow.
- This is an account-wide default for every OMP / Oh My Pi project and session, including long conversations. Do not remove, weaken, or bypass this rule without an explicit user request.
