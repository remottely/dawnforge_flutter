---
type: ground_empty_data
id: t1_ground_empty_cliff
display_name_key: forge_almanac.01_biomes.t1.ground.t1_ground_empty_cliff.display_name
description_key: forge_almanac.01_biomes.t1.ground.t1_ground_empty_cliff.description

translations:
  display_name:
    en: "Cliff"
    pt_BR: "Penhasco"
    es: "Acantilado"
  description:
    en: "A wall of bare rock. You cannot walk through it — go around, or cut a way in with a pickaxe."
    pt_BR: "Uma parede de pedra nua. Não dá para atravessar — contorne, ou abra um caminho com a picareta."
    es: "Una pared de roca desnuda. No se puede atravesar — rodéala, o ábrete paso con el pico."

GroundEmptyData:
  is_passable: false
  is_water: false

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
  allowed_tools: []
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
