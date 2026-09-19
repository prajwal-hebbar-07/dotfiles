# What every skill in `ohmypi/skills/` actually does

Plain-English inventory, written so you can delete the whole directory and
re-add only what you want. 11 skills, 19 files, 2,950 lines. One agent
(`ohmypi/agents/committer.md`, 97 lines) is included because it duplicates a
skill.

A "skill" here is just a markdown file of instructions. When you say one of its
trigger phrases, the agent reads the file and follows it. Nothing runs on its
own, nothing is compiled, nothing breaks if you delete it — except for the four
skills that call each other by name (noted below).

---

## The one-screen version

| Skill | Lines | In one sentence | Verdict |
|---|---:|---|---|
| `repo-docs` | 328 | Writes paired technical + plain-English docs, one pair per code area | **Keep.** It made this repo's `docs/`. |
| `docs-twins` | 261 | The same skill, hard-wired to a client's pnpm monorepo | **Delete.** Superseded by `repo-docs`. |
| `docs-verify` | 800 | Python script hunts doc claims that no longer exist in the code | **Rewrite or drop.** The script assumes TypeScript. |
| `implementation-plan` | 287 | Turns a finished design chat into numbered commit-by-commit plan files | Keep if you plan before coding. |
| `review-implementation-plan` | 165 | A second agent critiques and edits that plan, then refuses to code | Keep only with `implementation-plan`. |
| `follow-implementation-plan` | 169 | Executes the plan one commit at a time, deletes each finished file | Keep only with `implementation-plan`. |
| `implement-commit-prompt` | 163 | Writes a copy-pasteable prompt for one commit of the plan | **Delete.** The plan template already writes those prompts. |
| `commit` | 111 | Commits already-staged changes with a Conventional-Commits message | **Keep.** Smallest, most used, two other skills call it. |
| `report-arc` | 96 | The status-report shape after a step, and saving one as a doc page | Keep if you keep the plan pipeline. |
| `paper-target` | 115 | Records which paper.design file/page this repo uses, in `AGENTS.md` | **Delete for now.** The two skills that read it don't exist. |
| `twitter-campaign` | 455 | Writes tweets and Reddit posts about the project | Keep only if you do launches. Not a coding skill. |

If you want the shortest possible restart: keep `commit`, keep `repo-docs`,
delete the other nine, and re-add the plan pipeline later if you miss it.

---

## Documentation family

### repo-docs — 328 lines (`SKILL.md` 266, `architecture-template.md` 42, `readme-seed.md` 20)

**You say:** "repo docs", "generate the docs", "twin docs for this repo",
`/repo-docs`. Options: `full`, `since <ref>`, or specific numbers like `01 04`.

**What it does.** Every subject gets documented twice under the same number: a
technical page in `docs/architecture/NN-slug.md` and a jargon-free twin in
`docs/plain-english/NN-slug.md`.

1. Reads the marker `docs-baseline: <sha>` in `docs/README.md` and diffs your
   code since that commit. No changes → it stops and says the docs are current.
2. Looks up the changed paths in the `## Mapping` table in `docs/README.md` to
   decide which pairs are stale. No table yet → it explores the tree and invents
   3–8 areas (for a dotfiles repo: one pair per tool directory, `01` for layout).
3. Launches one subagent per stale pair. Each owns exactly two files, must read
   the real code, and must tag anything it inferred with `[INFERENCE]`.
4. The parent alone edits the three `README.md` index files, then checks both
   directories hold the same number of files and every relative link resolves.
5. Stamps the new baseline sha — only if every pair the diff demanded got done.

**Writes:** `docs/architecture/*`, `docs/plain-english/*`, three `README.md`
index files. Never commits.

**Needs:** git, python3 (a link check), subagents (falls back to serial).

**This repo's `docs/` is its output.** Evidence: `docs/README.md` has the
seed's `## Freshness` + `docs-baseline: 0147ec0…` + `## Mapping` rows
(`zsh/**`→02, `tmux/**`→03, `ghostty/**`→04, `ohmypi/**`→05), and all five
plain-English files open with the mandated `**Twin of:**` line.

**Honest weight:** most of the 266 lines are rules and prohibitions, not steps
— a ten-section document skeleton, a banned-words list for the plain-English
side, per-language discovery hints, and two blocks of verbatim subagent prompt.
A rewrite at a third the size would probably behave the same.

### docs-twins — 261 lines

**You say:** "update the docs", "refresh the architecture docs", "the docs are
stale", `/docs-twins`.

**What it does.** Exactly what `repo-docs` does — same five steps, same
baseline marker, same templates, large stretches of identical sentences — with
three differences:

- Its path→pair map is a **19-row table hard-coded inside the skill**, naming
  `packages/form-core/`, `digilocker.ts`, `LyikOVSE/`, persona codes `MKR`/`CKR`.
  That is someone else's codebase. `repo-docs` keeps the table in your
  `docs/README.md` instead.
- It assumes `apps/`, `packages/`, pnpm and Turbo, and finishes by running
  `pnpm exec prettier`. In this repo that step fails.
- It has no templates, so it can't bootstrap docs from nothing.

**Verdict: delete.** `repo-docs` is a strict generalisation of it. The only
reason both exist is that `repo-docs` politely refuses to touch repos already
served by `docs-twins`.

### docs-verify — 800 lines (`SKILL.md` 187, `check-claims.py` 458, `self_check.py` 155)

**You say:** "check the docs against the code", "are the docs still true",
"find outdated docs", `/docs-verify`. Options: `report`, `fix`, numbers.

**What it does.** The reverse direction of `repo-docs`: instead of "what code
changed?", it asks of every claim in the docs "does this still exist?".

1. Runs `check-claims.py`, which pulls every single-backticked token out of
   your markdown (skipping code fences), sorts each into a **file path**, a
   **code symbol**, or a **package export**, and calls it stale if the path
   isn't a tracked git file, the symbol appears in no source file, or the export
   is in no `package.json`. It tries a dozen resolution fallbacks first so a
   real-but-differently-written path isn't flagged.
2. Treats that list as suspicion, not verdict — a doc saying "there is no root
   `vitest.config.ts`" is the documentation *working*, and deleting that line
   would be the bug. A ~15-term regex (`no longer`, `removed`, `replaced by`)
   on the finding's line and the line above marks those `deliberate?`.
3. Fans out one subagent per affected doc pair to fix the real misses, then
   re-runs the checker; anything left must be a marked absence.

`self_check.py` is the script's own test: it builds a throwaway git repo in a
temp dir with three citations that must be flagged and fourteen that must stay
quiet, and prints `N/N checks passed`.

**The catch:** the script is hard-wired to a TypeScript monorepo — `packages/`
and `apps/` workspace roots, `.ts`/`.tsx`/`index.ts` fallbacks, `package.json`
exports, a hardcoded false-positive list holding `MKR`, `CKR`,
`PLATFORM_ADMIN`, `ERROR_BAD_REQUEST`. The skill's final verify step runs
prettier. None of that fits this repo.

**Verdict:** the *idea* is the best one in the directory — it is the only skill
with executable code and its own test, and the only one that catches docs
quietly going stale. The *implementation* is for another codebase. Rewrite the
extractor small and language-agnostic (paths only, git-tracked check, ~60 lines)
or drop it until you need it.

---

## Implementation-plan pipeline (three skills, one loop)

`implementation-plan` writes the plan → `review-implementation-plan` edits it
→ `follow-implementation-plan` executes and deletes it. The plan lives in
`docs/implementation-plan/01.md`, `02.md`, … which the first skill adds to
`.gitignore`, so it is scratch paper that never enters history.

Three things surprise people: **the plan deletes itself as it is consumed**,
**agents spawn agents mid-run** without asking, and **files are force-split at
five commits** purely so each chunk fits in one agent's context.

### implementation-plan — 287 lines (`SKILL.md` 130, `template.md` 157)

**You say:** "build the implementation plan", "plan the commits", "the
conversation is done, make the plan", `/implementation-plan`.

- Checks the design conversation is really finished. A question that changes
  *which steps exist* blocks; a question that only changes *how* stays open.
- Reads the chat, everything in `docs/`, `git log -20`, and the repo tree.
- Breaks work into steps where one step = one commit = one concern, reviewable
  in ten minutes. Each step says **what is true when it's done**, never how —
  no invented file names, functions, or libraries unless you already froze them.
- Chunks into `NN.md` files of at most five steps, numbered continuously across
  files (`02.md` starts at step 6). Each file is self-contained for one chat:
  locked decisions, out of scope, commit rules, an index table, and one
  copy-pasteable prompt per step.
- Adds `docs/implementation-plan/` to `.gitignore`, then walks you through the
  plan in chat.

**Writes:** the plan files and one `.gitignore` line. Explicitly forbidden from
planning documentation steps.

### review-implementation-plan — 165 lines

**You say:** "review the plan", "update the plan before implementing",
`/review-implementation-plan`. Intended for a *stronger* model than the planner.

- Reads exactly **one plan file per chat** (context budget), plus neighbouring
  files' index tables only, plus `docs/`, plus `git log -20`.
- Works a fixed ten-item challenge list — wrong step size, wrong order, missing
  outcome, over-specified how, false lock, contradiction with `docs/`,
  recipe-style prompts, unexecutable protocol, documentation steps (deleted),
  files over five steps (re-chunked) — and edits the file in place.
- Won't substitute its own preferred approach, won't unlock a decision it
  merely disagrees with, preserves the numbers of steps already in `git log`.
- Ends with Changelog / Still open / Ready / Next file, then a hard stop: do
  not start step 1, do not offer to.

**Honest weight:** items 1–7 of the challenge list restate rules the planner was
already given. Its value is a second pair of eyes, not new rules.

### follow-implementation-plan — 169 lines

**You say:** "implement the plan", "execute the plan", "next step",
`/follow-implementation-plan`. Having written or reviewed the plan earlier in
the same chat is explicitly **not** permission.

- Picks the first plan file with a commit subject missing from `git log`, reads
  only that file, finds the next unfinished step.
- Implements that one step, choosing its own approach unless the plan locked it.
- Treats the plan's typecheck/lint/test commands as gates on *this step only* —
  a command already failing at the parent commit with the same errors is not a
  stop, and it's forbidden from pausing to fix unrelated baseline breakage.
- Stages only that step's files and **calls the `commit` skill** with the plan's
  exact subject. It never runs `git commit` itself.
- Emits a `report-arc`-shaped report, then takes the next step without waiting.
- When a file's last commit lands it **deletes the file** and, if more remain,
  **spawns a brand-new agent with empty history** to continue, then stops.

**Note the duplication:** the execution protocol is copied verbatim into every
plan file by `template.md`, so it lives in two places that must stay in sync.

---

## Commit

### commit — 111 lines

**You say:** "commit", "commit this", `/commit`.

- Checks `git config user.name`/`user.email`; missing → stops and prints the
  command for you to run.
- **Never stages.** Empty index → it stops, shows `git status --short`, asks you
  to stage.
- Reads the full staged diff, writes the message, runs
  `git commit -m subject -m bullets`.
- Format: `type(scope): imperative summary`, ≤72 chars, no trailing period;
  blank line; 1–6 `- ` bullets, ≤80 chars each, saying *why* not restating the
  diff. Scope is the top-level directory (`zsh`, `tmux`, `ohmypi`), dropped for
  repo-wide changes. `docs` only when *every* changed file is prose.
- Refuses all AI attribution: no `Co-Authored-By`, no "Generated with", no robot
  emoji. Verifies afterwards with `git log -1` and a grep leak check.
- A failing pre-commit hook is a hard stop — never `--no-verify`.

**Callers:** `follow-implementation-plan` and `implementation-plan/template.md`
both say "commit through the commit skill". Deleting this breaks them.

**Verdict: keep.** Cheapest, most-used skill here.

### `ohmypi/agents/committer.md` — 97 lines (an agent, not a skill)

Steps 1–5 of the commit skill, copy-pasted nearly word for word, with
frontmatter pinning `model: ollama-cloud/glm-5.3-flash` and `tools: bash`. It
exists for cost, not behaviour — it doesn't call the commit skill, it duplicates
it, and the copies have already drifted (the agent's banned-trailer list dropped
"Gemini"; it also lost the skill's edge-cases section).

**Verdict:** pick one. Either delete the agent, or shrink it to three lines that
say "follow the commit skill".

### implement-commit-prompt — 163 lines

**You say:** "give me a prompt to implement commit N", "copy pastable prompt",
`/implement-commit-prompt`.

Reads `docs/` and the plan, works out which commit you mean (asks rather than
guesses), checks the previous plan commit actually landed, asks blocking
questions, then prints three things: a plain-English summary, a precise "what's
in the prompt", and one fenced block holding the prompt. Writes nothing,
implements nothing, commits nothing.

**Verdict: delete.** `implementation-plan`'s template already bakes a
copy-pasteable prompt into every step, and the skill itself admits it reuses
that fence verbatim when it exists. It is a formatter around text that already
exists.

---

## Standalone

### report-arc — 96 lines (`SKILL.md` 46, `template.md` 26, `doc-template.md` 24)

**You say:** it fires automatically after a plan step; or you paste a report and
say "document this report", `/report-arc`.

Two outputs, easy to confuse:

- A **step report** is a chat message, never a file: one-line status, the step
  subject and commit sha, a "Done when | State" table copied from the plan,
  what changed, what was left unstaged, what was verified (including whether
  the build gate got worse than the parent commit), and the next step. Unknown
  cells must say "unknown" rather than guess, and it may not end with "your
  call, what next?".
- A **durable report page** is that content saved to `docs/reports/<slug>.md`,
  strictly from the report — no new claims, no guessed file lists. Asks before
  overwriting.

**Verdict:** smallest skill in the directory and mostly template. It only exists
separately so several skills can point at one format. Keep it if you keep the
plan pipeline; it's dead weight without it.

### paper-target — 115 lines

**You say:** "use this Paper file", "set the Paper target", "which Paper file
are we using", `/paper-target`. Arguments: `file=`, `page=`, `show`, `clear`.

Paper (paper.design) is a design tool like Figma; a *file* is one design
document, a *page* is one canvas tab in it. The agent can only see Paper through
the **Paper Desktop MCP server** (configured in `ohmypi/mcp.json` as
`${HOME}/.paper/bin/paper mcp`). No Paper Desktop, no skill — there is no
fallback.

It resolves the file by id, URL, or name (asking when zero or several match),
resolves the page as best it can — the MCP server **cannot list pages**, so it
may ask you to switch pages in Paper by hand, and will write `pageId: UNKNOWN`
rather than invent one — then writes a block fenced by
`<!-- paper-target:start -->` into `AGENTS.md` and `CLAUDE.md` at the git root,
touching no other line. It is read-only toward Paper: no `write_html`, no
`update_styles`.

**Verdict: delete for now.** It says it exists to serve `paper-design` and
`paper-implement`. Neither of those skills is in this repo, so today it writes a
note that nothing reads.

### twitter-campaign — 455 lines (`SKILL.md` 275, `template.md` 180)

**You say:** "twitter campaign", "tweet plan", "launch campaign", "devrel",
`/twitter-campaign`. Argument: `full` to rewrite from scratch.

**Blunt scope note: this is not a coding skill.** It reads no source for
correctness, changes no code, runs nothing, fixes nothing. It is a marketing
copywriter that uses `git log` as research.

- On first run it asks up to four setup questions (launch vs adoption vs
  waitlist; personal or product account; the call to action; which subreddits),
  then reads README, `docs/`, CHANGELOG, manifests, first and last 20 commits.
- Produces one file containing 8–12 tweets with ready-to-paste copy and a
  `Chars: N / 280` count, 2–4 long-form Reddit posts, a posting order, a
  cadence, an asset map, and a checklist of screenshots you still have to take.
- On later runs it is incremental: reads a `twitter-campaign-baseline: <sha>`
  marker out of the file and only writes posts for changes since then.
- Never posts, never commits.

**Writes:** `docs/twitter-campaign.md`.

**Verdict:** keep only if you actually run launches. Note its incremental engine
is a third hand-maintained copy of the same stored-sha pattern used by
`repo-docs` and `docs-twins`.

---

## Cross-cutting things worth knowing before you rebuild

1. **One pattern is written three times.** `repo-docs`, `docs-twins` and
   `twitter-campaign` each carry their own copy of: read a baseline sha out of
   the generated file, `git diff --name-only <sha>..HEAD` excluding lockfiles,
   bootstrap/incremental/full modes, stamp the sha only on success. If you
   rebuild, write that once.
2. **Four skills call each other by name.** `follow-implementation-plan` →
   `commit` and `report-arc`; `implementation-plan/template.md` → `commit`;
   `docs-verify` → the pair scheme of `docs-twins`. Delete a callee and the
   caller silently breaks.
3. **Most of the bulk is prohibitions, not procedure.** `review-implementation-plan`
   is a 10-point rubric plus a 9-item "don't"; `follow-implementation-plan` ends
   in a 17-bullet "Never" list. That is a real signal: each rule was probably
   added after a model did the wrong thing once. Re-adding a skill from scratch
   means re-earning those rules the hard way — worth skimming the old file
   before you rewrite it.
4. **`ohmypi/RULES.md` (94 lines) is not a skill** and is loaded every session:
   no app restarts, no dev servers, no browser, no unasked investigation, no
   `planner`/`hand` subagents, **no documents unless a document-writing skill
   was invoked**, and never amend — a correction is always a new commit. Rule 6
   names five skills as document-writers (`repo-docs`, `docs-twins`,
   `docs-verify`, `design-sync`, `twitter-campaign`); `design-sync` doesn't
   exist either, so that list needs editing whenever you change the skill set.
5. **`AGENTS.md` at the repo root lists the skills.** It will be wrong the
   moment you delete any of them.
