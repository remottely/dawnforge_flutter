---
type: i_actor_biological_data
id: actor_player
display_name_key: player.display_name
description_key: player.description
groups: [player]

IActorBiologicalData:
  gift_items: []

IActorData:
  held_item_id: ""
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
  dodge_stamina_cost: 3.0
  dodge_chance: 0.0
  dodge_roll_enabled: false
  move_speed: 3.0
  void_move_speed_multiplier: 1
  acceleration: 18.75
  friction: 30.0
  is_void_mode: false
  ai_behavior: NEUTRAL
  ai_combat_style: MELEE_PRIMARY
  wander_interval_max: 5.0
  enemy_actor_ids: []
  force_flight_in_battle: false
  spawn_sex_random: true
  spawn_as_mature: true
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
  initial_state_key: state_input_idle
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
  occlusion_target: ALL
  occlusion_padding: [0, 0, 0, 0]
  base_temperature: 37.0
  thermal_tolerance: 30.0
  base_max_health: 5.0
  base_max_mana: 5.0
  base_max_energy: 50.0
  base_max_stamina: 10.0
  allowed_tools: [INNATE, SWORD, BOW, STAFF]
  inventory_size: 30
  health_bar_width: 1.5
  health_bar_height: 0.1875
  bar_offset_y: 8.0
  hide_bar_when_full: true
  health_bar_always_visible: true
  energy_bar_width: 24.0
  energy_bar_height: 2.0
  energy_bar_vertical_spacing: 2.0
  energy_bar_always_visible: false
  mana_bar_width: 1.5
  mana_bar_height: 0.125
  mana_bar_always_visible: false
  has_label_component: true
  is_label_editable: true
  default_label_text: "player name test"
  sprite_variants: 0
  sound_receive_damage: "res://data/audio/sfx/hit/Generic Hit 1_3.wav"
  sound_die: "res://data/audio/sfx/destroy/Generic Hit 2_5.wav"
  xp_reward: 0

IVisualObjectData:
  spritesheet: "res://data/cosmetics/03_skin/vampire/sprites/cosmetic_skin_vampire_white.png"
  frame_size: [2, 2]
  position_offset: [0, 0]
  sprite_anchor: BOTTOM_LEFT
  animation_speed: 0.15
  juvenile_idle_frames: 3
  juvenile_walk_frames: 4
  juvenile_backward_frames: 6
  idle_frames: 3
  walk_frames: 4
  backward_frames: 6
  void_juvenile_idle_frames: 3
  void_juvenile_walk_frames: 4
  void_juvenile_backward_frames: 6
  void_idle_frames: 3
  void_walk_frames: 4
  void_backward_frames: 6
  # The light the player carries: dark at noon, full at midnight. Alpha is its peak energy.
  glow_type: NIGHT_AURA
  glow_color: [1.0, 1.0, 1.0, 0.85]
  glow_radius: 2.0
  glow_speed: 1.0
  glow_origin_offset: 0.0
  casts_shadow: true
  shadow_origin_offset: -0.5625
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

states:
  - key: state_input_idle
  - key: state_input_move
  - key: state_input_dodge
translations:
  display_name:
    en: "Player"
    pt_BR: "Jogador"
    es: "Jugador"
  description:
    en: "That is you."
    pt_BR: "Esse é você."
    es: "Ese eres tú."

---

# The Player

The one authored actor that is nobody's creature: it belongs to no biome, no
tier and no workstation, which is why it sits beside the almanac rather than
inside it. Imported verbatim from the Godot pack (`games/dawnforge/data/player/`)
so the two engines describe the same person — the pack format never forks
(rule 31).

DELTA: the `translations:` block in the frontmatter is added here. In the Godot repo the
player's two strings live in `generated/locales/translations_static.csv`, which
this repo has no equivalent of for CONTENT text — an almanac document carries
its own words, and this is an almanac document in every other respect.
