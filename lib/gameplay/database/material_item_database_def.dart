import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_quality.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item_icon_data.dart';

final class MaterialItemDatabaseDef {
  static const Map<HandItemId, MaterialItem> materialItemList = {
    // HandItemId.wood: MaterialItem(
    //   id: HandItemId.wood,
    //   name: 'Wood',
    //   description: 'Basic crafting material from trees',
    //   quality: HandItemQuality.normal,
    //   baseValue: 5,
    //   maxStackSize: 999,
    //   materialType: 'wood',
    // ),
    // HandItemId.stone: MaterialItem(
    //   id: HandItemId.stone,
    //   name: 'Stone',
    //   description: 'Common building material',
    //   quality: HandItemQuality.normal,
    //   baseValue: 3,
    //   maxStackSize: 999,
    //   materialType: 'stone',
    // ),
    // HandItemId.iron_ore: MaterialItem(
    //   id: HandItemId.iron_ore,
    //   name: 'Iron Ore',
    //   description: 'Raw iron ore for smelting',
    //   quality: HandItemQuality.silver,
    //   baseValue: 15,
    //   maxStackSize: 999,
    //   materialType: 'ore',
    // ),
    // HandItemId.gold_ore: MaterialItem(
    //   id: HandItemId.gold_ore,
    //   name: 'Gold Ore',
    //   description: 'Precious gold ore',
    //   quality: HandItemQuality.gold,
    //   baseValue: 50,
    //   maxStackSize: 999,
    //   materialType: 'ore',
    // ),
    // HandItemId.fiber: MaterialItem(
    //   id: HandItemId.fiber,
    //   name: 'Fiber',
    //   description: 'Plant fiber for crafting',
    //   quality: HandItemQuality.normal,
    //   baseValue: 2,
    //   maxStackSize: 999,
    //   materialType: 'fiber',
    // ),
    HandItemId.dungeon_key: MaterialItem(
      id: HandItemId.dungeon_key,
      name: 'Dungeon Key',
      description: 'Opens locked dungeon doors. Consumed on use.',
      quality: HandItemQuality.normal,
      baseValue: 0,
      maxStackSize: 99,
      materialType: 'key',
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 6,
        spriteColumnIndex: 6,
      ),
    ),
    // HandItemId.wheat_item: MaterialItem(
    //   id: HandItemId.wheat_item,
    //   name: 'Wheat',
    //   description: 'Golden wheat grain. Can be milled into flour.',
    //   quality: HandItemQuality.normal,
    //   baseValue: 8,
    //   maxStackSize: 99,
    //   materialType: 'crop',
    // ),
  };
}
