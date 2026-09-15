#!/usr/bin/env python3
"""Dawnforge Developer Toolkit — the single cross-platform entrypoint.

Port of the Godot repo's `dawnforge.py`: wraps the ordered content pipeline in
`scripts/pipeline/`. Step numbering is SHARED with the Godot repo — a step keeps
its number even while unported, so cross-repo references stay valid.

Usage:
    .venv/bin/python dawnforge.py <command> [--dry-run|--check]

Commands:
    import         Convert almanac .md into generated JSON (step 04)
    full           Run every ported step, in order

Unported steps (numbers reserved, arriving with their systems): 06 islands,
07 biome-spawns, 08 shared-logic (→ generates .dart here), 09 procedural
spawns, 12 sfx-defaults.
"""
import argparse
import importlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PIPELINE = ROOT / "scripts" / "pipeline"
sys.path.insert(0, str(PIPELINE))
sys.path.insert(0, str(ROOT / "scripts" / "lib"))

# Maps each CLI command to the pipeline module that implements it. The numeric
# prefix is the execution order, and `full` walks this table top to bottom.
STEP_MODULES: dict[str, str] = {
    "sprites": "02_extract_sprites_from_atlas",
    "placeholders": "03_fill_missing_sprite_placeholders",
    "import": "04_import_almanac_to_json",
    "translations": "05_build_translation_tables",
    "component-keys": "10_generate_component_keys",
    "biome-terrain": "11_import_biome_terrain_to_json",
    "loadouts": "26_import_loadouts_to_json",
}

# Steps that can verify the generated files against their SSOT without writing.
CHECKABLE: tuple[str, ...] = (
    "import", "translations", "component-keys", "biome-terrain", "loadouts")


def run_step(command: str, dry_run: bool, check: bool) -> int:
    module = importlib.import_module(STEP_MODULES[command])
    return int(module.run(dry_run=dry_run, check=check) or 0)


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=[*STEP_MODULES, "full"])
    parser.add_argument("--dry-run", action="store_true",
                        help="report what would be written, write nothing")
    parser.add_argument("--check", action="store_true",
                        help="compare generated output against the SSOT; exit 1 on drift")
    args = parser.parse_args()

    commands = list(STEP_MODULES) if args.command == "full" else [args.command]
    for command in commands:
        if args.check and command not in CHECKABLE:
            continue
        code = run_step(command, dry_run=args.dry_run, check=args.check)
        if code != 0:
            return code
    return 0


if __name__ == "__main__":
    sys.exit(main())
