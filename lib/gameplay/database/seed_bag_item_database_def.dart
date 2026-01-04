import 'package:darkness_dungeon/gameplay/inventory/items/seed_bag_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_quality.dart';

final class SeedBagItemDatabaseDef {
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
      season: 'any',
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
      season: 'any',
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
      season: 'any',
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
      season: 'summer',
    ),
  };
}
