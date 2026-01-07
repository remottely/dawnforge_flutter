/// Farm module constants following K1 architecture pattern
/// (Constants local to the module)
class FarmConstants {
  FarmConstants._(); // Private constructor to prevent instantiation

  // Grid
  static const int kDefaultFarmWidth = 20;
  static const int kDefaultFarmHeight = 20;
  static const double kTileSize = 32.0;

  // Timing
  static const int kWaterDurationMinutes = 60; // 1 hora
  static const int kCropGrowthCheckIntervalSeconds = 10;

  // Limits
  static const int kMaxCropsPerPlayer = 100;

  // Seeds - IDs dos items de semente
  static const String kStrawberrySeedId = 'strawberry_seed_bag';
  static const String kTomatoSeedId = 'tomato_seed_bag';
  static const String kPotatoSeedId = 'potato_seed_bag';

  // Harvested Items - IDs dos items colhidos
  static const String kStrawberryId = 'strawberry';
  static const String kTomatoId = 'tomato';
  static const String kPotatoId = 'potato';

  // Tools - IDs das ferramentas
  static const String kShovelId = 'shovel';
  static const String kWateringCanId = 'wateringCan';
  static const String kHarvestBasketId = 'harvestBasket';
}
