import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_rarity.dart';

final class WeaponItemDatabaseDef {
  WeaponItemDatabaseDef._();

  static const Map<HandItemId, WeaponItem> weaponsItemList = {
    HandItemId.staff: WeaponItem(
      id: HandItemId.staff,
      name: 'Staff',
      description: 'TODO',
      rarity: HandItemRarity.common,
      baseValue: 100,
      iconPath: '',
      damage: 15,
      attackSpeed: 1.2,
      critChance: 0.05,
      critMultiplier: 1.5,
    ),
    HandItemId.ironSword: WeaponItem(
      id: HandItemId.ironSword,
      name: 'Iron Sword',
      description: 'A sturdy iron sword for basic combat',
      rarity: HandItemRarity.common,
      baseValue: 100,
      iconPath: '',
      damage: 15,
      attackSpeed: 1.2,
      critChance: 0.05,
      critMultiplier: 1.5,
    ),
    HandItemId.sword: WeaponItem(
      id: HandItemId.sword,
      name: 'Legendary Blade',
      description: 'A mythical sword forged by ancient smiths',
      rarity: HandItemRarity.legendary,
      baseValue: 5000,
      iconPath: 'assets/images/items/legendary_blade.png',
      damage: 80,
      attackSpeed: 1.5,
      critChance: 0.25,
      critMultiplier: 2.5,
    ),
    HandItemId.staff_fire: WeaponItem(
      id: HandItemId.staff_fire,
      name: 'Fire Staff',
      description: 'A magical staff that shoots fireballs',
      rarity: HandItemRarity.rare,
      baseValue: 350,
      iconPath: 'assets/images/items/fire_staff.png',
      damage: 20,
      attackSpeed: 1.0,
      critChance: 0.1,
      critMultiplier: 2.0,
    ),
    HandItemId.wand: WeaponItem(
      id: HandItemId.wand,
      name: 'Ice Wand',
      description: 'A magical wand that shoots ice projectiles',
      rarity: HandItemRarity.uncommon,
      baseValue: 200,
      iconPath: 'assets/images/items/ice_wand.png',
      damage: 12,
      attackSpeed: 1.3,
      critChance: 0.07,
      critMultiplier: 1.6,
    ),
  };

  /// Enum-keyed view mirroring weaponsByHandType for consumers expecting a mutable map.
  static final Map<HandItemId, WeaponItem> weapons = {
    for (final entry in weaponsItemList.entries) entry.key: entry.value,
  };
}
