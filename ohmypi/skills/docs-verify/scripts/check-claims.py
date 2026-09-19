#!/usr/bin/env python3
"""Check every checkable claim in docs/ against the code, and report the misses.

Extracts three kinds of claim from the markdown, all of them from inside backticks
so prose is never mistaken for a citation:

  path    a repo-relative or package-relative file/directory path
  symbol  an identifier-shaped name (camelCase, PascalCase, UPPER_SNAKE, foo())
  export  a subpath in some package.json "exports" map, cited by a doc

and prints the ones that do not resolve. Paths are tried literally first, then under
every workspace root, because the inventory tables cite package-relative paths like
`src/form/audit/fold.ts`. Symbols are matched against the set of identifiers that
actually appear in the source, not against a language server: this is a cheap
existence check, not a type check.

Findings are advisory. A doc may name a dead symbol on purpose ("replaced by",
"no longer exists"), so lines that read like that are flagged `deliberate?`
rather than dropped -- a human or an agent decides.

Usage:
  check-claims.py [--json] [--only docs/architecture/09-form-core.md] [repo-root]
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys

# --- claim extraction -------------------------------------------------------

# Anything in single backticks. Doubles/triples are code blocks, skipped separately.
INLINE = re.compile(r"`([^`\n]+)`")

# A path claim: has a slash and a plausible file extension, or is a known root.
PATHISH = re.compile(
    r"^[\w@./*{},~-]+/[\w@./*{},~-]*$|^[\w.-]+\.(ts|tsx|js|json|md|yml|yaml|conf|sh|css)$"
)
BRACES = re.compile(r"\{([^}]*)\}")

# Identifier shapes worth checking. Deliberately narrow: a lowercase word on its
# own is prose ("the fold", "a registry"), not a citation.
SYMBOL = re.compile(
    r"""^(
      [a-z][a-zA-Z0-9]*[A-Z][a-zA-Z0-9]*   # camelCase with a hump
    | [A-Z][a-z0-9]+[A-Za-z0-9]*           # PascalCase
    | [A-Z][A-Z0-9]+(_[A-Z0-9]+)+          # UPPER_SNAKE_CASE
    )(\(\))?$""",
    re.VERBOSE,
)

# Backticked things that are never code in these docs.
NOT_CODE = {
    "README",
    "AGENTS",
    "CLAUDE",
    "INFERENCE",
    "TODO",
    "HEAD",
    "OK",
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
    "HIDE",
    "SHOW",
    "MKR",
    "CKR",
    "ADMIN",
    "PLATFORM_ADMIN",
    # Asset types for organization branding wire parameters
    "SMALL_LOGO",
    "LARGE_LOGO",
    "SPA_CONFIG",
    "true",
    "false",
    "null",
    "undefined",
    # HTTP cookie / security attributes cited in config docs; not our identifiers.
    "SameSite",
    "HttpOnly",
    "Secure",
    # Third-party API error response codes
    "ERROR_BAD_REQUEST",
}

# Wording that means the doc names something on purpose because it is absent. A
# negative claim ("there is no root vitest.config.ts", "no AbortController anywhere")
# is documentation doing its job, and the §9 trap lists are full of them.
DELIBERATE = re.compile(
    r"no longer|d(?:oes|o) not exist|never exist|removed|deleted|replaced by|used to|"
    r"was renamed|not\s+`|instead of|dead code|superseded|retired|pre-refactor|"
    r"there is no|there are no|\bno\b[^.]{0,40}`|does not need|\banywhere\b|"
    r"exported-but-unused|unused|if it (grows|gains)|would be|rather than|"
    r"generated|TypeDoc|on the table|proposed|the fix|grows a new|\blibrary's\b|"
    r"\be\.g\.|\bfor example|\bsuch as|\brejected\b|not needed|not required|returns?\s+|"
    r"\bfails?\s+with\s+|output filenames?",
    re.I,
)


def workspace_roots(root: str) -> list[str]:
    roots = [""]
    for parent in ("packages", "apps"):
        d = os.path.join(root, parent)
        if os.path.isdir(d):
            roots += [f"{parent}/{sub}/" for sub in sorted(os.listdir(d)) if os.path.isdir(os.path.join(d, sub))]
    return roots


def expand_braces(token: str) -> list[str]:
    """`src/form/audit/{fold,registry}.ts` -> two paths."""
    m = BRACES.search(token)
    if not m:
        return [token]
    out = []
    for part in m.group(1).split(","):
        out += expand_braces(token[: m.start()] + part.strip() + token[m.end() :])
    return out


# Tracked files worth scanning for identifiers, by extension or exact name.
SCANNABLE = (
    ".ts", ".tsx", ".js", ".mjs", ".mts", ".rs", ".toml",
    ".json", ".yml", ".yaml", ".conf", ".sh", ".md",
)
SCANNABLE_NAMES = {"Dockerfile", "Makefile", ".npmrc", ".env.test", ".env.example"}


def tracked_files(root: str) -> list[str]:
    return subprocess.run(
        ["git", "ls-files"], cwd=root, capture_output=True, text=True, check=True
    ).stdout.split()


def source_identifiers(root: str, files: list[str]) -> set[str]:
    """Every identifier appearing anywhere in tracked config or source.

    Config files count: `allowBuilds` lives in pnpm-workspace.yaml and `LOGOUT_URL`
    in an env file, and a doc citing either is telling the truth.
    """
    idents: set[str] = set()
    for rel in files:
        base = os.path.basename(rel)
        if not (rel.endswith(SCANNABLE) or base in SCANNABLE_NAMES):
            continue
        if rel.startswith("docs/") and not rel.startswith("docs/fixtures/"):
            continue  # a doc may not vouch for itself, but fixtures are real observed data
        try:
            with open(os.path.join(root, rel), encoding="utf-8", errors="ignore") as fh:
                text = fh.read()
        except OSError:
            continue
        idents.update(re.findall(r"[A-Za-z_$][A-Za-z0-9_$]*", text))
    return idents


def basenames(files: list[str]) -> set[str]:
    """File names as cited: `theme.json`, `Makefile`, and stems like `sectionActions`.

    The stem matters because inventory tables cite a test by its subject
    (`sectionActions`) while the file on disk is `sectionActions.test.ts`.
    """
    out: set[str] = set()
    for f in files:
        base = os.path.basename(f)
        out.add(base)
        out.add(base.split(".")[0])
    return out


def package_names(root: str, files: list[str]) -> set[str]:
    """Workspace package names plus every declared dependency name."""
    names: set[str] = set()
    for rel in files:
        if os.path.basename(rel) != "package.json":
            continue
        try:
            with open(os.path.join(root, rel), encoding="utf-8") as fh:
                pkg = json.load(fh)
        except (OSError, ValueError):
            continue
        if pkg.get("name"):
            names.add(pkg["name"])
        for field in ("dependencies", "devDependencies", "peerDependencies"):
            names.update(pkg.get(field, {}) or {})
    return names


def package_dirs(root: str, files: list[str]) -> dict[str, str]:
    """Package name -> its directory, so deep imports can be resolved to files."""
    out: dict[str, str] = {}
    for rel in files:
        if os.path.basename(rel) != "package.json":
            continue
        try:
            with open(os.path.join(root, rel), encoding="utf-8") as fh:
                name = json.load(fh).get("name")
        except (OSError, ValueError):
            continue
        if name:
            out[name] = os.path.dirname(rel)
    return out


def export_subpaths(root: str) -> set[str]:
    """Declared exports of every workspace package, as `@scope/name/subpath`."""
    out: set[str] = set()
    for rel in subprocess.run(
        ["git", "ls-files", "packages/*/package.json", "apps/*/package.json"],
        cwd=root,
        capture_output=True,
        text=True,
        check=True,
    ).stdout.split():
        try:
            with open(os.path.join(root, rel), encoding="utf-8") as fh:
                pkg = json.load(fh)
        except (OSError, ValueError):
            continue
        name = pkg.get("name")
        exports = pkg.get("exports")
        if not name or not isinstance(exports, dict):
            continue
        for sub in exports:
            if "*" in sub:
                continue
            out.add(name if sub == "." else f"{name}/{sub.lstrip('./')}")
    return out


def strip_code_blocks(text: str) -> str:
    """Blank out fenced blocks; they hold commands and JSON, not citations."""
    return re.sub(r"^```.*?^```", "", text, flags=re.S | re.M)


def check_doc(root: str, rel: str, facts: dict) -> list[dict]:
    with open(os.path.join(root, rel), encoding="utf-8") as fh:
        raw = fh.read()
    body = strip_code_blocks(raw)
    offsets = {}  # line text -> line number, first occurrence
    for n, line in enumerate(raw.splitlines(), 1):
        offsets.setdefault(line, n)

    idents, exports = facts["idents"], facts["exports"]
    findings = []
    lines = body.splitlines()
    for i, line in enumerate(lines):
        lineno = offsets.get(line, 0)
        # Prose wraps, so a negative claim's cue ("There is no ...") may sit on the
        # line above the citation. Judge deliberateness on both.
        window = (lines[i - 1] if i else "") + " " + line
        for token in INLINE.findall(line):
            token = token.strip().rstrip(".,;:")
            if not token or token in NOT_CODE:
                continue
            if not re.search(r"[A-Za-z]", token):
                continue  # table pipes and stray punctuation, not a claim
            if "<" in token or "..." in token or "Thing" in token:
                continue  # `@lyik/types/<name>`, `capture/.../x.test.ts`, `LyikThing.tsx`

            # A package name or an exports-map subpath: @lyik/form-core/form/audit
            if token.startswith("@"):
                bare = token.split("(")[0]
                if bare in facts["packages"] or bare in exports:
                    continue
                pkg = "/".join(bare.split("/")[:2])
                if pkg in facts["packages"]:
                    if pkg not in facts["pkgdirs"]:
                        continue  # a third-party dependency; its files are not ours to check
                    # a deep import through a "./*" pattern resolves to a file inside
                    # that package, e.g. @lyik/types/token -> packages/types/src/token.ts
                    tail = bare.split("/", 2)[2] if bare.count("/") > 1 else ""
                    if tail and _resolves_in_package(root, facts, pkg, tail):
                        continue
                    findings.append(_finding("export", bare, line, lineno, window))
                continue
            if _is_path_claim(token, facts):
                cleaned = re.sub(r":\d+(-\d+)?$", "", token)
                if cleaned.startswith("./"):
                    cleaned = cleaned[2:]
                if "*" in cleaned:
                    continue  # an exports-map pattern, not a file to look for
                if "/" not in cleaned and cleaned in facts["basenames"]:
                    continue  # cited by name alone, and the repo holds one
                # A brace form is several claims at once: report the members that
                # are absent, so `{fold,registry}.ts` cannot hide a dead half.
                missing = [
                    p
                    for p in expand_braces(cleaned)
                    if not _resolves(root, p, rel, facts) and not _git_ignored(root, p)
                ]
                if missing:
                    shown = token if len(missing) == 1 and "{" not in token else f"{token} -> {', '.join(missing)}"
                    findings.append(_finding("path", shown, line, lineno, window))
                continue

            name = token.split("(")[0]
            if SYMBOL.match(token) and name not in idents and name not in facts["basenames"]:
                findings.append(_finding("symbol", token, line, lineno, window))
    return findings


# Prefixes that make a slashed token a repo path rather than a branch name or a URL.
ROOTED = ("apps/", "packages/", "docs/", ".github/", "src/", "public/", "scripts/", "dist/")


def _is_path_claim(token: str, facts: dict) -> bool:
    """A citation of a file, not a branch name, a URL, or a home-relative path."""
    if token.startswith(("~", "http", "/")) or " " in token:
        return False
    if not PATHISH.match(token):
        return False
    # Domain names/endpoints, e.g. api2.cursor.sh or ollama.com
    if re.search(r"\b[a-zA-Z0-9-]+\.(com|org|net|io|ai|sh|app|dev)\b", token) and not token.startswith(ROOTED):
        if "/" not in token and token.count(".") >= 2:
            return False
    if token.startswith(ROOTED):
        return True
    if "/" not in token:
        # bare file name: only a claim if it looks like a file the repo could hold
        return token in facts["basenames"] or bool(re.search(r"\.\w{2,4}$", token))
    # slashed but unrooted: a claim only when it ends in a real extension
    return bool(re.search(r"\.(ts|tsx|js|json|md|yml|yaml|conf|sh|css)$", token))


def _resolves(root: str, path: str, citing_doc: str, facts: dict) -> bool:
    if "*" in path:
        return True  # a pattern, not a file
    if path in facts["tracked"]:
        return True
    # cited as the tail of a real path, e.g. "renderer/map.ts"
    needle = "/" + path.rstrip("/")
    if any(t.endswith(needle) for t in facts["tracked"]):
        return True
    if any(t.startswith(path.rstrip("/") + "/") for t in facts["tracked"]):
        return True  # a directory, cited with or without its trailing slash
    prefixes = list(_ROOTS)
    # a relative markdown link resolves against the doc that carries it
    prefixes.append(os.path.dirname(citing_doc) + "/")
    for prefix in prefixes:
        base = os.path.normpath(os.path.join(root, prefix + path))
        if os.path.exists(base):
            return True
        # an inventory row may cite a module without its extension
        if any(os.path.exists(base + ext) for ext in (".ts", ".tsx", ".json", "/index.ts")):
            return True
    # TypeScript ESM: import './gate.js' in source points to gate.ts on disk.
    # A doc that cites './gate.js' (explaining an import chain) is citing a real file.
    if path.endswith(".js"):
        ts_stem = path[:-3]
        for ts_ext in (".ts", ".tsx"):
            ts_path = ts_stem + ts_ext
            if ts_path in facts["tracked"]:
                return True
            ts_needle = "/" + ts_path
            if any(t.endswith(ts_needle) for t in facts["tracked"]):
                return True
    return False


def _resolves_in_package(root: str, facts: dict, pkg: str, tail: str) -> bool:
    """`@lyik/types/token` -> packages/types/src/token.ts, via the package's own dir."""
    d = facts["pkgdirs"].get(pkg)
    if not d:
        return False
    for candidate in (f"{d}/{tail}", f"{d}/src/{tail}"):
        for ext in ("", ".ts", ".tsx", ".json", "/index.ts", "/index.tsx"):
            if os.path.exists(os.path.join(root, candidate + ext)):
                return True
    return False


def _finding(kind: str, token: str, line: str, lineno: int, window: str = "") -> dict:
    return {
        "kind": kind,
        "token": token,
        "line": lineno,
        "deliberate?": bool(DELIBERATE.search(window or line)),
        "context": line.strip()[:160],
    }


def _git_ignored(root: str, path: str) -> bool:
    """Generated output (`apps/web/docs/api/`, `dist/`) is absent by design, not stale."""
    return (
        subprocess.run(
            ["git", "check-ignore", "-q", path], cwd=root, capture_output=True
        ).returncode
        == 0
    )


def main() -> int:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    as_json = "--json" in sys.argv
    only = None
    if "--only" in sys.argv:
        only = args.pop(0) if args else None
    root = args[0] if args else "."
    root = os.path.abspath(root)

    global _ROOTS
    _ROOTS = workspace_roots(root)

    docs = []
    for d in ("docs", "docs/architecture", "docs/plain-english"):
        full = os.path.join(root, d)
        if not os.path.isdir(full):
            continue
        docs += [f"{d}/{f}" for f in sorted(os.listdir(full)) if f.endswith(".md")]
    if os.path.exists(os.path.join(root, "README.md")):
        docs.append("README.md")
    if "--include-historical" not in sys.argv:
        # This one documents the *old* v2 repo on purpose; its paths are meant to be absent.
        docs = [d for d in docs if "v2-v3-gap-analysis" not in d]
    docs = [d for d in docs if not _git_ignored(root, d)]
    if only:
        docs = [d for d in docs if d.endswith(only) or only.endswith(d)]

    files = tracked_files(root)
    facts = {
        "idents": source_identifiers(root, files),
        "exports": export_subpaths(root),
        "packages": package_names(root, files),
        "basenames": basenames(files),
        "tracked": set(files),
        "pkgdirs": package_dirs(root, files),
    }

    report = {}
    for rel in docs:
        found = check_doc(root, rel, facts)
        if found:
            report[rel] = found

    if as_json:
        print(json.dumps(report, indent=2))
        return 0

    total = sum(len(v) for v in report.values())
    hard = sum(1 for v in report.values() for f in v if not f["deliberate?"])
    for rel, found in report.items():
        print(f"\n{rel}")
        for f in found:
            flag = " (deliberate?)" if f["deliberate?"] else ""
            print(f"  {f['line']:>4}  {f['kind']:<6} {f['token']}{flag}")
            print(f"        {f['context']}")
    print(f"\n{total} unresolved claim(s) in {len(report)} file(s); {hard} not obviously deliberate")
    return 1 if hard else 0


if __name__ == "__main__":
    sys.exit(main())
