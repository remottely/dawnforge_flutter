---
type: prop_crop_data
id: t1_prop_crop_plant_vine
display_name_key: forge_almanac.01_biomes.t1.props.t1_prop_crop_plant_vine.display_name
description_key: forge_almanac.01_biomes.t1.props.t1_prop_crop_plant_vine.description
biome_spawn_weight: 0.15

_sprites:
  atlas_position: [0, 174]
  frames_grid: [1, 3]

translations:
  display_name:
    en: "Vine Plant"
    pt_BR: "Planta de Cipó"
    es: "Planta de Enredadera"
  description:
    en: "A vine plant growing wild. Cut it with a sickle for its fiber."
    pt_BR: "Uma planta de cipó crescendo solta. Corte com a foice para pegar a fibra."
    es: "Una planta de enredadera creciendo suelta. Córtala con la hoz para sacar la fibra."

PropCropData:
  ground_stage: PLANTED
  has_ground_stage: true
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
  idle_sway_amplitude: 1.5
  idle_sway_speed: 2.0
  sway_on_contact: false
  is_pushable: false
  weight: 0.0
  heat_radius: 0.0
  respawn_time: 10.0
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
  thermal_tolerance: 230.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  interaction_range: 0.5
  interaction_prompt: "Harvest [E]"
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
  spritesheet: "res://data/forge_almanac/01_biomes/t1/props/sprites/t1_prop_crop_plant_vine.png"
  frame_size: [1, 1]
  position_offset: [0, 0]
  sprite_anchor: BOTTOM_LEFT
  animation_speed: 0.15
  glow_type: NONE
  glow_color: [0.0, 0.0, 0.0, 0.0]
  glow_radius: 0.0
  glow_speed: 0.0
  glow_origin_offset: 0.0
  casts_shadow: false
  shadow_origin_offset: -0.0625
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

drops:
  - item_id: t1_item_fiber_vine
    chance: 1.0
    min_amount: 1
    max_amount: 1
---