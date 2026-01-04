import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_quality.dart';

final class WeaponItemDatabaseDef {
  WeaponItemDatabaseDef._();

  static const Map<HandItemId, WeaponItem> weaponsItemList = {
    HandItemId.staff: WeaponItem(
      id: HandItemId.staff,
      name: 'Staff',
      description: 'TODO',
      quality: HandItemQuality.normal,
      baseValue: 100,
      damage: 15,
      attackSpeed: 1.2,
      critChance: 0.05,
      critMultiplier: 1.5,
    ),
    HandItemId.ironSword: WeaponItem(
      id: HandItemId.ironSword,
      name: 'Iron Sword',
      description: 'A sturdy iron sword for basic combat',
      quality: HandItemQuality.normal,
      baseValue: 100,
      damage: 15,
      attackSpeed: 1.2,
      critChance: 0.05,
      critMultiplier: 1.5,
    ),
    // HandItemId.sword: WeaponItem(
    //   id: HandItemId.sword,
    //   name: 'Legendary Blade',
    //   description: 'A mythical sword forged by ancient smiths',
    //   quality: HandItemQuality.iridium,
    //   baseValue: 5000,
    //   damage: 80,
    //   attackSpeed: 1.5,
    //   critChance: 0.25,
    //   critMultiplier: 2.5,
    // ),
    // HandItemId.staff_fire: WeaponItem(
    //   id: HandItemId.staff_fire,
    //   name: 'Fire Staff',
    //   description: 'A magical staff that shoots fireballs',
    //   quality: HandItemQuality.gold,
    //   baseValue: 350,
    //   damage: 20,
    //   attackSpeed: 1.0,
    //   critChance: 0.1,
    //   critMultiplier: 2.0,
    // ),
    // HandItemId.wand: WeaponItem(
    //   id: HandItemId.wand,
    //   name: 'Ice Wand',
    //   description: 'A magical wand that shoots ice projectiles',
    //   quality: HandItemQuality.silver,
    //   baseValue: 200,
    //   damage: 12,
    //   attackSpeed: 1.3,
    //   critChance: 0.07,
    //   critMultiplier: 1.6,
    // ),
  };

  /// Enum-keyed view mirroring weaponsByHandType for consumers expecting a mutable map.
  static final Map<HandItemId, WeaponItem> weapons = {
    for (final entry in weaponsItemList.entries) entry.key: entry.value,
  };
}
