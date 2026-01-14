import 'package:dawnforge/gameplay/database/smallburg/smallburg_crop_entity_database_def.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/loot_category.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/season.dart';
import 'package:dawnforge/gameplay/inventory/entities/data/item_icon_data.dart';
import 'package:dawnforge/gameplay/inventory/items/harvest_loot_item.dart';

const vegetableColumn = 7;
const treeColumn = 13;

// int _getSpriteRowIndex(int rowIndex) {
//   return (rowIndex * 2) + 1;
// }

final class SmallBurgHarvestLootItemDatabaseDef {
  SmallBurgHarvestLootItemDatabaseDef._();
  static const Map<HandItemId, HarvestLootItem> harvestLootItemList = {
    HandItemId.radish_loot_item: HarvestLootItem(
      requiredSeason: SeasonType.any,
      id: HandItemId.radish_loot_item,
      name: 'Radish',
      description: 'A crisp radish. Can be eaten or sold.',
      quality: HandItemQuality.normal,
      baseValue: 12,
      healthRestore: 8,
      staminaRestore: 8,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (radishSpriteRowIndex * 2) + 1,
        spriteColumnIndex: vegetableColumn,
      ),
      category: LootCategory.vegetable,
      regrowthDays: 0,
    ),
    HandItemId.strawberry_loot_item: HarvestLootItem(
      requiredSeason: SeasonType.any,
      id: HandItemId.strawberry_loot_item,
      name: 'Strawberry',
      description: 'A fresh red strawberry. Can be eaten or sold.',
      quality: HandItemQuality.normal,
      baseValue: 15,
      healthRestore: 10,
      staminaRestore: 10,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (strawberrySpriteRowIndex * 2) + 1,
        spriteColumnIndex: vegetableColumn,
      ),
      category: LootCategory.vegetable,
      regrowthDays: 0,
    ),
    HandItemId.tomato_loot_item: HarvestLootItem(
      requiredSeason: SeasonType.any,
      id: HandItemId.tomato_loot_item,
      name: 'Tomato',
      description: 'A juicy red tomato. Perfect for salads.',
      quality: HandItemQuality.silver,
      baseValue: 20,
      healthRestore: 12,
      staminaRestore: 12,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (tomatoSpriteRowIndex * 2) + 1,
        spriteColumnIndex: vegetableColumn,
      ),
      category: LootCategory.vegetable,
      regrowthDays: 0,
    ),
    HandItemId.apple_loot_item: HarvestLootItem(
      requiredSeason: SeasonType.any,
      id: HandItemId.apple_loot_item,
      name: 'Apple',
      description: 'A crisp apple. Can be eaten or sold.',
      quality: HandItemQuality.normal,
      baseValue: 12,
      healthRestore: 8,
      staminaRestore: 8,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (appleSpriteRowIndex * 2) + 1,
        spriteColumnIndex: treeColumn,
      ),
      category: LootCategory.vegetable,
      regrowthDays: 0,
    ),
    // HandItemId.apple: HarvestLootItem(
    //   requiredSeason: SeasonType.any,
    //   id: HandItemId.apple,
    //   name: 'Apple',
    //   description: 'Fresh apple you can eat or sell.',
    //   quality: HandItemQuality.normal,
    //   baseValue: 12,
    //   healthRestore: 8,
    //   staminaRestore: 8,
    //   iconData: ItemIconData(
    //     spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
    //     spriteWidth: 16,
    //     spriteHeight: 16,
    //     spriteRowIndex: appleSpriteRowIndex * 2,
    //     spriteColumnIndex: vegetableColumn,
    //   ),
    //   category: LootCategory.vegetable,
    //   regrowthDays: 0,
    // ),
    // HandItemId.strawberry: HarvestLootItem(
    //   requiredSeason: SeasonType.any,
    //   id: HandItemId.strawberry,
    //   name: 'Strawberry',
    //   description: 'Sweet strawberry ready to eat.',
    //   quality: HandItemQuality.normal,
    //   baseValue: 15,
    //   healthRestore: 10,
    //   staminaRestore: 10,
    //   iconData: ItemIconData(
    //     spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
    //     spriteWidth: 16,
    //     spriteHeight: 16,
    //     spriteRowIndex: strawberrySpriteRowIndex * 2,
    //     spriteColumnIndex: vegetableColumn,
    //   ),
    //   category: LootCategory.vegetable,
    //   regrowthDays: 0,
    // ),
    // HandItemId.tomato: HarvestLootItem(
    //   requiredSeason: SeasonType.any,
    //   id: HandItemId.tomato,
    //   name: 'Tomato',
    //   description: 'Juicy tomato perfect for salads.',
    //   quality: HandItemQuality.silver,
    //   baseValue: 20,
    //   healthRestore: 12,
    //   staminaRestore: 12,
    //   iconData: ItemIconData(
    //     spritesheetPath: 'tiled/SmallBurg/texture_atlas_grid_tiles.png',
    //     spriteWidth: 16,
    //     spriteHeight: 16,
    //     spriteRowIndex: tomatoSpriteRowIndex * 2,
    //     spriteColumnIndex: vegetableColumn,
    //   ),
    //   category: LootCategory.vegetable,
    //   regrowthDays: 0,
    // ),
  };
}
