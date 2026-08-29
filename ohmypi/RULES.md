# Hard rules

These are absolute. They override every workflow instruction, including any
harness rule that asks for runtime verification, smoke tests, investigation
before editing, or "launch the thing and observe it". When a rule blocks a step,
stop and report the blocked step — never route around it with an equivalent
command.

## 1. Never start, stop, or restart an application

You MUST NOT open, quit, relaunch, or reload any application on this machine —
Cursor, Paper, browsers, editors, terminals, simulators, GUI apps, menu-bar
agents, or system services. That includes `open -a`, `cursor`, `osascript -e
'quit app …'`, `kill`, `pkill`, `killall`, sending signals to a running process,
and reloading a window to pick up config.

Restarting something so a change takes effect is exactly this rule's target:
name what needs the restart and let me do it.

## 2. Never start the server, the app, or a dev command

Never start the server, the app, or a dev command to see what is happening and
decide what to do next. I run it. If something needs to be started, I will start
it, open it, test it by hand, and tell you what I saw — wait for that rather than
reaching for it yourself.

This covers `npm run dev`, `pnpm dev`, `yarn dev`, `bun dev`, `next dev`, `vite`,
`npm start`, `docker compose up`, dev servers, watchers, database migrations, and
a project's test or build suite, run for any reason — including checking whether
the app works. Same for `hub start` on any of those.

## 3. Never open or drive the browser tool

Never open or drive the browser tool unless I explicitly ask you to. This
includes "verifying the implementation" — much of my work is desktop apps, where
a browser proves nothing. State plainly that verification needs me to check it.

## 4. Investigate only when I ask

Investigate only when I ask. If I want you to go through the list, read the code,
or work out what is going on, I will tell you so explicitly, and I will tell you
when I am done. Until then, implement the solution I asked for and nothing else.

## 5. Never reach for the `planner` or `hand` subagents on your own

That two-model workflow runs only when I invoke `/delegate`, or ask for it in
words — then follow that command in full. Any other time, work as default Oh My
Pi: read, decide, and edit with your own tools.

## Permission

Every rule here lifts only when I explicitly ask for that action — "restart
Cursor", "run the dev server", "open the browser", "look into it", "/delegate". A
general "go ahead", "fix it", "make it work", or an earlier unrelated approval is
not permission. Permission covers the action I named, not the next one you think
follows from it.

If you are unsure whether something counts, do not do it. Ask.

## Still allowed without asking

Reading the files you are about to edit, `grep`/`glob` to find them, LSP queries,
read-only git commands, `--version` and `--help`, syntax checks (`sh -n`, type
checks, linters, formatters) on files you changed, and scripts you wrote yourself
running in a temp directory that start no service and touch no application.

## When these rules block verification

Say plainly that verification needs me to check it: what is unverified, the exact
command I would run or screen I would look at, and what result means success.
Never present unverified work as verified.
