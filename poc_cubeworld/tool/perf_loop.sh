#!/usr/bin/env bash
# The performance loop of docs/PERFORMANCE_VS_GODOT_2026-09-11.md, as one command: release
# build, radius 8 / 12 / 16, fill time, sustained fps and peak memory per radius. The gates of
# VP1.5, VP2.2 and VP3 (docs/VOXEL_PACKAGES_PLAN_2026-09-14.md) read its table.
#
#   tool/perf_loop.sh                 # build this POC in release, then measure
#   tool/perf_loop.sh --no-build DIR  # measure an already built POC rooted at DIR
#
# Close other heavy work first: the numbers are wall-clock on the developer's machine.
set -euo pipefail
cd "$(dirname "$0")/.."

root=.
if [[ ${1:-} == --no-build ]]; then
  root=${2:?--no-build needs the POC directory}
else
  flutter build macos --release >/dev/null
fi
app=$root/build/macos/Build/Products/Release/cubeworld_poc.app/Contents/MacOS/cubeworld_poc
shots=$(mktemp -d)

printf '| radius | fill ms | faces | fps | peak RSS MB |\n|--:|--:|--:|--:|--:|\n'
for r in 8 12 16; do
  out=$( { perl -e 'alarm 300; exec @ARGV' /usr/bin/time -l "$app" --new --seed=42 --radius=$r \
    --frames=3000 --settle=900 --screenshot="$shots/r$r.png"; } 2>&1 || true)
  fill=$(grep -oE 'faces in [0-9]+ ms' <<<"$out" | grep -oE '[0-9]+' | head -1)
  faces=$(grep -oE 'chunks, [0-9]+ faces' <<<"$out" | grep -oE '[0-9]+' | head -1)
  fps=$(grep -oE '\[probe\] fps [0-9]+' <<<"$out" | grep -oE '[0-9]+$' | tail -1)
  rss=$(grep -E 'maximum resident set size' <<<"$out" | grep -oE '^ *[0-9]+' | tr -d ' ')
  printf '| %s | %s | %s | %s | %s |\n' "$r" "${fill:-?}" "${faces:-?}" "${fps:-?}" "$(( ${rss:-0} / 1048576 ))"
done
