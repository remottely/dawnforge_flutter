#!/usr/bin/env python3
"""Single source of truth for every path an automation script needs.

Ported from the Godot repo's `scripts/lib/project_paths.py` (rule 23): each script
importing a constant here instead of hand-counting `Path(__file__).resolve().parents[N]`,
so moving a script one folder deeper never silently points it at the wrong tree.

Repo layout (decision D7, `docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md`):

    lib/src/core/        the ENGINE (Tessera-Dart). Knows no game's folder names (rule 29).
    lib/src/generated/   generated Dart content/wiring — never hand-edited (rule 17).
    games/<game>/        a game: its content pack (`data/`), changelogs and manual.
    assets/generated/    pipeline JSON output per game — never hand-edited.
    scripts/ docs/       shared automation and builder-facing documents.
    reference/           archived material (legacy_flutter/) — never read (rule 10).

Usage from any script under `scripts/`:

    import sys
    from pathlib import Path
    sys.path.insert(0, str(next(
        p / "lib" for p in Path(__file__).resolve().parents
        if (p / "lib" / "project_paths.py").is_file())))
    from project_paths import DATA_ROOT, PROJECT_ROOT
"""
import os
from pathlib import Path

_MARKERS = ("pubspec.yaml", "lib", "scripts")


def _find_project_root(start: Path) -> Path:
    """Walk up from `start` until the folder holding the Flutter package is found."""
    for candidate in (start, *start.parents):
        if all((candidate / marker).exists() for marker in _MARKERS):
            return candidate
    raise SystemExit(
        f"[project_paths] Repo root not found above {start} — "
        f"expected a folder containing {', '.join(_MARKERS)}."
    )


PROJECT_ROOT: Path = _find_project_root(Path(__file__).resolve().parent)
"""Repo root — the folder holding `pubspec.yaml`, `lib/` and `scripts/`."""

LIB_ROOT: Path = PROJECT_ROOT / "lib"
SRC_ROOT: Path = LIB_ROOT / "src"

CORE_ROOT: Path = SRC_ROOT / "core"
"""The engine half of the engine-vs-content split — reusable across games."""

GENERATED_DART_ROOT: Path = SRC_ROOT / "generated"
"""Generated Dart (key tables, wiring). Content, never logic (rule 17)."""

SHARED_LOGIC_ROOT: Path = CORE_ROOT / "shared_logic"
DEFINITIONS_ROOT: Path = SHARED_LOGIC_ROOT / "definitions"
COMPONENTS_ROOT: Path = CORE_ROOT / "components"
CORE_RESOURCES_ROOT: Path = CORE_ROOT / "resources"
"""The data classes every `.md` is authored against — the SSOT for which fields exist."""

GAMES_ROOT: Path = PROJECT_ROOT / "games"
"""One folder per game: content pack, changelogs, player manual."""


def available_games() -> list[str]:
    """Every game in the repository, by folder name, sorted."""
    if not GAMES_ROOT.is_dir():
        return []
    return sorted(p.name for p in GAMES_ROOT.iterdir() if (p / "data").is_dir())


def game_root(game_name: str) -> Path:
    root = GAMES_ROOT / game_name
    if not root.is_dir():
        raise SystemExit(
            f"[project_paths] No game named '{game_name}' — expected {root}. "
            f"Known games: {', '.join(available_games()) or '(none)'}."
        )
    return root


_GAME_ENV = "TESSERA_GAME"

ACTIVE_GAME: str = os.environ.get(_GAME_ENV, "dawnforge")
"""The game every path below resolves against. Same environment contract as the Godot
repo: `dawnforge.py --pack <game>` sets it; constants are fixed at import time."""

if ACTIVE_GAME not in available_games():
    raise SystemExit(
        f"[project_paths] {_GAME_ENV}='{ACTIVE_GAME}' names no game. "
        f"Known games: {', '.join(available_games()) or '(none)'}."
    )

DAWNFORGE_ROOT: Path = GAMES_ROOT / ACTIVE_GAME
"""Root of the active game (its pack, changelogs, manual)."""

DATA_ROOT: Path = DAWNFORGE_ROOT / "data"
"""The active game's authored content pack — Markdown+YAML, the SSOT (rule 31)."""

if not DATA_ROOT.is_dir():
    raise SystemExit(
        f"[project_paths] {DATA_ROOT} is missing — game '{ACTIVE_GAME}' has no content pack."
    )


def pack_root(game_name: str) -> Path:
    """The content pack of `<game_name>`, whether or not it is the active game."""
    root = game_root(game_name) / "data"
    if not root.is_dir():
        raise SystemExit(f"[project_paths] Game '{game_name}' has no content pack at {root}.")
    return root


ALMANAC_ROOT: Path = DATA_ROOT / "forge_almanac"
"""The living `.md` content database."""

PLAYER_DATA_ROOT: Path = DATA_ROOT / "player"
"""The player's own document. Beside the almanac rather than inside it because
the player belongs to no biome, no tier and no workstation — the same place the
Godot pack keeps it."""

OBJECT_DOCUMENT_ROOTS: tuple[tuple[Path, str], ...] = (
    (ALMANAC_ROOT, ""),
    (PLAYER_DATA_ROOT, "player"),
)
"""Every pack root holding WORLD-OBJECT documents, with the prefix each one's
output takes under the generated almanac. Steps 02, 03 and 04 all walk this —
a root added to one step and forgotten in another is a document that imports
without a sprite, or gets a sprite nothing imports."""


def object_documents() -> list[tuple[Path, Path]]:
    """`(document, output directory)` for every world-object `.md` in the pack.

    The output directory is relative to the generated almanac root, so a
    document's JSON lands where the manifest says it does regardless of which
    pack root it came from.

    A root that does not exist contributes nothing: a pack without a `player/`
    document has no player yet, which is a state of a young pack and not a
    failure (rule 20). An EMPTY almanac is a different matter and its own
    step's problem — that one has to be authored.
    """
    found: list[tuple[Path, Path]] = []
    for root, prefix in OBJECT_DOCUMENT_ROOTS:
        if not root.is_dir():
            continue
        for document in sorted(root.rglob("*.md")):
            found.append((document, Path(prefix) / document.parent.relative_to(root)))
    return found


ATLAS_ROOT: Path = DATA_ROOT / "atlas"
TEMPLATES_ROOT: Path = DATA_ROOT / "templates"
WORLD_DATA_ROOT: Path = DATA_ROOT / "world"
AUDIO_ROOT: Path = DATA_ROOT / "audio"
UI_DATA_ROOT: Path = DATA_ROOT / "ui"

ASSETS_ROOT: Path = PROJECT_ROOT / "assets"

GENERATED_ROOT: Path = ASSETS_ROOT / "generated" / ACTIVE_GAME
"""Everything the pipeline writes FOR THE ACTIVE GAME (JSON + sprite manifests).
Never hand-edited (rule 17). Registries boot from here via the asset bundle."""

LOCALES_ROOT: Path = GENERATED_ROOT / "locales"
"""Generated translation tables — the pack's own text."""

SCRIPTS_ROOT: Path = PROJECT_ROOT / "scripts"
DOCS_ROOT: Path = PROJECT_ROOT / "docs"
TESTS_ROOT: Path = PROJECT_ROOT / "test"

REFERENCE_ROOT: Path = PROJECT_ROOT / "reference"
"""Archived material (legacy_flutter/). Never indexed, never read as prior art (rule 10)."""

CLAUDE_DIR: Path = PROJECT_ROOT / ".claude"
SKILLS_ROOT: Path = CLAUDE_DIR / "skills"

AI_CACHE_DIR: Path = CLAUDE_DIR / "cache"
"""Machine-local derived data for the AI harness (the knowledge index lives here).
Gitignored — nothing in it is authored, everything is rebuildable."""
