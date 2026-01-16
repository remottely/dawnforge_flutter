import 'package:dawnforge/game/features/game_world/database/smallburg/smallburg_crop_entity_database_def.dart';
import 'package:dawnforge/game/features/game_world/database/smallburg/smallburg_database_def.dart';
import 'package:dawnforge/game/features/inventory/items/seed_bag_item.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_quality.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';
import 'package:dawnforge/game/features/inventory/entities/data/item_icon_data.dart';

const _vegetableColumn = 9;
const _treeColumn = 15;

final class SmallBurgSeedBagItemDatabaseDef {
  static const Map<HandItemId, SeedBagItem> seedBagList = {
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
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (radishSpriteRowIndex * 2) + 1,
        spriteColumnIndex: _vegetableColumn,
      ),
    ),
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
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (strawberrySpriteRowIndex * 2) + 1,
        spriteColumnIndex: _vegetableColumn,
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
      requiredSeason: SeasonType.summer,
      iconData: ItemIconData(
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (tomatoSpriteRowIndex * 2) + 1,
        spriteColumnIndex: _vegetableColumn,
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
        spritesheetPath: SmallburgDatabaseDef.kGridTilesTextureAtlasPath,
        spriteWidth: 16,
        spriteHeight: 16,
        spriteRowIndex: (appleSpriteRowIndex * 2) + 1,
        spriteColumnIndex: _treeColumn,
      ),
    ),
  };
}
