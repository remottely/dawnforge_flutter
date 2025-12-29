final class InventoryDef {
  InventoryDef._();
  static const int kSizeInventoryDefault = 12;
  static const int kSizeInventoryMax = 36;
  static const int kSizeInventoryUpgradeLvl2 = 24;
  static const int kSizeInventoryUpgradeLvl3 = 36;

  static const int kStackAmountDefault = 999;
  static const int kStackAmountEquipment = 1;
  static const int kStackAmountSeed = 999;
  static const int kStackAmountResource = 999;
  static const int kStackAmountCrop = 999;
  static const int kStackAmountFood = 999;
  static const int kStackAmountBait = 999;

  static const double kNormalQualityMultiplier = 1.0;
  static const double kSilverQualityMultiplier = 1.25;
  static const double kGoldQualityMultiplier = 1.5;
  static const double kIridiumQualityMultiplier = 2.0;
  static const double kShopSellPriceModifier = 0.50;
  static const double kShippingBinSellPriceModifier = 1.0;
  static const double kTillerProfessionBonus = 0.10;
  static const double kRancherProfessionBonus = 0.20;
  static const double kArtisanProfessionBonus = 0.40;
  static const double kAnglerProfessionBonus = 0.50;
  static const int kLowTierEnergyRestore = 13;
  static const int kMidTierEnergyRestore = 25;
  static const int kHighTierEnergyRestore = 38;
  static const int kLowTierHealthRestore = 5;
  static const int kMidTierHealthRestore = 11;
  static const int kHighTierHealthRestore = 17;
  static const double kSilverQualityBaseChance = 0.0;
  static const double kQualityChancePerLevel = 0.01;
  static const double kGoldQualityStartLevel = 5;
  static const double kIridiumQualityStartLevel = 10;
  static const int kBasicFertilizerQualityBoost = 1;
  static const int kQualityFertilizerQualityBoost = 2;
  static const int kDeluxeFertilizerQualityBoost = 3;
  static const int kFoodBuffDurationSeconds = 180;
  static const int kSpeedBuffDurationSeconds = 240;
  static const int kRawFishEnergyPenalty = -75;
  static const int kTrashEnergyValue = -15;
  static const int kMaxGoldAmount = 999999999;
}
