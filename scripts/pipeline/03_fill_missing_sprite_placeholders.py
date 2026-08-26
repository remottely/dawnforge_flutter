#!/usr/bin/env python3
"""Pipeline step 03 — fill missing sprites with tier placeholder templates.

The Dart twin of the Godot repo's `03_fill_missing_sprite_placeholders.py`.
After step 02 cut everything the atlas provides, any `.md` whose `spritesheet:`
target still does not exist gets a placeholder copied from the pack's template
set (`data/templates/sprites/t<tier>_template_<size>.png`), so the renderer
never meets a missing file: content that lacks final art shows the tier's
placeholder instead of crashing an asset load.

Tier comes from the filename (`t3_item_…` → t3) or the parent folder, falling
back to t1. Armor items and actors take the double-size template (32x32 at a
16px tile); everything else the base one — same sizing rule as the Godot step.

    .venv/bin/python dawnforge.py placeholders [--dry-run]
"""
from __future__ import annotations

import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import ALMANAC_ROOT, PROJECT_ROOT, TEMPLATES_ROOT  # noqa: E402

step02 = __import__("02_extract_sprites_from_atlas")

TIERS = range(1, 6)  # t1..t5 — mirrors the Godot repo's tier_enums SSOT
BASE_SIZE = f"{step02.TILE_DIMENSION}x{step02.TILE_DIMENSION}"
DOUBLE_SIZE = f"{step02.TILE_DIMENSION * 2}x{step02.TILE_DIMENSION * 2}"


def detect_tier(md: Path) -> str:
    for part in md.stem.split("_"):
        if part.startswith("t") and part[1:].isdigit() and int(part[1:]) in TIERS:
            return part
    parent = md.parent.name
    if parent.startswith("t") and parent[1:].isdigit() and int(parent[1:]) in TIERS:
        return parent
    return f"t{TIERS.start}"


def template_for(md: Path) -> Path:
    size = (
        DOUBLE_SIZE
        if "_item_armor" in md.stem or "_actor_" in md.stem
        else BASE_SIZE
    )
    template = TEMPLATES_ROOT / "sprites" / f"{detect_tier(md)}_template_{size}.png"
    if not template.is_file():
        raise SystemExit(f"[03] template missing: {template}")
    return template


def run(dry_run: bool = False, check: bool = False) -> int:
    del check  # not checkable: fills gaps, never owns the files it wrote
    created = 0
    present = 0
    for md in sorted(ALMANAC_ROOT.rglob("*.md")):
        content = md.read_text(encoding="utf-8")
        sheet_match = step02.SPRITESHEET_RE.search(content)
        if not sheet_match:
            continue  # no spritesheet authored at all — nothing to place hold
        dest = step02.res_to_output(sheet_match.group(1).strip(), md)
        if dest.is_file():
            present += 1
            continue
        template = template_for(md)
        if dry_run:
            print(f"[dry-run] {md.name}: {template.name} -> "
                  f"{dest.relative_to(PROJECT_ROOT)}")
            created += 1
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(template, dest)
        print(f"[03] {md.name} <- {template.name}")
        created += 1

    print(f"[03] done — placeholders: {created} | already present: {present}")
    return 0


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    sys.exit(run(dry_run=args.dry_run))
