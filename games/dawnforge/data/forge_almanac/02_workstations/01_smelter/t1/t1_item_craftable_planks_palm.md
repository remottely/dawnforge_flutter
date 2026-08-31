---
type: item_craftable_data
id: t1_item_craftable_planks_palm
display_name_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_craftable_planks_palm.display_name
description_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_craftable_planks_palm.description

translations:
  display_name:
    en: "Palm Planks"
    pt_BR: "Pranchas de Palmeira"
    es: "Tablones de Palma"
  description:
    en: "Planks of palm, cut flat at the smelter. Half of everything you build needs them."
    pt_BR: "Pranchas de palmeira, cortadas lisas na fundição. Metade do que você constrói precisa delas."
    es: "Tablones de palma, cortados lisos en la fundición. La mitad de lo que construyes los necesita."

ItemCraftableData:
  crafted_at: SMELTER
  craft_time: 5.0
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
  max_stack: 100
  sell_value: 10
  magnet_speed: 12.5
  pickup_delay: 0.5
  lifetime: 300.0
  sound_swing: ""
  sound_primary_action: ""
  sound_equip: ""
  sound_pickup: ""

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/02_workstations/01_smelter/t1/sprites/t1_item_craftable_planks_palm.png"
  frame_size: [1, 1]
  position_offset: [0, 0]
  sprite_anchor: BOTTOM_LEFT
  animation_speed: 0.15
  idle_frames: 0
  walk_frames: 0
  backward_frames: 0
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

ingredients:
  - id: t1_item_logs_palm
    amount: 5
  - id: t1_item_coal
    amount: 1
---
