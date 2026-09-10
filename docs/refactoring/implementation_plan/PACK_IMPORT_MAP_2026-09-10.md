# The pack import map — what content this port carries, and what it does not

> **How to use this document.** The content pack is the shared contract (study §4) and it
> is imported here **one slice at a time**, by the commit that needs it. Nothing has ever
> written down how much is left, so every slice re-measures it by hand. This is that
> measurement, with the remaining documents grouped into batches and each batch handed to
> the `FP` step that will need it. No item here needs a decision.
>
> **Out of scope:** the port work itself — a batch names the data class and registry arm
> its documents need, and the port plan owns the behaviour. This document never says how a
> thing works, only which documents must exist before it can.
>
> **Measured 2026-09-10 at `0.53.0`** against the spec's pack at `tessera 0.440.4`:
> **930 Markdown documents there, 64 here.** Re-measure before acting.
>
> **A caution this map cannot fix.** FP0.11's drift check — landing the same day — reported
> on its first run that **28 of the imported documents and 67 keys have already forked**
> from their originals. The counts below say what has *crossed*, never that what crossed is
> current. Import batches must run the drift check afterwards, not just the pipeline.

## Progress

| ID | Batch | Documents | For | State |
|:---|:---|---:|:---|:---|
| **PI1** | `03_farm`, tiers 1–2 | 0 | FP4.4 | **complete** — nothing to import; FP4.4's remaining slices are code only |
| **PI2a** | the rest of the three stations already here | 210 | FP4.5 · FP7.5 | pending |
| **PI2b** | the forge and the kitchen | 80 | FP7.12 | pending |
| **PI3** | the second biome, surface | ~99 t2 | FP7.3 | pending |
| **PI4** | audio: `sfx_defaults.md` + the sound tree | 1 + 114 | FP7.9 | pending |
| **PI5** | quests, then achievements | 36 + 131 | FP7.6 | pending |
| **PI6** | cosmetics | 166 | FP7.11 | pending |
| **PI7** | the five caves | 5 | FP7.4 | pending |
| **PI8** | `ui_anim_config.md` | 1 | FP5.1 | pending |
| **PI9** | tiers 3, 4 and 5 | ~319 | FP7.5 | pending |

---

## 1. What is here

| Family | Spec | Here | Owner |
|:---|---:|---:|:---|
| `forge_almanac/` | 534 | 59 | per FP slice — §2 |
| `cosmetics/` | 166 | 0 | FP7.11 |
| `achievements/` | 131 | 0 | FP7.6 |
| `quests/` | 36 | 0 | FP7.6 |
| `templates/` | 28 | 0 | never — §3 |
| `world/` | 16 | 1 | FP7.3 (surface), FP7.4 (caves), never (islands) |
| `rules/` | 8 | 0 | never — §3 |
| `ui/` | 2 | 1 | FP5.1 and FP7.9 — and the one here is not one of the two |
| `audio/` | 1 (+114 sounds) | 0 | FP7.9 |
| `locales/` | 1 (+ a CSV) | 0 | never as a file — §3 |
| `fonts/` | 0 (3 typefaces) | 0 | `D-7` |
| `player/`, `progression/` | 1 each | 1 each | **complete** |

### The almanac is a ladder, and this port is standing on the first rung

| Tier | Spec | Here |
|:---|---:|---:|
| t1 | 109 | 52 |
| t2 | 106 | 7 |
| t3 | 106 | 0 |
| t4 | 106 | 0 |
| t5 | 107 | 0 |

Five tiers of **almost exactly the same 107 documents** — the same families, the same
fields, better numbers. That shape is the single most useful fact in this document: once
tier 1 parses, tiers 2–5 are volume and not risk, and the thing that gates them is not the
importer but `is_content_unlocked` (FP7.5) and the tier field that decides where a tier
lives in the world (FP7.3). **Importing them earlier is not free** — it puts items in the
crafting menu the player cannot reach and props in a scatter that has nowhere to put them.

---

## 2. The batches

### PI2 · The workstations, which are emptier here than the folder names suggest

`02_workstations/` holds five stations over there and three here, and the three that are
here are nearly empty:

| Station | Spec | Here |
|:---|---:|---:|
| `01_smelter` | 75 | 12 |
| `02_workshop` | 115 | **1** |
| `04_seed_station` | 40 | 7 |
| `03_forge` | 55 | 0 |
| `05_kitchen` | 25 | 0 |

**One document of the workshop's 115 is here.** That is the sharpest number in this map: the
station whose recipe list opens the whole tool tree (FP4.5's chain — every tool is a
`WORKSHOP` recipe) is represented by a single document, because imports have been driven by
what one commit needed and never by what a station *is*. FP4.5's gate does not require more —
one pickaxe recipe closes the loop — but the first player who opens the workshop panel and
sees one row will be looking at an import gap, not at a design.

**PI2a** is the rest of those three stations (210 documents), and it is tier-shaped like
everything else: tier 1 with the surface that shows it, tiers 2–5 with PI9. **PI2b** is the
forge and the kitchen (80), which are new prop families and belong with FP7.12.

### PI3 · The second biome, on the surface

`world/procedural/procedural_swamp.md` plus the t2 almanac documents its population names.
The port plan already makes this a sub-gate rather than an import: **`ProceduralWorldManager.
initialize` crashing on a second biome IS FP7.3's gate**, and it cannot crash until a second
biome exists. So PI3 is the smallest batch with the largest information return, and it
should be run as a probe before FP7.3 is planned in detail.

The other three surface biomes (`desert`, `snow`, `lava`) follow the same shape and wait for
the tier field to have somewhere to put them.

### PI4 · Audio

One document (`audio/sfx_defaults.md`) and 114 sound files. The document is the whole
contract — which sound each verb makes, by material — and it is the reason FP7.9 also owes
pipeline step 12 (`AUTOMATION_DEBT_2026-09-10.md` §1.1). The 37 unresolved `res://`
references the emitted JSON already carries are all in this family: they are pointing at
these files, from documents that crossed before the sounds did.

The `.import` sidecars Godot writes next to every asset **do not cross** — they are that
engine's import cache and mean nothing here.

### PI5 · Quests, then achievements

36 quest documents and 131 achievements, in that order, because the achievements read the
statistics ledger and the quests read the objectives — FP7.6 already fixes the order
(statistics first). The achievements also carry `_families.yaml` and are *generated* over
there by `generate_achievement_families.py`; rule 23 says the generator crosses with them,
which makes this the one batch that is a script port as well as a copy.

### PI6 · Cosmetics

166 documents, and the six `cosmetic_*_id` fields are already authored on the player
document here — so this family is unusual: the **references exist and the targets do not**.
Nothing breaks today because nothing reads those fields. FP7.11 owns it, and it owns the two
generators with it.

### PI7 · The five caves

`procedural_cave_<biome>.md` × 5, with FP7.4's layer work. They are listed separately from
PI3 because a cave is not a biome with a different table: it is a second world layer, and
importing it before `WorldLayer` exists puts five documents in the tree that nothing can
load — rule 5's own argument, applied to content.

### PI8 · `ui_anim_config.md`

One document, the animation timings every surface reads. It is owed by FP5.1 and it is the
cheapest of these batches; its sibling `ui_sound_config.md` rides with PI4.

**Note a divergence while here:** this repo's `data/ui/` holds `ui_strings.md`, which the
spec does not have — its static interface strings live in `locales/translations_static.csv`
and reach the tables through step 05. That fork was deliberate (0.20.0, rule 19 had no
satisfiable source otherwise) and is exactly the kind of document FP0.11's allowlist must
declare with its reason.

### PI9 · Tiers 3, 4 and 5

~319 documents, mechanical, and last for the reason §1 gives: a tier the player cannot
reach is content the game must still load, scatter and offer.

---

## 3. What never crosses, and why

- **`rules/`** (8 documents: `CREATURE_RULES.md`, `ITEM_RULES.md`, `SURVIVAL_RULES.md`, …)
  are game-design prose, not engine content. The engine never reads them, and the study
  makes the Godot repo the spec — a copy here would be a second design SSOT, which is the
  fork the contract exists to prevent. Cite them by path; do not copy them. The four
  design documents at the pack root (`GDD_V1.0.md`, `STUDY.md`, …) are the same answer.
- **`templates/`** (28 document templates) is authoring machinery, and authoring happens on
  the delivery track (`AUTOMATION_DEBT_2026-09-10.md` §6.2). They are still the best field
  reference when an import fails, so read them; do not carry them. The sprite placeholders
  under `templates/sprites/` are a different thing and are already here — step 03 needs them.
- **`locales/translations_static.csv`** is step 05's second source *over there*. Here that
  role is `data/ui/ui_strings.md` (§PI8). The strings themselves cross, one surface at a
  time, in the commit that shows them — never the file.
- **`world/islands/`** (6 documents) is island mode, which this port does not have and does
  not plan (FP7.2 records that the spec's respawn manager is island-only).
- **`rigs/`, `vfx/`, `.obsidian/`, every `.import` sidecar** — 3D rigs, Godot particle
  resources, an editor's vault, and an import cache.
- **`fonts/`** waits on `D-7`, which parks the pixel font until the surfaces exist.

---

## 4. What an import batch owes

Every batch, without exception:

1. the documents, **copied verbatim** — never re-authored, never reordered, never
   "improved" in transit; a delta is a fork and FP0.11 will now say so;
2. the data class and registry arm anything new needs, or the batch does not land — rule 5
   means an unrouted `type:` is a crash, not a skip;
3. **every id the batch names must resolve** — the loot sweep and step 26's entry check are
   the two existing precedents, and a batch that references a document from a later batch is
   a batch that is out of order;
4. the pipeline re-run and `--check` green, then **the drift check** (FP0.11), which is the
   half that says whether what crossed is current;
5. rule 34: content the player meets gets its changelog line, in both languages.

---

## Decision register

| ID | Blocks | Question | Recommendation |
|:---|:---|:---|:---|
| **PI-D1** | nothing today | Should the four design documents at the pack root (`GDD_V1.0.md`, `STUDY.md`, `AUTOMATION_PATTERNS_V1.0.md`) be copied here so a session can read the game's intent without the sibling checked out? | **No — cite, never copy.** A copied design document has no drift check (FP0.11 covers the pack, not the prose), and the study already makes the Godot repo the readable spec. If the sibling's absence is the real problem, the honest fix is FP0.11's "not applicable, never a pass" answer applied to documentation: a session without the sibling should be told so, not handed a stale copy. |
