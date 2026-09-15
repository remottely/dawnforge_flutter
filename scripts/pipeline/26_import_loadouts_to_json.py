#!/usr/bin/env python3
"""Step 26 — starting loadouts: `progression/*.md` → generated JSON + manifest.

The Flutter-track twin of the Godot repo's `26_import_loadouts_to_tres.py`,
reshaped the way step 04 was (decision D3): the Godot step renders a `.tres`
with one `ItemAmount` sub-resource per entry; here the loadout IS the emitted
JSON, read by `IStartingLoadoutData.fromJson` and routed by the manifest into
`LoadoutRegistry`. Same SSOT (`games/<game>/data/progression/*.md`), same two
fields (`entries`, `granted_xp`), both REQUIRED — an omitted one is not a
default: an empty `entries` list is a real answer (*this loadout grants
nothing*) and absence is not.

One check the Godot step leaves to runtime is made here, because it is cheap
here and a crash in the player's first second there: every entry id must be
an authored item DOCUMENT in the pack. `ItemRegistry.get` would throw at boot
anyway (rule 5); failing in the pipeline names the file.

    .venv/bin/python dawnforge.py loadouts              # write
    .venv/bin/python dawnforge.py loadouts --dry-run    # list, write nothing
    .venv/bin/python dawnforge.py loadouts --check      # exit 1 on drift
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import (  # noqa: E402
    PROGRESSION_DATA_ROOT,
    PROGRESSION_GENERATED_ROOT,
    PROJECT_ROOT,
    object_documents,
)

OUTPUT_ROOT = PROGRESSION_GENERATED_ROOT
MANIFEST_NAME = "manifest.json"
GENERATED_BY = "scripts/pipeline/26_import_loadouts_to_json.py"
LOADOUT_TYPE = "i_starting_loadout_data"


def _frontmatter(text: str, source: Path) -> dict:
    """The YAML document of one loadout file (same contract as step 04)."""
    if not text.startswith("---"):
        raise SystemExit(f"[26] {source}: no YAML frontmatter")
    body = text[3:]
    closing = body.find("\n---")
    yaml_text = body[:closing] if closing != -1 else body
    data = yaml.safe_load(yaml_text)
    if not isinstance(data, dict):
        raise SystemExit(f"[26] {source}: frontmatter is not a mapping")
    return data


def _authored_item_ids() -> set[str]:
    """Every item document's id — the stem IS the id (rule 7)."""
    return {
        document.stem for document, _ in object_documents()
        if "_item_" in document.stem
    }


def _read_loadout(source: Path, item_ids: set[str]) -> dict:
    """One emitted loadout, validated exactly as `IStartingLoadoutData` will."""
    doc = _frontmatter(source.read_text(encoding="utf-8"), source)
    where = f"[26] {source.name}"
    if "entries" not in doc:
        raise SystemExit(f"{where}: `entries` is required — author [] for a "
                         f"loadout that grants nothing, never omit")
    if "granted_xp" not in doc:
        raise SystemExit(f"{where}: `granted_xp` is required — author 0 for none")
    raw = doc["entries"]
    if not isinstance(raw, list):
        raise SystemExit(f"{where}: `entries` must be a list, got {raw!r}")
    entries: list[dict] = []
    for index, row in enumerate(raw):
        if not isinstance(row, dict) or set(row) != {"id", "amount"}:
            raise SystemExit(f"{where}: entries[{index}] must be exactly "
                             f"`id` + `amount`, got {row!r}")
        item_id = row["id"]
        amount = row["amount"]
        if not isinstance(item_id, str) or not item_id:
            raise SystemExit(f"{where}: entries[{index}] has an empty id")
        if item_id not in item_ids:
            raise SystemExit(f"{where}: entries[{index}] names {item_id!r}, "
                             f"which is no authored item document")
        if not isinstance(amount, int) or isinstance(amount, bool) or amount < 1:
            raise SystemExit(f"{where}: {item_id} has amount {amount!r}; "
                             f"a positive whole number or nothing")
        entries.append({"id": item_id, "amount": amount})
    xp = doc["granted_xp"]
    if not isinstance(xp, int) or isinstance(xp, bool) or xp < 0:
        raise SystemExit(f"{where}: `granted_xp` must be zero or a positive "
                         f"whole number, got {xp!r}")
    return {
        "id": source.stem,
        "type": LOADOUT_TYPE,
        "entries": entries,
        "granted_xp": xp,
    }


def build_outputs() -> dict[str, str]:
    """Every output as {relative_path: file_content}, deterministic order."""
    if not PROGRESSION_DATA_ROOT.is_dir():
        raise SystemExit(
            f"[26] the pack has no {PROGRESSION_DATA_ROOT.relative_to(PROJECT_ROOT)} "
            f"— it must hold at least starting_loadout_default.md; the boot asks for it")
    sources = sorted(PROGRESSION_DATA_ROOT.glob("*.md"))
    if not sources:
        raise SystemExit(f"[26] no loadout .md under {PROGRESSION_DATA_ROOT}")
    item_ids = _authored_item_ids()

    outputs: dict[str, str] = {}
    manifest_entries: list[dict] = []
    for source in sources:
        loadout = _read_loadout(source, item_ids)
        relative_path = f"{loadout['id']}.json"
        outputs[relative_path] = json.dumps(
            loadout, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
        manifest_entries.append(
            {"id": loadout["id"], "type": loadout["type"], "path": relative_path}
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
        print(f"[26][dry-run] {len(outputs) - 1} loadouts + manifest; nothing written.")
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
            print(f"[26][check] {len(drifted)} file(s) drifted from the .md SSOT:")
            for path in drifted:
                print(f"  {path}")
            return 1
        print(f"[26][check] {len(outputs)} files match the SSOT.")
        return 0

    if OUTPUT_ROOT.is_dir():
        for old in OUTPUT_ROOT.rglob("*.json"):
            old.unlink()
    for path, content in outputs.items():
        target = OUTPUT_ROOT / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
    print(f"[26] wrote {len(outputs) - 1} loadouts + manifest -> "
          f"{OUTPUT_ROOT.relative_to(PROJECT_ROOT)}")
    return 0


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    sys.exit(run(dry_run=args.dry_run, check=args.check))
