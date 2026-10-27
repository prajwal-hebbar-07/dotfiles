# Slicing

How `/issues` cuts the app into issues, and the checks an issue must pass
before it is written. The cutting rules follow Matt Pocock's `to-tickets`.

## What an issue is

A narrow but complete path through every layer the feature touches (schema,
logic, interface, screen, tests), not a layer on its own. When it is done it
can be demonstrated or verified on its own. It is small enough for one
implementer to hold in one sitting and for one pull request to review in
about an hour. If its body would pass 20,000 characters, it is too big or it
copies too much: cut the slice, or copy only the fields the issue uses.

## Issue 0, bootstrap

Always first, and blocks every other issue. It builds an empty app that can be
developed, tested and shipped, from the stack and the architecture's shape and
concerns:

- the repository skeleton for the chosen stack and the deployable units the
  architecture names, and the one command that runs everything on a laptop
- configuration and secrets as the `K` concern says, and the environments
- the test tooling from the stack, one passing test at each level the
  architecture names, and the command to run them
- CI that runs them on every change, and the deploy and rollback path if the
  stack names one
- observability and error handling baseline, only as far as a `K` item says
- every `C` item that is a platform or tooling fact (a language version, a
  host)

It builds no feature. Its acceptance criteria are checks that each of those
works, not a list of files.

## Cutting

1. Start from the journeys. If there is no design, start from the flows. A
   slice follows one journey, or the part of one that can be demonstrated
   alone: the first slice of a journey is its shortest working path (the
   happy path on the thinnest data), later slices add the branches, the
   failure states, and the roles.
2. Take the architecture items a slice needs, and build each module, entity
   and concern in the **first** slice that needs it, to the depth that slice
   needs. A later slice that needs more adds to it. Never an issue that only
   creates tables, or only a module, with no behaviour to show.
3. Prefactoring goes first and is its own issue, only when the repository
   already has code that must change shape so the slice is easy. A wide
   mechanical change goes expand, then migrate in batches (each blocked by the
   expand), then contract (blocked by every batch).
4. A flow's failure paths belong to the slice that builds the flow, unless the
   path is large enough to demonstrate alone (a retry queue, an admin
   recovery screen): then its own slice, blocked by the first.
5. Every abuse case `B` is built and verified in the slice of the flow it
   guards. Every `N` that is a number (latency, size, uptime) is built where
   the cost arises and has its check in that slice; an `N` that spans the
   whole app (an availability target, an accessibility standard) gets one
   late issue that verifies it across the app.
6. Test each slice with "what can I demo when this is done?". No answer means
   a horizontal slice: redraw it.
7. Dependencies are real needs only: the slice that creates an entity blocks
   the slices that use it. Add no edge for tidiness. Every issue except issue
   0 is blocked by issue 0: write it in **Blocked by** and add the edge like
   any other.
8. Waves: wave 0 is issue 0; each later wave is the issues whose blockers are
   all in earlier waves. Two issues that would edit the same module in the same
   wave are put in different waves, or merged, so they do not collide.

## Self-sufficiency

An issue passes only if an implementer who has nothing but that issue could
build it and tell whether it is done. For each issue, check:

1. **Copied, not pointed at.** Every `R`, `N`, `C`, `M`, `E`, `F`, `K`, `B`,
   `J`, `P`, screen, stack decision and ADR it cites has its text pasted in,
   word for word. Every ID in the body resolves to an item in a document, and
   every item in the Sources line is present in the body.
2. **Testable.** Each requirement has at least one acceptance criterion with a
   falsifier. A requirement with an `Accept:` line copies it; one without is
   written from the requirement's own words, and the criterion says it was
   derived. Each criterion can be checked by a named test.
3. **Every state.** For an issue with UI: every screen has every state the
   design lists, with its words; a state the design omits and the screen needs
   is an open point, not a guess.
4. **No stranger.** No term outside the glossary and no reference to "the
   previous issue", "as above" or "the usual way".
5. **No open question hides.** Every `Q`, `AQ`, `DQ`, `SQ` or accepted unknown
   that touches the issue is in **Assumptions** with the value to build. A
   question whose answer could change which issues exist stops the run.
6. **Fresh reader.** A sub-agent that is given only the issue files (not the
   documents, not the chat) answers: "What would you have to ask the author
   before you could build this and know it is done? Quote the line, or say
   what is missing." Run it in batches of up to five issues. Each gap it
   finds is fixed by pasting the missing text from the documents. It only
   counts if it reports "nothing left to ask" for every issue, or the
   remainder are open points shown to the user.

## Checks by command

List the live items of each document, to compare with the Coverage table:

```sh
live() { grep -hE "$1" "$2" | grep -vi 'dropped' ; }
live '^- \*\*(R|N|C)[0-9]+\*\*' docs/requirements.md
live '^### (M|E|F|K|B)[0-9]+ ' docs/architecture.md
live '^### S[0-9]+ ' docs/stack.md
live '^### (J|S|P)[0-9]+ ' docs/design.md
```

Every ID in an issue file exists in a document:

```sh
grep -ohE '\b(R|N|C|X|M|E|F|K|B|J|P|S)[0-9]+\b' docs/issues/*.md | sort -u
```

(`S` is a stack decision or a screen; check it against `stack S` or `screen S`
in the line it appears in.) Body size:

```sh
wc -c docs/issues/*.md
```
