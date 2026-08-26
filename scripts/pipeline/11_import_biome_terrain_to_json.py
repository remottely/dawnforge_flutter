#!/usr/bin/env python3
"""Step 11 — biome terrain density: `world/procedural/*.md` → generated JSON.

The Flutter-track twin of the Godot repo's `11_patch_biome_terrain_density.py`,
reshaped the same way step 04 was (decision D3): the Godot step PATCHES the
authored densities into biome `.tres` resources that exist independently; here
the biome resource IS the emitted JSON, so this step emits it whole. Same SSOT
(`games/<game>/data/world/procedural/procedural_<biome>.md`), same field names
as `BiomeData` on the engine side.

The five densities are SHARES OF THE WORLD, never noise values — the
ProceduralWorldManager converts each share into a noise cut through its own
quantile table at boot. The validation here repeats the manager's on purpose:
failing in the pipeline names the file, failing at boot only says the world
could not be generated.

Scope: SURFACE biomes only (`procedural_<biome>.md`). The cave layer's
`procedural_cave_<biome>.md` files carry the `cave_terrain_*` shares and join
this step when the cave layer is ported. The population tables (`limits`,
`density_noise`, `prop_entries`, `actor_entries`) — the Godot repo's step 09
subject (`09_import_procedural_spawns_to_tres.py`) — are folded in here since
FP4.1a, because this step already emits the biome resource whole: a second
step patching the same JSON would give one file two owners under `--check`.

    .venv/bin/python dawnforge.py biome-terrain              # write
    .venv/bin/python dawnforge.py biome-terrain --dry-run    # list, write nothing
    .venv/bin/python dawnforge.py biome-terrain --check      # exit 1 on drift
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import GENERATED_ROOT, PROJECT_ROOT, WORLD_DATA_ROOT  # noqa: E402

PROCEDURAL_DIR = WORLD_DATA_ROOT / "procedural"
OUTPUT_ROOT = GENERATED_ROOT / "world" / "biomes"
MANIFEST_NAME = "manifest.json"
GENERATED_BY = "scripts/pipeline/11_import_biome_terrain_to_json.py"

# md key under `terrain:` -> emitted field. Same mapping as the Godot step 11,
# so a density authored once reads identically on both engines.
TERRAIN_FIELDS: tuple[tuple[str, str], ...] = (
    ("water", "terrain_water_share"),
    ("wall", "terrain_wall_share"),
    ("wall_height2", "terrain_wall_height2_share"),
    ("wall_height3", "terrain_wall_height3_share"),
)

# Population entry contracts: {key: (required, validator)}. Key sets are CLOSED —
# an unrecognized key is a typo, and a typo'd optional key would otherwise
# silently become its default (the exact silent fallback rule 5 exists to kill:
# `densty_influence:` reading as "even spread" ships a wrong world, quietly).
_PROP_ENTRY_KEYS: dict[str, tuple[bool, str]] = {
    "prop_id": (True, "id"),
    "attempts_per_chunk": (True, "count"),
    "spawn_chance": (True, "chance"),
    "cluster_min": (True, "count"),
    "cluster_max": (True, "count"),
    "cluster_radius": (True, "count"),
    "density_influence": (False, "share"),
}
_ACTOR_ENTRY_KEYS: dict[str, tuple[bool, str]] = {
    "actor_id": (True, "id"),
    "pack_chance": (True, "chance"),
    "pack_min": (True, "count"),
    "pack_max": (True, "count"),
    "pack_radius": (True, "count"),
}


def _checked_entry(source: Path, block: str, index: int, entry: object,
                   keys: dict[str, tuple[bool, str]]) -> dict:
    """One population entry, every key validated by its declared kind."""
    where = f"[11] {source.name}: {block}[{index}]"
    if not isinstance(entry, dict):
        raise SystemExit(f"{where} is not a mapping")
    for key in entry:
        if key not in keys:
            raise SystemExit(f"{where}: unknown key {key!r}")
    checked: dict = {}
    for key, (required, kind) in keys.items():
        value = entry.get(key)
        if value is None:
            if required:
                raise SystemExit(f"{where}: missing {key!r}")
            checked[key] = 0.0  # density_influence: declared default, even spread
            continue
        if kind == "id":
            if not isinstance(value, str) or not value:
                raise SystemExit(f"{where}: {key} {value!r} is not a non-empty string")
        elif kind == "count":
            if not isinstance(value, int) or isinstance(value, bool) or value < 1:
                raise SystemExit(f"{where}: {key} {value!r} is not an int >= 1")
        elif kind == "chance":
            if not isinstance(value, (int, float)) or isinstance(value, bool) \
                    or not 0.0 < float(value) <= 1.0:
                raise SystemExit(f"{where}: {key} {value!r} outside (0, 1]")
            value = float(value)
        else:  # share
            if not isinstance(value, (int, float)) or isinstance(value, bool) \
                    or not 0.0 <= float(value) <= 1.0:
                raise SystemExit(f"{where}: {key} {value!r} outside [0, 1]")
            value = float(value)
        checked[key] = value
    for lo, hi in (("cluster_min", "cluster_max"), ("pack_min", "pack_max")):
        if lo in checked and checked[lo] > checked[hi]:
            raise SystemExit(f"{where}: {lo} {checked[lo]} > {hi} {checked[hi]}")
    return checked


def _read_population(source: Path, doc: dict) -> dict:
    """The population half of a biome: limits, richness field, spawn tables."""
    limits = doc.get("limits")
    if not isinstance(limits, dict) or set(limits) != {
            "max_props_per_chunk", "max_actors_per_chunk"}:
        raise SystemExit(
            f"[11] {source.name}: `limits:` must carry exactly "
            f"max_props_per_chunk and max_actors_per_chunk"
        )
    for key, value in limits.items():
        if not isinstance(value, int) or isinstance(value, bool) or value < 0:
            raise SystemExit(f"[11] {source.name}: limits.{key} {value!r} "
                             f"is not an int >= 0")

    density_noise = doc.get("density_noise")
    if not isinstance(density_noise, dict) or set(density_noise) != {"frequency"}:
        raise SystemExit(
            f"[11] {source.name}: `density_noise:` must carry exactly frequency")
    frequency = density_noise["frequency"]
    if not isinstance(frequency, (int, float)) or isinstance(frequency, bool) \
            or float(frequency) <= 0.0:
        raise SystemExit(f"[11] {source.name}: density_noise.frequency "
                         f"{frequency!r} is not a number > 0")

    population: dict = {
        "max_props_per_chunk": limits["max_props_per_chunk"],
        "max_actors_per_chunk": limits["max_actors_per_chunk"],
        "density_noise_frequency": float(frequency),
    }
    for block, keys in (("prop_entries", _PROP_ENTRY_KEYS),
                        ("actor_entries", _ACTOR_ENTRY_KEYS)):
        entries = doc.get(block)
        if not isinstance(entries, list):
            raise SystemExit(f"[11] {source.name}: `{block}:` must be a list "
                             f"(author [] for a barren biome, never omit)")
        population[block] = [
            _checked_entry(source, block, i, entry, keys)
            for i, entry in enumerate(entries)
        ]
    cap_pairs = (("prop_entries", "max_props_per_chunk"),
                 ("actor_entries", "max_actors_per_chunk"))
    for block, cap in cap_pairs:
        if population[block] and population[cap] < 1:
            raise SystemExit(f"[11] {source.name}: {block} authored but "
                             f"{cap} is 0 — nothing could ever spawn")
    return population


def _frontmatter(text: str, source: Path) -> dict:
    """The YAML document of one biome file (same contract as step 04)."""
    if not text.startswith("---"):
        raise SystemExit(f"[11] {source}: no YAML frontmatter")
    body = text[3:]
    closing = body.find("\n---")
    yaml_text = body[:closing] if closing != -1 else body
    data = yaml.safe_load(yaml_text)
    if not isinstance(data, dict):
        raise SystemExit(f"[11] {source}: frontmatter is not a mapping")
    return data


def _read_biome(source: Path) -> dict:
    """One emitted biome object, validated exactly as the manager will."""
    doc = _frontmatter(source.read_text(encoding="utf-8"), source)

    layer = doc.get("layer")
    if layer != 0:
        raise SystemExit(
            f"[11] {source.name}: layer {layer!r} — surface biome files carry "
            f"layer 0; cave files are named procedural_cave_* and are unported"
        )
    tier = doc.get("tier")
    if not isinstance(tier, int) or tier < 1:
        raise SystemExit(f"[11] {source.name}: tier {tier!r} is not an int >= 1")

    terrain = doc.get("terrain")
    if not isinstance(terrain, dict):
        raise SystemExit(f"[11] {source.name}: no `terrain:` density block")

    biome: dict = {
        # `procedural_forest.md` -> `biome_forest_data`: the same id the Godot
        # step patches, so cross-repo references stay valid.
        "id": f"biome_{source.stem.removeprefix('procedural_')}_data",
        "type": "biome_data",
        "tier": tier,
    }
    for md_key, field in TERRAIN_FIELDS:
        value = terrain.get(md_key)
        if not isinstance(value, (int, float)) or isinstance(value, bool):
            raise SystemExit(
                f"[11] {source.name}: terrain.{md_key} {value!r} is not a number"
            )
        biome[field] = float(value)

    water = biome["terrain_water_share"]
    wall = biome["terrain_wall_share"]
    height2 = biome["terrain_wall_height2_share"]
    height3 = biome["terrain_wall_height3_share"]
    if not 0.0 < water < 1.0:
        raise SystemExit(f"[11] {source.name}: water share {water} outside (0, 1)")
    if not 0.0 < wall < 1.0:
        raise SystemExit(f"[11] {source.name}: wall share {wall} outside (0, 1)")
    if water + wall >= 1.0:
        raise SystemExit(
            f"[11] {source.name}: water {water} + wall {wall} leaves no floor"
        )
    if height2 <= 0.0 or height3 <= 0.0 or height2 + height3 >= 1.0:
        raise SystemExit(
            f"[11] {source.name}: wall height shares {height2} and {height3} "
            f"must each be > 0 and sum to < 1, or a height would be unreachable"
        )
    biome.update(_read_population(source, doc))
    return biome


def build_outputs() -> dict[str, str]:
    """Every output as {relative_path: file_content}, deterministic order."""
    sources = sorted(
        md for md in PROCEDURAL_DIR.glob("procedural_*.md")
        if not md.name.startswith("procedural_cave_")
    )
    if not sources:
        raise SystemExit(f"[11] no procedural_*.md under {PROCEDURAL_DIR}")

    outputs: dict[str, str] = {}
    manifest_entries: list[dict] = []
    tiers_seen: dict[int, str] = {}
    for source in sources:
        biome = _read_biome(source)
        tier = biome["tier"]
        if tier in tiers_seen:
            raise SystemExit(
                f"[11] {source.name}: tier {tier} already authored by "
                f"{tiers_seen[tier]} — one biome per tier"
            )
        tiers_seen[tier] = source.name
        relative_path = f"{biome['id']}.json"
        outputs[relative_path] = json.dumps(
            biome, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
        manifest_entries.append(
            {"id": biome["id"], "type": biome["type"], "path": relative_path}
        )

    manifest = {
        "generated_by": GENERATED_BY,
        "entries": sorted(manifest_entries, key=lambda e: e["id"]),
    }
    outputs[MANIFEST_NAME] = json.dumps(manifest, ensure_ascii=False, indent=2) + "\n"
    return outputs


def run(dry_run: bool = False, check: bool = False) -> int:
    outputs = build_outputs()

    if dry_run:
        for path in outputs:
            print(OUTPUT_ROOT.relative_to(PROJECT_ROOT) / path)
        print(f"[11][dry-run] {len(outputs) - 1} biomes + manifest; nothing written.")
        return 0

    if check:
        drifted: list[str] = []
        on_disk = {
            str(p.relative_to(OUTPUT_ROOT)) for p in OUTPUT_ROOT.rglob("*.json")
        } if OUTPUT_ROOT.is_dir() else set()
        for path, content in outputs.items():
            target = OUTPUT_ROOT / path
            if not target.is_file() or target.read_text(encoding="utf-8") != content:
                drifted.append(path)
        for path in sorted(on_disk - set(outputs)):
            drifted.append(f"{path} (stale — source .md gone)")
        if drifted:
            print(f"[11][check] {len(drifted)} file(s) drifted from the .md SSOT:")
            for path in drifted:
                print(f"  {path}")
            return 1
        print(f"[11][check] {len(outputs)} files match the SSOT.")
        return 0

    if OUTPUT_ROOT.is_dir():
        for old in OUTPUT_ROOT.rglob("*.json"):
            old.unlink()
    for path, content in outputs.items():
        target = OUTPUT_ROOT / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
    print(f"[11] wrote {len(outputs) - 1} biomes + manifest -> "
          f"{OUTPUT_ROOT.relative_to(PROJECT_ROOT)}")
    return 0


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    sys.exit(run(dry_run=args.dry_run, check=args.check))
