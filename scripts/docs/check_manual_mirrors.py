#!/usr/bin/env python3
"""Refuse a player manual whose `en/` and `pt-BR/` halves have stopped mirroring each other.

WHAT RULE 34 PROMISES, AND WHAT NOTHING CHECKED. Every player-visible commit ships its
manual page in `games/<game>/docs/manual/en/` **and** `pt-BR/` — "same filename, same
heading order". That promise had no enforcement here, while its twin for the changelogs
got `check_changelog_is_ordered.py` the day it was written (`L-010`).

The asymmetry matters because the failure is silent in exactly the way a changelog's is
not. A missing changelog section is noticed by the next person writing one. A manual page
that exists only in English is noticed by a Brazilian seven-year-old, who is not in this
repository.

WHAT IT CHECKS, per game:

    filenames   `en/` and `pt-BR/` hold the same set of `.md` files
    shape       each pair has the same number of headings, at the same levels, in the
                same order — the structure survives translation even though no word does

WHAT IT DELIBERATELY DOES NOT CHECK:

    heading TEXT   translated by definition. Levels and order are the whole comparable part.
    map ⊆ files    a page listed in the section map and not yet written is a PLAN, not a
                   defect. The converse — a page nobody listed — is the defect.

THE SECTION MAP IS THE HALF THIS SCRIPT CANNOT FINISH YET. The spec's twin also asserts
that every page which EXISTS is listed in `manual/README.md`, and this manual has no
README: writing one means naming the pages, and page names are the port plan's `D-4`,
still open. So the map check is reported as NOT RUN, in words, with the decision it waits
on — never silently skipped and never counted as a pass. The moment `README.md` exists
the check runs against it with no further edit; that is the shape of the guard, not a
promise about it.
"""
import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import available_games, game_root  # noqa: E402

# Every heading in these trees is ATX. Fenced code can contain `#`, so fences are tracked
# rather than trusted.
_HEADING = re.compile(r"^(#{1,6})\s+\S")
_FENCE = re.compile(r"^\s*(```|~~~)")

LOCALES = ("en", "pt-BR")


def manual_root(game: str) -> Path:
    return game_root(game) / "docs" / "manual"


def pages(locale_dir: Path) -> set[str]:
    if not locale_dir.is_dir():
        return set()
    return {p.name for p in locale_dir.glob("*.md")}


def heading_levels(path: Path) -> list[int]:
    """The page's shape: one integer per heading, in order. Fenced blocks are skipped."""
    levels: list[int] = []
    in_fence = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if _FENCE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        match = _HEADING.match(line)
        if match:
            levels.append(len(match.group(1)))
    return levels


def mapped_pages(readme: Path) -> set[str]:
    """Every `page.md` named anywhere in the README.

    Read from the whole file rather than from one section: a map that moved a line down
    is not the failure this looks for.
    """
    return set(re.findall(r"`([a-z0-9-]+\.md)`", readme.read_text(encoding="utf-8")))


def check_game(game: str) -> tuple[list[str], bool]:
    """`(problems, map_was_checked)` for one game's manual."""
    root = manual_root(game)
    if not root.is_dir():
        return [f"{game}: no manual at {root}"], False

    problems: list[str] = []
    english, portuguese = pages(root / "en"), pages(root / "pt-BR")

    for name in sorted(english - portuguese):
        problems.append(f"{game}: en/{name} has no pt-BR/ mirror")
    for name in sorted(portuguese - english):
        problems.append(f"{game}: pt-BR/{name} has no en/ mirror")

    for name in sorted(english & portuguese):
        en_shape = heading_levels(root / "en" / name)
        pt_shape = heading_levels(root / "pt-BR" / name)
        if en_shape != pt_shape:
            problems.append(
                f"{game}: {name} — en/ has {len(en_shape)} heading(s) {en_shape} and "
                f"pt-BR/ has {len(pt_shape)} {pt_shape}; the prose is translated, the "
                f"structure is not")

    readme = root / "README.md"
    if not readme.is_file():
        return problems, False

    listed = mapped_pages(readme)
    for name in sorted((english | portuguese) - listed - {"README.md"}):
        problems.append(
            f"{game}: {name} exists and the README's section map does not list it — "
            f"adding a page silently is how a section map becomes a folder listing")
    return problems, True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true",
                        help="exit 1 on any mismatch (the mode the suite runs)")
    parser.parse_args()

    problems: list[str] = []
    unmapped: list[str] = []
    for game in available_games():
        game_problems, map_checked = check_game(game)
        problems.extend(game_problems)
        if not map_checked:
            unmapped.append(game)

    for problem in problems:
        print(f"  ✗ {problem}")
    if problems:
        print(f"\n[manual] {len(problems)} problem(s). `en/` and `pt-BR/` hold the same "
              f"filenames and the same heading structure — rule 34.")
        return 1

    print(f"[manual] {', '.join(available_games())}: filenames and heading structure "
          f"mirror cleanly in {' + '.join(LOCALES)}.")
    for game in unmapped:
        print(f"[manual] ⚠️  NOT CHECKED for {game}: the section map "
              f"({manual_root(game).name}/README.md) does not exist, so 'every page is "
              f"listed' was not verified. It waits on the port plan's D-4, the page-name "
              f"decision (FP0.15). This line is not a pass.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
