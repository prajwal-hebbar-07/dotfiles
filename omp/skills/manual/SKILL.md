---
name: manual
description: Create an empty manual.md at the project root for the user's private notes and add it to .gitignore. Never reads the file. Use when the user runs /skill:manual.
disable-model-invocation: true
---

# manual

Give the project a private `manual.md` at its root: created empty if missing,
listed in `.gitignore`, never read by an agent. Afterwards the `manual-guard`
extension blocks every OMP tool call that names the file, and the `manual-md`
rule forbids reaching it any other way.

Invoke explicitly as `/skill:manual`.

## Never

- Read, print, search, summarize, overwrite or empty `manual.md`, even to
  check it. Existence is tested with `test -e`, nothing else.
- Do only what the request needs: create the file and ignore it. Never commit,
  stage, untrack or touch other files. A useful extra is named in one line,
  not done.
- Never ask what is already settled. The repository answers everything this
  skill needs.

## Step 1 — create and ignore

Run this exactly once, as written. The file name is assembled from `$name`
because `manual-guard` blocks any command that spells it out; this script is
the only sanctioned exception, and nothing else may copy the trick.

```sh
name=manual
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
file="$root/$name.md"
ignore="$root/.gitignore"
if [ -e "$file" ]; then echo "$name.md: already exists"; else : > "$file" && echo "$name.md: created"; fi
if grep -qxE "/?$name[.]md" "$ignore" 2>/dev/null; then
  echo ".gitignore: already lists $name.md"
else
  if [ -s "$ignore" ] && [ -n "$(tail -c1 "$ignore")" ]; then echo >> "$ignore"; fi
  echo "$name.md" >> "$ignore" && echo ".gitignore: added $name.md"
fi
git -C "$root" ls-files --error-unmatch "$name.md" >/dev/null 2>&1 && echo "tracked: yes"
```

Outside a git repository the project root is the current directory, and the
`.gitignore` entry is still written.

## Step 2 — report

Reply with the lines the script printed, plus the root path. If it printed
`tracked: yes`, add one line: git already tracks `manual.md`, so the ignore
entry has no effect until `git rm --cached manual.md` is run — named, not run.
