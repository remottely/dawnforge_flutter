---
type: prop_crop_data
id: t1_prop_crop_vegetable_wheat
display_name_key: forge_almanac.03_farm.t1.t1_prop_crop_vegetable_wheat.display_name
description_key: forge_almanac.03_farm.t1.t1_prop_crop_vegetable_wheat.description

_sprites:
  atlas_position: [0, 118]
  frames_grid: [1, 6]

translations:
  display_name:
    en: "Wheat Crop"
    pt_BR: "Plantação de Trigo"
    es: "Cultivo de Trigo"
  description:
    en: "Wheat growing in tilled soil. Water it, wait, then cut it with a sickle — and plant it again after."
    pt_BR: "Trigo crescendo em terra arada. Regue, espere e corte com a foice — e plante de novo depois."
    es: "Trigo creciendo en tierra arada. Riégalo, espera y córtalo con la hoz — y vuelve a plantarlo después."

PropCropData:
  ground_stage: PLANTED
  has_ground_stage: true
  is_waterable: true
  peak_stage: HARVESTABLE
  is_immortal: false
  days_to_die_if_unharvested: 3
  is_hand_harvestable: true
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
  has_idle_sway: true
  idle_sway_amplitude: 1.0
  idle_sway_speed: 1.0
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
  occlusion_y_offset: 0.0
  occlusion_target: NONE
  occlusion_padding: [4, 8, 4, 7]
  base_temperature: 22.0
  thermal_tolerance: 80.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  interaction_range: 0.5
  interaction_prompt: "Harvest [E]"
  allowed_tools: [SICKLE]
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
  spritesheet: "res://data/forge_almanac/03_farm/t1/sprites/t1_prop_crop_vegetable_wheat.png"
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
  shadow_origin_offset: -0.375
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

stage_occlusion_configs:
  PLANTED:
    area_size: [1, 1]
    y_offset: -0.25
    override_target: NONE
    sway_on_contact: false
    balloon_y_offset: 0.0
  SPROUT:
    area_size: [1, 1]
    y_offset: -0.25
    override_target: ACTOR
    sway_on_contact: false
    balloon_y_offset: 0.25
  BUDDING:
    area_size: [1, 1]
    y_offset: -0.25
    override_target: NONE
    sway_on_contact: true
    balloon_y_offset: 0.5
  FLOWERING:
    area_size: [1, 1]
    y_offset: -0.25
    override_target: NONE
    sway_on_contact: true
    balloon_y_offset: 0.75
  HARVESTABLE:
    area_size: [1, 1]
    y_offset: -0.25
    override_target: NONE
    sway_on_contact: true
    balloon_y_offset: 1.0
  DEAD:
    area_size: [1, 1]
    y_offset: -0.25
    override_target: NONE
    sway_on_contact: true
    balloon_y_offset: 0.0
stage_drop_configs:
  HARVESTABLE:
    - item_id: t1_item_buildable_seed_vegetable_wheat
      chance: 0.25
      min_amount: 1
      max_amount: 1
    - item_id: t1_item_consumable_vegetable_wheat
      chance: 1.0
      min_amount: 2
      max_amount: 3
---