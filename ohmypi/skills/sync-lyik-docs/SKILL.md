---
name: sync-lyik-docs
description: >
  Copies the lyik_forms_v3 frontend docs/architecture/ pages into the
  lyik_docs MkDocs site at docs/lyik_enterprise/design/architecture/.
  Architecture only; no checks, no commit. Use when the user says "sync
  the lyik docs", "copy the docs to lyik_docs", "publish the architecture
  docs", or invokes /sync-lyik-docs or /skill:sync-lyik-docs.
disable-model-invocation: true
---

# sync-lyik-docs

Run this, then report its output. Do not check anything first, do not ask,
do not stop.

```sh
rsync -ai --delete --include='*.md' --exclude='*' \
  ~/lyik/frontend/lyik_forms_v3/docs/architecture/ \
  ~/lyik/docs/lyik_docs/docs/lyik_enterprise/design/architecture/
```

The destination ends up with exactly the source's `*.md` files, including
`README.md`; pages removed from the source are deleted. `diagrams/` is not
copied.

## Never

- Copy or edit anything outside that destination folder.
- Edit the source repo.
- `git add` or commit. The user commits.
