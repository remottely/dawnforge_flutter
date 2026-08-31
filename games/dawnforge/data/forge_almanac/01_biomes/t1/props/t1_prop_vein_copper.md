---
type: prop_data
id: t1_prop_vein_copper
display_name_key: forge_almanac.01_biomes.t1.props.t1_prop_vein_copper.display_name
description_key: forge_almanac.01_biomes.t1.props.t1_prop_vein_copper.description
biome_spawn_weight: 0.2

_sprites:
  atlas_position: [0, 54]
  frames_grid: [1, 3]

translations:
  display_name:
    en: "Copper Vein"
    pt_BR: "Veio de Cobre"
    es: "Veta de Cobre"
  description:
    en: "A vein of copper running through the stone. Break it with a pickaxe and the ore is yours."
    pt_BR: "Um veio de cobre atravessando a pedra. Quebre com a picareta e o minério é seu."
    es: "Una veta de cobre cruzando la piedra. Rómpela con el pico y el mineral es tuyo."

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
  is_flat: false
  collision_shape_type: CIRCLE
  collision_padding: [4, 6, 4, 6]
  has_collision: true
  allows_actor_overlap: true
  is_projectile_passable: true
  occlusion_y_offset: -0.25
  occlusion_target: NONE
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 22.0
  thermal_tolerance: 1063.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
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
  sound_receive_damage: "res://data/audio/sfx/hit/Nail Wood 1_6.wav"
  sound_die: "res://data/audio/sfx/destroy/Rock Impact 15.wav"
  xp_reward: 1
  tier_placement_rule: SAME_TIER

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/01_biomes/t1/props/sprites/t1_prop_vein_copper.png"
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
  - item_id: t1_item_ore_copper
    chance: 1.0
    min_amount: 1
    max_amount: 1
---