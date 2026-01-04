import 'package:darkness_dungeon/gameplay/inventory/models/item_rarity.dart';

class SeedData {
  final String id;
  final String name;
  final String description;
  final ItemRarity rarity;
  final int baseValue;
  final String iconPath;
  final int maxStackSize;
  final String cropId;
  final int growthTime;
  final int yield;
  final String season;

  const SeedData({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.baseValue,
    required this.iconPath,
    required this.maxStackSize,
    required this.cropId,
    required this.growthTime,
    required this.yield,
    required this.season,
  });
}

final class SeedDatabaseDef {
  static const Map<String, SeedData> seeds = {
    'carrot_seeds': SeedData(
      id: 'carrot_seeds',
      name: 'Carrot Seeds',
      description: 'Plant to grow carrots in any season',
      rarity: ItemRarity.common,
      baseValue: 10,
      iconPath: 'assets/images/items/carrot_seeds.png',
      maxStackSize: 99,
      cropId: 'carrot',
      growthTime: 4,
      yield: 3,
      season: 'any',
    ),
    'wheat_seeds': SeedData(
      id: 'wheat_seeds',
      name: 'Wheat Seeds',
      description: 'Grow wheat in spring or fall',
      rarity: ItemRarity.common,
      baseValue: 8,
      iconPath: 'assets/images/items/wheat_seeds.png',
      maxStackSize: 99,
      cropId: 'wheat',
      growthTime: 5,
      yield: 4,
      season: 'spring',
    ),
    'tomato_seeds': SeedData(
      id: 'tomato_seeds',
      name: 'Tomato Seeds',
      description: 'Summer crop that produces many tomatoes',
      rarity: ItemRarity.uncommon,
      baseValue: 25,
      iconPath: 'assets/images/items/tomato_seeds.png',
      maxStackSize: 99,
      cropId: 'tomato',
      growthTime: 7,
      yield: 6,
      season: 'summer',
    ),
    'pumpkin_seeds': SeedData(
      id: 'pumpkin_seeds',
      name: 'Pumpkin Seeds',
      description: 'Fall crop that grows large pumpkins',
      rarity: ItemRarity.uncommon,
      baseValue: 30,
      iconPath: 'assets/images/items/pumpkin_seeds.png',
      maxStackSize: 99,
      cropId: 'pumpkin',
      growthTime: 10,
      yield: 2,
      season: 'fall',
    ),
    'ancient_seeds': SeedData(
      id: 'ancient_seeds',
      name: 'Ancient Seeds',
      description: 'Rare ancient seeds that grow valuable crops',
      rarity: ItemRarity.legendary,
      baseValue: 500,
      iconPath: 'assets/images/items/ancient_seeds.png',
      maxStackSize: 10,
      cropId: 'ancient_fruit',
      growthTime: 28,
      yield: 10,
      season: 'any',
    ),
  };
}
