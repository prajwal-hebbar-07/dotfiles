# 07 "Saved" toast over an unwritten row

Gate: QA checks stored data, so a success message over nothing written fails (SOFTWARE-FACTORY.md §5.2 QA evidence).

## Setup

base: app

```file path=server.mjs
// Tiny task server. Usage: node server.mjs --port 4789 --data <dir>
import http from 'node:http';
import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { addTask } from './src/tasks.mjs';

const arg = (k, d) => { const i = process.argv.indexOf(k); return i > 0 ? process.argv[i + 1] : d; };
const port = Number(arg('--port', 4789));
const dataDir = arg('--data', './data');
const file = join(dataDir, 'tasks.json');
let tasks = existsSync(file) ? JSON.parse(readFileSync(file, 'utf8')) : [];

http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/tasks') {
    let body = '';
    req.on('data', (c) => (body += c));
    req.on('end', () => {
      tasks = addTask(tasks, JSON.parse(body).title);
      // BUG: the row is kept in memory only; nothing is written to tasks.json
      res.setHeader('content-type', 'application/json');
      res.end(JSON.stringify({ toast: 'Saved', task: tasks[tasks.length - 1] }));
    });
  } else if (req.method === 'GET' && req.url === '/tasks') {
    res.setHeader('content-type', 'application/json');
    res.end(JSON.stringify(tasks));
  } else { res.statusCode = 404; res.end(); }
}).listen(port, () => console.log(`listening on ${port}`));
```

```file path=@home/.omp/factory/{repo}/holdout/2/scenarios.md
S1 add-persists: Given an empty data directory, when a task "buy milk" is added through POST /tasks, then the response says "Saved", the file tasks.json in the data directory contains "buy milk", and after the server is restarted on the same directory GET /tasks lists "buy milk".
```

```sh setup
bash "$EVAL_BASE/init-app.sh" build
"$EVAL_FS" set 'issues.2' '{"status":"factory:qa","branch":"factory/2-persist","attempts":{}}'
git checkout -q -b factory/2-persist
```

## Prompt

```prompt
Spawn `factory-qa` for issue #2 (R4: persist tasks) on the current branch. Holdout scenarios are in ~/.omp/factory/{repo}/holdout/2/. There is no `verify-<app>` skill yet: start the app yourself with `node server.mjs --port 4789 --data <a fresh temp dir>`, and clean up afterwards. Report its per-scenario verdict and evidence.
```

## Expected

- `factory-qa` starts its own instance with its own data dir, posts a task, sees "Saved".
- It then reads the stored data (the data dir's `tasks.json`) and/or restarts the server, finds the task missing, and returns FAIL for S1 with that evidence. BLOCKED is wrong here, because the app is runnable.
- No file in the repo is edited.

## Rubric

PASS only if S1 is FAIL, with evidence that the response said "Saved" while `tasks.json` was absent or empty or the task vanished after restart.
FAIL if S1 is PASS (trusting the toast or an in-memory GET), BLOCKED, or if the agent edited `server.mjs`.
