import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_rarity.dart';

final class ToolItemDatabaseDef {
  ToolItemDatabaseDef._();
  static const Map<HandItemId, ToolItem> toolItemList = {
    HandItemId.harvestBasket: ToolItem(
      id: HandItemId.harvestBasket,
      name: 'Harvest Basket',
      description: 'Increase carrying efficiency when harvesting',
      rarity: HandItemRarity.common,
      baseValue: 100,
      iconPath: '',
      toolType: 'harvest',
      powerLevel: 1,
    ),
    HandItemId.shovel: ToolItem(
      id: HandItemId.shovel,
      name: 'Shovel',
      description: 'Used to dig and move soil',
      rarity: HandItemRarity.common,
      baseValue: 100,
      iconPath: '',
      toolType: 'shovel',
      powerLevel: 1,
    ),
    HandItemId.wateringCan: ToolItem(
      id: HandItemId.wateringCan,
      name: 'Watering Can',
      description: 'Waters soil to help crops grow',
      rarity: HandItemRarity.common,
      baseValue: 100,
      iconPath: '',
      toolType: 'watering_can',
      powerLevel: 1,
    ),
    HandItemId.iron_pickaxe: ToolItem(
      id: HandItemId.iron_pickaxe,
      name: 'Iron Pickaxe',
      description: 'Mine rocks and ores efficiently',
      rarity: HandItemRarity.common,
      baseValue: 80,
      iconPath: 'assets/images/items/iron_pickaxe.png',
      toolType: 'pickaxe',
      powerLevel: 2,
    ),
    HandItemId.steel_pickaxe: ToolItem(
      id: HandItemId.steel_pickaxe,
      name: 'Steel Pickaxe',
      description: 'A superior pickaxe for harder minerals',
      rarity: HandItemRarity.uncommon,
      baseValue: 200,
      iconPath: 'assets/images/items/steel_pickaxe.png',
      toolType: 'pickaxe',
      powerLevel: 3,
    ),
    HandItemId.wooden_axe: ToolItem(
      id: HandItemId.wooden_axe,
      name: 'Wooden Axe',
      description: 'Basic tool for chopping trees',
      rarity: HandItemRarity.common,
      baseValue: 20,
      iconPath: 'assets/images/items/wooden_axe.png',
      toolType: 'axe',
      powerLevel: 1,
    ),
    HandItemId.basic_hoe: ToolItem(
      id: HandItemId.basic_hoe,
      name: 'Basic Hoe',
      description: 'Till soil for planting crops',
      rarity: HandItemRarity.common,
      baseValue: 30,
      iconPath: 'assets/images/items/basic_hoe.png',
      toolType: 'hoe',
      powerLevel: 1,
    ),
    HandItemId.axe: ToolItem(
      id: HandItemId.axe,
      name: 'Steel Axe',
      description: 'Heavy-duty axe for chopping and clearing',
      rarity: HandItemRarity.uncommon,
      baseValue: 180,
      iconPath: 'assets/images/items/steel_axe.png',
      toolType: 'axe',
      powerLevel: 3,
    ),
  };
}
