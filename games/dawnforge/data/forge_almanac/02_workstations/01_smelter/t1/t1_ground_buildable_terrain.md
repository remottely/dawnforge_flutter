---
type: ground_buildable_data
id: t1_ground_buildable_terrain
display_name_key: forge_almanac.02_workstations.01_smelter.t1.t1_ground_buildable_terrain.display_name
description_key: forge_almanac.02_workstations.01_smelter.t1.t1_ground_buildable_terrain.description

_sprites:
  atlas_position: [5, 0]
  frames_grid: [1, 1]

translations:
  display_name:
    en: "Natural Ground"
    pt_BR: "Chão Natural"
    es: "Suelo Natural"
  description:
    en: "The plain ground of wherever you are standing. Use it to fill a hole or flatten a patch."
    pt_BR: "O chão comum do lugar onde você está. Sirve para tapar um buraco ou aplainar um pedaço."
    es: "El suelo llano del lugar donde estás. Sirve para tapar un hoyo o aplanar un trozo."

GroundBuildableData:
  z_index_offset: 0
  use_tilemap_layer: true
  target_layer_name: TerrainLayer
  tile_source_id: 0
  tile_atlas_coords: [0, 0]
  terrain_set: 0
  terrain: 0
  use_biome_terrain: true
  is_dense_terrain: true
  blocks_props: false
  allows_resource_spawning: true
  speed_modifier: 1.0
  farm_prop_id: t1_prop_soil
  farm_tools: [SHOVEL]
  floats_on_water: false
  elevation_allowed_tools: [PICKAXE]

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: false
  collision_shape_type: QUADRILATERAL
  collision_padding: [0, 0, 0, 0]
  has_collision: false
  allows_actor_overlap: false
  is_projectile_passable: true
  occlusion_y_offset: 0.0
  occlusion_target: ALL
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 22.0
  thermal_tolerance: 500.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  allowed_tools: [SLEDGEHAMMER]
  inventory_size: 30
  health_bar_width: 1.5
  health_bar_height: 0.1875
  bar_offset_y: 8.0
  hide_bar_when_full: true
  health_bar_always_visible: false
  energy_bar_width: 24.0
  energy_bar_height: 2.0
  energy_bar_vertical_spacing: 2.0
  energy_bar_always_visible: false
  mana_bar_width: 1.5
  mana_bar_height: 0.125
  mana_bar_always_visible: false
  has_label_component: false
  is_label_editable: false
  default_label_text: ""
  sprite_variants: 0
  sound_receive_damage: "res://data/audio/sfx/hit/Nail Wood 1_6.wav"
  sound_die: ""
  xp_reward: 5
  tier_placement_rule: SAME_TIER

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/02_workstations/01_smelter/t1/sprites/t1_ground_buildable_terrain.png"
  frame_size: [1, 1]
  position_offset: [0, 0]
  sprite_anchor: BOTTOM_LEFT
  animation_speed: 0.15
  glow_type: NONE
  glow_color: [0.0, 0.0, 0.0, 0.0]
  glow_radius: 0.0
  glow_speed: 0.0
  glow_origin_offset: 0.0
  casts_shadow: true
  shadow_origin_offset: -0.0625
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

elevation_drops:
  - item_id: t1_item_stone_moss
    chance: 1.0
    min_amount: 1
    max_amount: 2

drops:
  - item_id: t1_item_buildable_ground_grass
    chance: 1.0
    min_amount: 1
    max_amount: 1

# THE CAVE WALL IS THE DEPOSIT. Underground this same tile is ~83% of the world and open
# floor is ~14% of it, and a prop can only stand on open floor — so ore authored only in
# procedural_cave_<bioma>.md is ore found by walking into a pocket, never by digging. These
# chances are per WALL TILE CUT, so the yield scales with how far the player tunnels instead
# of with how many pockets they stumble into: ~1 tile in 25 pays out, and a 15-tile tunnel
# averages roughly one ore and one coal. The surface's `elevation_drops` above is untouched —
# a mountain is not a mine.
cave_elevation_drops:
  - item_id: t1_item_stone_moss
    chance: 1.0
    min_amount: 1
    max_amount: 2
  - item_id: t1_item_coal
    chance: 0.025
    min_amount: 1
    max_amount: 2
  - item_id: t1_item_ore_copper
    chance: 0.013
    min_amount: 1
    max_amount: 2
---