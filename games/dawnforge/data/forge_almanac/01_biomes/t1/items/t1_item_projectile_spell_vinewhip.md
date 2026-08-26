---
type: item_projectile_data
id: t1_item_projectile_spell_vinewhip
display_name_key: forge_almanac.01_biomes.t1.items.t1_item_projectile_spell_vinewhip.display_name
description_key: forge_almanac.01_biomes.t1.items.t1_item_projectile_spell_vinewhip.description

translations:
  display_name:
    en: "Vine Whip"
    pt_BR: "Chicote de Cipó"
    es: "Látigo de Enredadera"
  description:
    en: "A lash of living vine, thrown from a staff.\n\nDamage: 1\nUsed with: Vine Staff"
    pt_BR: "Uma chicotada de cipó vivo, lançada por um cajado.\n\nDano: 1\nUsado com: Cajado de Cipó"
    es: "Un latigazo de enredadera viva, lanzado desde un bastón.\n\nDaño: 1\nSe usa con: Bastón de Enredadera"

ItemProjectileData:
  collision_shape_type: CIRCLE
  collision_padding: [8, 4, 0, 4]
  speed: 6.0
  max_range: 12.5
  damage: 1.0
  knockback: 3.0
  is_flying: false
  can_hit_flying: true
  pass_through_passable_objects: true
  sound_hit: ""

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
  sprite_scale: 1.0
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
  spritesheet: "res://data/forge_almanac/01_biomes/t1/items/sprites/t1_item_projectile_spell_vinewhip.png"
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