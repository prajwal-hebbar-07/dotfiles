# Codebase map: <project>

A map of this repository for anyone, person or model, opening it cold: what
is where, and where to go to change something. It describes the code as it
is on this commit, nothing planned. Kept current by `/skill:debate-implement`
with every issue it builds. Last updated by #<n> <issue title>, <date>.

## What the app is

<One or two lines, from the requirements' Overview.> What it must do, how it
is built and why: [requirements](requirements.md) · [stack](stack.md) ·
[architecture](architecture.md) · [design](design.md) ·
[glossary](glossary.md) · [plan and issues](issues.md). Leave out a link to
a file that does not exist.

## Run, test, build

| To | Command |
| --- | --- |
| Run it locally | <command, from the bootstrap issue or the README> |
| Run the tests | <command> |
| Lint, type check, build | <command, or `none`> |

## Layout

One row per directory, and per file at the top level or worth naming on its
own. Generated, vendored and dependency folders get one row saying so.

| Path | What is there |
| --- | --- |
| `<path>` | <one line: what it holds, in the glossary's words> |

## Modules

The architecture's modules as the code has them.

| Module | Files | Owns | Depends on |
| --- | --- | --- | --- |
| M1 <name> | `<path>` | <E IDs, and where they are stored> | <M IDs> |

## Data

| Entity | Stored in | Written only by |
| --- | --- | --- |
| E1 <term> | <table, key, file> | <module and function> |

## Tests

| Kind | Where | Run with |
| --- | --- | --- |
| <unit, integration, journey> | `<path or pattern>` | <command> |

## Conventions

Only what the code shows, one line each: how errors are returned, how files
and tests are named, where new code of each kind goes.

## Where to change what

| To change | Go to |
| --- | --- |
| <a behaviour, in the glossary's words> | `<path>`, `<function or section>` |
