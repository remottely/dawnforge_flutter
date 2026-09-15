#!/usr/bin/env python3
"""Refuse a `tr('key')` in `lib/` whose key is missing from any emitted locale table.

Rule 19 sends every user-facing string through `tr()` with a key, and rule 5
makes a missing key CRASH — at render, in `LocalizationSystem.tr`, which is
the moment a player opens the surface. That is later than a red suite (plan
FP0.17). The pipeline's step 05 already refuses a key translated in one locale
and missing in another; what nobody checked is the CODE side: a key typed in
Dart that no locale carries at all.

What is checked: every string-LITERAL argument to `tr(` under `lib/` exists
in every `assets/generated/<game>/locales/*.json`. A call whose argument is
not a literal (a variable, an interpolation) cannot be checked here and is
COUNTED and printed, never swallowed — a rising count is a surface building
keys at runtime, which is its own conversation.

    python3 scripts/project/check_translation_keys.py           # report; exit 1 on a missing key
    python3 scripts/project/check_translation_keys.py --check   # the same (kept for rule 23's shape)

Runs from the suite script (`check_test_suite_is_clean.py`).
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import LIB_ROOT, LOCALES_ROOT, PROJECT_ROOT  # noqa: E402

TR_CALL = re.compile(r"(?<![\w.])(?<!String )tr\(\s*([^)]*?)\s*\)", re.S)
"""Every `tr(...)` CALL: not a method on something (`foo.tr(` is not ours) and
not a declaration (`String tr(String key)` — the function and the method that
define it were counted as two uncheckable calls at 0.52.0)."""
LITERAL = re.compile(r"^(['\"])([^'\"$]+)\1$")
"""A plain single- or double-quoted literal with no interpolation."""


def literal_keys(dart: str) -> tuple[set[str], int]:
    """`(keys, non_literal_calls)` for one file's text.

    Comment lines are dropped first: the doc comments that explain rule 19
    mention `tr()` by name, and prose is not a call. An EMPTY argument is
    skipped too — it cannot compile, so it can only be prose inside a string.
    """
    code = "\n".join(
        line for line in dart.splitlines() if not line.lstrip().startswith("//"))
    keys: set[str] = set()
    dynamic = 0
    for argument in TR_CALL.findall(code):
        argument = argument.strip().rstrip(",").strip()
        if not argument:
            continue
        match = LITERAL.match(argument)
        if match is None:
            dynamic += 1
        else:
            keys.add(match.group(2))
    return keys, dynamic


def locale_tables() -> dict[str, set[str]]:
    """`{locale: keys}` from every emitted table."""
    tables: dict[str, set[str]] = {}
    for path in sorted(LOCALES_ROOT.glob("*.json")):
        table = json.loads(path.read_text(encoding="utf-8"))
        strings = table.get("strings")
        if not isinstance(strings, dict):
            raise SystemExit(f"[tr] {path.relative_to(PROJECT_ROOT)}: no strings map")
        tables[path.stem] = set(strings)
    if not tables:
        raise SystemExit(f"[tr] no locale tables under {LOCALES_ROOT.relative_to(PROJECT_ROOT)} "
                         f"— run the pipeline first")
    return tables


def run() -> int:
    tables = locale_tables()
    used: dict[str, list[str]] = {}
    dynamic_total = 0
    for dart in sorted(LIB_ROOT.rglob("*.dart")):
        keys, dynamic = literal_keys(dart.read_text(encoding="utf-8"))
        dynamic_total += dynamic
        for key in keys:
            used.setdefault(key, []).append(str(dart.relative_to(PROJECT_ROOT)))
    missing: list[str] = []
    for key, files in sorted(used.items()):
        absent = [locale for locale, keys in tables.items() if key not in keys]
        if absent:
            missing.append(f"`{key}` ({', '.join(files)}) missing in {', '.join(absent)}")
    print(f"[tr] {len(used)} literal keys across {len(tables)} locales; "
          f"{dynamic_total} non-literal tr() call(s) not checkable here.")
    if missing:
        print(f"[tr] {len(missing)} key(s) no locale carries:")
        for line in missing:
            print(f"  {line}")
        return 1
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true", help="same as the default run")
    parser.parse_args()
    sys.exit(run())
