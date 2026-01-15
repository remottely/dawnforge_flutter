import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';
import 'package:dawnforge/game/features/inventory/items/seed_bag_item.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';

final class ModernFarmSeedBagItemDatabaseDef {
  static const Map<HandItemId, SeedBagItem> seedBagList = {
    HandItemId.strawberry_seed_bag: SeedBagItem(
      id: HandItemId.strawberry_seed_bag,
      name: 'Strawberry Seed Bag',
      description: 'Plant these to grow strawberries',
      quality: HandItemQuality.normal,
      baseValue: 50,
      cropId: HandItemId.strawberry,
      growthTime: 4,
      yield: 3,
      requiredSeason: SeasonType.any,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 10,
        spriteColumnIndex: 7,
      ),
    ),
    HandItemId.apple_seed_bag: SeedBagItem(
      id: HandItemId.apple_seed_bag,
      name: 'Apple Seed Bag',
      description: 'Plant these to grow apples',
      quality: HandItemQuality.normal,
      baseValue: 50,
      cropId: HandItemId.apple,
      growthTime: 7,
      yield: 3,
      requiredSeason: SeasonType.any,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 10,
        spriteColumnIndex: 8,
      ),
    ),
    HandItemId.radish_seed_bag: SeedBagItem(
      id: HandItemId.radish_seed_bag,
      name: 'Radish Seed Bag',
      description: 'Plant these to grow radishes',
      quality: HandItemQuality.normal,
      baseValue: 50,
      cropId: HandItemId.radish,
      growthTime: 7,
      yield: 6,
      requiredSeason: SeasonType.any,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 10,
        spriteColumnIndex: 5,
      ),
    ),
    HandItemId.tomato_seed_bag: SeedBagItem(
      id: HandItemId.tomato_seed_bag,
      name: 'Tomato Seed Bag',
      description: 'Plant these to grow tomatoes',
      quality: HandItemQuality.normal,
      baseValue: 60,
      cropId: HandItemId.tomato,
      growthTime: 4,
      yield: 3,
      requiredSeason: SeasonType.any,
      iconData: ItemIconData(
        spritesheetPath: 'tiled/Modern_Farm_v1.2/Icons/Icons_16x16.png',
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: 10,
        spriteColumnIndex: 15,
      ),
    ),
  };
}
