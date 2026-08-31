#!/usr/bin/env python3
"""Step 04 — convert the almanac `.md` pack into generated JSON.

The Flutter-track twin of the Godot repo's `04_import_almanac_to_tres.py`, and
deliberately much smaller: `.tres` needed a per-class field table
(`HIER_BLOCK_FIELDS`) to bind typed script properties, but JSON carries the
authored values verbatim — TYPED validation lives on the Dart side, in each
data class's `fromReader` constructor (`lib/src/core/resources/`), which is the
single place a field's type and default are declared. This emitter therefore
never restates a field list; it flattens and passes through.

What it does per world-object `.md` (every root in `OBJECT_DOCUMENT_ROOTS`):

1. Parse the YAML frontmatter (everything between the opening `---` and the
   closing `---`, or the whole file when unclosed).
2. Flatten the hierarchical class blocks (`ItemData:`, `IWorldObjectData:`, …)
   into ONE flat object, next to the scalar top-level keys (`type`, `id`,
   `display_name_key`, `description_key`). A key authored in two blocks with
   two different values is invalid content — crash, never pick one (rule 5).
3. Drop `translations` (step 05's input) and every `_`-prefixed block
   (`_sprites` is step 02's input) — they are pipeline inputs, not game data.
4. Write `GENERATED_ROOT/forge_almanac/<relative-dirs>/<id>.json`, and one
   `manifest.json` listing every entry (id, type, path) — what the Dart
   `AlmanacLoader` boots the registries from.

Enums stay as their AUTHORED NAMES (`HOE`, `FORBIDDEN`); the Dart `JsonReader`
matches them case-insensitively ignoring underscores.

    .venv/bin/python dawnforge.py import              # write
    .venv/bin/python dawnforge.py import --dry-run    # list, write nothing
    .venv/bin/python dawnforge.py import --check      # exit 1 on drift
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
    ALMANAC_ROOT, GENERATED_ROOT, PROJECT_ROOT, object_documents,
)

OUTPUT_ROOT = GENERATED_ROOT / "forge_almanac"
MANIFEST_NAME = "manifest.json"
GENERATED_BY = "scripts/pipeline/04_import_almanac_to_json.py"



def _frontmatter(text: str, source: Path) -> dict:
    """The YAML document of one almanac file."""
    if not text.startswith("---"):
        raise SystemExit(f"[04] {source}: no YAML frontmatter")
    body = text[3:]
    closing = body.find("\n---")
    yaml_text = body[:closing] if closing != -1 else body
    data = yaml.safe_load(yaml_text)
    if not isinstance(data, dict):
        raise SystemExit(f"[04] {source}: frontmatter is not a mapping")
    return data


def flatten_entry(doc: dict, source: Path) -> dict:
    """One flat JSON object from the hierarchical class blocks."""
    flat: dict = {}

    def put(key: str, value: object) -> None:
        if key in flat and flat[key] != value:
            raise SystemExit(
                f"[04] {source}: key '{key}' authored twice with different "
                f"values ({flat[key]!r} vs {value!r}) — fix the content"
            )
        flat[key] = value

    for key, value in doc.items():
        if key == "translations" or key.startswith("_"):
            continue  # pipeline inputs for other steps, not game data
        if isinstance(value, dict) and key[:1].isupper():
            # A CLASS BLOCK (`PropData:`, `IWorldObjectData:` — the pack's
            # authoring convention is PascalCase for class blocks, snake_case
            # for fields): its entries are the fields. No field table here —
            # what a field means, its type and its default are declared once,
            # in the Dart data class that reads it.
            for field, field_value in value.items():
                put(field, field_value)
        else:
            # A top-level field (type, id, *_key, spawn weights, structured
            # maps like stage_drop_configs) passes through verbatim, nested
            # shape preserved.
            put(key, value)

    for required in ("type", "id"):
        if required not in flat:
            raise SystemExit(f"[04] {source}: missing '{required}'")
    if flat["id"] != source.stem:
        raise SystemExit(
            f"[04] {source}: id '{flat['id']}' != filename '{source.stem}'"
        )
    return flat


def build_outputs() -> dict[str, str]:
    """Every output as {relative_path: file_content}, deterministic order."""
    sources = object_documents()
    if not sources:
        raise SystemExit(f"[04] no .md files under {ALMANAC_ROOT}")

    outputs: dict[str, str] = {}
    manifest_entries: list[dict] = []
    for source, relative_dir in sources:
        flat = flatten_entry(_frontmatter(source.read_text(encoding="utf-8"), source), source)
        relative_path = str(relative_dir / f"{flat['id']}.json")
        outputs[relative_path] = json.dumps(flat, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
        manifest_entries.append(
            {"id": flat["id"], "type": flat["type"], "path": relative_path}
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
        print(f"[04][dry-run] {len(outputs) - 1} entries + manifest; nothing written.")
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
        stale = on_disk - set(outputs)
        for path in sorted(stale):
            drifted.append(f"{path} (stale — source .md gone)")
        if drifted:
            print(f"[04][check] {len(drifted)} file(s) drifted from the .md SSOT:")
            for path in drifted:
                print(f"  {path}")
            return 1
        print(f"[04][check] {len(outputs)} files match the SSOT.")
        return 0

    # Full rewrite: clear stale outputs, then write everything.
    if OUTPUT_ROOT.is_dir():
        for old in OUTPUT_ROOT.rglob("*.json"):
            old.unlink()
    for path, content in outputs.items():
        target = OUTPUT_ROOT / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")
    print(f"[04] wrote {len(outputs) - 1} entries + manifest -> "
          f"{OUTPUT_ROOT.relative_to(PROJECT_ROOT)}")
    return 0


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    sys.exit(run(dry_run=args.dry_run, check=args.check))
