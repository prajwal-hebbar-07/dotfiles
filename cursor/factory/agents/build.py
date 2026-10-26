#!/usr/bin/env python3
"""Refresh cursor/factory/agents from omp/agents.

Run from the repo root: python3 cursor/factory/agents/build.py
factory-reviewer.md is hand-written and left alone.
"""
from __future__ import annotations

import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SRC = os.path.join(ROOT, "omp", "agents")
DST = os.path.dirname(os.path.abspath(__file__))

# Cursor model ids. Opus medium is not in the Cursor model list; builder uses Opus high.
# GPT is the second family: builder-check, holdout author, explainer, design direction.
MODELS = {
    "factory-builder": ("claude-opus-5-5-high", False),
    "factory-builder-unstick": ("claude-opus-5-5-high", False),
    "factory-planner": ("claude-opus-5-5-high", True),
    "factory-spec-review": ("claude-opus-5-5-high", True),
    "factory-test-review": ("claude-opus-5-5-high", True),
    "factory-qa-review": ("claude-opus-5-5-high", True),
    "factory-ui-review": ("claude-opus-5-5-high", True),
    "factory-design-review": ("claude-opus-5-5-high", True),
    "factory-designer": ("claude-opus-5-5-high", False),
    "factory-design-director": ("gpt-5.6-sol-medium", False),
    "factory-qa": ("claude-sonnet-5-5-high", False),
    "factory-qa-author": ("gpt-5.6-sol-medium", False),
    "factory-builder-check": ("gpt-5.6-sol-medium", True),
    "factory-explainer": ("gpt-5.6-sol-medium", False),
}

PREAMBLE = """## Cursor

You run inside Cursor. The parent prompt includes `DOTFILES`, an absolute path.

- A `skill://name` reference is `$DOTFILES/skills/name/SKILL.md`. A `skill://factory/file.md` reference is `$DOTFILES/skills/factory/file.md`. Read it before you follow it.
- There is no `ask` tool and no `agent://` channel. Stop by putting `questions` in the final json block.
- Do not run `omp`. Do not push, merge, or open a pull request.
- When this file names ponytail, read `~/.agents/skills/ponytail/SKILL.md` if it exists and follow it.
- When this file names the review rubric or `factory-review`, read `$DOTFILES/skills/factory-review/SKILL.md` and follow it.
- Holdout scenarios live only under `~/.cursor/factory/holdout/`. Read or write them only if you are `factory-qa` or `factory-qa-author`.
- Paper is the Paper MCP. When this file names `paper-design` or `paper-design-prompt`, read that skill under `$DOTFILES/skills/` and call `get_guide` before other Paper tools. Ignore `mcp__paper_*` names in the text below.
"""

EXTRAS = {
    "factory-qa": (
        "- Do not call `browser.open`. Run the commands the brief names. "
        "If a check needs a browser and the Cursor IDE browser tools are available, use those. "
        "If you cannot run the check, return BLOCKED with a manual-check list. Never PASS a scenario you did not run.\n"
    ),
    "factory-builder-unstick": (
        "- Cursor has no live advisor. The parent passes a note from `factory-reviewer` "
        "as the advisor note. Treat it as that guess, and say in `notes` whether you followed it.\n"
    ),
}


def split_frontmatter(text):
    if not text.startswith("---\n"):
        raise SystemExit("missing frontmatter")
    end = text.find("\n---\n", 4)
    if end < 0:
        raise SystemExit("unclosed frontmatter")
    raw = text[4:end]
    body = text[end + 5 :]
    fields = {}
    for line in raw.splitlines():
        if ":" not in line:
            continue
        key, val = line.split(":", 1)
        fields[key.strip()] = val.strip()
    return fields, body


def convert(name, text):
    fields, body = split_frontmatter(text)
    model, readonly = MODELS[name]
    body = body.replace("~/.omp/factory/<repo>/holdout/", "~/.cursor/factory/holdout/<repo>/")
    body = body.replace("~/.omp/factory/", "~/.cursor/factory/holdout/")
    body = body.replace("the bundled `reviewer`", "`factory-reviewer`")
    body = body.replace("the correctness `reviewer`", "`factory-reviewer`")
    body = body.replace(
        "- Drive the user's own Chrome: open every tab with\n"
        "  `browser.open({ name, url, app: { relay: false, tern: false } })`.",
        "- Drive the UI with the Cursor IDE browser tools when a check needs a browser. "
        "Do not call `browser.open`. If those tools are unavailable, return BLOCKED with a manual-check list.",
    )
    body = body.replace(
        "- Drive the user's own Chrome: open tabs with\n"
        "  `browser.open({ name, url, app: { relay: false, tern: false } })`, on your\n"
        "  own instance (own port, own empty data dir) that you stop afterwards.",
        "- Drive the UI with the Cursor IDE browser tools, on an instance you started "
        "(own port, own empty data dir) and then stop. Do not call `browser.open`.",
    )
    desc = fields.get("description", "").strip().strip('"')
    desc = desc.replace("~/.omp/factory/<repo>/holdout/", "~/.cursor/factory/holdout/<repo>/")
    desc = desc.replace("~/.omp/factory/", "~/.cursor/factory/holdout/")
    desc = desc.replace('"', "'")
    lines = [
        "---",
        "name: %s" % name,
        'description: "%s"' % desc,
        "model: %s" % model,
    ]
    if readonly:
        lines.append("readonly: true")
    lines.append("---")
    lines.append("")
    extra = EXTRAS.get(name, "")
    lines.append(PREAMBLE.rstrip())
    if extra:
        lines.append(extra.rstrip())
    lines.append("")
    lines.append(body.lstrip("\n"))
    return "\n".join(lines).rstrip() + "\n"


def main():
    for filename in sorted(os.listdir(SRC)):
        if not filename.endswith(".md"):
            continue
        name = filename[:-3]
        if name not in MODELS:
            raise SystemExit("no model mapping for %s" % name)
        with open(os.path.join(SRC, filename), encoding="utf-8") as f:
            text = f.read()
        out = convert(name, text)
        with open(os.path.join(DST, filename), "w", encoding="utf-8") as f:
            f.write(out)
        print(filename)


if __name__ == "__main__":
    main()
