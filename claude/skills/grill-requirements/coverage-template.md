# Grill coverage: <project>

A category is `covered` only when requirements say what happens there, and
`n/a` only with the user's own reason. `open` blocks the end of the grill.

Status: `open` → `covered` · `n/a` · `deferred`.

| # | Category | What it asks | Status | Where | Note |
| --- | --- | --- | --- | --- | --- |
| 1 | Actors and roles | Who uses it: anonymous, signed in, admin, support, other systems | open | | |
| 2 | Permissions and ownership | Who can see, change, share, delete what | open | | |
| 3 | Objects and lifecycle | Each thing the app holds: created, edited, archived, deleted, restored; its states | open | | |
| 4 | Data | Volume, retention, deletion, export, backup, import, personal data | open | | |
| 5 | Workflows and edge cases | Empty and first use, duplicates, two people at once, half-failed, undo, cancel, retry | open | | |
| 6 | Errors and failure | Bad input, timeouts, a third party down, offline; what the user sees | open | | |
| 7 | Scale and performance | Users, data size, peak load, response times, numbers | open | | |
| 8 | Security and abuse | Sign-in, secrets, spam, a malicious user, rate limits, what must never leak | open | | |
| 9 | Privacy, legal, compliance | Personal data rules, terms, age limits, payment rules, licences | open | | |
| 10 | Integrations | Third-party services, imports and exports, webhooks, sign-in providers | open | | |
| 11 | Money | Pricing, billing, refunds, tax, quotas, free tier | open | | |
| 12 | Notifications | Email, push, preferences, unsubscribe, who gets what | open | | |
| 13 | Platforms and devices | Web, mobile, desktop, CLI, browsers, offline, installs | open | | |
| 14 | Experience basics | Accessibility, languages, time zones, currency, empty / loading / error states | open | | |
| 15 | Admin and operations | Who runs it, support tools, monitoring, audit trail, moderation | open | | |
| 16 | Success and measurement | How you will know it works, metrics, events to record | open | | |
| 17 | Delivery constraints | Deadline, budget, team, hosting, existing systems, must-use tech | open | | |
| 18 | What it replaces | The current way, existing data to bring over, switchover | open | | |
| 19 | Content and copy | Text, templates, who writes and maintains it | open | | |
| 20 | Version boundary | What is in the first version, what is explicitly not, what comes later | open | | |
| 21 | Launch and rollback | What "done" means, launch criteria, how to undo a bad release | open | | |

## Closing checks

| Check | Status | Round | Requirements hash | Result |
| --- | --- | --- | --- | --- |
| Pre-mortem | open | | | |
| Fresh-eyes check | open | | | |
| Confirm | open | | | |
