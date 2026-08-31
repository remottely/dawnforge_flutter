---
type: ground_buildable_data
id: t1_ground_buildable_bridge_palm
display_name_key: forge_almanac.02_workstations.01_smelter.t1.t1_ground_buildable_bridge_palm.display_name
description_key: forge_almanac.02_workstations.01_smelter.t1.t1_ground_buildable_bridge_palm.description

translations:
  display_name:
    en: "Palm Bridge"
    pt_BR: "Ponte de Palmeira"
    es: "Puente de Palma"
  description:
    en: "Planks of palm laid over water so you can walk straight across."
    pt_BR: "Pranchas de palmeira deitadas sobre a água para você atravessar a pé."
    es: "Tablones de palma puestos sobre el agua para cruzar caminando."

GroundBuildableData:
  z_index_offset: 0
  use_tilemap_layer: false
  target_layer_name: TerrainLayer
  tile_source_id: 0
  tile_atlas_coords: [0, 0]
  terrain_set: -1
  terrain: -1
  use_biome_terrain: false
  is_dense_terrain: false
  blocks_props: false
  allows_resource_spawning: false
  speed_modifier: 1.0
  farm_prop_id: ""
  farm_tools: []
  floats_on_water: true

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: false
  collision_shape_type: QUADRILATERAL
  collision_padding: [0, 0, 0, 0]
  has_collision: false
  allows_actor_overlap: true
  is_projectile_passable: true
  occlusion_y_offset: 0.0
  occlusion_target: ALL
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 22.0
  thermal_tolerance: 208.0
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
  sound_receive_damage: ""
  sound_die: ""
  xp_reward: 0
  tier_placement_rule: SAME_TIER_OR_BELOW

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/02_workstations/01_smelter/t1/sprites/t1_ground_buildable_bridge_palm.png"
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

drops:
  - item_id: t1_item_buildable_ground_bridge_palm
    chance: 1.0
    min_amount: 1
    max_amount: 1
---