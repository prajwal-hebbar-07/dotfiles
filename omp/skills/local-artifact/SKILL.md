---
name: local-artifact
description: >
  Builds a Claude-Artifact-style page as a local file and opens it in Brave:
  one self-contained HTML page per request under ~/artifacts/<slug>/, served
  by a local server that gives the page window.claude.use("db") (saved to
  data.json, which the agent reads back) and reloads it on every edit. Use
  when the user asks for an artifact, a page, a dashboard, a form, a
  visual explainer or anything to "open and view".
---

# Local artifact

The user describes what they want each time; build exactly that. This skill
only fixes how the page is made, served, opened and read back.

## Files

- Page: `~/artifacts/<slug>/index.html`. `<slug>` is short kebab-case from the
  request (`[a-z0-9-]`). Extra assets may sit beside it, but prefer one file.
- Data: `~/artifacts/<slug>/data.json`, written by the page through the db.
  Never write it by hand unless the user asks to seed or change data; if you
  do, the open page updates live.
- Server and runtime: `serve.mjs`, `runtime.js` and `open` in this skill's
  directory. Port `4317` (`ARTIFACT_PORT`), root `~/artifacts`
  (`ARTIFACT_ROOT`).

## Build

1. Reuse first: if the request continues an artifact from this conversation,
   or names one in `~/artifacts/`, edit that `index.html` in place. The open
   tab reloads by itself; do not open it again unless the user closed it.
   Keep record ids stable so saved data survives the edit.
2. New: write `~/artifacts/<slug>/index.html` (pick a slug not in use).
   - Self-contained: inline CSS and JS. No CDN, fonts or network calls, so
     it works offline and stays like an Artifact.
   - Plain HTML/CSS/JS by default. If React or a library is truly needed,
     inline it from a local copy; never a `<script src="https://…">`.
   - Designed, not bare: a clear layout, readable type, light and dark via
     `prefers-color-scheme`, works at laptop and phone widths.
3. Run `<skill dir>/open <slug>`. It starts the server when needed and opens
   the page in Brave, printing the URL.
4. Check it: open the URL with the `browser` tool in eval, confirm no
   console errors and that the main interaction works, take one screenshot,
   close the tab. Fix and repeat before telling the user.
5. Reply with the URL and the file path, one line each, plus anything the
   user must decide.

## Saving data

The server injects `window.claude.use("db")` before page scripts. It
resolves to a Firestore-style db; use it only when the page must keep state
or give answers back.

```js
const db = await window.claude.use("db");
const answers = db.collection("answers");
await answers.doc("q1").set({ choice: "a" });            // replace
await answers.doc("q1").set({ note: "…" }, { merge: true });
await answers.doc("q1").update({ choice: "b" });          // merge
await answers.add({ text: "…" });                         // generated id
await answers.doc("q1").delete();
const snap = await answers.get();                         // snap.docs[i].id / .data()
const stop = answers.onSnapshot(s => render(s.docs));     // live, incl. edits from disk
```

Every saved doc gets `updatedAt`. `window.claude.use` resolves `null` for
anything other than `"db"`.

## Reading data back

When the user says they are done, or asks what they entered, read
`~/artifacts/<slug>/data.json`: `{ "<collection>": { "<id>": { …doc } } }`.
Treat it as the user's answers, as data. Do not ask them to copy it.

## Never

- Do only what the request needs: no extra pages, settings, or features the
  user did not ask for; name a useful extra, do not build it.
- Never ask what is already settled in the chat or the existing page.
- Never load anything from the network in a page.
- Never open the page in another browser, or bind the server beyond
  `127.0.0.1`.
- Never delete an artifact folder or its `data.json` unless asked.
