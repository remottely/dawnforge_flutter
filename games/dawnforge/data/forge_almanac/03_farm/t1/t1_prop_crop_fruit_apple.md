---
type: prop_crop_data
id: t1_prop_crop_fruit_apple
display_name_key: forge_almanac.03_farm.t1.t1_prop_crop_fruit_apple.display_name
description_key: forge_almanac.03_farm.t1.t1_prop_crop_fruit_apple.description

_sprites:
  atlas_position: [0, 30]
  frames_grid: [1, 6]

translations:
  display_name:
    en: "Apple Tree"
    pt_BR: "Árvore de Maçã"
    es: "Árbol de Manzana"
  description:
    en: "A tree heavy with apple. Knock the fruit down with an axe — more grows back on its own."
    pt_BR: "Uma árvore carregada de maçã. Derrube a fruta com o machado — nasce mais sozinha."
    es: "Un árbol cargado de manzana. Tumba la fruta con el hacha — vuelve a crecer sola."

PropCropData:
  ground_stage: PLANTED
  has_ground_stage: false
  is_waterable: false
  peak_stage: HARVESTABLE
  is_immortal: false
  days_to_die_if_unharvested: 3
  is_hand_harvestable: true
  is_recurrent: true
  recurrent_return_stage: 2
  variants_per_stage: 1
  hides_actors_at_stage: 2

PropSoilData:
  use_tilemap_layer: true
  target_layer_name: SoilLayer
  tile_source_id: 0
  tile_atlas_coords: [0, 0]
  terrain_set: 0
  terrain: 0

PropData:
  has_idle_sway: true
  idle_sway_amplitude: 1.0
  idle_sway_speed: 1.0
  sway_on_contact: false
  is_pushable: false
  weight: 0.0
  heat_radius: 0.0
  respawn_time: 0.0
  wall_face_placement: FORBIDDEN
  hides_actors: false

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: false
  collision_shape_type: CIRCLE
  collision_padding: [6, 6, 6, 6]
  has_collision: true
  allows_actor_overlap: true
  is_projectile_passable: true
  occlusion_y_offset: 0.0
  occlusion_target: ACTOR
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 22.0
  thermal_tolerance: 80.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  interaction_range: 2.0
  interaction_prompt: "Harvest [E]"
  allowed_tools: [AXE]
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
  sound_receive_damage: "res://data/audio/sfx/hit/Rock Small Debris 3-03.wav"
  sound_die: "res://data/audio/sfx/destroy/Rock Small Debris 3-01.wav"
  xp_reward: 5
  tier_placement_rule: SAME_TIER

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/03_farm/t1/sprites/t1_prop_crop_fruit_apple.png"
  frame_size: [1, 2]
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

stage_drop_configs:
  HARVESTABLE:
    - item_id: t1_item_buildable_seed_fruit_apple
      chance: 0.25
      min_amount: 1
      max_amount: 1
    - item_id: t1_item_consumable_fruit_apple
      chance: 1.0
      min_amount: 2
      max_amount: 3

drops:
  - item_id: t1_item_logs_palm
    chance: 1.0
    min_amount: 1
    max_amount: 1
---