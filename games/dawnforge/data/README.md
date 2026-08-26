# Dawnforge — Content Pack (Flutter track)

The authored content pack of this game: Markdown + YAML frontmatter, the SSOT for all
game content (rule 31). Same format as the Godot repo's
`games/dawnforge/data/` — **the pack format is shared between the two engines and must
never fork** (study §4, `docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md`).

Populated in plan step FP2.6 by importing a slice of the Godot repo's pack
(`01_biomes` + a `03_farm` subset). The pipeline (`dawnforge.py full`, ported in FP2)
reads this tree and emits JSON into `assets/generated/dawnforge/`.

Layout mirrors the Godot pack:

```
data/
├── forge_almanac/      the living .md content database (01_biomes, 02_workstations, …)
├── atlas/              source spritesheet of this pack
├── world/ templates/ audio/ ui/ …
```
