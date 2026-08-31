---
type: item_craftable_data
id: t1_item_craftable_leather_boar
display_name_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_craftable_leather_boar.display_name
description_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_craftable_leather_boar.description

translations:
  display_name:
    en: "Boar Leather"
    pt_BR: "Couro de Javali"
    es: "Cuero de Jabalí"
  description:
    en: "The hide of a boar, cleaned and softened at the smelter. An archer's gear is made of this."
    pt_BR: "A pele de javali, limpa e amaciada na fundição. O equipamento de arqueiro é feito disso."
    es: "La piel de jabalí, limpia y ablandada en la fundición. El equipo de arquero se hace con esto."

ItemCraftableData:
  crafted_at: SMELTER
  craft_time: 5.0
  craft_amount: 1

ItemData:
  material_type: LEATHER
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
  spritesheet: "res://data/forge_almanac/02_workstations/01_smelter/t1/sprites/t1_item_craftable_leather_boar.png"
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
  - id: t1_item_hide_boar
    amount: 5
  - id: t1_item_coal
    amount: 1
---
