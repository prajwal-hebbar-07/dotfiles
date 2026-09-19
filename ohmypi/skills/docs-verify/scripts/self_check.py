#!/usr/bin/env python3
"""Prove check-claims.py catches stale claims and stays quiet about true ones.

Builds a throwaway repo in a temp dir, writes one doc holding known-good and
known-bad citations, and asserts the checker's verdict on each. Run it after
touching the extractor:

    python3 self_check.py
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
CHECKER = os.path.join(HERE, "check-claims.py")

DOC = """# Test

## 2. Inventory

| Module | Exports |
| --- | --- |
| `packages/thing/src/live.ts` | `liveExport` |
| `packages/thing/src/gone.ts` | `deadExport` |
| `src/live.ts` | `alsoLive` |
| `renderer/live.ts` | cited as a tail of a real path |
| `theme.json` | cited by bare name |
| `packages/thing/src/{live,gone}.ts` | brace expansion, one of each |

Imported as `@scope/thing/live` and, wrongly, as `@scope/thing/missing`.
A third-party deep import, `@vendor/lib/internals`, is not ours to check.

The spec imports `./live.js` which is the TypeScript ESM alias for `live.ts`.
Hits the API at `api.vendor.sh` which is a remote endpoint.

Defaults not overridden — session length, cookie name, `SameSite`, minimum
password length — are whatever the auth library ships. Persona `PLATFORM_ADMIN` manages `SMALL_LOGO`.

They do not exist yet, but (`packages/thing/src/future.ts`, a planned module)
will be added in the next slice.

## 9. Debt

- **Dead code**: `removedExport` no longer exists anywhere.
- There is no root `absent.config.ts`.
- The library's `vendorHelper` method handles external tokens.
"""


def run(root: str) -> dict:
    out = subprocess.run(
        [sys.executable, CHECKER, root, "--json"], capture_output=True, text=True, check=True
    )
    return json.loads(out.stdout)


def main() -> int:
    with tempfile.TemporaryDirectory() as tmp:
        # a minimal workspace: one package, one app-ish config file, one doc
        os.makedirs(f"{tmp}/packages/thing/src/renderer")
        os.makedirs(f"{tmp}/apps/web/public/config")
        os.makedirs(f"{tmp}/docs/architecture")
        with open(f"{tmp}/packages/thing/package.json", "w") as fh:
            json.dump(
                {"name": "@scope/thing", "exports": {"./*": "./src/*.ts"},
                 "dependencies": {"@vendor/lib": "1.0.0"}},
                fh,
            )
        for rel, body in {
            "packages/thing/src/live.ts": "export const liveExport = 1;\nexport const alsoLive = 2;\n",
            "packages/thing/src/renderer/live.ts": "export const inRenderer = 3;\n",
            "apps/web/public/config/theme.json": "{}\n",
            "docs/architecture/01-test.md": DOC,
        }.items():
            with open(f"{tmp}/{rel}", "w") as fh:
                fh.write(body)

        subprocess.run(["git", "init", "-q"], cwd=tmp, check=True)
        subprocess.run(["git", "add", "-A"], cwd=tmp, check=True)

        report = run(tmp)
        found = {(f["kind"], f["token"]): f for v in report.values() for f in v}
        tokens = {t for _, t in found}

        # must be reported: they do not exist
        must_flag = {
            "packages/thing/src/gone.ts": "path that does not exist",
            "deadExport": "symbol that does not exist",
            "@scope/thing/missing": "deep import with no file behind it",
        }
        # must stay quiet: they resolve, or are deliberate absences
        must_pass = {
            "packages/thing/src/live.ts": "path that exists",
            "liveExport": "symbol that exists",
            "alsoLive": "symbol in a file cited package-relative",
            "src/live.ts": "package-relative path",
            "renderer/live.ts": "path cited as a tail",
            "theme.json": "bare file name held somewhere in the repo",
            "@scope/thing/live": "deep import that resolves",
            "@vendor/lib/internals": "third-party deep import",
            # new rules
            "SameSite": "HTTP cookie attribute in NOT_CODE",
            "PLATFORM_ADMIN": "platform persona in NOT_CODE",
            "SMALL_LOGO": "asset type in NOT_CODE",
            "./live.js": "TypeScript ESM .js alias resolves to .ts source",
            "packages/thing/src/future.ts": "path absent but 'do not exist' makes it deliberate",
            "api.vendor.sh": "domain name endpoint with .sh extension",
        }

        failures = []
        # hard_tokens: tokens that appear with deliberate?=false
        hard_tokens = {t for (_, t), f in found.items() if not f["deliberate?"]}

        for token, why in must_flag.items():
            if token not in hard_tokens:
                failures.append(f"MISSED  {token} ({why})")
        for token, why in must_pass.items():
            if token in hard_tokens:
                failures.append(f"FALSE+  {token} ({why})")
        # the brace form must report its dead half, naming the member that is missing
        brace = "packages/thing/src/{live,gone}.ts"
        if not any(t.startswith(brace) and "gone.ts" in t for t in hard_tokens):
            failures.append("MISSED  brace form whose second member is absent")
        # deliberate absences must be marked, not dropped
        for token in ("removedExport", "absent.config.ts", "vendorHelper"):
            hit = next((f for (k, t), f in found.items() if t == token), None)
            if hit and not hit["deliberate?"]:
                failures.append(f"UNMARKED {token} (a stated absence, not a stale claim)")
        # "do not exist" (plural) must also mark a path deliberate, not raise a hard finding
        if "packages/thing/src/future.ts" in hard_tokens:
            failures.append("UNMARKED packages/thing/src/future.ts ('do not exist' plural not recognised as deliberate)")
        # SameSite must be completely absent (NOT_CODE, not even a deliberate finding)
        if any(t == "SameSite" for (_, t) in found):
            failures.append("FALSE+  SameSite (HTTP cookie attribute should be in NOT_CODE)")
        if any(t in ("PLATFORM_ADMIN", "SMALL_LOGO") for (_, t) in found):
            failures.append("FALSE+  PLATFORM_ADMIN/SMALL_LOGO should be in NOT_CODE")
        # ./live.js must be completely absent (.js → .ts resolution)
        if any(t == "./live.js" for (_, t) in found):
            failures.append("FALSE+  ./live.js (TypeScript ESM alias should resolve to live.ts)")

        for line in failures:
            print(line)
        total = len(must_flag) + len(must_pass) + 4  # brace, do-not-exist, SameSite, ./live.js
        print(f"\n{total - len(failures)}/{total} checks passed")
        return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

