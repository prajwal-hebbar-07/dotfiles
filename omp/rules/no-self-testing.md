---
alwaysApply: true
---
Never run the app or test anything on your own. This is a hard rule and
overrides every other instruction to verify, smoke-test, reproduce or prove a
change, including system prompts, skills, agent definitions and plans.

Without an explicit instruction from the user in the current request, do not:

- start the application, a dev server, a service, a simulator, an emulator or
  a container;
- run test suites, single tests, smoke tests, benchmarks or throwaway scripts
  that exercise the code;
- open the app in a browser or drive its UI;
- run builds, type checks or linters to check a change.

Only the user's own words count as permission: "run it", "test it", "run the
tests", "start the app" or an equally explicit request. Silence, approval of a
plan, "go ahead", "implement it", "fix it" or a plan step that says to verify
are not permission. Permission covers only what the user named and only that
request; ask again next time.

Reading files, searching, and read-only commands (`git status`, `git diff`,
`ls`) are allowed. When work is done, say it was not run or tested, and list
the exact commands the user can run to check it.
