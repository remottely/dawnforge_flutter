---
type: actor_npc_data
id: t1_actor_npc_thornwick
display_name_key: forge_almanac.01_biomes.t1.actors.t1_actor_npc_thornwick.display_name
description_key: forge_almanac.01_biomes.t1.actors.t1_actor_npc_thornwick.description
groups: [npcs]

_sprites:
  atlas_position: [84, 1944]
  frames_grid: [6, 12]

translations:
  display_name:
    en: "Thornwick"
    pt_BR: "Thornwick"
    es: "Thornwick"
  description:
    en: "A woodcutter who lives among the forest trees. Friendly, talks a lot, and always needs a hand carrying wood."
    pt_BR: "Um lenhador que mora no meio das árvores da floresta. Simpático, fala muito, e sempre precisa de ajuda para carregar madeira."
    es: "Un leñador que vive entre los árboles del bosque. Simpático, habla mucho, y siempre necesita una mano con la madera."

ActorCreatureData:
  herd_radius: 16.0
  max_herd_size: 8

IActorBiologicalData:
  gift_items: [t1_item_logs_palm]

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
  base_action_speed: 1.0
  dodge_duration: 0.36
  dodge_cooldown: 1.0
  dodge_impulse: 7.5
  dodge_chance: 0.0
  dodge_roll_enabled: false
  move_speed: 2.5
  void_move_speed_multiplier: 1
  acceleration: 17.8125
  friction: 27.8125
  is_void_mode: false
  ai_behavior: PEACEFUL
  ai_combat_style: MELEE_PRIMARY
  wander_interval_min: 3.0
  wander_interval_max: 8.0
  wander_radius: 2.0
  follow_range: 0.0
  attack_stop_range: 0.0
  enemy_actor_ids: []
  force_flight_in_battle: false
  spawn_sex_random: true
  spawn_as_mature: true
  maturation_days: 1
  mating_maturity_days: 999
  gestation_days: 999
  squad_cohesion_range: 0.0
  squad_dispersion_range: 0.0
  mating_range: 0.0
  mating_stop_range: 0.0
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
    forest: ["res://data/audio/sfx/footstep/forest/Grass Run 1_1.wav", "res://data/audio/sfx/footstep/forest/Grass Run 1_2.wav"]
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
  base_temperature: 22.0
  thermal_tolerance: 50.0
  base_max_health: 100.0
  base_max_mana: 0.0
  base_max_energy: 100.0
  interaction_range: 3.0
  allowed_tools: []
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
  sound_receive_damage: "res://data/audio/sfx/hit/Bone 2-7.wav"
  sound_die: "res://data/audio/sfx/destroy/Bone 1-6.wav"
  xp_reward: 0

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/01_biomes/t1/actors/sprites/t1_actor_npc_thornwick.png"
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
  glow_type: NONE
  glow_color: [0.0, 0.0, 0.0, 0.0]
  glow_radius: 0.0
  glow_speed: 0.0
  glow_origin_offset: 0.0
  casts_shadow: true
  shadow_origin_offset: -0.5625
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 1

interactions:
  - behavior: START_QUEST
    condition: QUEST_AVAILABLE
    dialog_key: npc.thornwick.macro_quest_offer
    quest_id: quest_macro_t1_forest
    dialog_lines: [npc.thornwick.macro_quest_offer.page_1]
  - behavior: COMPLETE_QUEST
    condition: QUEST_COMPLETED
    dialog_key: npc.thornwick.macro_quest_done
    quest_id: quest_macro_t1_forest
    dialog_lines: [npc.thornwick.macro_quest_done.page_1]
  - behavior: START_QUEST
    condition: QUEST_AVAILABLE
    dialog_key: npc.thornwick.quest_offer
    quest_id: quest_forest_wood
    dialog_lines: [npc.thornwick.quest_offer.page_1, npc.thornwick.quest_offer.page_2]
  - behavior: DIALOG
    condition: QUEST_IN_PROGRESS
    dialog_key: npc.thornwick.quest_in_progress
    quest_id: ""
  - behavior: COMPLETE_QUEST
    condition: QUEST_COMPLETED
    dialog_key: npc.thornwick.quest_done
    quest_id: quest_forest_wood
    dialog_lines: [npc.thornwick.quest_done.page_1]
  - behavior: DIALOG
    condition: ALWAYS
    dialog_key: npc.thornwick.greeting
    quest_id: ""

states:
  - key: state_ai_wander

starting_inventory: []
---