#!/usr/bin/env python3
"""Shared engine for the repo's knowledge index — sources, chunking, BM25.

Ported from the Godot repo (`docs/AI_HARNESS.md` §Retrieval): it turns everything this
repository *knows* — design docs, the content pack, the changelogs, the skills, and the
full commit history — into a ranked-search index a session can query instead of
re-deriving answers from scratch.

Deliberate properties, in order of importance:

- **Stdlib only.** No venv, no PyYAML, no embeddings API. The index must work on a
  fresh clone with the system `python3`, offline, deterministically. Ranking is
  lexical BM25; semantic embeddings are out of scope until lexical recall measurably
  fails.
- **`reference/` is never indexed.** It holds the archived legacy codebase (rule 10),
  and excluding the whole tree keeps the ban structural.
- **`deprecated/` trees are never indexed** (rule 10), except each folder's README,
  which documents *why* things died and is knowledge worth retrieving.
- **The index is a cache, not an artifact.** It lives in `AI_CACHE_DIR` (gitignored),
  stamps the HEAD and a source fingerprint it was built from, and is rebuilt
  automatically by the search CLI whenever either moved.

Callers: `scripts/ai/index_project_knowledge.py` (build) and
`scripts/ai/search_project_knowledge.py` (query).
"""
from __future__ import annotations

import json
import math
import re
import subprocess
import unicodedata
from collections import defaultdict
from pathlib import Path
from typing import Iterator

from project_paths import (  # noqa: E402
    AI_CACHE_DIR,
    DATA_ROOT,
    DAWNFORGE_ROOT,
    DOCS_ROOT,
    PROJECT_ROOT,
    SCRIPTS_ROOT,
    SKILLS_ROOT,
)

INDEX_VERSION = 1
INDEX_PATH: Path = AI_CACHE_DIR / "knowledge_index.json"

# How many characters of one chunk the index stores and search prints. Chunks are
# entry points, not the document — the reader opens the file the hit names.
MAX_CHUNK_CHARS = 1800
MIN_CHUNK_CHARS = 160
MAX_COMMIT_BODY_CHARS = 1200

# BM25 constants, the textbook defaults.
BM25_K1 = 1.5
BM25_B = 0.75

_HEADING_RE = re.compile(r"^(#{1,4})\s+(.*)$")
_WORD_RE = re.compile(r"[a-z0-9_]+")


def _fold(text: str) -> str:
    """Lowercase and strip diacritics, so pt-BR queries match pt-BR prose
    regardless of accents ("configuração" == "configuracao")."""
    return "".join(
        c for c in unicodedata.normalize("NFKD", text.lower()) if not unicodedata.combining(c)
    )


# Small bilingual stopword list — the chat is pt-BR, the docs are mostly English,
# and queries arrive in both. Folded through `_fold` so accents never matter.
_STOPWORDS_RAW = """
the a an of to in is it and or for on with as at by be this that are was were from not no
its into than then so we you do does did has have had but if else when where which who how
what why all any each one two per via over under up down out now new never always only
every same own after before between both more most less can could should would may might
must will there here also such them they their his her him she he i me my our us your
o a os as um uma uns umas de do da dos das em no na nos nas por para com sem sob sobre e
ou mas se que qual quais quando onde como porque pois ao aos à às é são foi foram ser
estar está estão esse essa isso este esta isto aquele aquela aquilo seu sua seus suas meu
minha nosso nossa ele ela eles elas você vocês já não sim também muito mais menos todo
toda todos todas cada outro outra depois antes entre até desde
"""
STOPWORDS = frozenset(_fold(w) for w in _STOPWORDS_RAW.split())


def tokenize(text: str) -> list[str]:
    """Fold, split, drop stopwords. Snake_case identifiers are emitted whole AND
    as their parts, so `grid_manager` is findable by either spelling."""
    out: list[str] = []
    for tok in _WORD_RE.findall(_fold(text)):
        if len(tok) < 2 or tok in STOPWORDS:
            continue
        out.append(tok)
        if "_" in tok:
            out.extend(p for p in tok.split("_") if len(p) >= 2 and p not in STOPWORDS)
    return out


# ── Sources ──────────────────────────────────────────────────────────────────

def iter_source_files() -> list[Path]:
    """Every markdown file the index reads, deterministic order.

    reference/ (the archived legacy codebase) and deprecated/ trees (rule 10) are
    excluded structurally; a deprecated folder's README is re-included by name
    because it records the *why* of each retirement.
    """
    roots: list[tuple[Path, str]] = [
        (DOCS_ROOT, "**/*.md"),
        (SCRIPTS_ROOT, "**/*.md"),
        (DATA_ROOT, "**/*.md"),
        (SKILLS_ROOT, "*/SKILL.md"),
    ]
    singles = [
        PROJECT_ROOT / "CLAUDE.md",
        DAWNFORGE_ROOT / "CHANGELOG.md",
        DAWNFORGE_ROOT / "CHANGELOG.pt-BR.md",
    ]
    seen: set[Path] = set()
    files: list[Path] = []

    def _accept(path: Path) -> None:
        if path in seen or not path.is_file():
            return
        parts = path.relative_to(PROJECT_ROOT).parts
        if "reference" in parts:
            return  # archived legacy code, structurally excluded
        if "deprecated" in parts and path.name != "README.md":
            return  # rule 10 — keep only the README that explains the retirement
        seen.add(path)
        files.append(path)

    for root, pattern in roots:
        if root.is_dir():
            for path in sorted(root.glob(pattern)):
                _accept(path.resolve())
    for path in singles:
        _accept(path.resolve())
    return files


def iter_git_commits() -> Iterator[tuple[str, int, str, str]]:
    """Every commit as one chunk: (pseudo-path `git:<hash>`, line 1, title, text)."""
    out = subprocess.run(
        ["git", "log", "--format=%h%x1f%as%x1f%s%x1f%b%x1e"],
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    for record in out.split("\x1e"):
        record = record.strip("\n\r ")
        if not record:
            continue
        parts = (record.split("\x1f") + ["", "", "", ""])[:4]
        commit_hash, date, subject, body = (p.strip("\n\r") for p in parts)
        text = subject
        if body.strip():
            text += "\n" + body[:MAX_COMMIT_BODY_CHARS]
        yield f"git:{commit_hash}", 1, f"{date} · {subject[:110]}", text


# ── Chunking ─────────────────────────────────────────────────────────────────

def chunk_markdown(text: str) -> list[tuple[str, int, str]]:
    """Split one markdown document into (title, start_line, text) chunks.

    Sections are cut at `#`–`####` headings; tiny sections merge into their
    predecessor, oversized ones split again on blank lines (tracking the line
    cursor so every chunk still points into the real file).
    """
    lines = text.splitlines()
    sections: list[tuple[str, int, list[str]]] = []
    title, start, buf = "(top)", 1, []
    for lineno, line in enumerate(lines, 1):
        match = _HEADING_RE.match(line)
        if match:
            if any(l.strip() for l in buf):
                sections.append((title, start, buf))
            title, start, buf = match.group(2).strip() or "(untitled)", lineno, [line]
        else:
            buf.append(line)
    if any(l.strip() for l in buf):
        sections.append((title, start, buf))

    merged: list[tuple[str, int, str]] = []
    for sec_title, sec_start, sec_buf in sections:
        block = "\n".join(sec_buf).strip()
        if merged and len(block) < MIN_CHUNK_CHARS:
            prev_title, prev_start, prev_text = merged[-1]
            merged[-1] = (prev_title, prev_start, prev_text + "\n" + block)
            continue
        merged.append((sec_title, sec_start, block))

    chunks: list[tuple[str, int, str]] = []
    for sec_title, sec_start, block in merged:
        if len(block) <= MAX_CHUNK_CHARS:
            chunks.append((sec_title, sec_start, block))
            continue
        paragraphs = block.split("\n\n")
        acc: list[str] = []
        acc_start = sec_start
        cursor = sec_start
        for paragraph in paragraphs:
            para_lines = paragraph.count("\n") + 2  # +1 line, +1 for the blank separator
            if acc and sum(len(p) + 2 for p in acc) + len(paragraph) > MAX_CHUNK_CHARS:
                chunks.append((sec_title, acc_start, "\n\n".join(acc)))
                acc, acc_start = [], cursor
            acc.append(paragraph)
            cursor += para_lines
        if acc:
            chunks.append((sec_title, acc_start, "\n\n".join(acc)))
    return chunks


# ── Fingerprint / staleness ──────────────────────────────────────────────────

def _git_head() -> str:
    return subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=PROJECT_ROOT, capture_output=True, text=True, check=True
    ).stdout.strip()


def source_fingerprint(files: list[Path] | None = None) -> str:
    """Cheap change detector for the markdown sources: count + max mtime + bytes."""
    files = files if files is not None else iter_source_files()
    max_mtime = 0
    total = 0
    for path in files:
        stat = path.stat()
        max_mtime = max(max_mtime, stat.st_mtime_ns)
        total += stat.st_size
    return f"{len(files)}:{max_mtime}:{total}"


def index_is_stale(index: dict) -> bool:
    if index.get("version") != INDEX_VERSION:
        return True
    if index.get("head") != _git_head():
        return True
    return index.get("fingerprint") != source_fingerprint()


# ── Build / load / search ────────────────────────────────────────────────────

def build_index() -> dict:
    files = iter_source_files()
    chunks: list[dict] = []

    for path in files:
        rel = str(path.relative_to(PROJECT_ROOT))
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for title, start_line, chunk_text in chunk_markdown(text):
            chunks.append({"p": rel, "l": start_line, "t": title, "x": chunk_text})

    for pseudo_path, line, title, text in iter_git_commits():
        chunks.append({"p": pseudo_path, "l": line, "t": title, "x": text})

    postings: dict[str, dict[int, int]] = defaultdict(dict)
    doc_lengths: list[int] = []
    for chunk_id, chunk in enumerate(chunks):
        tokens = tokenize(chunk["t"] + "\n" + chunk["x"])
        doc_lengths.append(len(tokens) or 1)
        counts: dict[str, int] = defaultdict(int)
        for token in tokens:
            counts[token] += 1
        for token, tf in counts.items():
            postings[token][chunk_id] = tf

    return {
        "version": INDEX_VERSION,
        "head": _git_head(),
        "fingerprint": source_fingerprint(files),
        "avgdl": sum(doc_lengths) / len(doc_lengths),
        "dl": doc_lengths,
        "chunks": chunks,
        "postings": {t: [[i, tf] for i, tf in ids.items()] for t, ids in postings.items()},
    }


def save_index(index: dict) -> Path:
    AI_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    INDEX_PATH.write_text(json.dumps(index, ensure_ascii=False), encoding="utf-8")
    return INDEX_PATH


def load_index() -> dict | None:
    if not INDEX_PATH.is_file():
        return None
    try:
        return json.loads(INDEX_PATH.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return None


def source_kind(path: str) -> str:
    """Coarse source class, for `--sources` filtering."""
    if path.startswith("git:"):
        return "git"
    if path.startswith("docs/"):
        return "docs"
    if "CHANGELOG" in path:
        return "changelog"
    if path.startswith("games/"):
        return "content"
    if path.startswith("scripts/"):
        return "scripts"
    if path.startswith(".claude/"):
        return "skills"
    return "root"


def search(index: dict, query: str, k: int = 8, sources: set[str] | None = None) -> list[dict]:
    """BM25 over the chunks, with a coverage boost for hits that contain more of
    the query's distinct terms. Returns the top-k chunks as dicts with `score`."""
    query_terms = list(dict.fromkeys(tokenize(query)))
    if not query_terms:
        return []
    chunks = index["chunks"]
    doc_lengths = index["dl"]
    avgdl = index["avgdl"]
    postings = index["postings"]
    total_docs = len(chunks)

    scores: dict[int, float] = defaultdict(float)
    matched_terms: dict[int, int] = defaultdict(int)
    for term in query_terms:
        plist = postings.get(term)
        if not plist:
            continue
        df = len(plist)
        idf = math.log(1 + (total_docs - df + 0.5) / (df + 0.5))
        for chunk_id, tf in plist:
            dl = doc_lengths[chunk_id]
            tf_component = tf * (BM25_K1 + 1) / (tf + BM25_K1 * (1 - BM25_B + BM25_B * dl / avgdl))
            scores[chunk_id] += idf * tf_component
            matched_terms[chunk_id] += 1

    results: list[dict] = []
    for chunk_id, score in scores.items():
        chunk = chunks[chunk_id]
        if sources and source_kind(chunk["p"]) not in sources:
            continue
        if len(query_terms) > 1:
            coverage = (matched_terms[chunk_id] - 1) / (len(query_terms) - 1)
            score *= 1.0 + 0.25 * coverage
        results.append({"score": round(score, 3), **chunk})
    results.sort(key=lambda r: r["score"], reverse=True)
    return results[:k]


def ensure_fresh_index(rebuild_if_stale: bool = True) -> tuple[dict, bool]:
    """Load the index, rebuilding when missing or stale. Returns (index, rebuilt)."""
    index = load_index()
    if index is not None and not index_is_stale(index):
        return index, False
    if index is not None and not rebuild_if_stale:
        return index, False
    index = build_index()
    save_index(index)
    return index, True
