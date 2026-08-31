#!/usr/bin/env python3
"""Refuse a `LEDGER.md` where one `L-NNN` names two entries, and hand out the next free one.

The ledger's own header promises *"IDs are sequential and never reused, so a plan can still
cite `L-042` after the entry has been drained out of §Open"*. It was not true: six IDs named
two entries each. The cause is structural rather than careless — the next free ID is found by
**reading the file**, §Open is not sorted, and two sessions commit into `dev` in the same
window, so both read the same maximum and both append it.

That matters because the ID is the entry's only durable handle. Plans, `PENDING.md` and
commit bodies cite it by number, and once an entry is drained the number is all that is left
of it, so a citation of a collided ID is ambiguous forever.

Two halves, and the repo uses both:

- **`--next`** replaces "read the file and guess". One command, one answer, counting drained
  and struck IDs too, because *never reused* means never.
- **`--check`** exits 1 on a collision. It is wired into the commit gate
  (`scripts/ai/hooks/block_forbidden_git.py`), which is the right moment: two sessions racing
  cannot both pass it, because the second one to commit has both entries in its tree and sees
  the duplicate. The loser of the race renumbers, which is exactly who should.

    python3 scripts/project/check_ledger_ids_are_unique.py            # report, exit 0
    python3 scripts/project/check_ledger_ids_are_unique.py --check    # exit 1 on a collision
    python3 scripts/project/check_ledger_ids_are_unique.py --next     # print the next free ID

`duplicate_ids` and `next_free_id` take the file's **text** and import nothing, so the commit
hook can reuse them without inheriting this module's path handling — the hook is fail-open and
stdlib-only on purpose, and `scripts/lib/project_paths.py` raises `SystemExit` at import time
when the data symlink is missing. That import is therefore made lazily, inside `run()`.
"""
from __future__ import annotations

import argparse
import re
import sys

ENTRY_HEADER = re.compile(r"^### (L-\d+) · (.*)$", re.M)
"""An entry in §Open. The drained and struck entries are table rows, not headers."""

ANY_ID = re.compile(r"\bL-(\d+)\b")
"""Every ID the file mentions anywhere — §Open, §Drained, §Struck and prose alike. `--next`
counts all of them, because an ID is never reused even after its entry is gone."""


def duplicate_ids(text: str) -> dict[str, list[str]]:
    """`{id: [title, title]}` for every ID heading more than one entry. Empty when clean."""
    entries: dict[str, list[str]] = {}
    for identifier, title in ENTRY_HEADER.findall(text):
        entries.setdefault(identifier, []).append(title.strip())
    return {identifier: titles for identifier, titles in entries.items() if len(titles) > 1}


def next_free_id(text: str) -> str:
    numbers = [int(n) for n in ANY_ID.findall(text)]
    return f"L-{(max(numbers) + 1) if numbers else 1:03d}"


def run(check: bool, show_next: bool) -> int:
    # Lazy so the commit hook can import this module without the SystemExit risk.
    from pathlib import Path
    sys.path.insert(0, str(next(
        p / "lib" for p in Path(__file__).resolve().parents
        if (p / "lib" / "project_paths.py").is_file())))
    from project_paths import DOCS_ROOT

    ledger = DOCS_ROOT / "refactoring" / "LEDGER.md"
    text = ledger.read_text(encoding="utf-8")

    if show_next:
        print(next_free_id(text))
        return 0

    duplicates = duplicate_ids(text)
    entries = len(ENTRY_HEADER.findall(text))
    print(f"🔎 {entries} entradas em §Open · próximo ID livre: {next_free_id(text)}")

    for identifier, titles in sorted(duplicates.items()):
        print(f"  ❌ {identifier} encabeça {len(titles)} entradas:")
        for title in titles:
            print(f"       {title[:100]}")

    if duplicates:
        print(f"❌ {len(duplicates)} ID(s) usados duas vezes — renumere a entrada mais NOVA "
              f"(datada pelo git log), porque a mais antiga pode já estar citada em outro "
              f"lugar")
        return 1 if check else 0
    print("✅ Todo ID encabeça exatamente uma entrada")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Recusa um LEDGER.md com IDs duplicados; --next dá o próximo livre")
    parser.add_argument("--check", action="store_true",
                        help="Sai com 1 se algum ID encabeçar duas entradas")
    parser.add_argument("--next", dest="show_next", action="store_true",
                        help="Imprime o próximo ID livre e sai")
    args = parser.parse_args()
    sys.exit(run(check=args.check, show_next=args.show_next))
