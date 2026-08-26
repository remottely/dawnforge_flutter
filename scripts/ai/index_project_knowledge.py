#!/usr/bin/env python3
"""Build the repo's knowledge index — the retrieval half of the AI harness.

Chunks every knowledge source (docs/, scripts/*.md, the active content pack, the
skills, both changelogs, CLAUDE.md) plus the full git commit history into a local
BM25 index at `.claude/cache/knowledge_index.json` (gitignored, machine-local,
rebuildable). Query it with `scripts/ai/search_project_knowledge.py`, which also
rebuilds automatically whenever HEAD or a source file moves — running this script
by hand is only needed to inspect what goes in.

Engine and design notes live in `scripts/lib/knowledge_index.py`; the harness
picture is `docs/AI_HARNESS.md` §Retrieval.

    python3 scripts/ai/index_project_knowledge.py            # build + save
    python3 scripts/ai/index_project_knowledge.py --dry-run  # list sources, write nothing
    python3 scripts/ai/index_project_knowledge.py --stats    # build + print index shape
"""
from __future__ import annotations

import argparse
import sys
import time
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from knowledge_index import (  # noqa: E402
    INDEX_PATH,
    build_index,
    iter_source_files,
    save_index,
    source_kind,
)
from project_paths import PROJECT_ROOT  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--dry-run", action="store_true", help="list what would be indexed, write nothing")
    parser.add_argument("--stats", action="store_true", help="print index shape after building")
    args = parser.parse_args()

    if args.dry_run:
        files = iter_source_files()
        kinds = Counter(source_kind(str(f.relative_to(PROJECT_ROOT))) for f in files)
        for f in files:
            print(f.relative_to(PROJECT_ROOT))
        print(f"\n[dry-run] {len(files)} markdown files ({dict(kinds)}) + full git history; nothing written.")
        return 0

    started = time.perf_counter()
    index = build_index()
    path = save_index(index)
    elapsed = time.perf_counter() - started

    kinds = Counter(source_kind(c["p"]) for c in index["chunks"])
    size_mb = path.stat().st_size / 1_048_576
    print(f"[index] {len(index['chunks'])} chunks, {len(index['postings'])} terms, "
          f"{size_mb:.1f} MB, built in {elapsed:.1f}s -> {path.relative_to(PROJECT_ROOT)}")
    print(f"[index] chunks by source: {dict(kinds.most_common())}")
    if args.stats:
        lengths = index["dl"]
        print(f"[index] head={index['head'][:12]} avgdl={index['avgdl']:.0f} tokens, "
              f"longest chunk {max(lengths)} tokens, shortest {min(lengths)}")
    assert INDEX_PATH.is_file(), "index file missing after save"
    return 0


if __name__ == "__main__":
    sys.exit(main())
