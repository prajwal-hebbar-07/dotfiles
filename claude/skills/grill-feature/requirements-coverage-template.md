# Feature grill coverage: #<n> <title> · requirements

A category is `covered` only when requirements.md says what happens there,
and `n/a` only with the user's own reason. `open` blocks the end of the grill.

Status: `open` → `covered` · `n/a` · `deferred`.

| # | Category | What it asks | Status | Where | Note |
| --- | --- | --- | --- | --- | --- |
| 1 | Who and when | Which existing roles use it, which do not, in what moment | open | | |
| 2 | Permissions | Who can see, start, change, undo it | open | | |
| 3 | Existing behaviour | What people who use the app today see or do differently after it ships | open | | |
| 4 | Existing data | What happens to data from before it ships, as the person sees it | open | | |
| 5 | New data | What it keeps, how long, deletion, export, personal data | open | | |
| 6 | Workflows and edge cases | Empty, first use, duplicate, two people at once, half-finished, cancel, retry | open | | |
| 7 | Errors and failure | Bad input, a third party down, partial failure; what the person sees | open | | |
| 8 | Scale and performance | Today's volumes where it lands, the largest case, response times, numbers | open | | |
| 9 | Security and abuse | What must never leak, rate limits, a malicious user | open | | |
| 10 | Privacy and compliance | Personal data rules, consent, audit | open | | |
| 11 | Integrations and clients | Third-party services, imports, exports, old clients, public contracts | open | | |
| 12 | Notifications and copy | Who is told what, and the words | open | | |
| 13 | Rollout | Who gets it first, a switch if any, how a bad release is undone | open | | |
| 14 | Success | How you will know it works and is used | open | | |
| 15 | Boundary | What is in this feature, what is explicitly not, what comes later | open | | |

## Closing checks

| Check | Status | Round | Hashes | Result |
| --- | --- | --- | --- | --- |
| Pre-mortem | open | | | |
| Fresh-eyes check | open | | | |
| Confirm | open | | | |
