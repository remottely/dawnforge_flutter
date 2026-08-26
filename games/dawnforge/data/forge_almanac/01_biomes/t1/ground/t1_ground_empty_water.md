---
type: ground_empty_data
id: t1_ground_empty_water
display_name_key: forge_almanac.01_biomes.t1.ground.t1_ground_empty_water.display_name
description_key: forge_almanac.01_biomes.t1.ground.t1_ground_empty_water.description

translations:
  display_name:
    en: "Water"
    pt_BR: "Água"
    es: "Agua"
  description:
    en: "Water too deep to stand in. Build a bridge over it or walk around."
    pt_BR: "Água funda demais para ficar em pé. Faça uma ponte por cima ou dê a volta."
    es: "Agua demasiado honda para estar de pie. Haz un puente encima o da la vuelta."

GroundEmptyData:
  is_passable: false
  is_water: true

GroundBuildableData:
  z_index_offset: 0
  use_tilemap_layer: false
  target_layer_name: ""
  tile_source_id: 0
  tile_atlas_coords: [0, 0]
  terrain_set: -1
  terrain: -1
  use_biome_terrain: false
  is_dense_terrain: false
  blocks_props: true
  allows_resource_spawning: false
  speed_modifier: 1.0
  farm_prop_id: ""
  farm_tools: []
  floats_on_water: false

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: true
  collision_shape_type: QUADRILATERAL
  collision_padding: [0, 0, 0, 0]
  has_collision: false
  allows_actor_overlap: true
  is_projectile_passable: true
  occlusion_y_offset: 0.0
  occlusion_target: ALL
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 22.0
  thermal_tolerance: 9999.0
  base_max_health: 9999.0
  base_max_mana: 0.0
  base_max_energy: 0.0
  allowed_tools: [FISHING_ROD]
  minigame_reward_ids:
    - t1_item_craftable_coin_copper
    - t1_item_craftable_planks_palm
    - t1_item_craftable_leather_boar
  inventory_size: 0
  health_bar_width: 0.0
  health_bar_height: 0.0
  bar_offset_y: 0.0
  hide_bar_when_full: true
  health_bar_always_visible: false
  energy_bar_width: 0.0
  energy_bar_height: 0.0
  energy_bar_vertical_spacing: 0.0
  energy_bar_always_visible: false
  mana_bar_width: 0.0
  mana_bar_height: 0.0
  mana_bar_always_visible: false
  has_label_component: false
  is_label_editable: false
  default_label_text: ""
  sprite_variants: 0
  sound_receive_damage: ""
  sound_die: ""
  xp_reward: 0

IVisualObjectData:
  spritesheet: ""
  frame_size: [1, 1]
  position_offset: [0, 0]
  sprite_anchor: BOTTOM_LEFT
  animation_speed: 0.0
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

drops: []
---
