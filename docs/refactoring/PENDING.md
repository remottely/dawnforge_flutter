# Pending — everything documented and not yet done

> The derived index over the plans in `implementation_plan/`. Each item names its plan,
> its gate, and its state. Read this first when onboarding (the `/onboard` flow).

| # | Item | Plan | Gate | State |
|:--|:---|:---|:---|:---|
| 1 | FP0.9 — port the lifecycle skills | `implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md` | skills fire on their triggers | pending (rest of FP0 gate met 2026-08-25) |
| 2 | FP1.5/FP1.9 — component slice + domain `*Rules` ports | same plan | first components (health/movement) + rules with tests | first slice done 2026-08-26 (Direction/Movement/Health + 4 Rules); more vitals/AI components arrive with their systems |
| 3 | FP2.3 — sprites steps (02/03) | same plan | atlas cropped into sprite PNGs + manifest for the Dart AnimationCreator | pending — opens the FP3 block (its consumer is the renderer); the source atlas exists in the Godot repo (`data/atlas/dawnforge_v1_16x16_atlas_forge_almanac.png`); needs Pillow in the .venv. FP2.4 (translations) and FP2.5 (component-keys) done 2026-08-26 |
| 4 | FP3 — World & rendering (Flame) | same plan | walkable chunked world at 60fps with budget overlay | pending |
| 5 | FP4 — First gameplay loop | same plan | harvest → craft → place playable | pending |
| 6 | FP5–FP7 | same plan | per-phase gates | pending |
