#!/usr/bin/env python3
"""Refuse a content pack that has quietly forked from the spec repo's.

WHY THIS EXISTS (`L-006`). Every `.md` in `games/<game>/data/` here is a HAND-COPIED
SNAPSHOT of the same document in the Godot/Tessera repo (`SPEC_REPO_ROOT`). The pack
format is a SHARED contract that must never fork (study §4, risk register #3), and the
fork this allows is the quiet kind: not a parse failure but two engines rolling different
loot from the same authored tile. The pack is imported one slice at a time, so every
slice pins its own snapshot date and no two documents here are guaranteed to be from the
same version of over there. Nothing noticed. This is the something that notices.

THREE KINDS OF DIFFERENCE, AND ONLY ONE OF THEM IS A FORK.

  behind    a key the SPEC authors and this pack does not. Normal and expected: a field
            whose Dart data class does not exist yet cannot be authored here (rule 6),
            so the pack here is a SUBSET of the spec's by construction. Counted and
            summarised, never a failure — it is the port's backlog, not a fork.
  conflict  a key BOTH sides author, with different values. This is the fork: same
            document, same field, two answers. `L-006`'s own evidence is one of these.
  only-here a key this pack authors that the spec does not — the other half of a fork,
            and how a field invented on this side escapes back into the shared format.

`conflict` and `only-here` fail `--check` unless they are RECORDED, with a reason, in
the baseline beside this script. `--accept <path>` writes that record for one document
after a human has read the diff. Nothing is ever accepted in bulk.

HOW A DOCUMENT IS PAIRED WITH ITS TWIN. By its `id`, never its path — the port files
some documents under a different folder on purpose (the two `t1_ground_buildable_*`
snapshots live under the smelter here, under the biome over there), and a path match
would call a moved document a missing one. A document with no `id` in its frontmatter is
not a world object (`ui/ui_strings.md`, `world/procedural/*.md`, the loadouts) and pairs
by relative path, which is stable for those. A move is REPORTED, because the folder is
part of a world object's translation keys and therefore part of its content.

WHAT IS COMPARED. The frontmatter only — the YAML between the opening `---` and the next
one. The prose below it is a document's own commentary, written for whoever reads that
side, and is not the contract.

A MACHINE WITHOUT THE SIBLING REPO REPORTS *NOT APPLICABLE*, NEVER A PASS. The Godot
repo learned this one the expensive way (`L-306`, `check_pipeline_check_coverage.py`): a
guard that cannot see its subject and prints a green tick is worse than no guard, because
the tick is what people read. This one says, in words, that it compared nothing.
"""
import argparse
import sys
from datetime import date
from pathlib import Path

import yaml

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import (  # noqa: E402
    ACTIVE_GAME, DATA_ROOT, SPEC_REPO_ROOT, spec_pack_root, spec_repo_available,
)

BASELINE_PATH = Path(__file__).with_name("pack_snapshot_deltas.yaml")

# Documents that exist HERE and have no twin in the spec at all. One entry, one reason —
# a document nobody can point at over there is either this port's own invention or an
# import that lost its origin, and the two must never be confused.
ONLY_HERE: dict[str, str] = {
    "t1_item_tool_melee_hand": (
        "This port's own: the INNATE hand an empty hotbar slot resolves to (0.28.0, "
        "`ItemHand`/`ItemHandTool` — vocabulary invented here, PENDING #9). The spec "
        "answers the same question in code, with no authored document to copy."
    ),
    "README.md": (
        "The pack's own front page for readers of THIS repo. No frontmatter, no id, no "
        "content — it is a signpost, not a document the pipeline reads."
    ),
    "ui/ui_strings.md": (
        "The interface's own strings (0.20.0, step 05's second source). The spec keeps "
        "its UI text in scene files and `.po`-style tables, so there is nothing to "
        "snapshot; the pack format grew this file on the Flutter side first."
    ),
}

# Differences that are true of EVERY document, for one engine-level reason each. Recorded
# here rather than 51 times in the baseline: a per-document record of a repo-wide fact
# would bury the handful of differences that are actually about content.
SYSTEMIC: dict[str, str] = {
    "IVisualObjectData.spritesheet": (
        "Path rewrite on import: the spec's `…/assets/<name>.png` becomes `…/sprites/"
        "<name>.png` here, because `assets/` is Flutter's own word for the bundle root "
        "and a pack folder called `assets` inside `assets/` reads as a mistake."
    ),
    "IVisualObjectData.shadow_origin_offset": (
        "Authored here, gone from the spec: the field was in the shared shape when these "
        "documents were snapshotted and the spec has since dropped it. Harmless while no "
        "Dart data class reads it — it is inert YAML — but it is the CLEAREST single "
        "piece of evidence that the two packs drift, and it stays visible in this summary "
        "until the port either re-imports without it or the spec brings it back."
    ),
}


def frontmatter(document: Path) -> dict[str, object] | None:
    """The YAML between the opening `---` and the next one, or `None` if there is none."""
    lines = document.read_text(encoding="utf-8").split("\n")
    if not lines or lines[0].strip() != "---":
        return None
    closing = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if closing is None:
        raise SystemExit(f"[pack-snapshot] {document} opens a frontmatter it never closes.")
    parsed = yaml.safe_load("\n".join(lines[1:closing]))
    return parsed if isinstance(parsed, dict) else None


def flatten(value: object, prefix: str = "") -> dict[str, object]:
    """`{'a.b': 1}` from `{'a': {'b': 1}}`. Lists are values, compared whole."""
    if not isinstance(value, dict):
        return {prefix[:-1]: value}
    flat: dict[str, object] = {}
    for key, child in value.items():
        flat.update(flatten(child, f"{prefix}{key}."))
    return flat


def pack_key(document: Path, root: Path, front: dict[str, object] | None) -> str:
    """How a document is addressed: its `id` when it has one, else its relative path."""
    if front is not None and isinstance(front.get("id"), str):
        return str(front["id"])
    return document.relative_to(root).as_posix()


def read_pack(root: Path) -> dict[str, tuple[Path, dict[str, object]]]:
    found: dict[str, tuple[Path, dict[str, object]]] = {}
    for document in sorted(root.rglob("*.md")):
        front = frontmatter(document)
        key = pack_key(document, root, front)
        if key in found:
            raise SystemExit(
                f"[pack-snapshot] two documents in {root} answer to '{key}': "
                f"{found[key][0]} and {document}."
            )
        found[key] = (document, front or {})
    return found


class Delta:
    """One document's difference from its twin, split by kind."""

    def __init__(self, key: str, here: Path, spec: Path) -> None:
        self.key = key
        self.here = here
        self.spec = spec
        self.moved: bool = False
        self.behind: list[str] = []
        self.conflicts: dict[str, tuple[object, object]] = {}
        self.only_here_keys: dict[str, object] = {}

    @property
    def forks(self) -> list[str]:
        """The differences that are a fork, in the order a reader wants them."""
        return sorted([*self.conflicts, *self.only_here_keys])


def compare(here_root: Path, spec_root: Path) -> tuple[list[Delta], list[str], list[str]]:
    """`(deltas, unpaired_here, ids_only_over_there)` for the whole pack."""
    here = read_pack(here_root)
    spec = read_pack(spec_root)
    deltas: list[Delta] = []
    unpaired: list[str] = []
    for key, (document, front) in here.items():
        if key not in spec:
            unpaired.append(key)
            continue
        spec_document, spec_front = spec[key]
        delta = Delta(key, document, spec_document)
        delta.moved = (
            document.relative_to(here_root) != spec_document.relative_to(spec_root)
        )
        mine, theirs = flatten(front), flatten(spec_front)
        for field, value in mine.items():
            if field not in theirs:
                if field not in SYSTEMIC:
                    delta.only_here_keys[field] = value
            elif value != theirs[field] and field not in SYSTEMIC:
                delta.conflicts[field] = (value, theirs[field])
        delta.behind = sorted(f for f in theirs if f not in mine)
        deltas.append(delta)
    return deltas, sorted(unpaired), sorted(k for k in spec if k not in here)


def load_baseline() -> dict[str, dict[str, object]]:
    if not BASELINE_PATH.is_file():
        return {}
    parsed = yaml.safe_load(BASELINE_PATH.read_text(encoding="utf-8")) or {}
    documents = parsed.get("documents") if isinstance(parsed, dict) else None
    return documents if isinstance(documents, dict) else {}


def write_baseline(documents: dict[str, dict[str, object]]) -> None:
    header = (
        "# AUTO-GENERATED by scripts/content/check_pack_snapshot_matches_spec.py --accept\n"
        "# One entry per pack document whose frontmatter differs from the spec repo's on a\n"
        "# key BOTH sides author, or on a key only this pack authors. `why` is written by\n"
        "# hand and preserved across every --accept; a delta without one is refused, because\n"
        "# an unexplained difference between two engines' content IS the fork L-006 names.\n"
        "# Read the diff first: `--report <path>`.\n"
    )
    body = yaml.safe_dump(
        {"documents": dict(sorted(documents.items()))},
        sort_keys=False, allow_unicode=True, width=100,
    )
    BASELINE_PATH.write_text(header + body, encoding="utf-8")


def describe(delta: Delta, indent: str = "  ") -> list[str]:
    lines = [f"{indent}{delta.key}"]
    if delta.moved:
        lines.append(
            f"{indent}  moved: {delta.here.parent.name}/ here, "
            f"{delta.spec.parent.name}/ over there"
        )
    for field in sorted(delta.conflicts):
        mine, theirs = delta.conflicts[field]
        lines.append(f"{indent}  ~ {field}: {mine!r} here, {theirs!r} over there")
    for field in sorted(delta.only_here_keys):
        lines.append(f"{indent}  + {field}: {delta.only_here_keys[field]!r} — only here")
    return lines


def not_applicable() -> int:
    """Say, in words, that nothing was compared. This is not a pass."""
    print("[pack-snapshot] ⚠️  NOT APPLICABLE — nothing was compared.")
    print(f"[pack-snapshot] The spec repo is not on this machine: {SPEC_REPO_ROOT}")
    print("[pack-snapshot] Point TESSERA_SPEC_ROOT at it, or accept that this run")
    print("[pack-snapshot] checked no document at all. It did not find the pack clean.")
    return 0


def run(mode: str, target: str | None) -> int:
    spec_root = spec_pack_root(ACTIVE_GAME)
    if not spec_repo_available() or not spec_root.is_dir():
        return not_applicable()

    deltas, unpaired, only_over_there = compare(DATA_ROOT, spec_root)
    baseline = load_baseline()
    forked = [d for d in deltas if d.forks]

    if mode == "accept":
        assert target is not None, "[pack-snapshot] --accept needs a document path"
        wanted = Path(target).resolve()
        match = next((d for d in deltas if d.here.resolve() == wanted), None)
        if match is None:
            raise SystemExit(
                f"[pack-snapshot] {target} is not a pack document with a spec twin. "
                f"Documents with no twin belong in ONLY_HERE, in this script's header."
            )
        entry = dict(baseline.get(match.key, {}))
        entry.setdefault("why", "")
        entry["accepted"] = date.today().isoformat()
        entry["conflicts"] = {
            field: {"here": mine, "spec": theirs}
            for field, (mine, theirs) in sorted(match.conflicts.items())
        }
        entry["only_here"] = dict(sorted(match.only_here_keys.items()))
        if not match.forks:
            baseline.pop(match.key, None)
            print(f"[pack-snapshot] {match.key} has no fork left — record removed.")
        else:
            baseline[match.key] = entry
            print("\n".join(describe(match, indent="")))
            if not entry["why"]:
                print(f"[pack-snapshot] recorded. Now write `why:` in {BASELINE_PATH.name} — "
                      "--check refuses a delta nobody explained.")
        write_baseline(baseline)
        return 0

    # ---- report / check -----------------------------------------------------
    if mode == "report" and target is not None:
        wanted = Path(target).resolve()
        match = next((d for d in deltas if d.here.resolve() == wanted), None)
        if match is None:
            raise SystemExit(f"[pack-snapshot] {target} is not a pack document with a spec twin.")
        print("\n".join(describe(match, indent="")))
        print(f"  behind the spec by {len(match.behind)} key(s): {', '.join(match.behind) or '(none)'}")
        return 0

    behind_total = sum(len(d.behind) for d in deltas)
    print(f"[pack-snapshot] {len(deltas)} document(s) paired with {spec_root}")
    print(f"[pack-snapshot] behind the spec: {behind_total} authored key(s) across "
          f"{sum(1 for d in deltas if d.behind)} document(s) — the port's backlog, not a fork.")
    for field, reason in SYSTEMIC.items():
        touched = sum(1 for d in deltas if field in flatten(frontmatter(d.here) or {}))
        print(f"[pack-snapshot] systemic: {field} ({touched} document(s)) — {reason.split('.')[0]}.")

    problems: list[str] = []

    for key in unpaired:
        if key not in ONLY_HERE:
            problems.append(
                f"'{key}' has no twin in the spec pack and no entry in ONLY_HERE. "
                f"Either it was imported from a document that has since been renamed or "
                f"deleted over there, or it is this port's own — say which, in the header."
            )
    stale = [k for k in ONLY_HERE if k not in unpaired]
    for key in stale:
        problems.append(
            f"ONLY_HERE claims '{key}' has no twin, and it does have one now. "
            f"An allowlist entry that is no longer true hides the next real one."
        )

    for delta in forked:
        record = baseline.get(delta.key)
        if record is None:
            problems.append(
                f"'{delta.key}' forks from the spec and is not in {BASELINE_PATH.name}:\n"
                + "\n".join(describe(delta, indent="      "))
            )
            continue
        if not str(record.get("why", "")).strip():
            problems.append(f"'{delta.key}' is recorded with no `why`. An unexplained "
                            f"difference between two engines' content is the fork itself.")
        recorded = set(record.get("conflicts") or {}) | set(record.get("only_here") or {})
        new = sorted(set(delta.forks) - recorded)
        if new:
            problems.append(
                f"'{delta.key}' has drifted FURTHER since it was accepted "
                f"({record.get('accepted', 'unknown date')}):\n"
                + "\n".join(f"      {line}" for line in new)
            )
    for key in baseline:
        match = next((d for d in forked if d.key == key), None)
        if match is None:
            problems.append(
                f"{BASELINE_PATH.name} records '{key}' as forked and it no longer is. "
                f"Re-run --accept on it to drop the record."
            )

    forked_keys = sum(len(d.forks) for d in forked)
    recorded = " — all recorded, each with a reason" if not problems else ""
    print(f"[pack-snapshot] forked: {len(forked)} document(s), {forked_keys} key(s){recorded}")

    if problems:
        print()
        for problem in problems:
            print(f"[pack-snapshot] ❌ {problem}")
        print(f"\n[pack-snapshot] {len(problems)} problem(s). Read one with "
              f"--report <path>, accept it with --accept <path>.")
        return 1
    if only_over_there:
        print(f"[pack-snapshot] {len(only_over_there)} document(s) exist only in the spec — "
              f"content not imported yet, which is the whole port.")
    print("[pack-snapshot] ✅ no unrecorded fork")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--check", action="store_true",
                        help="fail on any fork this repo has not recorded (default)")
    parser.add_argument("--report", metavar="PATH",
                        help="print one document's full difference from its twin")
    parser.add_argument("--accept", metavar="PATH",
                        help="record one document's current fork in the baseline")
    args = parser.parse_args()
    if args.accept:
        return run("accept", args.accept)
    if args.report:
        return run("report", args.report)
    return run("check", None)


if __name__ == "__main__":
    raise SystemExit(main())
