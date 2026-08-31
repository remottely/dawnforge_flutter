#!/usr/bin/env python3
"""Ask the repo's own knowledge a question — docs, content, changelogs, 4k+ commits.

The query side of the AI harness's retrieval loop (`docs/AI_HARNESS.md` §Retrieval;
the `/recall` skill wraps this). BM25-ranked, bilingual (en / pt-BR, accents don't
matter), offline, stdlib-only. The index rebuilds automatically whenever HEAD or a
markdown source changed, so results never describe a repo that no longer exists.

Hits are ENTRY POINTS, not answers: open the file at the printed `path:line` and
verify at HEAD before acting on it. `git:<hash>` hits are commits — read them with
`git show <hash>`.

    python3 scripts/ai/search_project_knowledge.py "why is pausing forbidden"
    python3 scripts/ai/search_project_knowledge.py "cor da agua bioma" --k 5
    python3 scripts/ai/search_project_knowledge.py "layer offset" --sources docs,git
    python3 scripts/ai/search_project_knowledge.py "save reset" --json
"""
from __future__ import annotations

import argparse
import json
import sys
import textwrap
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from knowledge_index import ensure_fresh_index, search, source_kind  # noqa: E402

_VALID_SOURCES = {"docs", "git", "content", "scripts", "skills", "changelog", "root"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("query", help="the question, en or pt-BR")
    parser.add_argument("--k", type=int, default=8, help="how many hits (default 8)")
    parser.add_argument("--sources", default=None,
                        help=f"comma list to filter: {','.join(sorted(_VALID_SOURCES))}")
    parser.add_argument("--json", action="store_true", help="machine-readable output")
    parser.add_argument("--no-refresh", action="store_true",
                        help="use the existing index even if stale (faster, may be outdated)")
    args = parser.parse_args()

    sources = None
    if args.sources:
        sources = {s.strip() for s in args.sources.split(",") if s.strip()}
        unknown = sources - _VALID_SOURCES
        assert not unknown, f"unknown sources {sorted(unknown)}; valid: {sorted(_VALID_SOURCES)}"

    index, rebuilt = ensure_fresh_index(rebuild_if_stale=not args.no_refresh)
    results = search(index, args.query, k=args.k, sources=sources)

    if args.json:
        print(json.dumps({"query": args.query, "rebuilt": rebuilt, "results": results},
                         ensure_ascii=False, indent=2))
        return 0

    if rebuilt:
        print("[index] sources changed — index rebuilt fresh\n", file=sys.stderr)
    if not results:
        print(f"no hits for: {args.query!r} — try fewer/looser terms, or grep for code symbols")
        return 0

    for rank, hit in enumerate(results, 1):
        location = hit["p"] if hit["p"].startswith("git:") else f"{hit['p']}:{hit['l']}"
        print(f"#{rank}  {hit['score']:>7.2f}  [{source_kind(hit['p'])}]  {location} — {hit['t']}")
        snippet = " ".join(hit["x"].split())[:340]
        print(textwrap.indent(textwrap.fill(snippet, width=100), "      "))
        print()
    print("(hits are entry points — open the file / `git show <hash>` and verify at HEAD)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
