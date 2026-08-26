---
type: prop_soil_data
id: t1_prop_soil
display_name_key: forge_almanac.03_farm.t1.t1_prop_soil.display_name
description_key: forge_almanac.03_farm.t1.t1_prop_soil.description

translations:
  display_name:
    en: "Soil"
    pt_BR: "Terra Arada"
    es: "Tierra Arada"
  description:
    en: "Ground turned over with a hoe and ready for seeds. Water it and things grow faster."
    pt_BR: "Terra revirada com a enxada e pronta para semente. Regue e as coisas crescem mais rápido."
    es: "Tierra removida con la azada y lista para semillas. Riégala y las cosas crecen más rápido."

PropSoilData:
  use_tilemap_layer: true
  target_layer_name: SoilLayer
  tile_source_id: 0
  tile_atlas_coords: [0, 0]
  terrain_set: 0
  terrain: 0

PropData:
  has_idle_sway: false
  idle_sway_amplitude: 1.5
  idle_sway_speed: 0.5
  is_pushable: false
  weight: 0.0
  heat_radius: 0.0
  respawn_time: 0.0
  wall_face_placement: FORBIDDEN
  hides_actors: false

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: true
  collision_shape_type: QUADRILATERAL
  collision_padding: [0, 0, 0, 0]
  has_collision: false
  allows_actor_overlap: true
  is_projectile_passable: true
  occlusion_y_offset: 0.0
  occlusion_target: NONE
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 22.0
  thermal_tolerance: 500.0
  base_max_health: 1.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  interaction_range: 0.0
  interaction_prompt: ""
  allowed_tools: [PICKAXE]
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
  has_label_component: true
  is_label_editable: true
  default_label_text: ""
  sprite_variants: 0
  sound_receive_damage: ""
  sound_die: ""
  xp_reward: 5
  tier_placement_rule: SAME_TIER

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/03_farm/t1/sprites/t1_prop_soil.png"
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
---