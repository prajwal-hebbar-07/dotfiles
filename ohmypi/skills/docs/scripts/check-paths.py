#!/usr/bin/env python3
"""Check docs path claims and relative markdown links against git.

Language-agnostic. No symbol table, no package.json exports.

Usage:
  check-paths.py [--json] [repo-root]
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys

INLINE = re.compile(r"`([^`\n]+)`")
LINK = re.compile(r"\]\(([^)#\s]+)\)")
PATHISH = re.compile(
    r"^[\w.@/~-]+/[\w.@/~-]*$|^[\w.-]+\.[A-Za-z0-9]{1,8}$"
)
DELIBERATE = re.compile(
    r"no longer|d(?:oes|o) not exist|removed|deleted|replaced by|"
    r"there is no|there are no|retired|superseded|dead code|"
    r"was renamed|\(removed\)",
    re.I,
)
SKIP_DIRS = ("docs/architecture/diagrams", "docs/implementation-plan")


def git_lines(root: str, *args: str) -> list[str]:
    out = subprocess.run(
        ["git", *args], cwd=root, capture_output=True, text=True, check=True
    ).stdout.splitlines()
    return [l for l in out if l]


def tracked(root: str) -> set[str]:
    return set(git_lines(root, "ls-files"))


def strip_fences(text: str) -> str:
    return re.sub(r"^```.*?^```", "", text, flags=re.S | re.M)


def is_skipped(rel: str) -> bool:
    return any(rel == d or rel.startswith(d + "/") for d in SKIP_DIRS)


def doc_files(root: str, files: set[str]) -> list[str]:
    out = []
    for rel in sorted(files):
        if not rel.endswith(".md"):
            continue
        if is_skipped(rel):
            continue
        if rel == "README.md" or rel.startswith("docs/"):
            out.append(rel)
    return out


def resolves(root: str, path: str, citing: str, files: set[str]) -> bool:
    path = re.sub(r":\d+(-\d+)?$", "", path).lstrip("./")
    if path in files:
        return True
    needle = "/" + path.rstrip("/")
    if any(t.endswith(needle) for t in files):
        return True
    if any(t.startswith(path.rstrip("/") + "/") for t in files):
        return True
    abs_p = os.path.normpath(os.path.join(root, path))
    if os.path.exists(abs_p):
        return True
    rel_p = os.path.normpath(os.path.join(root, os.path.dirname(citing), path))
    return os.path.exists(rel_p)


def check_doc(root: str, rel: str, files: set[str]) -> list[dict]:
    raw = open(os.path.join(root, rel), encoding="utf-8").read()
    body = strip_fences(raw)
    findings = []
    lines = body.splitlines()
    for i, line in enumerate(lines):
        window = (lines[i - 1] if i else "") + " " + line
        deliberate = bool(DELIBERATE.search(window))
        for token in INLINE.findall(line):
            token = token.strip().rstrip(".,;:")
            if not token or " " in token or token.startswith(("http", "mailto", "~")):
                continue
            if not PATHISH.match(token):
                continue
            if not resolves(root, token, rel, files):
                findings.append(
                    {
                        "kind": "path",
                        "token": token,
                        "line": i + 1,
                        "deliberate?": deliberate,
                        "file": rel,
                    }
                )
        for href in LINK.findall(line):
            if href.startswith(("http", "mailto", "#")):
                continue
            if not resolves(root, href, rel, files):
                findings.append(
                    {
                        "kind": "link",
                        "token": href,
                        "line": i + 1,
                        "deliberate?": deliberate,
                        "file": rel,
                    }
                )
    return findings


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    as_json = "--json" in sys.argv
    root = os.path.abspath(args[0] if args else ".")
    files = tracked(root)
    report: dict[str, list[dict]] = {}
    for rel in doc_files(root, files):
        found = check_doc(root, rel, files)
        if found:
            report[rel] = found
    if as_json:
        print(json.dumps(report, indent=2))
    else:
        hard = 0
        for rel, found in report.items():
            print(f"\n{rel}")
            for f in found:
                flag = " (deliberate?)" if f["deliberate?"] else ""
                if not f["deliberate?"]:
                    hard += 1
                print(f"  {f['line']:>4}  {f['kind']:<4} {f['token']}{flag}")
        total = sum(len(v) for v in report.values())
        print(
            f"\n{total} unresolved claim(s) in {len(report)} file(s); "
            f"{hard} not obviously deliberate"
        )
    hard = sum(1 for v in report.values() for f in v if not f["deliberate?"])
    return 1 if hard else 0


if __name__ == "__main__":
    sys.exit(main())
