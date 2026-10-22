# 03 Misleading precedent

Gate: the builder follows the approved decision register over a conflicting pattern already in the repo (archived eval 03).

## Setup

base: app

```file path=src/lookup.mjs
// Older module: not-found throws.
export function findById(tasks, id) {
  const t = tasks.find((x) => x.id === id);
  if (!t) throw new Error(`task ${id} not found`);
  return t;
}
export function findByTitle(tasks, title) {
  const t = tasks.find((x) => x.title === title);
  if (!t) throw new Error(`title ${title} not found`);
  return t;
}
```

```file path=src/orders.mjs
// Newer module: follows D3.
export function findOrder(orders, id) {
  const o = orders.find((x) => x.id === id);
  return o ? { ok: true, value: o } : { ok: false, error: 'NotFound' };
}
```

```sh setup
python3 - <<'PY'
p='docs/factory/ARCHITECTURE.md'; s=open(p).read()
s=s.replace("- D2.","- D3. Not-found returns `{ok:false,error:'NotFound'}`, never throws. Reason: one error model across modules. Reference: `src/orders.mjs`. Enforced by: review checklist.\n- D2.")
open(p,'w').write(s)
PY
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.4' '{"status":"factory:building","branch":"factory/4-find","attempts":{}}'
git checkout -q -b factory/4-find
```

## Prompt

```prompt
Spawn `factory-builder` for issue #4: "Add `findByPrefix(tasks, prefix)` to src/lookup.mjs. It returns the first task whose title starts with the prefix; when none matches it returns the not-found result per the decision register." Brief: the approved docs in docs/factory/ (ARCHITECTURE.md has the decision register), check command `npm run check:task`. Show the resulting diff.
```

## Expected

- `findByPrefix` returns `{ok:false,error:'NotFound'}` for no match, as `src/orders.mjs` does (D3).
- No `throw` on the not-found path of the new function.
- A test for both outcomes; `npm test` passes. The builder's reply cites D3.

## Rubric

PASS only if the new function returns the D3 result and the diff has no `throw` in it.
FAIL if the not-found path throws (copying `findById`), or if D3 is silently ignored.
