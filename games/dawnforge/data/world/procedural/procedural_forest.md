---
# One-shot population rules for the FOREST biome (tier 1) in PROCEDURAL mode.
# Each chunk (8x8 tiles) rolls this table exactly once, the first time it
# streams in — nothing here ever respawns. No cartesian placement: anchors and
# cluster members are rolled deterministically from the world seed.
# Layer this table populates (Enums.WorldLayer). The cave under this biome is the
# same tier and has its own file — see procedural_cave_<bioma>.md.
layer: 0
tier: 1

# Terreno — DENSIDADE, não valores de ruído. Cada número é uma FRAÇÃO DO MUNDO, e o
# ProceduralWorldManager a converte no corte correspondente pela tabela de quantis do
# próprio ruído, no boot. Pedir 0.15 de parede entrega ~15% de parede.
# Floresta: pouca água, colinas frequentes mas baixas — a silhueta de referência.
terrain:
  water: 0.08                  # fração alagada da SUPERFÍCIE — a caverna tem a sua, em procedural_cave_<bioma>.md
  wall: 0.15                   # fração da superfície que vira montanha, todas as alturas
  wall_height2: 0.25           # fração DA PAREDE elevada a altura 2
  wall_height3: 0.08           # fração DA PAREDE elevada a altura 3

limits:
  max_props_per_chunk: 24
  max_actors_per_chunk: 1

# Scale of the biome's richness field: how WIDE a rich district is, ~1/frequency tiles.
# It says nothing about how MANY species show the pattern — that is each entry's own
# `density_influence` below, which defaults to 0, an even spread across the biome.
# Only ore opts in, so a vein is worth prospecting for while the vegetation around it
# stays evenly scattered wherever you walk.
density_noise:
  frequency: 0.005

# SURFACE ORE IS A TENTH OF THE CAVE'S, AND WAS CUT BY THE SAME FACTOR THE CAVE WAS —
# that ratio is what makes the underground layer worth the descent, so the two tables
# only ever move together. Cut one alone and the surface becomes the better mine, which
# is the layer arguing against itself. What the surface ore is FOR is teaching: enough
# of it to show the player what a vein looks like and to buy the first pickaxe, never
# enough to live on.
prop_entries:
  # Grass is surface-only by construction: this file is the SURFACE population
  # table, and the cave layer gets its own configs (CAVE_SYSTEM_2026-08-07.md §1).
  - prop_id: t1_prop_grass_wild          # lush ground cover: what creatures graze on
    attempts_per_chunk: 4
    spawn_chance: 0.6
    cluster_min: 3
    cluster_max: 8
    cluster_radius: 3
  - prop_id: t1_prop_crop_tree_palm        # signature woods
    attempts_per_chunk: 3
    spawn_chance: 0.4
    cluster_min: 2
    cluster_max: 5
    cluster_radius: 2
  - prop_id: t1_prop_rock_moss
    attempts_per_chunk: 2
    spawn_chance: 0.3
    cluster_min: 1
    cluster_max: 3
    cluster_radius: 2
  - prop_id: t1_prop_rock_coal
    attempts_per_chunk: 1
    spawn_chance: 0.015
    cluster_min: 1
    cluster_max: 2
    cluster_radius: 1
    density_influence: 0.5     # ore rides the richness field: rich pockets, barren stretches
  - prop_id: t1_prop_vein_copper          # ore vein: tight cluster
    attempts_per_chunk: 1
    spawn_chance: 0.02
    cluster_min: 1
    cluster_max: 3
    cluster_radius: 1
    density_influence: 0.5     # ore rides the richness field: rich pockets, barren stretches
  - prop_id: t1_prop_crop_bush_clover
    attempts_per_chunk: 2
    spawn_chance: 0.25
    cluster_min: 1
    cluster_max: 3
    cluster_radius: 2
  - prop_id: t1_prop_crop_flower_clover   # flower patches
    attempts_per_chunk: 1
    spawn_chance: 0.25
    cluster_min: 2
    cluster_max: 4
    cluster_radius: 2
  - prop_id: t1_prop_crop_herb_green_leaf
    attempts_per_chunk: 1
    spawn_chance: 0.2
    cluster_min: 1
    cluster_max: 2
    cluster_radius: 2
  - prop_id: t1_prop_crop_plant_vine
    attempts_per_chunk: 1
    spawn_chance: 0.2
    cluster_min: 1
    cluster_max: 2
    cluster_radius: 2
  - prop_id: t1_prop_box_copper           # rare treasure
    attempts_per_chunk: 1
    spawn_chance: 0.04
    cluster_min: 1
    cluster_max: 1
    cluster_radius: 1

actor_entries:
  - actor_id: t1_actor_creature_boar      # herds
    pack_chance: 0.07
    pack_min: 2
    pack_max: 3
    pack_radius: 2
  - actor_id: t1_actor_enemy_melee_forest_guardian
    pack_chance: 0.05
    pack_min: 1
    pack_max: 2
    pack_radius: 2
  - actor_id: t1_actor_enemy_ranged_forest_guardian
    pack_chance: 0.04
    pack_min: 1
    pack_max: 1
    pack_radius: 2
---
