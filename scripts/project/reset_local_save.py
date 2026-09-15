#!/usr/bin/env python3
"""Wipe this machine's game state so the next launch starts a fresh world.

WHY THIS EXISTS. Nothing has shipped, so there is **no save migration**: a build reads a
save or refuses it, and nothing converts an old one. That is a deliberate trade — it buys
the freedom to change any persisted shape without writing a migration — and the price is
that a save written before a breaking change is not "old data", it is a **trap**: it
either fails to load, or loads and reconstructs the world the way the code used to be,
which reads as a brand-new bug in whatever was just changed. So the obligation is on
whoever makes the change, not on whoever plays next: land the change, run this, and the
next launch starts clean. `CLAUDE.md` rule 32 and §Execution Workflow step 6 both name
this command, and until now neither could run it (`L-004`).

WHERE THE STATE IS, AND WHY THE SCRIPT DOES NOT KNOW. Dart writes under
`getApplicationSupportDirectory()`, which every platform keys by the app's own identity —
the macOS bundle id, the Linux application id, the Windows company and product. Those
live in four platform files, and typing `com.remottely.dawnforge` here would be a fifth
copy that goes stale the first time somebody renames the app in the other four. This
script READS them, and refuses to run if they disagree with each other: an app whose four
identities have drifted apart writes its state to more than one place, and a reset that
sweeps one of them is worse than no reset at all.

WHAT IT DOES NOT TOUCH. Player *settings* survive by default. `shared_preferences` holds
key bindings, the chosen locale and the volume sliders; none of them is world state, and
clearing them turns "start a fresh world" into "re-do your settings". `--all` opts into
those, for the clean-room repro that needs it.

THE PORT DELTA. The spec's twin sweeps every GAME in its repository, because Godot keys
`user://` by `config/name` and three projects live there. This repository builds ONE
Flutter application: one bundle id, one application-support folder, whatever `ACTIVE_GAME`
says. So there is no `--game` here, and the bare command — the one rule 32 names — is
already the whole sweep.

    python3 scripts/project/reset_local_save.py [--dry-run] [--all]
"""
import argparse
import os
import platform
import re
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import PROJECT_ROOT  # noqa: E402

# What "the world" is, on disk: one entry per directory the game writes a world into,
# relative to the application-support folder. FP6.1 writes the first of these; the
# script exists before it does, which is the whole point of L-004.
WORLD_STATE: tuple[tuple[str, str], ...] = (
    ("saves", "save slots"),
)

# Settings, kept unless --all. `shared_preferences` writes one file per platform, and its
# name is the plugin's, not ours.
SETTINGS_FILES: tuple[str, ...] = (
    "shared_preferences.json",
)


def _read_identity() -> dict[str, str]:
    """The app's identity, read from the four places the platforms keep it.

    Never typed here. A constant in a script is a copy, and a copy of an id is the thing
    that still says `dawnforge` on the day the app is renamed everywhere else.
    """
    def one(path: Path, pattern: str) -> str:
        text = (PROJECT_ROOT / path).read_text(encoding="utf-8")
        found = re.search(pattern, text, re.MULTILINE)
        if found is None:
            raise SystemExit(
                f"[reset-save] {path} no longer carries the app's identity "
                f"(looked for /{pattern}/). The platform file changed shape; this script "
                f"must be taught the new one rather than guess the old value."
            )
        return found.group(1).strip()

    return {
        "macos_bundle_id": one(Path("macos/Runner/Configs/AppInfo.xcconfig"),
                               r"^PRODUCT_BUNDLE_IDENTIFIER\s*=\s*(.+)$"),
        "linux_app_id": one(Path("linux/CMakeLists.txt"),
                            r'^set\(APPLICATION_ID\s+"([^"]+)"\)'),
        "binary_name": one(Path("linux/CMakeLists.txt"),
                           r'^set\(BINARY_NAME\s+"([^"]+)"\)'),
        "windows_company": one(Path("windows/runner/Runner.rc"),
                               r'VALUE "CompanyName", "([^"]+)"'),
        "windows_product": one(Path("windows/runner/Runner.rc"),
                               r'VALUE "ProductName", "([^"]+)"'),
    }


def _assert_identities_agree(identity: dict[str, str]) -> None:
    """Four platform files, one app. A disagreement is a crash, never a guess (rule 5)."""
    bundle = identity["macos_bundle_id"]
    windows_joined = f"{identity['windows_company']}.{identity['windows_product']}"
    disagreements = [
        (name, value) for name, value in (
            ("linux/CMakeLists.txt APPLICATION_ID", identity["linux_app_id"]),
            ("windows/runner/Runner.rc CompanyName.ProductName", windows_joined),
        ) if value != bundle
    ]
    if disagreements:
        lines = "\n".join(f"    {name}: {value}" for name, value in disagreements)
        raise SystemExit(
            f"[reset-save] the app has more than one identity:\n"
            f"    macos/Runner/Configs/AppInfo.xcconfig: {bundle}\n{lines}\n"
            f"[reset-save] Each identity is a SEPARATE application-support folder, so a "
            f"sweep of one leaves a world behind in the other. Reconcile the platform "
            f"files first; this script will not choose between them."
        )


def _support_roots(identity: dict[str, str]) -> list[tuple[str, Path]]:
    """Every folder `getApplicationSupportDirectory()` can resolve to, with its label.

    Both macOS shapes are listed on purpose: the app is sandboxed today
    (`macos/Runner/Release.entitlements`), which puts the folder inside a container, but a
    build made before the entitlement — or with it removed — writes to the plain one, and
    a world left in the shape nobody sweeps is exactly the trap this script exists for.
    Only folders that EXIST are ever touched.
    """
    home = Path.home()
    bundle = identity["macos_bundle_id"]
    container = home / "Library/Containers" / bundle / "Data"
    xdg_data = Path(os.environ.get("XDG_DATA_HOME") or home / ".local/share")
    appdata = os.environ.get("APPDATA")

    roots: list[tuple[str, Path]] = [
        ("macOS (sandboxed)", container / "Library/Application Support" / bundle),
        ("macOS (unsandboxed)", home / "Library/Application Support" / bundle),
        ("Linux (binary name)", xdg_data / identity["binary_name"]),
        ("Linux (application id)", xdg_data / identity["linux_app_id"]),
    ]
    if appdata:
        roots.append(("Windows", Path(appdata) / identity["windows_company"]
                      / identity["windows_product"]))
    return roots


def _settings_paths(identity: dict[str, str], roots: list[tuple[str, Path]]) -> list[Path]:
    """Where `shared_preferences` keeps settings on each platform."""
    home = Path.home()
    bundle = identity["macos_bundle_id"]
    found: list[Path] = [
        home / "Library/Containers" / bundle / f"Data/Library/Preferences/{bundle}.plist",
        home / f"Library/Preferences/{bundle}.plist",
    ]
    for _, root in roots:
        found.extend(root / name for name in SETTINGS_FILES)
    return found


def _remove(target: Path, dry_run: bool) -> None:
    if dry_run:
        return
    if target.is_dir():
        shutil.rmtree(target)
    else:
        target.unlink()


def run(dry_run: bool, take_settings: bool) -> int:
    identity = _read_identity()
    _assert_identities_agree(identity)
    roots = _support_roots(identity)

    print(f"[reset-save] app identity: {identity['macos_bundle_id']} "
          f"(read from four platform files, not typed here)")
    print(f"[reset-save] running on {platform.system()}; every platform's folder is "
          f"checked, only what exists is touched.")

    removed = 0
    for label, root in roots:
        if not root.is_dir():
            continue
        print(f"[reset-save] {label}: {root}")
        for relative, description in WORLD_STATE:
            target = root / relative
            if not target.exists():
                continue
            print(f"[reset-save]   {'would remove' if dry_run else 'removing'} "
                  f"{relative}/ — {description}")
            _remove(target, dry_run)
            removed += 1

    if take_settings:
        for target in _settings_paths(identity, roots):
            if not target.exists():
                continue
            print(f"[reset-save]   {'would remove' if dry_run else 'removing'} "
                  f"{target} — settings (--all)")
            _remove(target, dry_run)
            removed += 1
    else:
        print("[reset-save] settings kept — key bindings, locale and volume are not "
              "world state. --all takes them too.")

    if removed == 0:
        print("[reset-save] nothing to remove: this machine holds no world state for "
              "this app. Correct today — FP6.1 writes the first save.")
    else:
        print(f"[reset-save] {'would remove' if dry_run else 'removed'} {removed} item(s). "
              f"The next launch starts a fresh world.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--dry-run", action="store_true",
                        help="list what would be removed and remove nothing")
    parser.add_argument("--all", action="store_true", dest="take_settings",
                        help="also clear settings (key bindings, locale, volume)")
    args = parser.parse_args()
    return run(args.dry_run, args.take_settings)


if __name__ == "__main__":
    raise SystemExit(main())
