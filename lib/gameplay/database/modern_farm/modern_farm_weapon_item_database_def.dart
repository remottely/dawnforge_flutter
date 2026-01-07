import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_quality.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/data/item_icon_data.dart';

final class ModernFarmWeaponItemDatabaseDef {
  ModernFarmWeaponItemDatabaseDef._();

  static const Map<HandItemId, WeaponItem> weaponsItemList = {
    HandItemId.staff: WeaponItem(
      id: HandItemId.staff,
      name: 'Staff',
      description: 'TODO',
      quality: HandItemQuality.normal,
      baseValue: 100,
      damage: 15,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 6,
        spriteColumnIndex: 7,
      ),
    ),
    HandItemId.ironSword: WeaponItem(
      id: HandItemId.ironSword,
      name: 'Iron Sword',
      description: 'A sturdy iron sword for basic combat',
      quality: HandItemQuality.normal,
      baseValue: 100,
      damage: 15,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 6,
        spriteColumnIndex: 2,
      ),
    ),
    // HandItemId.sword: WeaponItem(
    //   id: HandItemId.sword,
    //   name: 'Legendary Blade',
    //   description: 'A mythical sword forged by ancient smiths',
    //   quality: HandItemQuality.iridium,
    //   baseValue: 5000,
    //   damage: 80,
    // ),
    // HandItemId.staff_fire: WeaponItem(
    //   id: HandItemId.staff_fire,
    //   name: 'Fire Staff',
    //   description: 'A magical staff that shoots fireballs',
    //   quality: HandItemQuality.gold,
    //   baseValue: 350,
    //   damage: 20,
    // ),
    // HandItemId.wand: WeaponItem(
    //   id: HandItemId.wand,
    //   name: 'Ice Wand',
    //   description: 'A magical wand that shoots ice projectiles',
    //   quality: HandItemQuality.silver,
    //   baseValue: 200,
    //   damage: 12,
    // ),
  };

  /// Enum-keyed view mirroring weaponsByHandType for consumers expecting a mutable map.
  static final Map<HandItemId, WeaponItem> weapons = {
    for (final entry in weaponsItemList.entries) entry.key: entry.value,
  };
}
