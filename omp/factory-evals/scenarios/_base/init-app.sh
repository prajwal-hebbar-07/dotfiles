#!/usr/bin/env bash
# Shared fixture step: commit the base files, create a local origin, init and
# stamp the factory state. Usage: init-app.sh <stage>
set -euo pipefail
cd "$EVAL_REPO"
git add -A
git commit -qm "chore: approved factory docs and app"
git init -q --bare "$EVAL_ORIGIN"
git remote add origin "$EVAL_ORIGIN"
git push -q origin main
"$EVAL_FS" init --mode app >/dev/null
for pair in requirements:REQUIREMENTS stack:STACK architecture:ARCHITECTURE issues:ISSUES; do
  "$EVAL_FS" stamp "${pair%%:*}" "docs/factory/${pair##*:}.md" >/dev/null
done
"$EVAL_FS" set stage "\"${1:-build}\"" >/dev/null
