import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item_type.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_rarity.dart';

final class MaterialDatabaseDef {
  static const Map<HandItemType, MaterialItem> materials = {
    HandItemType.wood: MaterialItem(
      id: HandItemType.wood,
      name: 'Wood',
      description: 'Basic crafting material from trees',
      rarity: ItemRarity.common,
      baseValue: 5,
      iconPath: 'assets/images/items/wood.png',
      maxStackSize: 999,
      materialType: 'wood',
    ),
    HandItemType.stone: MaterialItem(
      id: HandItemType.stone,
      name: 'Stone',
      description: 'Common building material',
      rarity: ItemRarity.common,
      baseValue: 3,
      iconPath: 'assets/images/items/stone.png',
      maxStackSize: 999,
      materialType: 'stone',
    ),
    HandItemType.iron_ore: MaterialItem(
      id: HandItemType.iron_ore,
      name: 'Iron Ore',
      description: 'Raw iron ore for smelting',
      rarity: ItemRarity.uncommon,
      baseValue: 15,
      iconPath: 'assets/images/items/iron_ore.png',
      maxStackSize: 999,
      materialType: 'ore',
    ),
    HandItemType.gold_ore: MaterialItem(
      id: HandItemType.gold_ore,
      name: 'Gold Ore',
      description: 'Precious gold ore',
      rarity: ItemRarity.rare,
      baseValue: 50,
      iconPath: 'assets/images/items/gold_ore.png',
      maxStackSize: 999,
      materialType: 'ore',
    ),
    HandItemType.fiber: MaterialItem(
      id: HandItemType.fiber,
      name: 'Fiber',
      description: 'Plant fiber for crafting',
      rarity: ItemRarity.common,
      baseValue: 2,
      iconPath: 'assets/images/items/fiber.png',
      maxStackSize: 999,
      materialType: 'fiber',
    ),
    HandItemType.dungeon_key: MaterialItem(
      id: HandItemType.dungeon_key,
      name: 'Dungeon Key',
      description: 'Opens locked dungeon doors. Consumed on use.',
      rarity: ItemRarity.common,
      baseValue: 0,
      iconPath: '',
      maxStackSize: 99,
      materialType: 'key',
    ),
    HandItemType.wheat_item: MaterialItem(
      id: HandItemType.wheat_item,
      name: 'Wheat',
      description: 'Golden wheat grain. Can be milled into flour.',
      rarity: ItemRarity.common,
      baseValue: 8,
      iconPath: 'assets/images/items/wheat.png',
      maxStackSize: 99,
      materialType: 'crop',
    ),
  };
}
