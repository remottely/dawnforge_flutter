#!/usr/bin/env python3
"""Pipeline step 02 — cut every authored sprite out of the central atlas.

The Dart twin of the Godot repo's `02_extract_sprites_from_atlas.py`, with two
deliberate deltas: Pillow instead of ~600 ImageMagick spawns (one library call
per crop, no external binary), and output under `GENERATED_ROOT` instead of
inside the pack — generated pixels are build output here (rule 17), and the
`res://data/…` path each `.md` authors is treated as the pack's internal URI
scheme, mapped per engine (`ContentPaths.resolveRes` on the Dart side).

Authored metadata, same anchored regexes as the Godot step:

    _sprites:
      atlas_position: [x, y]     # in TILES, where to cut from
      frames_grid: [cols, rows]  # grid of frames (default [1, 1])
    …
    spritesheet: "res://data/…/sprites/<id>.png"   # where to put it
    frame_size: [w, h]           # in TILES (default [1, 1])

Crop rect: position*tile → (frame_size*tile) × frames_grid. A crop that is
empty or runs past the atlas is a content bug and crashes (rule 5). A file
declaring `atlas_position` without `spritesheet` is half-authored — crash.

    .venv/bin/python dawnforge.py sprites [--dry-run]
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import (  # noqa: E402
    ALMANAC_ROOT,
    ATLAS_ROOT,
    GENERATED_ROOT,
    PROJECT_ROOT,
)

TILE_DIMENSION = 16
"""Matches `GameConstants.tileDimension` (lib/src/core/shared_logic/definitions/
game_constants.dart); step 08 (shared-logic) will generate this bridge when it
is ported — until then the pair is kept in sync by the atlas filename check
below, which encodes the tile size."""

RES_PREFIX = "res://data/"

LFS_POINTER_HEADER = b"version https://git-lfs.github.com/spec/v1"


def _line_key(key: str, value_pattern: str) -> re.Pattern:
    """Anchored at line start: unanchored, `frame_size:` also matched
    `primary_action_frame_size: [0, 0]` and the crop became the whole atlas."""
    return re.compile(rf"^\s*{key}:\s*{value_pattern}", re.MULTILINE)


ATLAS_POSITION_RE = _line_key("atlas_position", r"\[(\d+),\s*(\d+)\]")
SPRITESHEET_RE = _line_key("spritesheet", r"[\"']?(res://[^\"'\n\s]+)[\"']?")
FRAME_SIZE_RE = _line_key("frame_size", r"\[(\d+),\s*(\d+)\]")
FRAMES_GRID_RE = _line_key("frames_grid", r"\[(\d+),\s*(\d+)\]")


def atlas_path() -> Path:
    """The single atlas the pack ships. Zero or two is a content bug."""
    candidates = sorted(ATLAS_ROOT.glob("*.png")) if ATLAS_ROOT.is_dir() else []
    if len(candidates) != 1:
        raise SystemExit(
            f"[02] expected exactly one atlas .png under {ATLAS_ROOT}, "
            f"found {len(candidates)}"
        )
    atlas = candidates[0]
    if f"{TILE_DIMENSION}x{TILE_DIMENSION}" not in atlas.name:
        raise SystemExit(
            f"[02] atlas '{atlas.name}' does not carry the engine tile size "
            f"{TILE_DIMENSION}px — pack and engine disagree"
        )
    return atlas


def res_to_output(res_path: str, source: Path) -> Path:
    if not res_path.startswith(RES_PREFIX):
        raise SystemExit(
            f"[02] {source.name}: `spritesheet` must start with {RES_PREFIX}, "
            f"got {res_path!r}"
        )
    return GENERATED_ROOT / res_path[len(RES_PREFIX):]


def run(dry_run: bool = False, check: bool = False) -> int:
    del check  # not checkable: pixel output is verified by skip-if-identical below
    atlas_file = atlas_path()
    raw = atlas_file.read_bytes()
    if raw[:len(LFS_POINTER_HEADER)] == LFS_POINTER_HEADER:
        raise SystemExit(
            f"[02] {atlas_file} is a git-lfs pointer, not an image — "
            f"materialize it first"
        )
    atlas = Image.open(atlas_file)
    atlas_w, atlas_h = atlas.size

    updated = 0
    skipped = 0
    for md in sorted(ALMANAC_ROOT.rglob("*.md")):
        content = md.read_text(encoding="utf-8")
        pos_match = ATLAS_POSITION_RE.search(content)
        if not pos_match:
            continue

        sheet_match = SPRITESHEET_RE.search(content)
        if not sheet_match:
            raise SystemExit(
                f"[02] {md.name}: declares `atlas_position` but no "
                f"`spritesheet:` to write to."
            )
        size_match = FRAME_SIZE_RE.search(content)
        grid_match = FRAMES_GRID_RE.search(content)

        pos = (int(pos_match.group(1)), int(pos_match.group(2)))
        frame = (
            (int(size_match.group(1)), int(size_match.group(2)))
            if size_match else (1, 1)
        )
        grid = (
            (int(grid_match.group(1)), int(grid_match.group(2)))
            if grid_match else (1, 1)
        )

        x = pos[0] * TILE_DIMENSION
        y = pos[1] * TILE_DIMENSION
        w = frame[0] * TILE_DIMENSION * grid[0]
        h = frame[1] * TILE_DIMENSION * grid[1]
        if w <= 0 or h <= 0:
            raise SystemExit(
                f"[02] {md.name}: crop size must be positive, got {w}x{h} "
                f"(frame_size={list(frame)}, frames_grid={list(grid)})"
            )
        if x + w > atlas_w or y + h > atlas_h:
            raise SystemExit(
                f"[02] {md.name}: crop {w}x{h}+{x}+{y} runs past the "
                f"{atlas_w}x{atlas_h} atlas (atlas_position={list(pos)})"
            )

        dest = res_to_output(sheet_match.group(1).strip(), md)
        if dry_run:
            print(f"[dry-run] {md.name}: atlas {list(pos)} -> "
                  f"{dest.relative_to(PROJECT_ROOT)}")
            updated += 1
            continue

        crop = atlas.crop((x, y, x + w, y + h))
        if dest.is_file():
            with Image.open(dest) as existing:
                if existing.size == crop.size and existing.tobytes() == crop.tobytes():
                    skipped += 1
                    continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        crop.save(dest)
        print(f"[02] {md.name} (atlas {list(pos)} -> {dest.relative_to(PROJECT_ROOT)})")
        updated += 1

    print(f"[02] done — updated: {updated} | identical: {skipped}")
    return 0


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    sys.exit(run(dry_run=args.dry_run))
