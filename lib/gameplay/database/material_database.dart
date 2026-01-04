import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_rarity.dart';

final class MaterialDatabaseDef {
  static const Map<EquippedHandType, MaterialItem> materials = {
    EquippedHandType.wood: MaterialItem(
      id: EquippedHandType.wood,
      name: 'Wood',
      description: 'Basic crafting material from trees',
      rarity: ItemRarity.common,
      baseValue: 5,
      iconPath: 'assets/images/items/wood.png',
      maxStackSize: 999,
      materialType: 'wood',
    ),
    EquippedHandType.stone: MaterialItem(
      id: EquippedHandType.stone,
      name: 'Stone',
      description: 'Common building material',
      rarity: ItemRarity.common,
      baseValue: 3,
      iconPath: 'assets/images/items/stone.png',
      maxStackSize: 999,
      materialType: 'stone',
    ),
    EquippedHandType.iron_ore: MaterialItem(
      id: EquippedHandType.iron_ore,
      name: 'Iron Ore',
      description: 'Raw iron ore for smelting',
      rarity: ItemRarity.uncommon,
      baseValue: 15,
      iconPath: 'assets/images/items/iron_ore.png',
      maxStackSize: 999,
      materialType: 'ore',
    ),
    EquippedHandType.gold_ore: MaterialItem(
      id: EquippedHandType.gold_ore,
      name: 'Gold Ore',
      description: 'Precious gold ore',
      rarity: ItemRarity.rare,
      baseValue: 50,
      iconPath: 'assets/images/items/gold_ore.png',
      maxStackSize: 999,
      materialType: 'ore',
    ),
    EquippedHandType.fiber: MaterialItem(
      id: EquippedHandType.fiber,
      name: 'Fiber',
      description: 'Plant fiber for crafting',
      rarity: ItemRarity.common,
      baseValue: 2,
      iconPath: 'assets/images/items/fiber.png',
      maxStackSize: 999,
      materialType: 'fiber',
    ),
    EquippedHandType.dungeon_key: MaterialItem(
      id: EquippedHandType.dungeon_key,
      name: 'Dungeon Key',
      description: 'Opens locked dungeon doors. Consumed on use.',
      rarity: ItemRarity.common,
      baseValue: 0,
      iconPath: '',
      maxStackSize: 99,
      materialType: 'key',
    ),
    EquippedHandType.wheat_item: MaterialItem(
      id: EquippedHandType.wheat_item,
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
