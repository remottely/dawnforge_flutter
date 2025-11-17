import 'dart:developer' as developer;

import '../constants/inventory_constants.dart';
import '../items/crop_item.dart';
import '../models/item.dart';
import '../models/item_category.dart';
import '../models/item_quality.dart';

/// Service for calculating item prices following Stardew Valley's rules.
///
/// Handles:
/// - Quality multipliers
/// - Profession bonuses
/// - Sell location modifiers (shop vs shipping bin)
/// - Category-specific bonuses
final class ItemPriceService {
  ItemPriceService._();

  static final instance = ItemPriceService._();

  // ============================================================================
  // Player Professions (would come from player profile in real game)
  // ============================================================================

  bool _hasTillerProfession = false;
  bool _hasRancherProfession = false;
  bool _hasArtisanProfession = false;
  bool _hasAnglerProfession = false;

  /// Set player professions
  void setProfessions({
    bool tiller = false,
    bool rancher = false,
    bool artisan = false,
    bool angler = false,
  }) {
    _hasTillerProfession = tiller;
    _hasRancherProfession = rancher;
    _hasArtisanProfession = artisan;
    _hasAnglerProfession = angler;

    developer.log(
      '[ItemPriceService] Professions set: '
      'Tiller=$tiller, Rancher=$rancher, Artisan=$artisan, Angler=$angler',
    );
  }

  // ============================================================================
  // Price Calculation
  // ============================================================================

  /// Calculate sell price for an item.
  ///
  /// Takes into account:
  /// - Base value
  /// - Quality multiplier (for items that support quality)
  /// - Profession bonuses
  /// - Sell location modifier (shop discount vs full shipping bin price)
  int calculateSellPrice(
    Item item, {
    bool isShippingBin = true,
    ItemQuality? quality,
  }) {
    var price = item.baseValue.toDouble();

    // 1. Apply quality multiplier if item is a crop
    if (item is CropItem) {
      final itemQuality = quality ?? item.quality;
      price *= itemQuality.priceMultiplier;
    }

    // 2. Apply profession bonuses based on item category
    final professionBonus = _getProfessionBonus(item);
    price *= (1.0 + professionBonus);

    // 3. Apply sell location modifier
    if (!isShippingBin) {
      price *= InventoryConstants.kShopSellPriceModifier;
    }

    final finalPrice = price.round();

    developer.log(
      '[ItemPriceService] Price for ${item.name}: '
      'base=${item.baseValue}, final=$finalPrice '
      '(quality=${item is CropItem ? item.quality.name : "N/A"}, '
      'profession=${(professionBonus * 100).toStringAsFixed(0)}%, '
      'location=${isShippingBin ? "shipping" : "shop"})',
    );

    return finalPrice;
  }

  /// Calculate buy price for an item (from shops).
  ///
  /// Usually 2x the base sell price in Stardew Valley.
  int calculateBuyPrice(Item item) {
    final baseSellPrice = calculateSellPrice(item, isShippingBin: true);
    return (baseSellPrice * 2).round();
  }

  /// Get profession bonus multiplier for this item.
  double _getProfessionBonus(Item item) {
    if (item is CropItem) {
      // Tiller: +10% for crops
      if (_hasTillerProfession &&
          [
            ItemCategory.vegetables,
            ItemCategory.fruits,
            ItemCategory.flowers,
          ].contains(item.category)) {
        return InventoryConstants.kTillerProfessionBonus;
      }

      // Rancher: +20% for animal products
      if (_hasRancherProfession &&
          item.category == ItemCategory.animalProducts) {
        return InventoryConstants.kRancherProfessionBonus;
      }

      // Artisan: +40% for artisan goods
      if (_hasArtisanProfession && item.category == ItemCategory.artisanGoods) {
        return InventoryConstants.kArtisanProfessionBonus;
      }

      // Angler: +50% for fish
      if (_hasAnglerProfession && item.category == ItemCategory.fish) {
        return InventoryConstants.kAnglerProfessionBonus;
      }
    }

    return 0.0;
  }

  // ============================================================================
  // Quality Determination
  // ============================================================================

  /// Determine quality for harvested crop based on farming level and fertilizer.
  ///
  /// Quality chances in Stardew Valley:
  /// - Farming Level 0: 0% silver, 0% gold, 0% iridium
  /// - Farming Level 5: 5% silver, 0% gold, 0% iridium
  /// - Farming Level 10: 10% silver, 5% gold, 0% iridium
  /// - Farming Level 15 (with fertilizer): 15% silver, 10% gold, 5% iridium
  ///
  /// Each farming level adds 1% to all quality chances.
  /// Fertilizer adds bonus levels.
  ItemQuality determineHarvestQuality({
    required int farmingLevel,
    int fertilizerQualityBoost = 0,
    double randomValue = 0.5, // For testing, normally use Random()
  }) {
    final effectiveLevel = farmingLevel + fertilizerQualityBoost;

    // Calculate quality chances
    final iridiumChance = (effectiveLevel >= 10)
        ? (effectiveLevel - 10) * InventoryConstants.kQualityChancePerLevel
        : 0.0;
    final goldChance = (effectiveLevel >= 5)
        ? (effectiveLevel - 5) * InventoryConstants.kQualityChancePerLevel
        : 0.0;
    final silverChance =
        effectiveLevel * InventoryConstants.kQualityChancePerLevel;

    // Roll for quality (from highest to lowest)
    if (randomValue < iridiumChance) {
      return ItemQuality.iridium;
    } else if (randomValue < goldChance) {
      return ItemQuality.gold;
    } else if (randomValue < silverChance) {
      return ItemQuality.silver;
    } else {
      return ItemQuality.normal;
    }
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Calculate total value of a stack of items
  int calculateStackValue(
    Item item,
    int quantity, {
    bool isShippingBin = true,
    ItemQuality? quality,
  }) {
    final unitPrice = calculateSellPrice(
      item,
      isShippingBin: isShippingBin,
      quality: quality,
    );
    return unitPrice * quantity;
  }

  /// Reset all professions (for testing)
  void reset() {
    _hasTillerProfession = false;
    _hasRancherProfession = false;
    _hasArtisanProfession = false;
    _hasAnglerProfession = false;
    developer.log('[ItemPriceService] Reset');
  }
}
