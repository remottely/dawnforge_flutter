
import 'package:darkness_dungeon/core/utils/logger/game_logger.dart';

import 'package:darkness_dungeon/gameplay/inventory/config/inventory_def.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_quality.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/harvest_loot_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/enums/loot_category.dart';

final class ItemPriceService {
  ItemPriceService._();

  static final instance = ItemPriceService._();

  bool _hasTillerProfession = false;
  bool _hasRancherProfession = false;
  bool _hasArtisanProfession = false;
  bool _hasAnglerProfession = false;

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

    GameLogger.info('[ItemPriceService] Professions set: Tiller=$tiller, Rancher=$rancher, Artisan=$artisan, Angler=$angler');
  }

  int calculateSellPrice(
    HandItem item, {
    bool isShippingBin = true,
    HandItemQuality? quality,
  }) {
    var price = item.baseValue.toDouble();

    if (item is HarvestLootItem) {
      final itemQuality = quality ?? item.quality;
      price *= itemQuality.priceMultiplier;
    }

    final professionBonus = _getProfessionBonus(item);
    price *= 1.0 + professionBonus;

    if (!isShippingBin) {
      price *= InventoryDef.kShopSellPriceModifier;
    }

    final finalPrice = price.round();

    GameLogger.info('[ItemPriceService] Price for ${item.name}: base=${item.baseValue}, final=$finalPrice (quality=${item is HarvestLootItem ? item.quality.name : "N/A"}, profession=${(professionBonus * 100).toStringAsFixed(0)}%, location=${isShippingBin ? "shipping" : "shop"})');

    return finalPrice;
  }

  int calculateBuyPrice(HandItem item) {
    final baseSellPrice = calculateSellPrice(item);
    return baseSellPrice * 2;
  }

  double _getProfessionBonus(HandItem item) {
    if (item is HarvestLootItem) {
      if (_hasTillerProfession &&
          [
            LootCategory.vegetable,
            LootCategory.fruit,
            LootCategory.flower,
          ].contains(item.type)) {
        return InventoryDef.kTillerProfessionBonus;
      }

      if (_hasRancherProfession &&
          item.type == LootCategory.animalProduct) {
        return InventoryDef.kRancherProfessionBonus;
      }

      if (_hasArtisanProfession && item.type == LootCategory.artisanGood) {
        return InventoryDef.kArtisanProfessionBonus;
      }

      if (_hasAnglerProfession && item.type == LootCategory.fish) {
        return InventoryDef.kAnglerProfessionBonus;
      }
    }

    return 0.0;
  }

  HandItemQuality determineHarvestQuality({
    required int farmingLevel,
    int fertilizerQualityBoost = 0,
    double randomValue = 0.5,
  }) {
    final effectiveLevel = farmingLevel + fertilizerQualityBoost;

    final iridiumChance = (effectiveLevel >= 10)
        ? (effectiveLevel - 10) * InventoryDef.kQualityChancePerLevel
        : 0.0;
    final goldChance = (effectiveLevel >= 5)
        ? (effectiveLevel - 5) * InventoryDef.kQualityChancePerLevel
        : 0.0;
    final silverChance =
        effectiveLevel * InventoryDef.kQualityChancePerLevel;

    if (randomValue < iridiumChance) {
      return HandItemQuality.iridium;
    } else if (randomValue < goldChance) {
      return HandItemQuality.gold;
    } else if (randomValue < silverChance) {
      return HandItemQuality.silver;
    } else {
      return HandItemQuality.normal;
    }
  }

  int calculateStackValue(
    HandItem item,
    int quantity, {
    bool isShippingBin = true,
    HandItemQuality? quality,
  }) {
    final unitPrice = calculateSellPrice(
      item,
      isShippingBin: isShippingBin,
      quality: quality,
    );
    return unitPrice * quantity;
  }

  void reset() {
    _hasTillerProfession = false;
    _hasRancherProfession = false;
    _hasArtisanProfession = false;
    _hasAnglerProfession = false;
    GameLogger.info('[ItemPriceService] Reset');
  }
}
