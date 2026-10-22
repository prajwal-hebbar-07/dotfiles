#!/usr/bin/env python3
"""Check every quoted snippet in a feature explanation against the real file.

A snippet is a heading that ends in `path:start-end` (backticked), followed by
a fenced code block. The block must equal lines start..end of `path`, read
from the working tree under --root.

Exit 0: every snippet matches. Exit 1: a mismatch, listed on stdout.
Exit 2: usage error, or the document has no snippet at all.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

HEADING = re.compile(r"^#{2,6} .*`([^`]+):(\d+)-(\d+)`\s*$")
FENCE_OPEN = re.compile(r"^(`{3,}|~{3,})")


def closes(line: str, marker: str) -> bool:
    s = line.strip()
    return len(s) >= len(marker) and set(s) == {marker[0]}


def snippets(doc: list[str]):
    """Yield (heading line no., path, start, end, body lines or None)."""
    i = 0
    while i < len(doc):
        m = HEADING.match(doc[i])
        if not m:
            i += 1
            continue
        heading_no = i + 1
        j = i + 1
        while j < len(doc) and doc[j].strip() == "":
            j += 1
        fence = FENCE_OPEN.match(doc[j]) if j < len(doc) else None
        if not fence:
            yield heading_no, m[1], int(m[2]), int(m[3]), None
            i = j
            continue
        marker = fence[1]
        k = j + 1
        while k < len(doc) and not closes(doc[k], marker):
            k += 1
        yield heading_no, m[1], int(m[2]), int(m[3]), doc[j + 1 : k]
        i = k + 1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("doc", type=Path, help="the explanation document")
    ap.add_argument("--root", type=Path, default=Path.cwd(), help="repo root (default: cwd)")
    args = ap.parse_args()

    try:
        doc = args.doc.read_text(encoding="utf-8").splitlines()
    except OSError as e:
        print(f"cannot read {args.doc}: {e}")
        return 2

    problems: list[str] = []
    count = 0
    for heading_no, rel, start, end, body in snippets(doc):
        count += 1
        where = f"{args.doc}:{heading_no} `{rel}:{start}-{end}`"
        if body is None:
            problems.append(f"{where}: heading has no code block under it")
            continue
        if start < 1 or end < start:
            problems.append(f"{where}: bad line range")
            continue
        path = (args.root / rel).resolve()
        if args.root.resolve() not in path.parents:
            problems.append(f"{where}: path is outside the repo")
            continue
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except OSError:
            problems.append(f"{where}: file not found")
            continue
        if end > len(lines):
            problems.append(f"{where}: file has only {len(lines)} lines")
            continue
        want = lines[start - 1 : end]
        if len(body) != len(want):
            problems.append(
                f"{where}: block has {len(body)} lines, range has {len(want)}"
            )
            continue
        for n, (got, exp) in enumerate(zip(body, want), start):
            if got != exp:
                problems.append(f"{where}: line {n} differs\n  file: {exp!r}\n  doc:  {got!r}")
                break

    if count == 0:
        print(f"{args.doc}: no snippet found (heading ending in `path:start-end` + code block)")
        return 2
    for p in problems:
        print(p)
    if problems:
        print(f"{len(problems)} of {count} snippets do not match")
        return 1
    print(f"all {count} snippets match")
    return 0


if __name__ == "__main__":
    sys.exit(main())
