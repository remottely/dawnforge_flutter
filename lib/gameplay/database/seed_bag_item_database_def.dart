import 'package:darkness_dungeon/gameplay/inventory/items/seed_bag_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_id.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_rarity.dart';

final class SeedBagItemDatabaseDef {
  static const Map<HandItemId, SeedBagItem> seedBagList = {
    HandItemId.strawberry_seed_bag: SeedBagItem(
      id: HandItemId.strawberry_seed_bag,
      name: 'Strawberry Seed Bag',
      description: 'Plant these to grow strawberries',
      rarity: HandItemRarity.common,
      baseValue: 50,
      iconPath: '',
      cropId: 'strawberry',
      growthTime: 4,
      yield: 3,
      season: 'any',
    ),
    HandItemId.apple_seed_bag: SeedBagItem(
      id: HandItemId.apple_seed_bag,
      name: 'Apple Seed Bag',
      description: 'Plant these to grow apples',
      rarity: HandItemRarity.common,
      baseValue: 50,
      iconPath: '',
      cropId: 'apple',
      growthTime: 7,
      yield: 3,
      season: 'any',
    ),
    HandItemId.radish_seed_bag: SeedBagItem(
      id: HandItemId.radish_seed_bag,
      name: 'Radish Seed Bag',
      description: 'Plant these to grow radishes',
      rarity: HandItemRarity.common,
      baseValue: 50,
      iconPath: '',
      cropId: 'radish',
      growthTime: 7,
      yield: 6,
      season: 'any',
    ),
    HandItemId.tomato_seed_bag: SeedBagItem(
      id: HandItemId.tomato_seed_bag,
      name: 'Tomato Seed Bag',
      description: 'Plant these to grow tomatoes',
      rarity: HandItemRarity.common,
      baseValue: 60,
      iconPath: '',
      cropId: 'tomato',
      growthTime: 4,
      yield: 3,
      season: 'summer',
    ),
  };
}
