# Dawnforge — Godot → Flutter Port Study

> **The founding document of this repository's second life.** Written 2026-08-25, from a
> full read of `dawnforge_project` (the Godot/Tessera repo) at `0.1898.x`-era HEAD and of
> this repo's legacy code (now archived in `reference/legacy_flutter/`).
>
> This file records **what is being reproduced, what is deliberately not, and why** — so
> the reference is never lost. It is a *study*, not a plan: the executable plan lives in
> `docs/refactoring/implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md`.

---

## 1. Strategic context — why two engines

| Track | Repo | Role |
|:---|:---|:---|
| **Godot / Tessera** | `~/Documents/godot/remottely/dawnforge_project` | Consolidated delivery track. First Tessera game (Dawnforge) is near v1.0. Ships to Steam, multiplayer co-op. |
| **Flutter / Tessera-Dart** | this repo | Study track: reproduce the Tessera architecture in Flutter/Dart to explore new genres inside Flutter, with the same engineering discipline. **Singleplayer-first.** |

The two tracks share *architecture, content format, and the AI harness* — not code. A
lesson learned on either side is portable because the shapes match.

The legacy Flutter game that used to live here (Bonfire-based, `lib/` with ~298 files) was
archived wholesale to `reference/legacy_flutter/` on 2026-08-25. It is reference material
only — nothing imports from it, and no pattern is carried forward without passing through
the rules in `CLAUDE.md`.

---

## 2. Source project inventory (what Tessera/Godot is)

Measured at study time:

| Piece | Size | Notes |
|:---|:---|:---|
| GDScript | ~452 files | Node-lifecycle layer: components (49), base world objects (54), UI (58), FSM states |
| C# | ~292 files | "Game core": systems/managers, registries, factories, resources, 28 pure-domain `*Rules.cs` |
| Content resources | ~1,438 `.tres` | **Generated** from the `.md` pack — never hand-edited |
| Scenes | 36 `.tscn` | Deliberately few: "Shell vs Soul" — scenes are empty shells, data injects everything |
| Content pack | `games/dawnforge/data/` | Markdown + YAML frontmatter, the SSOT for all game content |
| Pipeline | `dawnforge.py` + `scripts/pipeline/` (steps 02–12) | `.md` → `.tres`, sprites from atlas, translations, generated key tables |
| AI harness | `CLAUDE.md` (34 rules) + `docs/AI_HARNESS.md` + `scripts/ai/` + 12 skills + 2 hooks | ~1,300 lines of Python, zero dependencies, fully portable |

### The architecture in one paragraph

Tessera is a **content engine**: `src/core/` is a reusable engine that never names the
game's content folders; `src/generated/` + the content pack are the game. World objects
(Actor / Prop / Ground / Item) are **shells** created only by **Factories**, which pull
self-validating **data Resources** from auto-discovering **Registries** and inject them
via `initialize(data)` (always duplicated — each instance owns its state). Behaviour is
composed from **components** (ECS-lite, one container per object in `WorldObjectCore`,
keys generated from class names), complex state uses **FSMs**, cross-system communication
goes through an **Events bus**, and grid math goes through **GridManager**. Pure decision
logic lives in `domain/*Rules` classes with no engine types. Everything fails fast:
**zero fallbacks, assert everywhere, a crash is a feature**. Serialization flows through
the data layer only.

None of that is Godot-specific. That is the finding that makes this port viable.

---

## 3. Concept mapping — Godot → Flutter/Dart

### 3.1 Direct translations (the ~70–80% that ports cleanly)

| Godot / Tessera concept | Flutter / Dart equivalent | Fidelity |
|:---|:---|:---|
| GDScript + C# hybrid | **Dart only** — the split existed because neither language covered both profiles; Dart does | improves |
| `Resource` data classes (self-validating, `_init` asserts) | plain Dart classes with `assert` in constructors, built from JSON | 1:1 |
| `.tres` content files | **JSON files** emitted by the same pipeline (see §4) | 1:1 |
| Registries (auto-discover `.tres`, typed dict, assert on miss) | Registries scanning bundled JSON assets (`AssetManifest`), `Map<String, T>`, throw on miss | 1:1 |
| Factories (only place allowed to instantiate) | Factories (only place allowed to construct world-object components) | 1:1 |
| `initialize(data)` + `duplicate()` | `initialize(data)` + `copyWith()`/clone constructor | 1:1 |
| `IComponent` + `WorldObjectCore` container | Dart component classes + one container object per world object | 1:1 |
| `ComponentKeys` generated from `class_name` | generated from Dart class names (same generator idea, step 10) | 1:1 |
| FSM (`StateMachine` + `State` nodes) | plain Dart FSM (no Node needed — simpler) | 1:1 |
| `Events` autoload (signal bus) | typed event bus (broadcast streams or listener registry), injected via service locator | 1:1 |
| Autoloads / managers | long-lived singletons via `get_it` (registered at boot, never null — rule 28 holds) | 1:1 |
| `domain/*Rules.cs` (pure logic) | pure Dart classes — **the easiest and highest-value port**, unit-testable with plain `dart test` | improves |
| `game_constants.gd` / `GameConstants.cs` pair | one `game_constants.dart` (no dual-language twin needed) | improves |
| GUT + GdUnit4 dual suite | one `flutter test` suite | improves |
| Localization CSV → `tr()` | same CSV source → generated ARB/lookup, one `tr()` helper | 1:1 |
| `SaveManager` (10 sections, versioned, fail-fast load) | JSON save via same section ownership, `path_provider` + `dart:io` | 1:1 |
| Blur-behind-menu shader | `BackdropFilter` — trivial in Flutter | improves |
| UI (58 GDScript Control files) | Flutter widgets — Flutter's strongest suit | improves |

### 3.2 Needs redesign (the costly 20–30%)

| Godot concept | Problem | Chosen approach |
|:---|:---|:---|
| Scene tree / `.tscn` shells | No scene files in Flame | Fine: Tessera already treats scenes as empty shells. The Factory *is* the scene — it assembles a `PositionComponent` + sprite + components in code. 36 scenes ≈ a handful of assembly functions. |
| `TileMap` + terrain autotiling + chunked procedural world | Flame has basic tile support (or Tiled maps); no terrain system, no chunk streaming | Custom chunk renderer on Flame (`SpriteBatch` per chunk layer, bake on demand — mirrors `procedural_map_view.gd`'s budgeted chunk bake). Biggest single engineering item. |
| `CharacterBody2D` physics / `move_and_slide` | Flame has hitboxes + collision callbacks, not solid-body resolution | Port movement from `domain/movement` rules + simple AABB grid collision (top-down game: grid occupancy is already the authority via `GridManager`). |
| Godot editor (inspector, scene preview, `.tres` preview) | No editor | Accepted loss for a code-first study engine. Debug overlays + hot reload partially compensate. Content stays authorable: the pack is Markdown. |
| High-level multiplayer API (RPCs, `MultiplayerSynchronizer`) | Nothing equivalent in Flutter | **Out of scope — deliberately** (§5). Singleplayer-first; sim-architecture decisions that keep the door open are kept (no pause, intent-shaped input). |
| Shaders (`menu_blur.gdshader`, vfx) | Flutter fragment shaders exist but the ecosystem is thinner | Menu blur → `BackdropFilter`. Other vfx case-by-case; Flame supports `FragmentShader` where needed. |
| `AudioStreamPlayer` buses | — | `flame_audio` / `audioplayers`, thin `AudioSystem` façade like the Godot one. |

### 3.3 Engine base decision: Flame direct, not Bonfire

The legacy code here used **Bonfire**. The port will use **Flame directly**. Reason:
Bonfire is itself an opinionated top-down framework (its own player/enemy classes, its own
component conventions, Tiled-centric maps) — it *competes* with Tessera's architecture
rather than hosting it. Tessera brings its own factories, components, FSM, grid, chunked
world; what it needs from below is exactly what bare Flame provides: game loop, render
tree, sprites/animation, camera/viewport, input, collision primitives, audio. Hosting
Tessera on Bonfire would mean two component systems and two opinions about what a "player"
is. *(Flagged as decision D2 — reversible while Phase 1 is pure Dart, expensive after.)*

---

## 4. The content pipeline — the biggest lever

The single most favorable fact for this port: **content is not written in `.tres`, it is
written in Markdown+YAML and generated.** The Godot pipeline is:

```
games/dawnforge/data/*.md  →  python3 dawnforge.py full  →  games/dawnforge/generated/*.tres
```

`.tres` is only a serialization format choice in step `04_import_almanac_to_tres.py`.
This repo gets the same pipeline with a JSON emitter:

```
games/<game>/data/*.md  →  python3 dawnforge.py full  →  assets/generated/<game>/*.json
```

Consequences:

- The ~1,438 existing resources are reusable **at the cost of one emitter**, not a rewrite.
- The pack contract (`docs/PACK_CONTRACT.md` in the Godot repo) is shared verbatim: tier
  prefixes, id = filename, hierarchical field blocks.
- A game authored for the Godot engine can, in principle, be *played* on the Flutter
  engine once system coverage matches — that is the long-term promise of the two-track
  strategy, and the reason the pack format must never fork.
- Generated key tables (`ComponentKeys`, state keys) emit `.dart` instead of `.gd`+`.cs` —
  one target instead of two.

What does **not** carry over from the pack unchanged: atlas/sprite extraction works as-is
(PNG in, PNG out), but Godot-specific outputs (`.import` files, `SpriteFrames` resources)
are replaced by a sprite/animation manifest JSON consumed by the Dart `AnimationCreator`.

---

## 5. Deliberate scope cuts

| Cut | Why | Door kept open by |
|:---|:---|:---|
| **Multiplayer** | The single most expensive Godot feature to reproduce (custom netcode from zero) and the least aligned with the study goal | Rule 30 kept (no pause, blocker stack, sim keeps running behind UI); input as intents; systems own their serialized sections |
| **C#/GDScript interop rules** (rules 26, parts of 8) | No boundary exists in Dart | — |
| **Steam transport** | Delivery-track concern | — |
| **GUT/GdUnit4 dual suite** | One language → one suite | `flutter test` + the same "suite is green before commit" policy |
| **Godot editor tools** (`tessera/tools/*.gd`) | No editor | Pipeline `--check` modes + debug overlays |

Everything else is in scope: world objects, components, FSM, registries, factories,
domain rules, grid, events, time system, spawning, drops, inventory, farming, progression,
quests, achievements, skill trees, thermal, save, localization, audio, UI surfaces,
minigames, procedural world with chunks and elevation — replicated incrementally in the
plan's phase order.

---

## 6. The AI harness port (replicated, not adapted-away)

The harness is engine-agnostic by construction (zero-dependency Python, BM25 over
Markdown, git history as corpus). Ported pieces and their deltas:

| Piece | Port status | Delta from Godot repo |
|:---|:---|:---|
| `CLAUDE.md` — the non-negotiable rules | rewritten for Dart, same spirit, renumbered | interop rules dropped; Godot-API rules re-aimed at Flame/Flutter APIs (e.g. rule 30's ban covers `pauseEngine()`) |
| `docs/AI_HARNESS.md` | ported | corpus globs and tool names updated |
| `scripts/ai/` (index, search, budget) + `scripts/lib/knowledge_index.py` | copied, paths adapted | corpus: this repo's `docs/**`, pack, skills, commits |
| `scripts/lib/project_paths.py` | rewritten for this tree | `DATA_ROOT`, `GENERATED_ROOT` → `assets/generated/`, etc. |
| Hook: `block_forbidden_git.py` | copied, paths adapted | same git prohibitions; data-pack write guard re-pointed |
| Hook: `check_edited_file_rules.py` | rewritten patterns | Dart tripwires: `pauseEngine`/`timeScale` writes, raw pointer reads outside `InputHelper`, `dynamic` in `src/core/` |
| Skills (12) | lifecycle 9 ported over time; know-how skills replaced | `csharp-interop`/`godot-run` → a future `flutter-run`; `scaffold-worldobject` re-templated for Dart |
| Ledger + evolution loop (`LEDGER.md`, `PENDING.md`, sweeps) | ported | identical mechanism |
| Version scheme `0.MINOR.PATCH`, bump-from-HEAD commit ritual | adopted fresh from `0.1.0` | version lives in `pubspec.yaml` |
| Rule 34 (changelog + manual, en/pt-BR, same commit) | ported | paths under `games/<game>/` |

---

## 7. Honest risk register

1. **Chunked world renderer performance** — Flame can do it (sprite batching, picture
   caching), but it is the one place where "Godot gave it for free" is most true. Mitigate
   early: Phase 3 builds the chunk renderer before any gameplay system depends on it, with
   a frame-budget harness from day one.
2. **Solo-dev bandwidth across two tracks** — the study track must never block the
   delivery track. The phase plan is sized so each phase is independently parkable.
3. **Pack-format drift** — two engines reading one format means a field added for one must
   not silently break the other. The pipeline's `--check` discipline is the guard; the
   pack contract doc is shared.
4. **Bonfire→Flame regression of the legacy game** — the legacy game is *not* being
   preserved; it is reference only. No obligation exists to keep it running.
5. **Flutter engine tick vs. simulation determinism** — the Godot sim runs on a fixed
   server clock (multiplayer heritage). Flame's `update(dt)` is variable-step. Adopt a
   fixed-step accumulator in the sim layer from the start; cheap now, painful later.

---

## 8. Decision register

| ID | Decision | Why | Reversible? |
|:---|:---|:---|:---|
| D1 | Two tracks, shared architecture + pack + harness, no shared code | Dart↔GDScript/C# code sharing is impossible; shape sharing is the real asset | — |
| D2 | **Flame direct, no Bonfire** | Tessera is the framework; Bonfire would be a second, competing one (§3.3) | Until Phase 3 starts; costly after |
| D3 | Content as **JSON** generated by the retargeted pipeline | Keeps `.md` pack as SSOT; 1,438 resources reused for the cost of one emitter | Yes (emitter swap) |
| D4 | **Singleplayer-first**, multiplayer-shaped sim (no pause, intents, sectioned saves) | §5 | Kept-open by design |
| D5 | Version scheme reset to `0.MINOR.PATCH` in `pubspec.yaml`, starting `0.1.0` | Same ritual as the Godot repo (rule on major locked at 0); legacy `1.110.x` numbering retired with the legacy code | — |
| D6 | Legacy code archived to `reference/legacy_flutter/`, excluded from the knowledge index corpus and from all imports | Clean-room rebuild; reference value only | Yes (it's all still there) |
| D7 | One Dart package, engine under `lib/src/core/` with the same sector model; game content under `games/<game>/` + `assets/generated/` | Mirrors the Godot tree so cross-repo navigation is muscle-memory | Refactorable |

---

## 9. What "done" looks like for the study track

Not v1.0 of a game. The study track is successful when:

1. The Tessera sector model exists in Dart with the same rules enforced (registries,
   factories, components, FSM, events, grid, domain rules, zero fallbacks).
2. The pipeline emits JSON from the same pack format and the engine boots from it.
3. A player-controlled actor walks a chunked, procedurally-assembled world with props,
   items, inventory, and one full gameplay loop (harvest → craft → place) — singleplayer.
4. The AI harness runs here with the same lifecycle (onboard → recall → plan → implement
   → verify → document → ship → observe → evolve).
5. New-genre experiments can be started as new packs under `games/` without touching
   `src/core/` — the actual point of the study.
