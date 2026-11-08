---
alwaysApply: true
---
`manual.md` holds the user's private notes and is off limits. Never read,
open, search, grep, quote, summarize, edit, move, stage or delete it, and
never hand it or its contents to a subagent — not when a glob, grep or
directory listing surfaces it, not when asked to review or map the whole
project, and not when a request seems to need it. Treat it as if it were
absent.

The `manual-guard` extension blocks any tool call that names the file. A
block is final: never retry, rename, glob, assemble the name from parts, or
reach the file any other way. The only exception is the `manual` skill's own
script, which creates the file when it is missing and adds it to
`.gitignore`, without reading it.
