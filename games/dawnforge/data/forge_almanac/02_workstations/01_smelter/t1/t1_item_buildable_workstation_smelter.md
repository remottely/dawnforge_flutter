---
type: item_buildable_data
id: t1_item_buildable_workstation_smelter
display_name_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_buildable_workstation_smelter.display_name
description_key: forge_almanac.02_workstations.01_smelter.t1.t1_item_buildable_workstation_smelter.description

_sprites:
  atlas_position: [0, 58]
  frames_grid: [1, 1]

translations:
  display_name:
    en: "Copper Smelter"
    pt_BR: "Fundição de Cobre"
    es: "Fundición de Cobre"
  description:
    en: "Melts rock and ore into bars, planks, cloth and coins. The copper one is where every builder starts.\n\nPlace it in the world to use it."
    pt_BR: "Derrete pedra e minério e transforma em barras, pranchas, tecido e moedas. A de cobre é onde todo construtor começa.\n\nColoque no mundo para usar."
    es: "Funde piedra y mineral y los vuelve barras, tablones, tela y monedas. La de cobre es donde empieza todo constructor.\n\nColócalo en el mundo para usarlo."

ItemBuildableData:
  blueprint_id: t1_prop_workstation_smelter

IItemActionData:
  action_range: 1.0
  action_effect_radius: 0.0
  drop_multiplier: 1.0

ItemCraftableData:
  crafted_at: NONE
  craft_time: 1.0
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
  max_stack: 1
  sell_value: 5
  magnet_speed: 12.5
  pickup_delay: 0.5
  lifetime: 300.0
  sound_swing: ""
  sound_primary_action: ""
  sound_equip: ""
  sound_pickup: ""

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/02_workstations/01_smelter/t1/sprites/t1_item_buildable_workstation_smelter.png"
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
  - id: t1_item_ore_copper
    amount: 5
  - id: t1_item_coal
    amount: 5
---