#!/usr/bin/env python3
"""Pipeline step 05 — build per-locale translation tables from the `.md` pack.

The Dart twin of the Godot repo's `05_build_translation_tables.py`, retargeted:
Godot rebuilt a CSV for its own importer; here each locale becomes one JSON map
at `GENERATED_ROOT/locales/<locale>.json`, loaded by the Dart
`LocalizationSystem` (rule 19: every user-facing string goes through `tr()`).

TWO sources, one table per locale:

1. What the CONTENT says — the `translations:` block of every almanac `.md`:

       display_name_key: forge_almanac.…​.display_name
       translations:
         display_name: {en: "…", pt_BR: "…", es: "…"}
         description:  {en: "…", pt_BR: "…", es: "…"}

   The key of a translated field is the document's own `<field>_key`, because
   the field names repeat across hundreds of files and cannot name themselves.

2. What the INTERFACE says — the `strings:` block under `UI_DATA_ROOT`, where
   each entry names its own key:

       strings:
         ui.menu.tab.inventory: {en: "…", pt_BR: "…", es: "…"}

   No authored world object owns the word on a button, so without this source
   rule 19 has nowhere to put it. (The Godot repo keeps these in a hand-written
   `translations_static.csv` inside its *generated* folder; here rules 17 and 31
   put them in the pack instead — same keys, pack format. See `ui_strings.md`.)

Every locale seen anywhere in either source gets a table, and a key translated
in one locale but missing in another is a HOLE the check reports — a key that
resolves in en and crashes in pt_BR is the worst kind of localization bug, found
at build time here instead (rule 5 at the pipeline altitude).

    .venv/bin/python dawnforge.py translations [--dry-run|--check]
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
    ALMANAC_ROOT, LOCALES_ROOT, PROJECT_ROOT, UI_DATA_ROOT, object_documents,
)

GENERATED_BY = "scripts/pipeline/05_build_translation_tables.py"


def _frontmatter(text: str, source: Path) -> dict:
    if not text.startswith("---"):
        raise SystemExit(f"[05] {source}: no YAML frontmatter")
    body = text[3:]
    closing = body.find("\n---")
    data = yaml.safe_load(body[:closing] if closing != -1 else body)
    if not isinstance(data, dict):
        raise SystemExit(f"[05] {source}: frontmatter is not a mapping")
    return data


def _absorb(
    tables: dict[str, dict[str, str]],
    per_locale: object,
    key: str,
    source: Path,
    where: str,
) -> None:
    """Writes one key's `{locale: text}` mapping into every locale's table."""
    if not isinstance(per_locale, dict):
        raise SystemExit(f"[05] {source}: {where} is not a mapping")
    for locale, text in per_locale.items():
        if not isinstance(text, str):
            raise SystemExit(f"[05] {source}: {where}.{locale} is not a string")
        table = tables.setdefault(str(locale), {})
        if key in table and table[key] != text:
            raise SystemExit(f"[05] {source}: key '{key}' translated twice ({locale})")
        table[key] = text


def _collect_content_strings(tables: dict[str, dict[str, str]]) -> None:
    """Source 1: the `translations:` block of every world-object document.

    Walks the same roots step 04 imports (`OBJECT_DOCUMENT_ROOTS`), not the
    almanac alone: a document that becomes game data and a document that
    carries game text are the same document, and a root known to one step and
    not the other is an object whose name resolves nowhere.
    """
    sources = object_documents()
    if not sources:
        raise SystemExit(f"[05] no .md files under {ALMANAC_ROOT}")

    for source, _ in sources:
        doc = _frontmatter(source.read_text(encoding="utf-8"), source)
        translations = doc.get("translations")
        if translations is None:
            continue
        if not isinstance(translations, dict):
            raise SystemExit(f"[05] {source}: translations is not a mapping")
        for field, per_locale in translations.items():
            key = doc.get(f"{field}_key")
            if not isinstance(key, str) or not key:
                raise SystemExit(
                    f"[05] {source}: translated field '{field}' has no "
                    f"'{field}_key' — the key is how tr() reaches it"
                )
            _absorb(tables, per_locale, key, source, f"translations.{field}")


def _collect_interface_strings(tables: dict[str, dict[str, str]]) -> None:
    """Source 2: the `strings:` block of every document under `UI_DATA_ROOT`.

    A pack with no `ui/` folder at all says nothing in its own interface yet —
    a legitimate state of a young pack, not a recovery (rule 20). A folder that
    exists and holds no document is the mistake, and says so.
    """
    if not UI_DATA_ROOT.is_dir():
        return
    sources = sorted(UI_DATA_ROOT.rglob("*.md"))
    if not sources:
        raise SystemExit(f"[05] {UI_DATA_ROOT} exists but holds no .md")

    for source in sources:
        doc = _frontmatter(source.read_text(encoding="utf-8"), source)
        strings = doc.get("strings")
        if not isinstance(strings, dict):
            raise SystemExit(
                f"[05] {source}: no 'strings' mapping — an interface document "
                f"exists to carry one"
            )
        for key, per_locale in strings.items():
            if not isinstance(key, str) or not key:
                raise SystemExit(f"[05] {source}: '{key}' is not a usable key")
            _absorb(tables, per_locale, key, source, f"strings.{key}")


def build_tables() -> tuple[dict[str, dict[str, str]], list[str]]:
    """({locale: {key: text}}, holes) from the pack's content and interface."""
    tables: dict[str, dict[str, str]] = {}
    holes: list[str] = []
    _collect_content_strings(tables)
    _collect_interface_strings(tables)

    all_keys = {key for table in tables.values() for key in table}
    for locale, table in sorted(tables.items()):
        for key in sorted(all_keys - set(table)):
            holes.append(f"{locale}: missing '{key}'")
    return tables, holes


def _outputs(tables: dict[str, dict[str, str]]) -> dict[str, str]:
    return {
        f"{locale}.json": json.dumps(
            {"generated_by": GENERATED_BY, "strings": dict(sorted(table.items()))},
            ensure_ascii=False, indent=2,
        ) + "\n"
        for locale, table in sorted(tables.items())
    }


def run(dry_run: bool = False, check: bool = False) -> int:
    tables, holes = build_tables()
    outputs = _outputs(tables)

    for hole in holes:
        print(f"[05][hole] {hole}")

    if dry_run:
        for name, table in sorted(tables.items()):
            print(f"{LOCALES_ROOT.relative_to(PROJECT_ROOT) / (name + '.json')}: "
                  f"{len(table)} strings")
        print(f"[05][dry-run] nothing written. holes: {len(holes)}")
        return 0

    if check:
        drifted = [
            name for name, content in outputs.items()
            if not (LOCALES_ROOT / name).is_file()
            or (LOCALES_ROOT / name).read_text(encoding="utf-8") != content
        ]
        stale = (
            {p.name for p in LOCALES_ROOT.glob("*.json")} - set(outputs)
            if LOCALES_ROOT.is_dir() else set()
        )
        drifted.extend(f"{name} (stale)" for name in sorted(stale))
        if drifted or holes:
            for name in drifted:
                print(f"[05][check] drifted: {name}")
            print(f"[05][check] FAILED — {len(drifted)} drifted, {len(holes)} holes.")
            return 1
        print(f"[05][check] {len(outputs)} locale tables match the SSOT, no holes.")
        return 0

    LOCALES_ROOT.mkdir(parents=True, exist_ok=True)
    for old in LOCALES_ROOT.glob("*.json"):
        if old.name not in outputs:
            old.unlink()
    for name, content in outputs.items():
        (LOCALES_ROOT / name).write_text(content, encoding="utf-8")
    total = sum(len(t) for t in tables.values())
    print(f"[05] wrote {len(outputs)} locale tables ({total} strings) -> "
          f"{LOCALES_ROOT.relative_to(PROJECT_ROOT)}; holes: {len(holes)}")
    return 0


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    sys.exit(run(dry_run=args.dry_run, check=args.check))
