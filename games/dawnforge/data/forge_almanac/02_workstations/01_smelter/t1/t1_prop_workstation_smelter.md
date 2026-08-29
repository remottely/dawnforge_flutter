---
type: prop_workstation_data
id: t1_prop_workstation_smelter
display_name_key: forge_almanac.02_workstations.01_smelter.t1.t1_prop_workstation_smelter.display_name
description_key: forge_almanac.02_workstations.01_smelter.t1.t1_prop_workstation_smelter.description

_sprites:
  atlas_position: [0, 59]
  frames_grid: [1, 1]

translations:
  display_name:
    en: "Copper Smelter"
    pt_BR: "Fundição de Cobre"
    es: "Fundición de Cobre"
  description:
    en: "Melts rock and ore into bars, planks, cloth and coins. The copper one is where every builder starts."
    pt_BR: "Derrete pedra e minério e transforma em barras, pranchas, tecido e moedas. A de cobre é onde todo construtor começa."
    es: "Funde piedra y mineral y los vuelve barras, tablones, tela y monedas. La de cobre es donde empieza todo constructor."

PropWorkstationData:
  workstation_type: SMELTER
  production_speed_multiplier: 1.0

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
  grid_size: [2, 1]
  is_flat: false
  collision_shape_type: QUADRILATERAL
  collision_padding: [0, 0, 0, 0]
  has_collision: true
  allows_actor_overlap: true
  is_projectile_passable: false
  occlusion_y_offset: -0.25
  occlusion_target: ACTOR
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 400.0
  thermal_tolerance: 600.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  interaction_range: 2.0
  interaction_prompt: "Interact [E]"
  allowed_tools: [SLEDGEHAMMER]
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
  xp_reward: 0
  tier_placement_rule: SAME_TIER_OR_BELOW

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/02_workstations/01_smelter/t1/sprites/t1_prop_workstation_smelter.png"
  frame_size: [2, 3]
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

drops:
  - item_id: t1_item_buildable_workstation_smelter
---