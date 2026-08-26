---
type: prop_forage_data
id: t1_prop_grass_wild
display_name_key: forge_almanac.01_biomes.t1.props.t1_prop_grass_wild.display_name
description_key: forge_almanac.01_biomes.t1.props.t1_prop_grass_wild.description
biome_spawn_weight: 1.5

_sprites:
  atlas_position: [0, 223]
  frames_grid: [1, 2]

translations:
  display_name:
    en: "Wild Grass"
    pt_BR: "Grama Selvagem"
    es: "Hierba Silvestre"
  description:
    en: "A tuft of tall forest grass. Animals graze on it when they are hurt or worn out."
    pt_BR: "Um tufo de mato alto da floresta. Os bichos pastam nele quando estão machucados ou cansados."
    es: "Un mechón de hierba alta del bosque. Los animales pastan en él cuando están heridos o cansados."

PropForageData:
  health_restoration: 3.0
  energy_restoration: 3.0
  graze_duration: 1.5

PropData:
  has_idle_sway: true
  idle_sway_amplitude: 1.5
  idle_sway_speed: 0.9
  sway_on_contact: true
  is_pushable: false
  weight: 0.0
  heat_radius: 0.0
  respawn_time: 0.0
  wall_face_placement: FORBIDDEN
  hides_actors: false

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: false
  collision_shape_type: QUADRILATERAL
  collision_padding: [0, 0, 0, 0]
  has_collision: false
  allows_actor_overlap: true
  is_projectile_passable: true
  occlusion_y_offset: -0.125
  occlusion_target: ACTOR
  occlusion_padding: [4, 8, 4, 7]
  base_temperature: 22.0
  thermal_tolerance: 100.0
  base_max_health: 1.0
  base_max_mana: 5.0
  base_max_energy: 50.0
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
  spritesheet: "res://data/forge_almanac/01_biomes/t1/props/sprites/t1_prop_grass_wild.png"
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
  shadow_origin_offset: -0.25
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

drops:
  - item_id: t1_item_hay_wild
    chance: 0.5
    min_amount: 1
    max_amount: 1
---
