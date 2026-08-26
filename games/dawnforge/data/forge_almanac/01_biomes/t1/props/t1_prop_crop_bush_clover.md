---
type: prop_crop_data
id: t1_prop_crop_bush_clover
display_name_key: forge_almanac.01_biomes.t1.props.t1_prop_crop_bush_clover.display_name
description_key: forge_almanac.01_biomes.t1.props.t1_prop_crop_bush_clover.description
biome_spawn_weight: 0.25

_sprites:
  atlas_position: [0, 156]
  frames_grid: [1, 3]

translations:
  display_name:
    en: "Clover Bush"
    pt_BR: "Arbusto de Trevo"
    es: "Arbusto de Trébol"
  description:
    en: "A clover bush, tall and thick. Tall enough to crouch behind, too."
    pt_BR: "Um arbusto de trevo, alto e fechado. Alto o bastante para se esconder atrás."
    es: "Un arbusto de trébol, alto y tupido. Alto como para esconderse detrás."

PropCropData:
  ground_stage: PLANTED
  has_ground_stage: false
  is_waterable: false
  peak_stage: BUDDING
  is_immortal: true
  days_to_die_if_unharvested: 1
  is_hand_harvestable: false
  is_recurrent: false
  recurrent_return_stage: 0
  variants_per_stage: 1
  hides_actors_at_stage: 1

PropSoilData:
  use_tilemap_layer: true
  target_layer_name: SoilLayer
  tile_source_id: 0
  tile_atlas_coords: [0, 0]
  terrain_set: 0
  terrain: 0

PropData:
  has_idle_sway: false
  idle_sway_amplitude: 2.0
  idle_sway_speed: 0.8
  sway_on_contact: false
  is_pushable: false
  weight: 0.0
  heat_radius: 0.0
  respawn_time: 0.0
  wall_face_placement: FORBIDDEN
  hides_actors: true

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: false
  collision_shape_type: QUADRILATERAL
  collision_padding: [0, 0, 0, 0]
  has_collision: false
  allows_actor_overlap: true
  is_projectile_passable: true
  occlusion_y_offset: -0.125
  occlusion_target: NONE
  occlusion_padding: [4, 8, 4, 7]
  base_temperature: 22.0
  thermal_tolerance: 100.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  interaction_range: 0.0
  interaction_prompt: ""
  allowed_tools: [INNATE, SICKLE]
  inventory_size: 30
  health_bar_width: 1.5
  health_bar_height: 0.1875
  bar_offset_y: 0.0
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
  sound_receive_damage: "res://data/audio/sfx/hit/Foliage Foley 2-5.wav"
  sound_die: "res://data/audio/sfx/destroy/Foliage Foley 3-8.wav"
  xp_reward: 1
  tier_placement_rule: SAME_TIER

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/01_biomes/t1/props/sprites/t1_prop_crop_bush_clover.png"
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
  shadow_origin_offset: -0.1875
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

stage_occlusion_configs:
  PLANTED:
    area_size: [1, 1]
    y_offset: 0.0
    override_target: ACTOR
    sway_on_contact: false
    balloon_y_offset: 0.0
  SPROUT:
    area_size: [1, 1]
    y_offset: -0.125
    override_target: NONE
    sway_on_contact: true
    balloon_y_offset: 0.25
  BUDDING:
    area_size: [1, 1]
    y_offset: -0.125
    override_target: NONE
    sway_on_contact: true
    balloon_y_offset: 0.5
stage_drop_configs:
  PLANTED:
    - item_id: t1_item_buildable_seed_bush_clover
      chance: 0.25
      min_amount: 1
      max_amount: 1
  SPROUT:
    - item_id: t1_item_buildable_seed_bush_clover
      chance: 0.5
      min_amount: 1
      max_amount: 1
  BUDDING:
    - item_id: t1_item_buildable_seed_bush_clover
      chance: 0.5
      min_amount: 1
      max_amount: 1
    - item_id: t1_item_flower_clover
      chance: 1.0
      min_amount: 1
      max_amount: 1
---