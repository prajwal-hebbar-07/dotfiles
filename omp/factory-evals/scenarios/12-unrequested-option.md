# 12 Unrequested option or wrapper

Gate: spec review flags an abstraction, wrapper, option, or "for later" code no requirement asks for as Required (the "Simpler" axis, SOFTWARE-FACTORY.md §5.2, §5.8).

## Setup

base: app

```sh setup
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.1' '{"status":"factory:review","branch":"factory/1-tasks","attempts":{}}'
git checkout -q -b factory/1-tasks
python3 - <<'PY'
p='src/tasks.mjs'; s=open(p).read()
old="""export function completeTask(tasks, id) {
  return tasks.map((t) => (t.id === id ? { ...t, done: true } : t));
}"""
new="""export function completeTask(tasks, id, { toggle = false, onComplete = null, clock = () => Date.now() } = {}) {
  return tasks.map((t) => {
    if (t.id !== id) return t;
    const next = { ...t, done: toggle ? !t.done : true, completedAt: clock() };
    if (onComplete) onComplete(next);
    return next;
  });
}

// generic wrapper so other operations can be hooked later
export class TaskStore {
  constructor(tasks = []) { this.tasks = tasks; this.listeners = []; }
  subscribe(fn) { this.listeners.push(fn); }
  complete(id, opts) { this.tasks = completeTask(this.tasks, id, opts); this.listeners.forEach((l) => l(this.tasks)); }
}"""
assert old in s
open(p,'w').write(s.replace(old,new))
PY
git commit -qam "feat: complete a task (R2)"
```

## Prompt

```prompt
Spawn `factory-spec-review` for issue #1 (acceptance criterion R2 only: "Given an open task, when I complete it, then it is shown as done"), branch factory/1-tasks vs main. Brief: docs/factory/, `npm run check:task`. Report its verdict and findings.
```

## Expected

- Verdict REQUEST CHANGES.
- A Required (or Critical) finding names the `toggle`, `onComplete`, `clock` options and the `TaskStore` wrapper / `completedAt` field as unrequested by any `R`.
- Nothing in the reply approves the extra surface.

## Rubric

PASS only if the verdict is REQUEST CHANGES and at least one Required-or-higher finding names the unrequested options or the `TaskStore` wrapper.
FAIL if APPROVE, or if the extra surface appears only as Optional or Nit.
