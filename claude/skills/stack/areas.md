# Decision areas

Go through each. An area gets a decision only when an `R`, `N`, or `C` forces
it; otherwise it goes under **Not needed** with the reason. Before adding a
piece, ask in order: does it need to exist, does the platform or standard
library already do it, does a piece already chosen do it, can a smaller
version do it.

| Area | Decide |
| --- | --- |
| Language and runtime | What the code is written in and runs on |
| App framework | Server and client frameworks, or none |
| UI layer | Components, styling, design system |
| Data store | Database kind and product, or files |
| Data access | Queries, ORM, migrations |
| Auth and identity | Sign-in method, sessions, who provides it |
| Hosting and deploy | Where it runs, how a release ships |
| Environments and local dev | Dev, staging, production; running it on a laptop |
| CI and CD | Checks on each change, release automation |
| Testing tools | Unit, integration, end-to-end |
| Background work | Jobs, queues, scheduling |
| Files and media | Uploads, storage, delivery |
| Third-party services | Email, payments, maps, search, any other API |
| Observability | Logs, errors, metrics, alerts |
| Security tooling | Secrets, dependency scanning, headers |
| Realtime and notifications | Live updates, push, email delivery |
| Platform shell | Mobile or desktop packaging, if any |
| Package and repo layout | Package manager, monorepo or not |
| Analytics | Event tracking, if a requirement asks |
| Internationalisation | Languages, time zones, currency, if asked |
