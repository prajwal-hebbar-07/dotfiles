---
name: blueprint
description: After requirements and stack are settled, write docs/blueprint.html — one self-contained page that links the official docs of every stack choice and the component library, lists the install and setup steps, proposes the project structure, and breaks the build into chunks that can become issues, with the review steps that lead to design and raise-issues. An Opus 5.5 orchestrator fans the doc research and chunk drafting out to parallel Sonnet 5.5 workers, or GPT 6.1 Sol and Terra when either is unavailable or hits a limit. Use when the user wants to see how the settled documents turn into a build before designing.
disable-model-invocation: true
---

# blueprint

Turn `docs/requirements.md` and `docs/stack.md` into one page the user reads
before design: what the project is built with (linked to the official docs),
what to install and set up, how the project is laid out, and the build cut
into chunks that `raise-issues` turns into issues. The user reviews it, then
gives the design direction to `/skill:design`.

The parent session checks readiness and writes the file. A pinned
orchestrator does the rest: it reads the settled documents, sends the doc
research and then the chunk drafting to parallel workers, cuts and checks
the build order itself, and returns the page.

Invoke explicitly:

- `/skill:blueprint [focus]` — write or rewrite `docs/blueprint.html`.
- `/skill:blueprint <change>` — revise the existing page.

New apps only. A feature on an existing app skips this step: its stack is
already set, and `feature` goes from the spec to design and issues.

## Never

- Do only what the request needs. Add no technology, setup step, directory,
  chunk or issue candidate the requirements and stack do not call for. A
  useful extra is named under `Not included`, not planned.
- Never ask what is already settled: read the requirements, the stack, an
  existing `docs/blueprint.html`, `docs/codebase-map.md`, manifests and the
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
  except `docs/blueprint.html`.
- Let the parent session gather, chunk or compose the page itself, use an
  agent outside the pairs below, mix pairs, or continue silently when a
  pinned agent fails.
- Use scripts, external CSS, web fonts, images or trackers in the page. It
  is static HTML that opens from disk.

## Specialists

Use only these OMP task agents.

Primary pair:

- `blueprint-opus-orchestrator` — `anthropic/claude-opus-5-5`, high
  thinking. Runs Steps 2–4, spawns the workers, owns the cut, the checks
  and the page.
- `blueprint-sonnet-worker` — `anthropic/claude-sonnet-5-5`, medium
  thinking. Researches one slice of the stack docs or drafts the chunks it
  is given. Only the orchestrator spawns it.

Authorised fallback pair:

- `blueprint-sol-orchestrator` — `openai-codex/gpt-6.1-sol`, high thinking.
- `blueprint-terra-worker` — `openai-codex/gpt-6.1-terra`, medium thinking.

The parent spawns the primary orchestrator unless the user asks for the
fallback pair. If the orchestrator fails (including a rate limit or quota
error), is unavailable, reports a model other than its pin, or returns
`PAIR FAILED` because a worker did, name the failure and rerun Steps 2–4
from the start with the fallback orchestrator; nothing has been written, so
nothing carries over. Never mix pairs or use output from the superseded
pair. If the fallback pair fails the same way, stop and name it. No other
fallback is authorised.

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
   `docs/blueprint.html` (for `<change>`: keep everything the change does
   not touch, and send workers only what it does), `docs/codebase-map.md`
   when present, the manifests and the repository tree. Whatever the
   repository already has is `done`, not a step.
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
- Covers: "<requirement line, exact>" — <requirements.md section>
- Issue candidate: <pull-request-sized piece> — <the Covers lines it builds>
- Screen: <name>
- Creates: <path in the project structure>
- By hand: <manual step this chunk needs>
- Problems: <line that belongs elsewhere, vague line, missing stack choice — with the command that settles it>
```

The orchestrator then settles every `Problems` entry (moves the line, or
records a `Gaps` entry naming its command) and checks that every requirement
line ends up in exactly one chunk, or under `Gaps` with its reason.

## Step 4 — compose the page

The orchestrator composes the whole page and returns it as its agent file
specifies. One file, sections in this order, each with an `id` so the
table of contents links to it:

| Section | `id` | Content |
| --- | --- | --- |
| Header | — | Project name, `Updated: YYYY-MM-DD`, links to `requirements.md` and `stack.md` (relative, same folder) |
| Contents | `contents` | Links to every section below |
| Stack | `stack` | Table: area, choice and version, origin (from `docs/stack.md`), what it serves, official doc links with the date checked |
| Component library | `components` | The library, how it is installed and themed, links; or the `Gaps` entry when the stack has none and the app has a UI |
| Setup | `setup` | Numbered steps, each with its command in `<pre><code>`, the doc it came from, and `done` when the repository already has it; manual steps marked `by hand` |
| Project structure | `structure` | A `<pre>` tree; each entry one short note and the chunk that creates it; the framework's convention doc linked |
| Chunks | `chunks` | One `<section id="C<n>">` per chunk: title, `Covers` (requirement lines quoted), `Depends on` (links to chunk ids), `Decide when implementing` (deferred item, when any), `Issue candidates` (list), `Screens` (the screens it implies, by name) |
| Gaps | `gaps` | What blocks a chunk, each with the command that settles it |
| Not included | `not-included` | Useful extras left out, one line each |
| Next steps | `next` | The review checklist below, as a list |

The `Next steps` list, in this order:

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

Markup: semantic HTML (`header`, `nav`, `main`, `section`, `table`), one
short inline `<style>` (system font, readable line length, light and dark
through `prefers-color-scheme`), external links with `rel="noreferrer"`.
No script.

## Step 5 — write `docs/blueprint.html`

The parent takes the orchestrator's page from `<!doctype html>` to
`</html>` (reading the full `agent://<id>` output when the inline result is
a preview) and writes it to `docs/blueprint.html`, replacing any earlier
page. It changes nothing in the page.

## Reply

Reply with the path, the pair that ran (and the failure that switched it,
when it did), the number of stack links, setup steps (and how many are
`done` or `by hand`), chunks, issue candidates and gaps, and the next
command: the first gap's command, or `/skill:design <direction>` when there
is none. Do not repeat the page in chat.
