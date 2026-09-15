---
type: item_tool_melee_data
id: t1_item_tool_melee_pickaxe_copper
display_name_key: forge_almanac.02_workstations.02_workshop.t1.t1_item_tool_melee_pickaxe_copper.display_name
description_key: forge_almanac.02_workstations.02_workshop.t1.t1_item_tool_melee_pickaxe_copper.description

_sprites:
  atlas_position: [0, 96]
  frames_grid: [1, 1]

translations:
  display_name:
    en: "Copper Pickaxe"
    pt_BR: "Picareta de Cobre"
    es: "Pico de Cobre"
  description:
    en: "Copper is soft, but it is the first metal you can shape.\n\nTool: Pickaxe\nGood for: breaking rocks and ore\nDamage: 1\nEnergy per use: 1\nDurability: 100 uses"
    pt_BR: "O cobre é mole, mas é o primeiro metal que você consegue moldar.\n\nFerramenta: Picareta\nServe para: quebrar pedras e minérios\nDano: 1\nEnergia por uso: 1\nDurabilidade: 100 usos"
    es: "El cobre es blando, pero es el primer metal que puedes moldear.\n\nHerramienta: Pico\nSirve para: romper rocas y minerales\nDaño: 1\nEnergía por uso: 1\nDurabilidad: 100 usos"

ItemToolMeleeData:
  melee_secondary_action: NONE

IItemToolData:
  tool_type: PICKAXE
  cost_type: ENEGY_DEFERRED
  attack_damage: 1.0
  action_cost: 1.0

IItemDurabilityData:
  max_durability: 100
  durability_cost: 1

IItemActionData:
  action_range: 1.0
  action_effect_radius: 0.0
  drop_multiplier: 1.0

ItemCraftableData:
  crafted_at: WORKSHOP
  craft_time: 5.0
  craft_amount: 1

ItemData:
  material_type: STONE
  spritesheet_icon: ""
  rotation_offset: -90.0
  pivot_offset: [0.25, -0.25]
  invert_animation: false
  sprite_scale: 1.0
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
  spritesheet: "res://data/forge_almanac/02_workstations/02_workshop/t1/sprites/t1_item_tool_melee_pickaxe_copper.png"
  frame_size: [1, 1]
  position_offset: [-0.5, 0.125]
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
  tier: 1

ingredients:
  - id: t1_item_craftable_planks_palm
    amount: 5
  - id: t1_item_craftable_bar_copper
    amount: 1

world3d_form: ITEM_ONLY
---
