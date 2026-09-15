#!/usr/bin/env python3
"""Make the merge commit the git guard cannot inspect, after proving it is safe.

WHY THIS EXISTS (`L-008`). Two rules in this repo are jointly unsatisfiable for a commit
with two parents. `CLAUDE.md` §Parallel sessions commits with an explicit pathspec, and
`scripts/ai/hooks/block_forbidden_git.py` refuses a `git commit` without one, because a
bare commit sweeps in whatever a parallel session happens to have staged. Git itself
refuses a pathspec commit while `MERGE_HEAD` exists — *"cannot do a partial commit during
a merge"*. So the only route to a merge commit is the exact bare commit the guard exists
to stop, and the escape used at 0.45.3 was `GIT_EDITOR=true git merge --continue`, which
is not the `commit` subcommand and so was never inspected at all.

The hole is not that a merge is dangerous. It is that the ONE case the guard cannot
inspect is the case that commits the most — the whole index, unexamined. So the guard now
refuses `git merge --continue` and names this script, and this script does the inspecting
the guard would have done:

  1. the merge is real and finished — `MERGE_HEAD` exists and no path is still conflicted;
  2. **every staged path is one the merge itself could have touched** — the set of files
     that differ between the merge base and `MERGE_HEAD`. A staged path outside that set
     is not part of this merge; it is somebody else's work about to be committed under
     this message, which is precisely what the pathspec rule protects;
  3. the message carries no AI attribution (`CLAUDE.md` §Commit message format), read
     from the same pattern the hook uses rather than a second copy of it.

Only then does it commit. `--dry-run` stops after the proof.

    python3 scripts/project/commit_merge.py -F <msgfile> [--dry-run]
"""
import argparse
import importlib.util
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(next(
    p / "lib" for p in Path(__file__).resolve().parents
    if (p / "lib" / "project_paths.py").is_file())))
from project_paths import PROJECT_ROOT, SCRIPTS_ROOT  # noqa: E402


def _attribution_pattern():
    """The hook's own pattern, loaded from the hook. One definition, not two.

    A second copy would drift, and the copy that drifts is the one that stops matching
    the trailer this tooling actually emits.
    """
    source = SCRIPTS_ROOT / "ai" / "hooks" / "block_forbidden_git.py"
    spec = importlib.util.spec_from_file_location("block_forbidden_git", source)
    assert spec is not None and spec.loader is not None, f"[commit-merge] cannot load {source}"
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.AI_ATTRIBUTION


def _git(*args: str) -> str:
    result = subprocess.run(
        ["git", *args], cwd=PROJECT_ROOT, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise SystemExit(
            f"[commit-merge] git {' '.join(args)} failed:\n{result.stderr.strip()}")
    return result.stdout


def _lines(output: str) -> list[str]:
    return [line for line in output.splitlines() if line.strip()]


def run(message_file: Path, dry_run: bool) -> int:
    merge_head = PROJECT_ROOT / ".git" / "MERGE_HEAD"
    if not merge_head.is_file():
        raise SystemExit(
            "[commit-merge] there is no merge in progress (.git/MERGE_HEAD is absent). "
            "An ordinary commit takes the pathspec route CLAUDE.md documents; this script "
            "is only for the commit with two parents.")

    conflicted = _lines(_git("diff", "--name-only", "--diff-filter=U"))
    if conflicted:
        raise SystemExit(
            "[commit-merge] the merge is not finished — still conflicted:\n"
            + "\n".join(f"    {path}" for path in conflicted))

    message = message_file.read_text(encoding="utf-8")
    if _attribution_pattern().search(message):
        raise SystemExit(
            f"[commit-merge] {message_file} carries AI attribution, which this repo "
            "forbids (CLAUDE.md §Commit message format). The history's author is the "
            "person who ships it.")

    base = _git("merge-base", "HEAD", "MERGE_HEAD").strip()
    theirs = set(_lines(_git("diff", "--name-only", base, "MERGE_HEAD")))
    staged = set(_lines(_git("diff", "--cached", "--name-only")))
    outside = sorted(staged - theirs)

    print(f"[commit-merge] merge base {base[:8]}; the other side touches {len(theirs)} "
          f"path(s); {len(staged)} staged.")
    if outside:
        raise SystemExit(
            "[commit-merge] the index holds work this merge did not bring:\n"
            + "\n".join(f"    {path}" for path in outside)
            + "\n[commit-merge] A merge commit takes the WHOLE index — git allows no "
              "pathspec here — so committing now would carry those under this message. "
              "Unstage them (git restore --staged <path>) and run again. If they are "
              "yours and belong in this merge, they belong in a commit of their own "
              "first.")
    print("[commit-merge] every staged path belongs to the merge.")

    if dry_run:
        print("[commit-merge] --dry-run: nothing committed.")
        return 0

    print(_git("commit", "-F", str(message_file)).strip())
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("-F", "--file", required=True, type=Path,
                        help="the commit message file")
    parser.add_argument("--dry-run", action="store_true",
                        help="run every proof and stop before committing")
    args = parser.parse_args()
    return run(args.file, args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
