#!/usr/bin/env python3
"""Refuse a changelog pair that is out of order, duplicated, or not mirrored.

Rule 34 makes the two changelogs the player's record, and their header makes
four promises about their shape: newest first, one section per version, the
seven categories in one fixed order, and en/pt-BR saying the same things.
None of the four was checked by anything: at 0.47.0 both files carried
`0.45.4` and `0.45.3` ABOVE `0.47.0` — a parallel session's sections landed in
the wrong place — and 0.48.0 repaired it by hand (plan FP0.16).

What is checked, in both files and across them:

- every `## ` section names a version `M.m.p`, or is the ONE pending
  `## 0.0.0-NEXT` at the top that the commit command stamps;
- versions are strictly newest-first and no version appears twice;
- every `### ` heading is one of the seven categories, in the fixed order,
  none twice in a section, and a section has at least one;
- both files carry the same versions in the same order, and the same
  categories per version — the mirror rule 34 asks for.

Two modes, because the suite runs BEFORE the stamp and CI runs after:

    python3 scripts/project/check_changelog_is_ordered.py           # pending section allowed
    python3 scripts/project/check_changelog_is_ordered.py --check   # exit 1 on a surviving 0.0.0-NEXT too

The suite script (`check_test_suite_is_clean.py`) runs the first form as its
opening half: a broken changelog fails the suite before the analyzer starts.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import DAWNFORGE_ROOT, PROJECT_ROOT  # noqa: E402

CHANGELOGS: tuple[Path, ...] = (
    DAWNFORGE_ROOT / "CHANGELOG.md",
    DAWNFORGE_ROOT / "CHANGELOG.pt-BR.md",
)
PENDING = "0.0.0-NEXT"
CATEGORIES: tuple[str, ...] = (
    "💥 Breaking Changes",
    "✨ New",
    "🔧 Changed",
    "⚖️ Balance",
    "🐛 Fixed",
    "🎨 Art & Audio",
    "🧹 Internal",
)
SECTION = re.compile(r"^## (.+?)\s*$", re.M)
CATEGORY = re.compile(r"^### (.+?)\s*$", re.M)
VERSION = re.compile(r"^(\d+)\.(\d+)\.(\d+)$")


def sections(text: str) -> list[tuple[str, list[str]]]:
    """`[(version, [category, ...]), ...]` in file order."""
    found: list[tuple[str, list[str]]] = []
    matches = list(SECTION.finditer(text))
    for index, match in enumerate(matches):
        start = match.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        found.append((match.group(1), CATEGORY.findall(text[start:end])))
    return found


def problems(text: str, label: str, strict: bool) -> list[str]:
    """Every shape violation in one file, as sentences naming the file."""
    out: list[str] = []
    parsed = sections(text)
    if not parsed:
        return [f"{label}: no `## ` sections at all"]
    seen: set[str] = set()
    previous: tuple[int, int, int] | None = None
    for position, (version, categories) in enumerate(parsed):
        if version == PENDING:
            if strict:
                out.append(f"{label}: `## {PENDING}` survived — the commit command stamps it")
            elif position != 0:
                out.append(f"{label}: `## {PENDING}` is not the first section")
        else:
            match = VERSION.match(version)
            if match is None:
                out.append(f"{label}: `## {version}` is not a version")
            else:
                current = tuple(int(n) for n in match.groups())
                if previous is not None and current >= previous:
                    out.append(f"{label}: `## {version}` sits below a version that is not newer")
                previous = current
        if version in seen:
            out.append(f"{label}: `## {version}` appears twice")
        seen.add(version)

        if not categories:
            out.append(f"{label}: `## {version}` has no category")
        last = -1
        for category in categories:
            if category not in CATEGORIES:
                out.append(f"{label}: `## {version}` has an unknown category `### {category}`")
                continue
            rank = CATEGORIES.index(category)
            if rank == last:
                out.append(f"{label}: `## {version}` repeats `### {category}`")
            elif rank < last:
                out.append(f"{label}: `## {version}` has `### {category}` out of order")
            last = rank
    return out


def mirror_problems(texts: dict[str, str]) -> list[str]:
    """Where the two files disagree about which versions and categories exist."""
    labels = list(texts)
    if len(labels) != 2:
        return []
    first, second = (sections(texts[label]) for label in labels)
    if [v for v, _ in first] != [v for v, _ in second]:
        return [f"{labels[0]} and {labels[1]} do not carry the same versions in the same order"]
    out: list[str] = []
    for (version, a), (_, b) in zip(first, second):
        if a != b:
            out.append(f"`## {version}`: {labels[0]} has {a} and {labels[1]} has {b}")
    return out


def run(check: bool) -> int:
    texts: dict[str, str] = {}
    for path in CHANGELOGS:
        if not path.is_file():
            print(f"[changelog] missing: {path.relative_to(PROJECT_ROOT)}")
            return 1
        texts[str(path.relative_to(PROJECT_ROOT))] = path.read_text(encoding="utf-8")
    found: list[str] = []
    for label, text in texts.items():
        found.extend(problems(text, label, strict=check))
    found.extend(mirror_problems(texts))
    if found:
        print(f"[changelog] {len(found)} problem(s):")
        for line in found:
            print(f"  {line}")
        return 1
    count = len(sections(next(iter(texts.values()))))
    print(f"[changelog] {count} sections, ordered and mirrored in both languages.")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true",
                        help="also refuse a surviving 0.0.0-NEXT (post-commit / CI)")
    args = parser.parse_args()
    sys.exit(run(check=args.check))
