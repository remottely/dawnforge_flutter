# Pending — everything documented and not yet done

> The derived index over the plans in `implementation_plan/`. Each item names its plan,
> its gate, and its state. Read this first when onboarding (the `/onboard` flow).

| # | Item | Plan | Gate | State |
|:--|:---|:---|:---|:---|
| 1 | FP0.9 — port the lifecycle skills | `implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md` | skills fire on their triggers | pending (rest of FP0 gate met 2026-08-25) |
| 2 | FP1.5/FP1.9 — component slice + domain `*Rules` ports | same plan | first components (health/movement) + rules with tests | first slice done 2026-08-26 (Direction/Movement/Health + 4 Rules); more vitals/AI components arrive with their systems |
| 3 | FP2.3 — sprites steps (02/03) | same plan | atlas cropped into sprite PNGs | done 2026-08-26 (22 crops + 14 placeholders; Pillow; `res://data/…` mapped to `assets/generated/<game>/…`). FP2.4/FP2.5 done 2026-08-26. Note: the Godot repo restructured (`tessera.py`, pipeline under `tessera/scripts/`) — cross-repo references in our docs may need a sweep |
| 4 | FP3 — World & rendering (Flame) | same plan | walkable chunked world at 60fps with budget overlay | **gate met 2026-08-26** — hand-run on the macOS app held **120fps** (the display's own ceiling) walking one direction continuously, which is the load pattern that stresses streaming hardest: load at the leading edge and unload at the trailing one, every chunk border, plus each new chunk's spawn burst since 0.19.0. A sustained 8.3ms frame against a 1200µs stream budget is ~2× the headroom the 60fps gate asked for. FP3.1–3.3 done 2026-08-26; FP3.4 in five commits (0.8.0–0.12.0); FP3.5 grid collision (0.13.0); FP3.6 overlay (0.14.0) |
| 5 | FP4 — First gameplay loop | same plan | harvest → craft → place playable | FP4.1 done 2026-08-26 in four commits (0.15.0 loot tables + biome population parse, 0.16.0 DropRules, 0.18.0 physical pickups, 0.19.0 procedural scatter + prop occupancy); FP4.2a inventory domain done (0.17.0). **Remaining: FP4.2b** (hotbar + inventory surface, pulling UIStateMachine forward from FP5.1), **FP4.3** (verbs/permissions, then place), **FP4.4** (farm transform), **FP4.5** (crafting — the gate). Ground destruction deferred to FP7 by decision |
| 6 | FP5–FP7 | same plan | per-phase gates | pending |
