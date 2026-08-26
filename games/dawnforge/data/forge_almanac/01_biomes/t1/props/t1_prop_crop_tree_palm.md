---
type: prop_crop_data
id: t1_prop_crop_tree_palm
display_name_key: forge_almanac.01_biomes.t1.props.t1_prop_crop_tree_palm.display_name
description_key: forge_almanac.01_biomes.t1.props.t1_prop_crop_tree_palm.description
biome_spawn_weight: 0.5

_sprites:
  atlas_position: [0, 186]
  frames_grid: [1, 6]

translations:
  display_name:
    en: "Palm Tree"
    pt_BR: "Árvore de Palmeira"
    es: "Árbol de Palma"
  description:
    en: "A grown palm tree. Chop it with an axe and the logs fall."
    pt_BR: "Uma árvore de palmeira já crescida. Corte com o machado e os troncos caem."
    es: "Un árbol de palma ya crecido. Córtalo con el hacha y caen los troncos."

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
  hides_actors_at_stage: 2

PropSoilData:
  use_tilemap_layer: true
  target_layer_name: SoilLayer
  tile_source_id: 0
  tile_atlas_coords: [0, 0]
  terrain_set: 0
  terrain: 0

PropData:
  has_idle_sway: false
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
  collision_padding: [4, 6, 4, 6]
  has_collision: true
  allows_actor_overlap: true
  is_projectile_passable: false
  occlusion_y_offset: -0.25
  occlusion_target: ACTOR
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 22.0
  thermal_tolerance: 208.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  interaction_range: 0.5
  interaction_prompt: "Harvest [E]"
  allowed_tools: [INNATE, AXE]
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
  sound_receive_damage: "res://data/audio/sfx/hit/Wood 04.wav"
  sound_die: "res://data/audio/sfx/destroy/Tree Falling 1-1.wav"
  xp_reward: 1
  tier_placement_rule: SAME_TIER

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/01_biomes/t1/props/sprites/t1_prop_crop_tree_palm.png"
  frame_size: [2, 3]
  position_offset: [0, 0.25]
  sprite_anchor: BOTTOM_CENTER
  animation_speed: 0.15
  glow_type: NONE
  glow_color: [0.0, 0.0, 0.0, 0.0]
  glow_radius: 0.0
  glow_speed: 0.0
  glow_origin_offset: 0.0
  casts_shadow: true
  shadow_origin_offset: -0.5
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

stage_occlusion_configs:
  PLANTED:
    area_size: [0.875, 0.75]
    y_offset: -0.375
    override_target: ACTOR
    balloon_y_offset: 0.0
  SPROUT:
    area_size: [0.875, 1]
    y_offset: -0.375
    override_target: ACTOR
    balloon_y_offset: 0.25
  BUDDING:
    area_size: [0.5, 2.5]
    y_offset: -0.375
    override_target: ACTOR
    balloon_y_offset: 0.5
stage_drop_configs:
  PLANTED:
    - item_id: t1_item_buildable_seed_tree_palm
      chance: 0.25
      min_amount: 1
      max_amount: 1
  SPROUT:
    - item_id: t1_item_buildable_seed_tree_palm
      chance: 0.5
      min_amount: 1
      max_amount: 1
  BUDDING:
    - item_id: t1_item_buildable_seed_tree_palm
      chance: 0.5
      min_amount: 1
      max_amount: 1
    - item_id: t1_item_logs_palm
      chance: 1.0
      min_amount: 1
      max_amount: 1
---