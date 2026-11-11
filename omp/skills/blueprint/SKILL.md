---
name: blueprint
description: After requirements and stack are settled, write docs/blueprint/ — five short linked HTML pages (overview, stack, setup, structure, build) that a senior engineer reads in 15–30 minutes, led by inline SVG diagrams and one shared colour code — linking the official docs of every stack choice, listing the setup steps with their commands, proposing the project structure and cutting the build into chunks that become issues, with the review steps that lead to design and raise-issues. MiniMax M3.1 Flash workers research the docs and draft the chunks in parallel; a GPT 6.1 Sol orchestrator does the heavy part (the cut, the checks and the pages). Use when the user wants to see how the settled documents turn into a build before designing.
disable-model-invocation: true
---

# blueprint

Turn `docs/requirements.md` and `docs/stack.md` into a short set of pages
the user reads before design: what the project is built with (linked to
the official docs), what to install and set up, how the project is laid
out, and the build cut into chunks that `raise-issues` turns into issues.
The reader is a senior engineer with 15–30 minutes: every page opens with a
diagram, colour means the same thing on every page, and detail stays
folded until asked for. The user reviews it, then gives the design
direction to `/skill:design`.

The parent session checks readiness and writes the files. A pinned
orchestrator does the rest: it reads the settled documents, sends the doc
research and then the chunk drafting to parallel workers, cuts and checks
the build order itself, and returns the pages.

Invoke explicitly:

- `/skill:blueprint [focus]` — write or rewrite `docs/blueprint/`.
- `/skill:blueprint <change>` — revise the existing pages.

New apps only. A feature on an existing app skips this step: its stack is
already set, and `feature` goes from the spec to design and issues.

## Never

- Do only what the request needs. Add no technology, setup step, directory,
  chunk or issue candidate the requirements and stack do not call for. A
  useful extra is named under `Not included`, not planned.
- Never ask what is already settled: read the requirements, the stack, an
  existing `docs/blueprint/`, `docs/codebase-map.md`, manifests and the
  repository first. There is nothing to ask the user; a gap goes to its grill.
- Choose, swap or add a technology. A choice the build needs that
  `docs/stack.md` lacks (a component library when the requirements have a
  UI, a host, an auth provider) is a `Gaps` entry naming
  `/skill:grill-stack`, not a pick.
- Invent behaviour. A chunk covers requirement lines as written; a vague
  line is a `Gaps` entry naming `/skill:grill-requirements`.
- Link a page you have not opened in this run, a secondary source when the
  official docs cover the point, or docs for a version other than the one in
  `docs/stack.md`.
- Install, scaffold, run anything, raise issues, commit, or write any file
  outside `docs/blueprint/`.
- Let the parent session gather, chunk or compose the pages itself, use an
  agent other than the two below, or continue silently when a pinned agent
  fails.
- Use scripts, web fonts, image files, a CDN, trackers, `<style>` blocks,
  `style` attributes or any stylesheet other than the shared `style.css`.
  The pages are static HTML that open from disk; diagrams are inline SVG.
- Write a wall of text: a page over its reading budget in
  `skill://blueprint/page.md`, prose before a page's first diagram, or a
  fact repeated on two pages.

## Specialists

Use only these OMP task agents. MiniMax M3.1 Flash does everything except
the heavy part (the cut, the checks, the diagrams and the pages), which
GPT 6.1 Sol does.

- `blueprint-sol-orchestrator` — `openai-codex/gpt-6.1-sol`, high
  thinking. Runs Steps 2–4, spawns the workers, owns the cut, the checks
  and the pages.
- `blueprint-flash-worker` — `ollama-cloud/minimax-m3.1-flash`, medium
  thinking. Researches one slice of the stack docs or drafts the chunks it
  is given. Only the orchestrator spawns it.

No fallback is authorised. If the orchestrator fails (including a rate
limit or quota error), is unavailable, reports a model other than its pin,
or returns `PAIR FAILED` because a worker did, stop and name the failure;
nothing has been written, and the user reruns `/skill:blueprint` later.

Spawn each agent by its name and never pass a per-call `model`; each agent
file pins its model and reports its identity first. The orchestrator
spawns workers from its own nesting level, so `task.maxRecursionDepth`
must stay at its default `2` or higher.

## Step 1 — readiness

Print one line per check, `ready` or `not ready: <what> — run <command>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `docs/requirements.md` exists | `/skill:draft-docs requirements`, then `/skill:grill-requirements` |
| 2 | `docs/stack.md` exists | `/skill:draft-docs stack`, then `/skill:grill-stack` |
| 3 | Both have `Status: Settled`: their grills closed with nothing the user neither answered nor deferred. A file without a `Status:` line is not settled | rerun the grill that owns it; it resumes from the file |

Any `not ready` stops the run and names each `Unresolved` item. Print each
`Open questions` item in the requirements and each `Decisions for you` item
in the stack as a `warning:` line: the user deferred it to implementation,
and the chunks that depend on one name it under `Decide when implementing`.

## Step 2 — orchestrate: gather

The parent spawns the orchestrator with the invocation (focus or change),
the readiness warnings and the date. Steps 2–4 are the orchestrator's.

1. Read `docs/requirements.md`, `docs/stack.md`, an existing
   `docs/blueprint/` (for `<change>`: keep everything the change does not
   touch, and send workers only what it does), `docs/codebase-map.md` when
   present, the manifests and the repository tree. Whatever the repository
   already has is `done`, not a step.
2. **Docs wave.** One parallel batch of `docs` workers, at most eight; one
   per stack choice, related choices grouped (one ecosystem, one worker) when
   there are more. Each task gives the choices with the versions from
   `docs/stack.md` and asks, per choice, for: the getting-started or
   installation page for the framework the project uses, the reference page
   a developer will need most, and for the component library its theming
   page (at most three links, each confirmed to cover the version, with the
   date checked); every setup command taken from those pages, not from
   memory (create the project, add each dependency, initialise the
   component library, environment variables); the accounts or keys the
   user creates by hand; and, for the framework, its documented project
   layout. Return format, per choice:

   ```text
   ### <area>: <choice> <version>
   - Link: <title> — <URL> — covers <version>, checked YYYY-MM-DD
   - Setup: <command> — <URL>
   - By hand: <account, key or variable> — <URL>
   - Layout: <convention, framework only> — <URL>
   - Problems: <page missing, version not covered, conflict with the stack>
   ```

3. The orchestrator orders the setup steps, marks `done` against the
   repository, and takes the project layout from the framework's documented
   conventions, adding only what the chunks need.

## Step 3 — chunk the build

The orchestrator cuts the requirements into the chunks a careful author
would build, in order; the workers only fill them in. The rules are
`raise-issues`' slicing rules, so its issues follow the chunks:

1. **C0 setup.** The setup steps plus a walking skeleton: runtime,
   framework, datastore and host wired end to end with one trivial path.
   Every other chunk depends on it. Skip it when the repository already
   runs.
2. **Vertical chunks.** One per user-observable capability, cut through
   data, logic and interface, so each can be shown and tested alone. Never
   one chunk per layer.
3. **Shared work first.** Code several chunks need is its own chunk before
   them.
4. **Issue candidates.** Each chunk lists the pull-request-sized pieces it
   splits into; small chunks are one candidate.
5. **Not issue material.** Work the user does by hand (accounts, keys,
   domains, store listings) is listed under the step that needs it, never
   as a candidate.

**Chunk wave.** One parallel batch of `chunks` workers, at most eight; one
per chunk, neighbouring chunks grouped when there are more. Each task gives
the chunk's id, title, the requirement lines assigned to it (quoted), its
dependencies, any `Decide when implementing` item, and the stack choices
and setup steps it uses. Return format, per chunk:

```text
### C<n> <title>
- Summary: <one sentence, at most 20 words: what a person can do once this chunk ships, in the requirements' words>
- Covers: "<requirement line, exact>" — <requirements.md section>
- Issue candidate: <pull-request-sized piece, at most 10 words> — <the Covers lines it builds>
- Screen: <name>
- Creates: <path in the project structure>
- By hand: <manual step this chunk needs>
- Problems: <line that belongs elsewhere, vague line, missing stack choice — with the command that settles it>
```

The orchestrator then settles every `Problems` entry (moves the line, or
records a `Gaps` entry naming its command) and checks that every requirement
line ends up in exactly one chunk, or under `Gaps` with its reason.

## Step 4 — compose the pages

The orchestrator reads `skill://blueprint/page.md` and composes the five
pages it defines, in its skeleton, components, colour code and diagrams,
within its reading budgets. The content each page carries:

| Page | Content |
| --- | --- |
| `index.html` | Project name and one-line goal; stats (chunks, issues, setup steps with `by hand` count, gaps, deferred decisions); the system map and the build map; `Before you continue` (each gap, the command that settles it, the chunks it blocks); `Decide when implementing` (each deferred item, the user's words, the chunks that need it); the next steps below; the pages with their read times; `Not included` folded in `<details>` |
| `stack.html` | One card per stack choice: area, choice and version, origin badge from `docs/stack.md`, what it serves, up to three official doc links with the date checked; the component library, how it is installed and themed, or the `Gaps` entry when the stack has none and the app has a UI |
| `setup.html` | Numbered steps, each a short title, its command in `<pre><code>`, the doc it came from, and `done` when the repository already has it or `by hand` for manual steps; a table of environment variables with where each comes from |
| `structure.html` | A `<pre>` tree; each entry one short note and the chunk pill that creates it; the framework's convention doc linked |
| `build.html` | Per chunk in build order: `C<n>`, title, summary, `Depends on` (links), issue candidates, screens, `Decide when implementing` when any, its gap when blocked, and its `Covers` lines quoted in `<details>` |

The next steps, in this order, as `ol.steps`:

1. Check each chunk's `Covers` against the requirements and the order of
   the chunks; ask for changes with `/skill:blueprint <change>`.
2. Settle every `Gaps` entry with the command it names, then rerun
   `/skill:blueprint`.
3. Decide the design direction (a product to start from, how it should
   feel), then run `/skill:design <direction>`: wireframes first, then the
   Paper design.
4. After the design is approved, run `/skill:raise-issues`; it uses these
   chunks as the build order.
5. Work each issue with `/skill:issue-branch <URL>`, give the architecture
   for it, then `/skill:implement <URL>` or `/skill:work <URL>`.

Before returning, the orchestrator checks each page: it opens with its
diagram, its read time is within budget, every diagram follows
`page.md`'s diagram rules (unique marker ids, no colour attributes, at
most 12 nodes, labels within length), every internal link has its target
id, and every requirement line still appears on `build.html` or under a
gap. External links carry `rel="noreferrer"`.

## Step 5 — write `docs/blueprint/`

The parent reads the orchestrator's full output (`agent://<id>` when the
inline result is a preview), writes each page from its `=== <path> ===`
marker to the next into `docs/blueprint/`, and copies
`skill://blueprint/style.css` there unchanged. It changes nothing in the
pages. It deletes a page in `docs/blueprint/` the new set no longer has,
and an old single-page `docs/blueprint.html` from an earlier version of
this skill.

## Reply

Reply with the path `docs/blueprint/index.html`, each page with its read time
and the total, the number of stack links, setup steps (and how many are
`done` or `by hand`), chunks, issue candidates and gaps, and the next
command: the first gap's command, or `/skill:design <direction>` when there
is none. Do not repeat the pages in chat.
