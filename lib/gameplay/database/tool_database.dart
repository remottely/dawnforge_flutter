import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_rarity.dart';

final class ToolDatabaseDef {
  ToolDatabaseDef._();
  static const Map<EquippedHandType, ToolItem> tools = {
    EquippedHandType.iron_pickaxe: ToolItem(
      id: EquippedHandType.iron_pickaxe,
      name: 'Iron Pickaxe',
      description: 'Mine rocks and ores efficiently',
      rarity: ItemRarity.common,
      baseValue: 80,
      iconPath: 'assets/images/items/iron_pickaxe.png',
      toolType: 'pickaxe',
      powerLevel: 2,
    ),
    EquippedHandType.steel_pickaxe: ToolItem(
      id: EquippedHandType.steel_pickaxe,
      name: 'Steel Pickaxe',
      description: 'A superior pickaxe for harder minerals',
      rarity: ItemRarity.uncommon,
      baseValue: 200,
      iconPath: 'assets/images/items/steel_pickaxe.png',
      toolType: 'pickaxe',
      powerLevel: 3,
    ),
    EquippedHandType.wooden_axe: ToolItem(
      id: EquippedHandType.wooden_axe,
      name: 'Wooden Axe',
      description: 'Basic tool for chopping trees',
      rarity: ItemRarity.common,
      baseValue: 20,
      iconPath: 'assets/images/items/wooden_axe.png',
      toolType: 'axe',
      powerLevel: 1,
    ),
    EquippedHandType.basic_hoe: ToolItem(
      id: EquippedHandType.basic_hoe,
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
