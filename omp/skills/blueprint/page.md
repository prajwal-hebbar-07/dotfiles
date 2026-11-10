# Blueprint pages

How the orchestrator composes `docs/blueprint/`. The reader is a senior
engineer who wants the whole picture in 15–30 minutes: diagrams first,
short pages, colour that means the same thing everywhere, detail folded
away until asked for.

## Page set

| File | Page | Opens with | Then | Budget |
| --- | --- | --- | --- | --- |
| `index.html` | Overview | System map, build map | Stats, `Before you continue`, `Decide when implementing`, next steps, page list, `Not included` | 5 min |
| `stack.html` | Stack | Stack layers | One card per choice, grouped by layer; the component library | 5 min |
| `setup.html` | Setup | Setup strip | Numbered steps with commands; environment variables | 5 min |
| `structure.html` | Structure | Folder map | The project tree, each entry tagged with its chunk | 3 min |
| `build.html` | Build | Build map | Size chart, then one card per chunk in build order | 10 min |

The set is at most 28 minutes. Read time is the visible words outside
`<pre>`, folded `<details>` bodies and SVG, at 200 words a minute, plus one
minute per diagram, rounded up. Each page shows it in `.readtime`
(`6 min read`) and the overview lists every page's time. A page over budget
is shortened: tighter wording, detail moved into `<details>`. Never drop a
requirement line, chunk, issue candidate, step, link or gap to fit.

## Writing

- Every page starts the same way: `h1`, `.readtime`, a `.tldr` box with at
  most three bullets saying what the page tells, then its first diagram.
  Prose comes after the picture, never before.
- Cards, lists, tables and badges over paragraphs. No paragraph over three
  sentences; no sentence over 20 words.
- Each fact lives on one page; others link to it (`build.html#C3`,
  `setup.html#step-4`). The overview summarises and links, it does not
  repeat.
- Requirement lines are quoted only inside `<details>`, never as running
  text.
- Plain words. No marketing, no restating the requirements in prose, no
  "this page describes".

## Colour code

`style.css` defines every colour; pages use its classes only. One meaning
per colour on every page, and every coloured thing also carries its
meaning in text (badge text, a legend), never colour alone.

| Kind | Classes | Meaning |
| --- | --- | --- |
| Layer | `ui` `app` `data` `ext` `role` | Interface, application, data, outside service, person or role |
| State | `done` `ready` `hand` `decide` `gap` | Already in the repository, to build, by hand, decide when implementing, blocked by a gap |
| Origin | `user-chosen` `existing` `fixed` `default` `candidate` | The `Origin` field in `docs/stack.md` |

A chunk's state is `done` when the repository already does it, `gap` when a
`Gaps` entry blocks it, `decide` when it has a `Decide when implementing`
item, else `ready`. A setup step is `done`, `hand` or plain.

## Page skeleton

Every page uses this frame; only `main` changes. `aria-current="page"`
marks the page being read.

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Build · Acme blueprint</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<header class="top"><div class="top-inner">
  <span class="project">Acme</span>
  <nav class="pages" aria-label="Blueprint pages">
    <a href="index.html">Overview</a>
    <a href="stack.html">Stack</a>
    <a href="setup.html">Setup</a>
    <a href="structure.html">Structure</a>
    <a href="build.html" aria-current="page">Build</a>
  </nav>
</div></header>
<main>
  <h1>Build</h1>
  <span class="readtime">8 min read</span>
  <div class="tldr"><strong>In short</strong>
    <ul><li>6 chunks, 14 issues, in this order.</li></ul>
  </div>
  <!-- first diagram, then the page's sections -->
</main>
<footer>Updated YYYY-MM-DD · From <a href="../requirements.md">requirements.md</a>
  and <a href="../stack.md">stack.md</a></footer>
</body>
</html>
```

## Components

Stats (overview), one `.stat` per count; `gap` and `decide` stats take
their class when non-zero:

```html
<div class="stats">
  <div class="stat"><span class="value">6</span><span class="label">chunks</span></div>
  <div class="stat"><span class="value">14</span><span class="label">issues</span></div>
  <div class="stat gap"><span class="value">1</span><span class="label">gaps</span></div>
</div>
```

Stack card (stack page), inside `.grid`, class by layer:

```html
<article class="card ui" id="stack-framework">
  <div class="card-head"><span class="area">Framework</span>
    <span class="badge user-chosen">User-chosen</span></div>
  <h3>Next.js 15.2</h3>
  <p>Serves: the member web app.</p>
  <ul><li><a href="https://nextjs.org/docs/app/getting-started/installation" rel="noreferrer">Installation</a>
    <span class="checked">checked YYYY-MM-DD</span></li></ul>
</article>
```

Setup step (setup page), inside `ol.steps`, class by state:

```html
<li class="hand" id="step-2">
  <h3>Create the database project <span class="badge hand">by hand</span></h3>
  <p>Sign up and copy the connection string into <code>DATABASE_URL</code>.</p>
  <p class="checked">From <a href="https://…" rel="noreferrer">Getting started</a></p>
</li>
```

Chunk card (build page), class by state:

```html
<section class="card decide" id="C2">
  <div class="card-head"><span class="pill chunk">C2</span><h3>Sign in</h3>
    <span class="pill">3 issues</span>
    <span class="badge decide">decide when implementing</span></div>
  <p>Members sign in with email and land on their dashboard.</p>
  <p><span class="field">Depends on</span> <a class="pill chunk" href="#C1">C1</a></p>
  <p><span class="field">Issue candidates</span></p>
  <ul><li>Email sign-in with session cookie</li></ul>
  <p><span class="field">Screens</span> <span class="pill">Sign in</span></p>
  <div class="callout decide"><h3>Decide when implementing</h3>
    <ul><li>Session length — "not sure, decide later" (requirements, Open questions)</li></ul></div>
  <details><summary>Requirement lines (4)</summary>
    <blockquote>"Members must sign in with email." (Requirements)</blockquote></details>
</section>
```

Callouts: `.callout.gap` for `Before you continue` (each gap with the
command that settles it, linked to the chunks it blocks) and
`.callout.decide` for deferred decisions (each with the user's words and
the chunks that need it). Omit a callout that would be empty.

## Diagrams

Inline SVG only, inside `figure.diagram` with a `figcaption` (one sentence:
how to read it) and a `.legend` of badges for every class the diagram uses.

- `<svg viewBox="0 0 W H" role="img" aria-labelledby="…">` with a `<title>`;
  `W` at most 960. No `width`/`height`, `fill`, `stroke` or `style`
  attributes: classes from `style.css` colour everything.
- Grid layout: node `rect` 160×48 with `rx="8"`, columns 200 apart (40 gap),
  rows 72 apart. The label sits at the node's centre, 8 above it when a
  `.sub` line sits 8 below. Labels at most 20 characters, sub lines at most
  24; abbreviate rather than overflow.
- Edges are `path.edge` from the right middle of one node to the left
  middle of the next, straight or with one elbow, never crossing a node,
  ending in a marker whose `id` is unique on the page (`arrow-<diagram>`).
  Edge labels (`text.edge-label`) at most three words.
- At most 12 nodes per diagram. More: split by phase or lane into several
  diagrams.
- A node that has a target on another page or section is wrapped in
  `<a href="…">`.
- Draw only what the documents name. No component, service, arrow or
  dependency the requirements and stack do not state or a stack choice
  imply (the app reads and writes its datastore). Architecture inside the
  app is the user's per issue; no diagram proposes it.

Example node, edge and marker:

```html
<figure class="diagram">
  <svg viewBox="0 0 400 100" role="img" aria-labelledby="sys-title">
    <title id="sys-title">System map</title>
    <defs><marker id="arrow-sys" viewBox="0 0 10 10" refX="9" refY="5"
      markerWidth="8" markerHeight="8" orient="auto-start-reverse">
      <path class="arrowhead" d="M0 0 L10 5 L0 10 z"/></marker></defs>
    <g class="node role"><rect x="20" y="26" width="160" height="48" rx="8"/>
      <text x="100" y="42">Member</text><text class="sub" x="100" y="58">posts, comments</text></g>
    <path class="edge" d="M180 50 H220" marker-end="url(#arrow-sys)"/>
    <text class="edge-label" x="200" y="42">uses</text>
    <a href="stack.html#stack-framework"><g class="node ui"><rect x="220" y="26" width="160" height="48" rx="8"/>
      <text x="300" y="42">Web app</text><text class="sub" x="300" y="58">Next.js 15.2</text></g></a>
  </svg>
  <figcaption>Who uses the app and what it talks to, left to right.</figcaption>
  <div class="legend"><span class="badge role">Person</span><span class="badge ui">Interface</span></div>
</figure>
```

Lanes (`rect.lane` with a `text.lane-label` at the top) group columns or
rows; bars are `rect.bar` (class by state) with a `text.bar-label`.

The six diagrams:

1. **System map** (overview). Lanes left to right: People (`role`),
   Interface (`ui`), Application (`app`), Data (`data`), Outside services
   (`ext`). Nodes: the roles in the requirements, the stack choices that
   run the app, and the outside systems the requirements name. Each edge is
   an interaction the requirements state, labelled.
2. **Build map** (overview; again in full on the build page). One node per
   chunk, `C<n>` and a short title, sub line `n issues`; column = the
   chunk's dependency depth; an arrow from each dependency to its
   dependent; class by chunk state; each node links to `build.html#C<n>`.
   Over 12 chunks: the overview shows one node per column (`Phase 1: C1–C3`)
   and the build page draws one map per phase.
3. **Stack layers** (stack page). Lanes top to bottom: Interface,
   Application, Data, Hosting and auth, plus Tooling only when the stack
   names some. One node per choice, version as its sub line, class by
   layer, linked to its card.
4. **Setup strip** (setup page). One node per step in order, four per row,
   `Step n` as the sub line, class `done`, `hand` or plain; arrows between
   consecutive steps; each links to `#step-<n>`.
5. **Folder map** (structure page). One node per top-level folder, class by
   the layer it holds, sub line the chunks that fill it. No arrows.
6. **Size chart** (build page). One horizontal bar per chunk in build
   order, length proportional to its issue candidates, class by chunk
   state, `C<n> title` to its left and the count at its end.
