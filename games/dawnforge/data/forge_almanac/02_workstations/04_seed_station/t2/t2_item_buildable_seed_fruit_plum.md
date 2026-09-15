---
type: item_buildable_data
id: t2_item_buildable_seed_fruit_plum
display_name_key: forge_almanac.02_workstations.04_seed_station.t2.t2_item_buildable_seed_fruit_plum.display_name
description_key: forge_almanac.02_workstations.04_seed_station.t2.t2_item_buildable_seed_fruit_plum.description

translations:
  display_name:
    en: "Plum Seeds"
    pt_BR: "Sementes de Ameixa"
    es: "Semillas de Ciruela"
  description:
    en: "Seeds of the plum plant. Put them in tilled soil and they grow.\n\nPlace it in the world to use it."
    pt_BR: "Sementes da planta de ameixa. Ponha em terra arada e elas crescem.\n\nColoque no mundo para usar."
    es: "Semillas de la planta de ciruela. Ponlas en tierra arada y crecen.\n\nSe coloca en el mundo para usarse."

ItemBuildableData:
  blueprint_id: t2_prop_crop_fruit_plum

IItemActionData:
  action_range: 1.0
  action_effect_radius: 0.0
  drop_multiplier: 1.0

ItemCraftableData:
  crafted_at: SEED_STATION
  craft_time: 10.0
  craft_amount: 1

ItemData:
  material_type: STONE
  spritesheet_icon: ""
  rotation_offset: 0.0
  pivot_offset: [0, 0]
  invert_animation: false
  sprite_scale: 0.5
  sprite_alpha: 1.0
  primary_action_animation: ""
  primary_action_frame_size: [0, 0]
  secondary_action_animation: ""
  secondary_action_frame_size: [0, 0]
  primary_motion: AUTO
  secondary_motion: AUTO
  motion_speed_scale: 1.0
  motion_reach_scale: 1.0
  primary_impact_delay: -1.0
  secondary_impact_delay: -1.0
  tactical_type: NONE
  max_stack: 100
  sell_value: 5
  magnet_speed: 12.5
  pickup_delay: 0.5
  lifetime: 300.0
  sound_swing: ""
  sound_primary_action: ""
  sound_equip: ""
  sound_pickup: ""

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/02_workstations/04_seed_station/t2/sprites/t2_item_buildable_seed_fruit_plum.png"
  frame_size: [1, 1]
  position_offset: [0, 0]
  sprite_anchor: BOTTOM_LEFT
  animation_speed: 0.15
  juvenile_idle_frames: 0
  juvenile_walk_frames: 0
  juvenile_backward_frames: 0
  idle_frames: 0
  walk_frames: 0
  backward_frames: 0
  void_juvenile_idle_frames: 0
  void_juvenile_walk_frames: 0
  void_juvenile_backward_frames: 0
  void_idle_frames: 0
  void_walk_frames: 0
  void_backward_frames: 0
  glow_type: NONE
  glow_color: [0.0, 0.0, 0.0, 0.0]
  glow_radius: 0.0
  glow_speed: 0.0
  glow_origin_offset: 0.0
  casts_shadow: true
  ground_line_offset: -0.0625
  shadow_style_dynamic: OCCLUDER_SPRITE_CAPPED
  shadow_style_celestial: SILHOUETTE
  sounds_volume: 1.0
  tier: 2

ingredients:
  - id: t2_item_consumable_fruit_plum
    amount: 1

world3d_form: ITEM_ONLY
---
