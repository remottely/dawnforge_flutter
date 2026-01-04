import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_quality.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item_icon_data.dart';

final class ModernFarmToolItemDatabaseDef {
  ModernFarmToolItemDatabaseDef._();
  static const Map<HandItemId, ToolItem> toolItemList = {
    HandItemId.harvestBasket: ToolItem(
      id: HandItemId.harvestBasket,
      name: 'Harvest Basket',
      description: 'Increase carrying efficiency when harvesting',
      quality: HandItemQuality.normal,
      baseValue: 100,
      toolType: 'harvest',
      powerLevel: 1,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 6,
        spriteColumnIndex: 5,
      ),
    ),
    HandItemId.shovel: ToolItem(
      id: HandItemId.shovel,
      name: 'Shovel',
      description: 'Used to dig and move soil',
      quality: HandItemQuality.normal,
      baseValue: 100,
      toolType: 'shovel',
      powerLevel: 1,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 6,
        spriteColumnIndex: 4,
      ),
    ),
    HandItemId.wateringCan: ToolItem(
      id: HandItemId.wateringCan,
      name: 'Watering Can',
      description: 'Waters soil to help crops grow',
      quality: HandItemQuality.normal,
      baseValue: 100,
      toolType: 'watering_can',
      powerLevel: 1,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 6,
        spriteColumnIndex: 3,
      ),
    ),
    // HandItemId.iron_pickaxe: ToolItem(
    //   id: HandItemId.iron_pickaxe,
    //   name: 'Iron Pickaxe',
    //   description: 'Mine rocks and ores efficiently',
    //   quality: HandItemQuality.normal,
    //   baseValue: 80,
    //   toolType: 'pickaxe',
    //   powerLevel: 2,
    // ),
    // HandItemId.steel_pickaxe: ToolItem(
    //   id: HandItemId.steel_pickaxe,
    //   name: 'Steel Pickaxe',
    //   description: 'A superior pickaxe for harder minerals',
    //   quality: HandItemQuality.silver,
    //   baseValue: 200,
    //   toolType: 'pickaxe',
    //   powerLevel: 3,
    // ),
    // HandItemId.wooden_axe: ToolItem(
    //   id: HandItemId.wooden_axe,
    //   name: 'Wooden Axe',
    //   description: 'Basic tool for chopping trees',
    //   quality: HandItemQuality.normal,
    //   baseValue: 20,
    //   toolType: 'axe',
    //   powerLevel: 1,
    // ),
    // HandItemId.basic_hoe: ToolItem(
    //   id: HandItemId.basic_hoe,
    //   name: 'Basic Hoe',
    //   description: 'Till soil for planting crops',
    //   quality: HandItemQuality.normal,
    //   baseValue: 30,
    //   toolType: 'hoe',
    //   powerLevel: 1,
    // ),
    // HandItemId.axe: ToolItem(
    //   id: HandItemId.axe,
    //   name: 'Steel Axe',
    //   description: 'Heavy-duty axe for chopping and clearing',
    //   quality: HandItemQuality.silver,
    //   baseValue: 180,
    //   toolType: 'axe',
    //   powerLevel: 3,
    // ),
  };
}
