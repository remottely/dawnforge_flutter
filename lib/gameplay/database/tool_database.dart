import 'package:darkness_dungeon/gameplay/inventory/models/item_rarity.dart';

class ToolData {
  final String id;
  final String name;
  final String description;
  final ItemRarity rarity;
  final int baseValue;
  final String iconPath;
  final String toolType;
  final int powerLevel;

  const ToolData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.baseValue,
    required this.iconPath,
    required this.toolType,
    required this.powerLevel,
  });
}

final class ToolDatabaseDef {
  ToolDatabaseDef._();
  static const Map<String, ToolData> tools = {
    'iron_pickaxe': ToolData(
      id: 'iron_pickaxe',
      name: 'Iron Pickaxe',
      description: 'Mine rocks and ores efficiently',
      rarity: ItemRarity.common,
      baseValue: 80,
      iconPath: 'assets/images/items/iron_pickaxe.png',
      toolType: 'pickaxe',
      powerLevel: 2,
    ),
    'steel_pickaxe': ToolData(
      id: 'steel_pickaxe',
      name: 'Steel Pickaxe',
      description: 'A superior pickaxe for harder minerals',
      rarity: ItemRarity.uncommon,
      baseValue: 200,
      iconPath: 'assets/images/items/steel_pickaxe.png',
      toolType: 'pickaxe',
      powerLevel: 3,
    ),
    'wooden_axe': ToolData(
      id: 'wooden_axe',
      name: 'Wooden Axe',
      description: 'Basic tool for chopping trees',
      rarity: ItemRarity.common,
      baseValue: 20,
      iconPath: 'assets/images/items/wooden_axe.png',
      toolType: 'axe',
      powerLevel: 1,
    ),
    'basic_hoe': ToolData(
      id: 'basic_hoe',
      name: 'Basic Hoe',
      description: 'Till soil for planting crops',
      rarity: ItemRarity.common,
      baseValue: 30,
      iconPath: 'assets/images/items/basic_hoe.png',
      toolType: 'hoe',
      powerLevel: 1,
    ),
  };
}
