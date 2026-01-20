#!/usr/bin/env python3
"""
Lint helper: forbid raw StringName literals (&"foo") outside const declarations.

Rules:
- StringNames must be defined as consts, preferably under game/utils/constants/ or
  a local module-level const.
- Any non-const usage of &"..." is flagged.
"""

from __future__ import annotations

import sys
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    violations: list[tuple[Path, int, str]] = []
    consts_outside_constants: list[tuple[Path, int, str]] = []

    for path in root.rglob("*.gd"):
        # Skip addon cache or import metadata.
        if ".import" in path.parts:
            continue

        try:
            content = path.read_text(encoding="utf-8").splitlines()
        except OSError as exc:
            print(f"lint_stringnames: failed to read {path}: {exc}", file=sys.stderr)
            return 1

        for lineno, line in enumerate(content, start=1):
            if '&"' not in line:
                continue
            stripped = line.lstrip()
            if stripped.startswith("#"):
                continue
            if stripped.startswith("const "):
                # Track consts defined outside the shared constants directory.
                rel = path.relative_to(root)
                if not str(rel).startswith("game/utils/constants") and not str(rel).startswith("tests/"):
                    consts_outside_constants.append((rel, lineno, line.rstrip()))
                continue
            violations.append((path.relative_to(root), lineno, line.rstrip()))

    if violations:
        print("Found raw StringName literals (use consts instead):")
        for path, lineno, text in violations:
            print(f"  {path}:{lineno}: {text}")
        return 1

    if consts_outside_constants:
        print("Notice: StringName consts outside game/utils/constants/ (ensure they are truly file-local):")
        for path, lineno, text in consts_outside_constants:
            print(f"  {path}:{lineno}: {text}")

    print("OK: no raw StringName literals found.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
