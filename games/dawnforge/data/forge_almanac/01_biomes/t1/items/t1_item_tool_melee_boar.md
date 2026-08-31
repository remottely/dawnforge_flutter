---
type: item_tool_melee_data
id: t1_item_tool_melee_boar
display_name_key: forge_almanac.01_biomes.t1.items.t1_item_tool_melee_boar.display_name
description_key: forge_almanac.01_biomes.t1.items.t1_item_tool_melee_boar.description

translations:
  display_name:
    en: "Boar Tusks"
    pt_BR: "Presas de Javali"
    es: "Colmillos de Jabalí"
  description:
    en: "Two curved tusks a boar was born with.\n\nDamage: 1\nEnergy per use: 1"
    pt_BR: "Duas presas curvas com que o javali já nasceu.\n\nDano: 1\nEnergia por uso: 1"
    es: "Dos colmillos curvos con los que nació el jabalí.\n\nDaño: 1\nEnergía por uso: 1"

ItemToolMeleeData:
  melee_secondary_action: NONE

IItemToolData:
  tool_type: INNATE
  cost_type: ENEGY_DEFERRED
  attack_damage: 1.0
  action_cost: 1.0

IItemDurabilityData:
  max_durability: 0
  durability_cost: 0

IItemActionData:
  action_range: 1.0
  action_effect_radius: 1.0
  drop_multiplier: 1.0

ItemCraftableData:
  crafted_at: NONE
  craft_time: 1.0
  craft_amount: 1

ItemData:
  material_type: STONE
  spritesheet_icon: ""
  rotation_offset: 0.0
  pivot_offset: [-0.125, 0.125]
  invert_animation: true
  sprite_scale: 1.0
  sprite_alpha: 1.0
  primary_action_animation: ""
  primary_action_frame_size: [0, 0]
  secondary_action_animation: ""
  secondary_action_frame_size: [0, 0]
  max_stack: 2
  sell_value: 0
  magnet_speed: 12.5
  pickup_delay: 0.5
  lifetime: 300.0
  sound_swing: ""
  sound_primary_action: ""
  sound_equip: ""
  sound_pickup: ""

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/01_biomes/t1/items/sprites/t1_item_tool_melee_boar.png"
  frame_size: [1, 1]
  position_offset: [-0.5, -0.0625]
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
---