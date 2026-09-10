#!/usr/bin/env python3
"""Run the whole verification suite: `flutter analyze` then `flutter test`. Exit 0 = green.

The one command every task runs before its commit (CLAUDE.md §Execution Workflow step 3).
"The suite is green" means every half passed:

- **the changelog pair** in shape (`check_changelog_is_ordered.py`, FP0.16) — newest
  first, mirrored in both languages, categories in their fixed order.

- **`flutter analyze`** at zero issues — the analyzer *is* half the rule set here
  (rule 4's strict typing lives in `analysis_options.yaml`), so an info-level lint is a
  failure, not a note.
- **`flutter test`** — the whole `test/` tree, which mirrors `lib/src/`.

    python3 scripts/project/check_test_suite_is_clean.py              # both halves
    python3 scripts/project/check_test_suite_is_clean.py --analyze-only
    python3 scripts/project/check_test_suite_is_clean.py --test-only  # quick iteration,
                                                                      # never a commit's proof
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import PROJECT_ROOT  # noqa: E402


def _run(label: str, args: list[str]) -> int:
    print(f"\n── {label}: {' '.join(args)}")
    result = subprocess.run(args, cwd=PROJECT_ROOT)
    print(f"── {label}: {'✅ clean' if result.returncode == 0 else f'❌ exit {result.returncode}'}")
    return result.returncode


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--analyze-only", action="store_true", help="skip the tests")
    group.add_argument("--test-only", action="store_true", help="skip the analyzer")
    args = parser.parse_args()

    codes: list[int] = []
    # The changelog pair first (FP0.16): cheapest half, and a broken record is
    # a failed task under rule 34 whatever the code does. The pending
    # `0.0.0-NEXT` is allowed here because the suite runs BEFORE the stamp.
    codes.append(_run("changelog", [
        sys.executable, "scripts/project/check_changelog_is_ordered.py"]))
    if not args.test_only:
        # --fatal-infos: an info is a failure — the analyzer is half the rule set (rule 4).
        codes.append(_run("analyze", ["flutter", "analyze", "--fatal-infos"]))
    if not args.analyze_only:
        codes.append(_run("test", ["flutter", "test"]))

    clean = all(code == 0 for code in codes)
    print(f"\n{'✅ suite is clean' if clean else '❌ suite is NOT clean'}")
    return 0 if clean else 1


if __name__ == "__main__":
    sys.exit(main())
