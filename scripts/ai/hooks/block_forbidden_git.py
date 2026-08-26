#!/usr/bin/env python3
"""Refuse the git invocations this repo has banned in writing.

PreToolUse guard on Bash (`docs/AI_HARNESS.md` §7), ported from the Godot repo. A hook
is a rule made physical, never a new rule in disguise — every pattern below is a
prohibition that already exists in prose, and the stderr message names where:

- **`git rebase` / `git commit --amend`** — `CLAUDE.md` §Parallel sessions. Both drive
  the index and the checkout, and a parallel session may have uncommitted work in this
  tree. A version collision is repaired with `git commit-tree` + a three-argument
  `git update-ref`, which touches neither.
- **`git commit` with no ` -- ` pathspec** — a bare commit sweeps in whatever the
  parallel session happens to have staged.
- **`git commit` naming `LEDGER.md` while an ID heads two entries** — the ledger's own
  header, *"IDs are sequential and never reused"*. The session committing second holds
  both entries and is the one that can see it.

FAIL-OPEN, deliberately. Nothing is imported beyond the standard library (in particular
NOT `scripts/lib/project_paths.py`, which raises `SystemExit` at import time when the
content pack is missing), and every unexpected exception exits 0.

Only the command POSITION of each shell segment is inspected, so a git command quoted
inside `echo` or a commit message is not a match.

    echo '{"tool_name":"Bash","tool_input":{"command":"git rebase -i HEAD~2"}}' \\
      | python3 scripts/ai/hooks/block_forbidden_git.py; echo "exit=$?"   # exit=2
"""
from __future__ import annotations

import json
import re
import shlex
import sys

EXIT_ALLOW = 0
EXIT_BLOCK = 2
"""The Claude Code hook contract: 0 is silence, 2 feeds stderr back to the model."""

_SEGMENT_SEPARATORS = re.compile(r"&&|\|\||[;\n|]")
"""Shell separators that start a new command position. `|` is included so the right
side of a pipe is inspected too; `&` is not, because splitting on it would also split
`&&` handled above and background-running a forbidden git command is not a real path."""

_LEDGER_PATH = "docs/refactoring/LEDGER.md"
"""Matched inside the commit's pathspec. Two sessions appending in the same window both
read the same maximum ID — the session that commits second has BOTH entries in its tree,
so it is the one that sees the duplicate and the one that should renumber."""


def _segments(command: str) -> list[str]:
    return _SEGMENT_SEPARATORS.split(command)


def _ledger_collision() -> str:
    """The refusal for a ledger holding a duplicate ID, or "" — including on any error.

    The uniqueness rule is defined once, in the script that checks it; this imports that
    definition rather than restating the pattern. The import is guarded because this hook
    must never stand between the model and its tool: an unreadable ledger, a moved script
    or a broken interpreter all mean allow.
    """
    try:
        from pathlib import Path
        root = Path(__file__).resolve().parents[3]
        sys.path.insert(0, str(root / "scripts" / "project"))
        from check_ledger_ids_are_unique import duplicate_ids, next_free_id

        text = (root / _LEDGER_PATH).read_text(encoding="utf-8")
        duplicates = duplicate_ids(text)
        if not duplicates:
            return ""
        named = ", ".join(sorted(duplicates))
        return (
            f"{_LEDGER_PATH} has {len(duplicates)} ID(s) heading two entries each: {named}. "
            f"An ID is an entry's only durable handle — plans and PENDING.md cite it by "
            f"number — so a collision makes both citations ambiguous forever. Renumber the "
            f"NEWER entry of each pair (date them with `git log -S '<title>' -- "
            f"{_LEDGER_PATH}`; the older one may already be cited elsewhere). The next free "
            f"ID is {next_free_id(text)}, and "
            f"`python3 scripts/project/check_ledger_ids_are_unique.py --next` always says."
        )
    except Exception:
        return ""


def _git_tokens(segment: str) -> list[str] | None:
    """The argv of `segment` when it invokes git at command position, else None."""
    try:
        tokens = shlex.split(segment)
    except ValueError:
        return None  # unbalanced quotes — this segment is not parseable, so not judged
    if not tokens or tokens[0] != "git":
        return None
    return tokens


def _subcommand(tokens: list[str]) -> str:
    """First non-flag token after `git`. Returns "" when there is none, which reads as
    'no subcommand recognised' and allows — fail-open all the way down."""
    for token in tokens[1:]:
        if not token.startswith("-"):
            return token
    return ""


def _refusal(command: str) -> str:
    """Why this command is refused, or "" when it is allowed."""
    for segment in _segments(command):
        tokens = _git_tokens(segment)
        if tokens is None:
            continue
        subcommand = _subcommand(tokens)

        if subcommand == "rebase":
            return (
                "git rebase is forbidden in this repo (CLAUDE.md §Parallel sessions): it "
                "drives the index and the checkout, and a parallel session may have "
                "uncommitted work here. Repair a version collision with git commit-tree "
                "plus a three-argument git update-ref."
            )

        if subcommand == "commit":
            if "--amend" in tokens:
                return (
                    "git commit --amend is forbidden in this repo (CLAUDE.md §Parallel "
                    "sessions), for the same reason as rebase: it rewrites through the "
                    "checkout a parallel session may be working in. Build the new commit "
                    "with git commit-tree and swap the branch with git update-ref."
                )
            if "--" not in tokens:
                return (
                    "git commit needs an explicit ' -- <pathspec>' (CLAUDE.md §Parallel "
                    "sessions). A bare commit sweeps in whatever a parallel session has "
                    "staged. Name every file the task touched, plus pubspec.yaml and both "
                    "CHANGELOGs."
                )
            if any(_LEDGER_PATH in token for token in tokens):
                collision = _ledger_collision()
                if collision:
                    return collision

    return ""


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return EXIT_ALLOW  # not our shape — never stand between the model and its tool

    try:
        if payload.get("tool_name") != "Bash":
            return EXIT_ALLOW
        command = payload.get("tool_input", {}).get("command", "")
        if not isinstance(command, str):
            return EXIT_ALLOW
        refusal = _refusal(command)
    except Exception:
        return EXIT_ALLOW

    if not refusal:
        return EXIT_ALLOW
    print(refusal, file=sys.stderr)
    return EXIT_BLOCK


if __name__ == "__main__":
    sys.exit(main())
