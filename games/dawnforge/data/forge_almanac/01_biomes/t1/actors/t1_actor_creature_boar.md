---
type: actor_creature_data
id: t1_actor_creature_boar
display_name_key: forge_almanac.01_biomes.t1.actors.t1_actor_creature_boar.display_name
description_key: forge_almanac.01_biomes.t1.actors.t1_actor_creature_boar.description
biome_spawn_weight: 1.0
groups: [creatures]

_sprites:
  atlas_position: [0, 632]
  frames_grid: [8, 8]

translations:
  display_name:
    en: "Boar"
    pt_BR: "Javali"
    es: "Jabalí"
  description:
    en: "A bristly pig that roots around the forest floor. It leaves you alone until you hit it — then it comes at you tusks first."
    pt_BR: "Um porco cheio de cerdas que fuça o chão da floresta. Ele deixa você em paz até você bater nele — aí vem para cima de presas."
    es: "Un cerdo lleno de cerdas que hoza por el suelo del bosque. Te deja en paz hasta que lo golpeas — entonces se lanza de colmillos."

ActorCreatureData:
  herd_radius: 16.0
  max_herd_size: 8

IActorBiologicalData:
  gift_items: [t1_item_hay_wild]

IActorData:
  held_item_id: t1_item_tool_melee_boar
  equipped_head_id: ""
  equipped_vest_id: ""
  equipped_legs_id: ""
  equipped_feet_id: ""
  cosmetic_head_id: ""
  cosmetic_hair_id: ""
  cosmetic_vest_id: ""
  cosmetic_accessories_id: ""
  cosmetic_legs_id: ""
  cosmetic_shoes_id: ""
  base_action_speed: 0.5
  dodge_duration: 0.36
  dodge_cooldown: 1.0
  dodge_impulse: 7.5
  dodge_chance: 0.0
  dodge_roll_enabled: false
  move_speed: 1.5
  void_move_speed_multiplier: 1
  acceleration: 10.4375
  friction: 15.625
  is_void_mode: false
  ai_behavior: NEUTRAL
  ai_combat_style: MELEE_PRIMARY
  wander_interval_min: 2.0
  wander_interval_max: 5.0
  wander_radius: 8.0
  follow_range: 8.0
  attack_stop_range: 0.5
  enemy_actor_ids: [actor_player]
  force_flight_in_battle: false
  spawn_sex_random: true
  spawn_as_mature: false
  maturation_days: 28
  mating_maturity_days: 28
  gestation_days: 28
  squad_cohesion_range: 4.0
  squad_dispersion_range: 8.0
  mating_range: 16.0
  mating_stop_range: 1.5
  juvenile_fly_idle_frames: 0
  juvenile_fly_walk_frames: 0
  juvenile_fly_backward_frames: 0
  juvenile_take_off_frames: 0
  juvenile_landing_frames: 0
  fly_idle_frames: 0
  fly_walk_frames: 0
  fly_backward_frames: 0
  take_off_frames: 0
  landing_frames: 0
  void_juvenile_fly_idle_frames: 0
  void_juvenile_fly_walk_frames: 0
  void_juvenile_fly_backward_frames: 0
  void_juvenile_take_off_frames: 0
  void_juvenile_landing_frames: 0
  void_fly_idle_frames: 0
  void_fly_walk_frames: 0
  void_fly_backward_frames: 0
  void_take_off_frames: 0
  void_landing_frames: 0
  locomotion_mode: GROUND
  initial_state_key: state_ai_wander
  sound_footstep:
    default: ["res://data/audio/sfx/footstep/forest/Grass Run 1_1.wav"]
    forest: ["res://data/audio/sfx/footstep/forest/Grass Run 1_1.wav", "res://data/audio/sfx/footstep/forest/Grass Run 1_2.wav", "res://data/audio/sfx/footstep/forest/Grass Run 1_3.wav", "res://data/audio/sfx/footstep/forest/Grass Run 1_5.wav"]
    swamp: ["res://data/audio/sfx/footstep/swamp/Water Run 1_1.wav", "res://data/audio/sfx/footstep/swamp/Water Run 1_2.wav", "res://data/audio/sfx/footstep/swamp/Water Run 1_3.wav", "res://data/audio/sfx/footstep/swamp/Water Run 1_4.wav"]
    desert: ["res://data/audio/sfx/footstep/desert/Sand Run 1_1.wav", "res://data/audio/sfx/footstep/desert/Sand Run 1_2.wav", "res://data/audio/sfx/footstep/desert/Sand Run 1_4.wav", "res://data/audio/sfx/footstep/desert/Sand Run 1_5.wav"]
    snow: ["res://data/audio/sfx/footstep/snow/Snow Run 1_3.wav", "res://data/audio/sfx/footstep/snow/Snow Run 1_9.wav", "res://data/audio/sfx/footstep/snow/Snow Run 1_11.wav", "res://data/audio/sfx/footstep/snow/Snow Run 1_12.wav"]
    lava: ["res://data/audio/sfx/footstep/lava/Dirt Walk 1-2.wav", "res://data/audio/sfx/footstep/lava/Dirt Walk 1-5.wav", "res://data/audio/sfx/footstep/lava/Dirt Walk 1-6.wav", "res://data/audio/sfx/footstep/lava/Dirt Walk 1-10.wav"]
  footstep_interval: 0.4

IWorldObjectData:
  grid_size: [1, 1]
  is_flat: false
  collision_shape_type: CIRCLE
  collision_padding: [5, 9, 5, 0]
  has_collision: true
  allows_actor_overlap: true
  is_projectile_passable: false
  occlusion_y_offset: 0.0
  occlusion_target: NONE
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 37.0
  thermal_tolerance: 30.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  allowed_tools: [INNATE, SWORD, BOW, STAFF]
  inventory_size: 0
  health_bar_width: 1.5
  health_bar_height: 0.1875
  bar_offset_y: 12.0
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
  sound_receive_damage: "res://data/audio/sfx/hit/Stab 3-1.wav"
  sound_die: "res://data/audio/sfx/destroy/Blood & Gore 1-2.wav"
  xp_reward: 5

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/01_biomes/t1/actors/sprites/t1_actor_creature_boar.png"
  frame_size: [2, 1]
  position_offset: [0, 0]
  sprite_anchor: BOTTOM_LEFT
  animation_speed: 0.15
  juvenile_idle_frames: 8
  juvenile_walk_frames: 4
  juvenile_backward_frames: 0
  idle_frames: 8
  walk_frames: 3
  backward_frames: 0
  void_juvenile_idle_frames: 8
  void_juvenile_walk_frames: 4
  void_juvenile_backward_frames: 0
  void_idle_frames: 8
  void_walk_frames: 3
  void_backward_frames: 0
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

states:
  - key: state_ai_wander
    properties: {'thermal_avoidance_enabled': True}
  - key: state_stun
  - key: state_ai_follow
  - key: state_ai_attack
  - key: state_ai_cooperative_harvest
  - key: state_ai_mating
  - key: state_ai_graze
  - key: state_ai_flee

drops:
  - item_id: t1_item_hide_boar
    chance: 0.25
    min_amount: 1
    max_amount: 1

starting_inventory: []
---