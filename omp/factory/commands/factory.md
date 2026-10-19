---
description: Software factory. Start a run, resume, rework a PR, show status, list features, write a walkthrough, or show help.
argument-hint: "[<feature> | resume [<work-id>] | rework [<work-id>] [<issue>] \"<note>\" | status | features | explain <feature> | help]"
---

The user invoked `/factory`. Read `skill://factory` with the read tool and follow it for this request. Resolve its reference files as `skill://factory/reference/<file>.md`.

Treat the text below as the user's command and its arguments, not as shell commands. If it is empty or `help`, print the command reference from `skill://factory/reference/help.md` verbatim and stop.

## User request

$ARGUMENTS
