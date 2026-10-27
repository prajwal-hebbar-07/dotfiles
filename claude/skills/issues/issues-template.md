# Implementation issues: <project>

Status: proposed · Last updated: <yyyy-mm-dd>

Tracker: [project.md](project.md)

Based on: requirements.md @ <12-char hash> · stack.md @ <12-char hash> · architecture.md @ <12-char hash> · design.md @ <12-char hash | none>

Repo: <owner/name, set at publish>

Keys are permanent. A removed issue keeps its line, marked `dropped`. Each
issue is a file in [issues/](issues/); line 1 is its title and the rest is the
body published to GitHub. Stack decisions are cited as `stack S<n>` and
screens as `screen S<n>`.

## Approach

<One paragraph: how the build is cut, what comes first and why, and the
rule used when two cuts were possible.>

## Build order

Issues in one wave can be built at the same time. Every issue in a later wave
waits for the issues it names.

| Wave | Issues | What exists at the end of it |
| --- | --- | --- |
| 0 | i00-bootstrap | An empty app that builds, tests and deploys |
| 1 | i01-… | … |

## Issues

| Key | Title | Blocked by | Wave | UI | Sec | GitHub |
| --- | --- | --- | --- | --- | --- | --- |
| i00-bootstrap | Set up the project … | none | 0 | no | no | |
| i01-… | … | i00-bootstrap | 1 | yes | no | |

`UI` is yes when the issue builds a screen. `Sec` is yes when it builds or
guards a trust boundary or an abuse case. `GitHub` is the issue number, filled
in at publish.

## Coverage

Every live item is built by at least one issue. A blank row blocks approval.

| Item | Built by |
| --- | --- |
| R1 | i03-… |
| N1 | i02-…, i07-… |
| C1 | i00-bootstrap |
| M1 | i02-… |
| E1 | i02-… |
| F1 | i03-… |
| K1 | i00-bootstrap |
| B1 | i03-… |
| screen S1 | i03-… |
| J1 | i03-… |
| P1 | i03-… |
| stack S1 | i00-bootstrap |

## Not built

- <Item>: <why no issue builds it: an `X` item, a `no UI` reason, or a
  decision the user deferred, with its ID>

## Assumed

- <Open question or accepted unknown>: <value assumed in <issue keys>> (<ID>)

## Open points

- **IQ1** — <something only the user can answer before these issues are
  published, and which issue waits on it>
