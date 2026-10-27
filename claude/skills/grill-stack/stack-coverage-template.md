# Stack grill coverage: <project>

A category is `covered` only when `stack.md` says what is decided there, and
`n/a` only with the user's own reason. `open` blocks the end of the grill.

Status: `open` → `covered` · `n/a` · `deferred`.

| # | Category | What it asks | Status | Where | Note |
| --- | --- | --- | --- | --- | --- |
| 1 | Language and runtime | Why this one, who can maintain it, how long it is supported | open | | |
| 2 | Framework | What it gives that the platform does not, how locked in | open | | |
| 3 | UI layer | Components, styling, accessibility fit | open | | |
| 4 | Data storage | Kind, product, size at the numbers, durability | open | | |
| 5 | Data access and migrations | How the schema changes without losing data | open | | |
| 6 | Auth and identity | Method, provider, sessions, account recovery | open | | |
| 7 | Hosting and deploy | Where it runs, how a release ships, how it rolls back | open | | |
| 8 | Environments and local dev | Dev, staging, production; one-command local run | open | | |
| 9 | CI and CD | What runs on each change, what blocks a release | open | | |
| 10 | Testing tools | Unit, integration, end-to-end; what runs where | open | | |
| 11 | Background work | Jobs, queues, schedules, retries, duplicates | open | | |
| 12 | Files and media | Storage, size limits, delivery, cleanup | open | | |
| 13 | Third-party services | Each one: need, price, limits, outage plan, swap cost | open | | |
| 14 | Observability | Logs, errors, metrics, alerts, who is told | open | | |
| 15 | Security tooling | Secrets, dependency scanning, headers, patching | open | | |
| 16 | Backup and recovery | What is backed up, how often, a tested restore | open | | |
| 17 | Performance and scale fit | Each `N` number against each choice's limit | open | | |
| 18 | Cost | Monthly at launch and at the numbers, and what grows | open | | |
| 19 | Licence and vendor risk | Licence fit, price changes, shutdown, data export | open | | |
| 20 | Team fit | What the user knows, learning time, who maintains it | open | | |
| 21 | Dependency count | Each package or service earns its place | open | | |
| 22 | Upgrade and exit paths | Major version upgrades, leaving each lock-in | open | | |
| 23 | Compatibility between choices | Versions and hosts that must work together | open | | |

## Closing checks

| Check | Status | Round | Hashes (stack / requirements) | Result |
| --- | --- | --- | --- | --- |
| Simplicity sweep | open | | | |
| Pre-mortem | open | | | |
| Fresh-eyes check | open | | | |
| Confirm | open | | | |
