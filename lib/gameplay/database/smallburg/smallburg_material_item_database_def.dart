import 'package:dawnforge/gameplay/database/smallburg/smallburg_database_def.dart';
import 'package:dawnforge/gameplay/inventory/items/material_item.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/material_type.dart';
import 'package:dawnforge/gameplay/inventory/entities/data/item_icon_data.dart';

final class SmallBurgMaterialItemDatabaseDef {
  static const Map<HandItemId, MaterialItem> materialItemList = {
    // HandItemId.wood: MaterialItem(
    //   id: HandItemId.wood,
    //   name: 'Wood',
    //   description: 'Basic crafting material from trees',
    //   quality: HandItemQuality.normal,
    //   baseValue: 5,
    //   materialType: MaterialType.wood,
    // ),
    // HandItemId.stone: MaterialItem(
    //   id: HandItemId.stone,
    //   name: 'Stone',
    //   description: 'Common building material',
    //   quality: HandItemQuality.normal,
    //   baseValue: 3,
    //   materialType: MaterialType.stone,
    // ),
    // HandItemId.iron_ore: MaterialItem(
    //   id: HandItemId.iron_ore,
    //   name: 'Iron Ore',
    //   description: 'Raw iron ore for smelting',
    //   quality: HandItemQuality.silver,
    //   baseValue: 15,
    //   materialType: MaterialType.ore,
    // ),
    // HandItemId.gold_ore: MaterialItem(
    //   id: HandItemId.gold_ore,
    //   name: 'Gold Ore',
    //   description: 'Precious gold ore',
    //   quality: HandItemQuality.gold,
    //   baseValue: 50,
    //   materialType: MaterialType.ore,
    // ),
    // HandItemId.fiber: MaterialItem(
    //   id: HandItemId.fiber,
    //   name: 'Fiber',
    //   description: 'Plant fiber for crafting',
    //   quality: HandItemQuality.normal,
    //   baseValue: 2,
    //   materialType: MaterialType.fiber,
    // ),
    HandItemId.dungeon_key: MaterialItem(
      id: HandItemId.dungeon_key,
      name: 'Dungeon Key',
      description: 'Opens locked dungeon doors. Consumed on use.',
      quality: HandItemQuality.normal,
      baseValue: 0,
      materialType: MaterialType.key,
      iconData: ItemIconData(
        spritesheetPath: SmallburgDatabaseDef.gridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 154,
        spriteColumnIndex: 12,
      ),
    ),
    // HandItemId.wheat_item: MaterialItem(
    //   id: HandItemId.wheat_item,
    //   name: 'Wheat',
    //   description: 'Golden wheat grain. Can be milled into flour.',
    //   quality: HandItemQuality.normal,
    //   baseValue: 8,
    //   materialType: MaterialType.crop,
    // ),
  };
}
