import 'package:dawnforge/game/database/smallburg/smallburg_database_def.dart';
import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/game/features/inventory/items/weapon_item.dart';

final class SmallBurgWeaponItemDatabaseDef {
  SmallBurgWeaponItemDatabaseDef._();

  static const Map<HandItemId, WeaponItem> weaponsItemList = {
    HandItemId.staff: WeaponItem(
      id: HandItemId.staff,
      name: 'Staff',
      description: 'TODO',
      quality: HandItemQuality.normal,
      baseValue: 100,
      damage: 15,
      iconData: ItemIconData(
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 149,
        spriteColumnIndex: 8,
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
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 149,
        spriteColumnIndex: 3,
      ),
    ),
  };

  // /// Enum-keyed view mirroring weaponsByHandType for consumers expecting a mutable map.
  // static final Map<HandItemId, WeaponItem> weapons = {
  //   for (final entry in weaponsItemList.entries) entry.key: entry.value,
  // };
}
