---
name: blueprint
description: After requirements and stack are settled, write docs/blueprint.html — one self-contained page that links the official docs of every stack choice and the component library, lists the install and setup steps, proposes the project structure, and breaks the build into chunks that can become issues, with the review steps that lead to design and raise-issues. Use when the user wants to see how the settled documents turn into a build before designing.
disable-model-invocation: true
---

# blueprint

Turn `docs/requirements.md` and `docs/stack.md` into one page the user reads
before design: what the project is built with (linked to the official docs),
what to install and set up, how the project is laid out, and the build cut
into chunks that `raise-issues` turns into issues. The user reviews it, then
gives the design direction to `/skill:design`.

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
- Use scripts, external CSS, web fonts, images or trackers in the page. It
  is static HTML that opens from disk.

## Step 1 — readiness

Print one line per check, `ready` or `not ready: <what> — run <command>`:

| # | Check | Fix |
| --- | --- | --- |
| 1 | `docs/requirements.md` exists | `/skill:draft-docs requirements`, then `/skill:grill-requirements` |
| 2 | `docs/stack.md` exists | `/skill:draft-docs stack`, then `/skill:grill-stack` |
| 3 | `docs/requirements-questions.md` and `docs/stack-questions.md` have no unanswered question | finish the grill that owns it |

Any `not ready` stops the run. Print each `Open questions` item in the
requirements and each `Decisions for you` item in the stack as a `warning:`
line; the chunks that depend on one say `waits on` it.

## Step 2 — gather

1. Read `docs/requirements.md`, `docs/stack.md`, `docs/codebase-map.md`
   when present, the manifests and the repository tree. Whatever the
   repository already has is `done`, not a step.
2. For each stack choice, open its official documentation and take: the
   getting-started or installation page for the framework the project uses,
   and the reference page a developer will need most. For the component
   library also take its theming page. Confirm each page covers the version
   in `docs/stack.md`; record the date checked. At most three links per
   choice.
3. Take every setup command from those pages, not from memory: create the
   project, add each dependency, initialise the component library,
   environment variables, and the accounts or keys the stack names (the
   user creates these by hand).
4. Take the project layout from the framework's documented conventions,
   adding only what the chunks need.

## Step 3 — chunk the build

Cut the requirements into the chunks a careful author would build, in
order. The rules are `raise-issues`' slicing rules, so its issues follow
the chunks:

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

Every requirement line ends up in exactly one chunk, or under `Gaps` with
its reason.

## Step 4 — write `docs/blueprint.html`

Replace any earlier page. One file, sections in this order, each with an
`id` so the table of contents links to it:

| Section | `id` | Content |
| --- | --- | --- |
| Header | — | Project name, `Updated: YYYY-MM-DD`, links to `requirements.md` and `stack.md` (relative, same folder) |
| Contents | `contents` | Links to every section below |
| Stack | `stack` | Table: area, choice and version, origin (from `docs/stack.md`), what it serves, official doc links with the date checked |
| Component library | `components` | The library, how it is installed and themed, links; or the `Gaps` entry when the stack has none and the app has a UI |
| Setup | `setup` | Numbered steps, each with its command in `<pre><code>`, the doc it came from, and `done` when the repository already has it; manual steps marked `by hand` |
| Project structure | `structure` | A `<pre>` tree; each entry one short note and the chunk that creates it; the framework's convention doc linked |
| Chunks | `chunks` | One `<section id="C<n>">` per chunk: title, `Covers` (requirement lines quoted), `Depends on` (links to chunk ids), `Waits on` (deferred item, when any), `Issue candidates` (list), `Screens` (the screens it implies, by name) |
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

## Reply

Reply with the path, the number of stack links, setup steps (and how many
are `done` or `by hand`), chunks, issue candidates and gaps, and the next
command: the first gap's command, or `/skill:design <direction>` when there
is none. Do not repeat the page in chat.
