/// Inventory system constants following Stardew Valley patterns.
final class InventoryConstants {
  InventoryConstants._();

  // ============================================================================
  // Inventory Capacity
  // ============================================================================

  /// Default inventory size (Stardew Valley starts with 12, can expand to 36)
  static const int kDefaultInventorySize = 12;

  /// Maximum inventory size after all backpack upgrades
  static const int kMaxInventorySize = 36;

  /// First backpack upgrade adds 12 slots (total: 24)
  static const int kFirstUpgradeSize = 24;

  /// Second backpack upgrade adds 12 slots (total: 36)
  static const int kSecondUpgradeSize = 36;

  // ============================================================================
  // Stack Sizes (Stardew Valley standards)
  // ============================================================================

  /// Default stack size for most items
  static const int kDefaultStackSize = 999;

  /// Stack size for equipment and tools (non-stackable)
  static const int kEquipmentStackSize = 1;

  /// Stack size for seeds // TODO(Kevin): adjust to strawberry, carrot, etc?
  static const int kSeedStackSize = 999;

  /// Stack size for resources (wood, stone, fiber)
  static const int kResourceStackSize = 999;

  /// Stack size for crops and foraged items
  static const int kCropStackSize = 999;

  /// Stack size for cooked food
  static const int kFoodStackSize = 999;

  /// Stack size for fishing bait
  static const int kBaitStackSize = 999;

  // ============================================================================
  // Quality Multipliers (Stardew Valley values)
  // ============================================================================

  /// Normal quality price multiplier
  static const double kNormalQualityMultiplier = 1.0;

  /// Silver quality price multiplier (1 star)
  static const double kSilverQualityMultiplier = 1.25;

  /// Gold quality price multiplier (2 stars)
  static const double kGoldQualityMultiplier = 1.5;

  /// Iridium quality price multiplier (3 stars)
  static const double kIridiumQualityMultiplier = 2.0;

  // ============================================================================
  // Sell Price Modifiers
  // ============================================================================

  /// Percentage of base value when selling to shops (50%)
  static const double kShopSellPriceModifier = 0.50;

  /// Bonus for selling through shipping bin (100%)
  static const double kShippingBinSellPriceModifier = 1.0;

  /// Tiller profession bonus (10% more for crops)
  static const double kTillerProfessionBonus = 0.10;

  /// Rancher profession bonus (20% more for animal products)
  static const double kRancherProfessionBonus = 0.20;

  /// Artisan profession bonus (40% more for artisan goods)
  static const double kArtisanProfessionBonus = 0.40;

  /// Angler profession bonus (50% more for fish)
  static const double kAnglerProfessionBonus = 0.50;

  // ============================================================================
  // Energy & Health Restoration
  // ============================================================================

  /// Base energy restore for low-tier crops (parsnip, etc)
  static const int kLowTierEnergyRestore = 13;

  /// Base energy restore for mid-tier crops
  static const int kMidTierEnergyRestore = 25;

  /// Base energy restore for high-tier crops
  static const int kHighTierEnergyRestore = 38;

  /// Base health restore for low-tier crops
  static const int kLowTierHealthRestore = 5;

  /// Base health restore for mid-tier crops
  static const int kMidTierHealthRestore = 11;

  /// Base health restore for high-tier crops
  static const int kHighTierHealthRestore = 17;

  // ============================================================================
  // Drop Rates
  // ============================================================================

  /// Chance for silver quality at farming level 0 (0%)
  static const double kSilverQualityBaseChance = 0.0;

  /// Chance increase per farming level (1% per level)
  static const double kQualityChancePerLevel = 0.01;

  /// Chance for gold quality at farming level 5 (5%)
  static const double kGoldQualityStartLevel = 5;

  /// Chance for iridium quality at farming level 10 (10%)
  static const double kIridiumQualityStartLevel = 10;

  /// Basic fertilizer quality boost (+1 level)
  static const int kBasicFertilizerQualityBoost = 1;

  /// Quality fertilizer quality boost (+2 levels)
  static const int kQualityFertilizerQualityBoost = 2;

  /// Deluxe fertilizer quality boost (+3 levels)
  static const int kDeluxeFertilizerQualityBoost = 3;

  // ============================================================================
  // Item Durations
  // ============================================================================

  /// Duration of buffs from food (in seconds)
  static const int kFoodBuffDurationSeconds = 180; // 3 minutes

  /// Duration of speed buff
  static const int kSpeedBuffDurationSeconds = 240; // 4 minutes

  // /// Duration of defense buff
  // static const int kDefenseBuffDurationSeconds = 300; // 5 minutes

  // ============================================================================
  // Misc Constants
  // ============================================================================

  /// Energy penalty for eating raw fish or inedible items
  static const int kRawFishEnergyPenalty = -75;

  /// Trash items give no energy
  static const int kTrashEnergyValue = -15;

  /// Maximum amount of gold the player can carry
  static const int kMaxGoldAmount = 999999999;
}
