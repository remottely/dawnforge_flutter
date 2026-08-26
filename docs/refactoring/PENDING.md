# Pending — everything documented and not yet done

> The derived index over the plans in `implementation_plan/`. Each item names its plan,
> its gate, and its state. Read this first when onboarding (the `/onboard` flow).

| # | Item | Plan | Gate | State |
|:--|:---|:---|:---|:---|
| 1 | FP0.9 — port the lifecycle skills | `implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md` | skills fire on their triggers | pending (rest of FP0 gate met 2026-08-25) |
| 2 | FP1.5/FP1.9 — component slice + domain `*Rules` ports | same plan | first components (health/movement) + rules with tests | first slice done 2026-08-26 (Direction/Movement/Health + 4 Rules); more vitals/AI components arrive with their systems |
| 3 | FP2.3 — sprites steps (02/03) | same plan | atlas cropped into sprite PNGs | done 2026-08-26 (22 crops + 14 placeholders; Pillow; `res://data/…` mapped to `assets/generated/<game>/…`). FP2.4/FP2.5 done 2026-08-26. Note: the Godot repo restructured (`tessera.py`, pipeline under `tessera/scripts/`) — cross-repo references in our docs may need a sweep |
| 4 | FP3 — World & rendering (Flame) | same plan | walkable chunked world at 60fps with budget overlay | FP3.1–3.3 done 2026-08-26; FP3.4 done 2026-08-26 in five commits (0.8.0–0.12.0: biome+terrain content & step 11, noise+generator, grid occupancy, chunk streaming, chunk renderer + procedural game boot — T1 scope, deltas in each commit body); remaining: FP3.5 grid collision, FP3.6 debug overlays + the on-device 60fps hand-run |
| 5 | FP4 — First gameplay loop | same plan | harvest → craft → place playable | pending |
| 6 | FP5–FP7 | same plan | per-phase gates | pending |
