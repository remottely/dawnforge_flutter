---
type: prop_data
id: t1_prop_rock_coal
display_name_key: forge_almanac.01_biomes.t1.props.t1_prop_rock_coal.display_name
description_key: forge_almanac.01_biomes.t1.props.t1_prop_rock_coal.description
biome_spawn_weight: 0.1

_sprites:
  atlas_position: [0, 17]
  frames_grid: [1, 3]

translations:
  display_name:
    en: "Coal Rock"
    pt_BR: "Rocha de Carvão"
    es: "Roca de Carbón"
  description:
    en: "A boulder with coal seams running through it. Break it with a pickaxe — without coal a smelter melts nothing."
    pt_BR: "Uma rocha com veias de carvão por dentro. Quebre com a picareta — sem carvão a fundição não derrete nada."
    es: "Una roca con vetas de carbón por dentro. Rómpela con el pico — sin carbón la fundición no funde nada."

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
  thermal_tolerance: 450.0
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
  default_label_text: Coal
  sprite_variants: 0
  sound_receive_damage: "res://data/audio/sfx/hit/Rock Impact 29.wav"
  sound_die: "res://data/audio/sfx/destroy/Rock Rolling 1_1.wav"
  xp_reward: 1
  tier_placement_rule: SAME_TIER

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/01_biomes/t1/props/sprites/t1_prop_rock_coal.png"
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
  - item_id: t1_item_coal
    chance: 1.0
    min_amount: 1
    max_amount: 2
---