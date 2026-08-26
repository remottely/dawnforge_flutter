---
type: item_consumable_data
id: t1_item_consumable_fruit_apple
display_name_key: forge_almanac.03_farm.t1.t1_item_consumable_fruit_apple.display_name
description_key: forge_almanac.03_farm.t1.t1_item_consumable_fruit_apple.description

_sprites:
  atlas_position: [0, 2]
  frames_grid: [1, 1]

translations:
  display_name:
    en: "Apple"
    pt_BR: "Maçã"
    es: "Manzana"
  description:
    en: "A red apple picked straight off the tree, still cold from the shade.\n\nWhen you use it:\n- Health: +1\n- Energy: +5"
    pt_BR: "Uma maçã vermelha colhida direto do pé, ainda fria da sombra.\n\nAo usar:\n- Vida: +1\n- Energia: +5"
    es: "Una manzana roja recogida del árbol, todavía fría de la sombra.\n\nAl usarlo:\n- Vida: +1\n- Energía: +5"

ItemConsumableData:
  health_restoration: 1.0
  energy_restoration: 5.0

ItemCraftableData:
  crafted_at: NONE
  craft_time: 1.0
  craft_amount: 1

ItemData:
  material_type: FABRIC
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
  sell_value: 1
  magnet_speed: 12.5
  pickup_delay: 0.5
  lifetime: 300.0
  sound_swing: ""
  sound_primary_action: ""
  sound_equip: ""
  sound_pickup: ""

IVisualObjectData:
  spritesheet: "res://data/forge_almanac/03_farm/t1/sprites/t1_item_consumable_fruit_apple.png"
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
---