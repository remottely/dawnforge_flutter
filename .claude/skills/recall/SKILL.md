---
version: 0.1.0
name: recall
description: |
  Search this repo's own knowledge — docs, the content almanac, both changelogs,
  the scripts and every commit — through the local BM25 index, before deriving
  anything from scratch. Use for "why/when/where did X change", "por que isso é
  assim", a prior-art check before planning, and the duplicate check rule 27
  demands before a ledger entry.
argument-hint: "\"<question>\" [--sources docs,git] [--k 8]"
---

# Recall — retrieval before derivation

`CLAUDE.md` §Execution Workflow step 1 says to check prior art first. This is that check.
The index answers in about a second, bilingual (en / pt-BR, accents ignored), offline,
stdlib only, and it rebuilds itself whenever HEAD or a Markdown source moved — staleness
is not something you have to think about.

```bash
python3 scripts/ai/search_project_knowledge.py "<question>" [--k 8] [--sources docs,git] [--json]
```

Sources to filter with: `docs` `git` `content` (the authored pack) `scripts` `skills`
`changelog` `root`.

## Reading the results

- **Hits are entry points, not answers.** Open the file at the printed `path:line`; read a
  `git:<hash>` hit with `git show <hash>`. Then verify the claim at HEAD before acting on
  it. Line numbers drift and this repo has two sessions committing into one worktree, so a
  hit describes the moment it was indexed, not necessarily now.
- **Score gaps matter more than scores.** A top hit at twice the second is a strong
  pointer. A flat top five means the query is too broad — add a distinctive term.
- **Nothing found is information too**, and it is the answer rule 27 wants before you open
  a ledger entry: if neither `LEDGER.md` nor `PENDING.md` knows your observation, it is
  new.

## The queries that work here

| You want | Ask for |
|:---|:---|
| Why a rule exists | the rule's subject, not its number — `"why is pausing forbidden"` beats `"rule 30"` |
| When a behaviour changed | the player-facing words, because both changelogs are indexed — `"item bar keys"` |
| Whether an idea was already rejected | the idea plus a decision word — `"gamepad cursor decision"` |
| Prior art for a port | the spec's own vocabulary — the Godot names survive in the port notes |
| A duplicate before a ledger entry | the observation's noun — `"inventory size default"` |

## What it does not cover

The index reads Markdown, scripts and commit messages. It does **not** read `lib/` Dart
source, so "which class calls this" is a `git grep` question, not a recall question. The
sibling spec repo (`SPEC_REPO_ROOT`) is a separate checkout and is not indexed here.
