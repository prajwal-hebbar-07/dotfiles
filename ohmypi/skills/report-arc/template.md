<one-line status: Step N implemented and committed | implemented, commit blocked | committed, next step | stopped — <reason in a few words>.>

**Step N** — `<type>(<scope>): <imperative summary>` — committed `<sha>` (`<file count>` files)

If not yet committed, drop the SHA and file count. Say **not committed**.

| Done when | State |
| --- | --- |
| <outcome from the plan, verbatim> | <what is true now, in this tree> |
| <next outcome> | <state> |

**Changed**

- <what this step actually did — outcomes or existing paths only>

**Left unstaged**

- <paths this step did not own, or `none`>

**Verification**

- <commands you ran, and the result>
- Gate vs parent: <unchanged error set → met | this step added N | skipped, host rule>

**Next**

Step N+1 — `<subject>`. Or: stopped — <identity | hook | this step added failures>.