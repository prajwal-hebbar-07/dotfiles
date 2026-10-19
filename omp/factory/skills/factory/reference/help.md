```text
/factory <feature>                     Start a run: requirements → stack →
                                       architecture → design → issues → build →
                                       review → QA → draft PR per issue
/factory resume [<work-id>]            Continue a run (after a crash, or after you
                                       merge a phase PR)
/factory rework [<work-id>] [<issue>] "<note>"
                                       Send feedback on an open PR; fixes land as
                                       new commits on top
/factory status                        List runs: work ID, stage, issues, open PRs,
                                       what each is waiting on
/factory features                      List the app's modules and features
/factory explain <feature>             Write or refresh docs/walkthroughs/<feature>.md
/factory help                          Show this list (bare /factory does too)

IDs:   work ID  NNN-slug, e.g. 003-todo-app (shown in every status line and by status)
       issue    GitHub issue number, 12 or #12
       note     free text in quotes
Short: with one unfinished run, omit the work ID; with one open PR, omit the issue.

Examples:
  /factory "todo app with auth"
  /factory resume
  /factory rework 12 "empty list should show a hint, not a blank page"
  /factory explain auth

After each gate and each queued question the factory stops and names the
document to read. Reply `approve` to continue, or type the change you want.
The factory never merges: merge the PR on GitHub, then /factory resume.
```
