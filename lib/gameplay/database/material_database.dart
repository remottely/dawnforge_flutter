import 'package:darkness_dungeon/gameplay/inventory/models/item_rarity.dart';

class MaterialData {
  final String id;
  final String name;
  final String description;
  final ItemRarity rarity;
  final int baseValue;
  final String iconPath;
  final int maxStackSize;
  final String materialType;

  const MaterialData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.baseValue,
    required this.iconPath,
    required this.maxStackSize,
    required this.materialType,
  });
}

final class MaterialDatabaseDef {
  static const Map<String, MaterialData> materials = {
    'wood': MaterialData(
      id: 'wood',
      name: 'Wood',
      description: 'Basic crafting material from trees',
      rarity: ItemRarity.common,
      baseValue: 5,
      iconPath: 'assets/images/items/wood.png',
      maxStackSize: 999,
      materialType: 'wood',
    ),
    'stone': MaterialData(
      id: 'stone',
      name: 'Stone',
      description: 'Common building material',
      rarity: ItemRarity.common,
      baseValue: 3,
      iconPath: 'assets/images/items/stone.png',
      maxStackSize: 999,
      materialType: 'stone',
    ),
    'iron_ore': MaterialData(
      id: 'iron_ore',
      name: 'Iron Ore',
      description: 'Raw iron ore for smelting',
      rarity: ItemRarity.uncommon,
      baseValue: 15,
      iconPath: 'assets/images/items/iron_ore.png',
      maxStackSize: 999,
      materialType: 'ore',
    ),
    'gold_ore': MaterialData(
      id: 'gold_ore',
      name: 'Gold Ore',
      description: 'Precious gold ore',
      rarity: ItemRarity.rare,
      baseValue: 50,
      iconPath: 'assets/images/items/gold_ore.png',
      maxStackSize: 999,
      materialType: 'ore',
    ),
    'fiber': MaterialData(
      id: 'fiber',
      name: 'Fiber',
      description: 'Plant fiber for crafting',
      rarity: ItemRarity.common,
      baseValue: 2,
      iconPath: 'assets/images/items/fiber.png',
      maxStackSize: 999,
      materialType: 'fiber',
    ),
    'dungeon_key': MaterialData(
      id: 'dungeon_key',
      name: 'Dungeon Key',
      description: 'Opens locked dungeon doors. Consumed on use.',
      rarity: ItemRarity.common,
      baseValue: 0,
      iconPath: '',
      maxStackSize: 99,
      materialType: 'key',
    ),
    'wheat_item': MaterialData(
      id: 'wheat_item',
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
