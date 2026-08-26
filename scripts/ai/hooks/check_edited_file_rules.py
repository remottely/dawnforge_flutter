#!/usr/bin/env python3
"""Flag a just-edited `.dart` file that broke a mechanically-checkable rule.

PostToolUse guard on Edit/Write (`docs/AI_HARNESS.md` §7), ported from the Godot repo.
This is a **tripwire, not a gate**: the edit has already landed, and exit 2 puts the
reason in front of the model so it fixes the line in the same breath.

Rules watched, chosen because each is a literal string a regex can find with no
judgement and no whitelist longer than one name:

- **rule 30** — the game never pauses. Flame's `pauseEngine()` / `resumeEngine()` and
  writes to a game's `.paused` property are forbidden: the simulation is
  multiplayer-shaped (decision D4). A surface that must hold the player uses
  `GameInputManager.pushUiBlocker(this)`.
- **rule 11** — raw pointer reads. Flame/Flutter event positions
  (`.canvasPosition`, `.globalPosition` on pointer events) belong to `InputHelper`
  alone, which is what keeps gamepad and touch at parity with the mouse (rule 12).
  Only `input_helper.dart` may read them. (Pattern deliberately narrow: it matches the
  Flame event accessors, not arbitrary `.position` reads.)

Comment lines are skipped, so a comment explaining why one of these was removed does
not trip the wire. Only the edited file is read, and only from disk, so Edit and Write
are both covered by one path.

FAIL-OPEN: any unexpected exception exits 0. Nothing outside the standard library is
imported — in particular NOT `scripts/lib/project_paths.py`, which raises `SystemExit`
at import time when the content pack is missing.

    echo '{"tool_name":"Edit","tool_input":{"file_path":"/abs/path/some.dart"}}' \\
      | python3 scripts/ai/hooks/check_edited_file_rules.py; echo "exit=$?"
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import NamedTuple

EXIT_ALLOW = 0
EXIT_FLAG = 2
"""The Claude Code hook contract: 0 is silence, 2 feeds stderr back to the model."""

_WATCHED_SUFFIXES = frozenset({".dart"})
"""Engine code only. A `.md` or a Python script quoting one of these strings is
documentation, not a violation — CLAUDE.md itself names them."""

_WATCHED_PARTS = ("lib",)
"""Only files under `lib/` are judged: a test may legitimately exercise a forbidden
shape to prove the engine refuses it, and `reference/` is not code we own."""

_COMMENT_PREFIXES = ("//",)

_CURSOR_EXEMPT_STEM = "inputhelper"
"""The one name allowed to read raw pointer positions, because it is what everything
else reads instead (rule 11). Compared against the stem with underscores stripped and
case folded, so `input_helper.dart` matches."""


class _Rule(NamedTuple):
    pattern: re.Pattern[str]
    reason: str
    is_cursor_read: bool = False
    """Carried on the rule itself rather than as an index set, so reordering or adding
    a rule cannot silently move the exemption onto the wrong one."""


_RULES: tuple[_Rule, ...] = (
    _Rule(
        re.compile(r"\b(?:pauseEngine|resumeEngine)\s*\("),
        "rule 30 — the game never pauses. pauseEngine()/resumeEngine() freeze the "
        "simulation clock; the sim stays multiplayer-shaped (decision D4). Use "
        "GameInputManager.pushUiBlocker(this) / popUiBlocker(this), which suppresses "
        "gameplay input and leaves the simulation running.",
    ),
    _Rule(
        re.compile(r"\.paused\s*=\s*"),
        "rule 30 — writing a game's .paused property reconstructs a pause by another "
        "name, and the ban covers every form of it. Use "
        "GameInputManager.pushUiBlocker(this) instead.",
    ),
    _Rule(
        re.compile(r"\.(?:canvasPosition|devicePosition)\b"),
        "rule 11 — gameplay code never reads the pointer directly. Use "
        "InputHelper.getCursorWorldPos() / getCursorScreenPos(), the single source of "
        "truth that keeps gamepad and touch at parity with the mouse (rule 12).",
        is_cursor_read=True,
    ),
)


def _violations(path: Path) -> list[str]:
    """Every rule this file breaks, as `file:line — reason`, comments excluded."""
    exempt_cursor = path.stem.replace("_", "").lower() == _CURSOR_EXEMPT_STEM
    findings: list[str] = []

    for number, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw_line.strip()
        if not line or line.startswith(_COMMENT_PREFIXES):
            continue
        for rule in _RULES:
            if exempt_cursor and rule.is_cursor_read:
                continue
            if rule.pattern.search(line):
                findings.append(f"{path.name}:{number} — {rule.reason}")

    return findings


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return EXIT_ALLOW  # not our shape — a tripwire never stands in the way

    try:
        raw_path = payload.get("tool_input", {}).get("file_path", "")
        if not isinstance(raw_path, str) or not raw_path:
            return EXIT_ALLOW
        path = Path(raw_path)
        if path.suffix not in _WATCHED_SUFFIXES or not path.is_file():
            return EXIT_ALLOW
        parts = path.parts
        if "lib" not in parts or "reference" in parts:
            return EXIT_ALLOW
        findings = _violations(path)
    except Exception:
        return EXIT_ALLOW

    if not findings:
        return EXIT_ALLOW
    print("\n".join(findings), file=sys.stderr)
    return EXIT_FLAG


if __name__ == "__main__":
    sys.exit(main())
