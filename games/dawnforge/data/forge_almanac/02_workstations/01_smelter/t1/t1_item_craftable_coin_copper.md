---
type: item_craftable_data
id: t1_item_craftable_coin_copper
display_name_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_craftable_coin_copper.display_name
description_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_craftable_coin_copper.description

translations:
  display_name:
    en: "Copper Coin"
    pt_BR: "Moeda de Cobre"
    es: "Moneda de Cobre"
  description:
    en: "A small coin of copper, struck at the smelter. Traders like these."
    pt_BR: "Uma moeda pequena de cobre, batida na fundição. Os comerciantes gostam delas."
    es: "Una moneda pequeña de cobre, acuñada en la fundición. A los comerciantes les gustan."

ItemCraftableData:
  crafted_at: SMELTER
  craft_time: 5.0
  craft_amount: 1

ItemData:
  material_type: METAL
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
  max_stack: 1000
  sell_value: 0
  magnet_speed: 12.5
  pickup_delay: 0.5
  lifetime: 300.0
  sound_swing: ""
  sound_primary_action: ""
  sound_equip: ""
  sound_pickup: ""

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/02_workstations/01_smelter/t1/sprites/t1_item_craftable_coin_copper.png"
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
  - id: t1_item_craftable_bar_copper
    amount: 1
---
