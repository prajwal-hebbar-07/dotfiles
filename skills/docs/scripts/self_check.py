#!/usr/bin/env python3
"""Temp-repo assertions for check-paths.py. No side effects on the real tree."""

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent

DOC = (
    "See `src/app.py` and `src/missing.py`.\n"
    "\n"
    "There is no `src/gone.py`.\n"
    "\n"
    "Link to [ok](01-app.md) and [bad](nope.md).\n"
)


def git(cwd: Path, *args: str) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def seed(root: Path) -> None:
    git(root, "init")
    git(root, "config", "user.email", "t@t.test")
    git(root, "config", "user.name", "t")
    (root / "src").mkdir()
    (root / "src" / "app.py").write_text("x = 1\n")
    docs = root / "docs" / "architecture"
    docs.mkdir(parents=True)
    (docs / "01-app.md").write_text(DOC)
    git(root, "add", ".")
    git(root, "commit", "-m", "seed")


def main() -> None:
    script = HERE / "check-paths.py"
    with tempfile.TemporaryDirectory() as raw:
        root = Path(raw)
        seed(root)
        proc = subprocess.run(
            ["python3", str(script), str(root)], capture_output=True, text=True
        )
        out = proc.stdout
        checks = [
            ("missing path flagged", "path src/missing.py" in out),
            ("live path quiet", "src/app.py" not in out),
            ("gone marked deliberate", "path src/gone.py (deliberate?)" in out),
            ("broken link flagged", "link nope.md" in out),
            ("self link quiet", "link 01-app.md" not in out),
            ("nonzero because hard findings", proc.returncode == 1),
        ]
        for name, ok in checks:
            print(f"{'ok' if ok else 'FAIL'}  {name}")
        failed = [name for name, ok in checks if not ok]
        if failed:
            print(out)
            raise SystemExit(f"{len(failed)} failed")
        print(f"{len(checks)}/{len(checks)} checks passed")


if __name__ == "__main__":
    main()
