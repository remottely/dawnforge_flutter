import 'package:darkness_dungeon/gameplay/inventory/entities/enums/hand_item_id.dart';

/// Tipo de transação do market (compra ou venda).
enum MarketTransactionType { buy, sell }

/// Erros possíveis em uma transação de market.
enum MarketTransactionError {
  insufficientFunds,
  inventoryFull,
  itemUnavailable,
  notTradeable,
  invalidItem,
  unknown,
}

/// Item disponível no market.
class MarketItem {
  final HandItemId itemId;
  final int buyPrice;
  final int? sellPrice; // null se não vendável
  final bool isAvailable;
  final String category; // ex.: seeds, tools, misc

  const MarketItem({
    required this.itemId,
    required this.buyPrice,
    this.sellPrice,
    this.isAvailable = true,
    this.category = 'seeds',
  });

  bool get isSeed => itemId.isSeed;
  bool get isSellable => sellPrice != null;
}

/// Catálogo estático do market (MVP) contendo sementes.
class MarketCatalog {
  MarketCatalog._();

  /// Lista de itens de sementes com preços balanceados simples.
  static const List<MarketItem> seeds = [
    MarketItem(
      itemId: HandItemId.carrot_seed_bag,
      buyPrice: 15,
      sellPrice: 9,
    ),
    MarketItem(
      itemId: HandItemId.radish_seed_bag,
      buyPrice: 18,
      sellPrice: 11,
    ),
    MarketItem(
      itemId: HandItemId.cabbage_seed_bag,
      buyPrice: 25,
      sellPrice: 15,
    ),
    MarketItem(
      itemId: HandItemId.turnip_seed_bag,
      buyPrice: 20,
      sellPrice: 12,
    ),
    MarketItem(
      itemId: HandItemId.wheat_seed_bag,
      buyPrice: 12,
      sellPrice: 7,
    ),
    MarketItem(
      itemId: HandItemId.pepper_seed_bag,
      buyPrice: 28,
      sellPrice: 17,
    ),
    MarketItem(
      itemId: HandItemId.cotton_seed_bag,
      buyPrice: 22,
      sellPrice: 13,
    ),
    MarketItem(
      itemId: HandItemId.onion_seed_bag,
      buyPrice: 24,
      sellPrice: 14,
    ),
    MarketItem(
      itemId: HandItemId.cauliflower_seed_bag,
      buyPrice: 30,
      sellPrice: 18,
    ),
    MarketItem(
      itemId: HandItemId.corn_seed_bag,
      buyPrice: 26,
      sellPrice: 16,
    ),
    MarketItem(
      itemId: HandItemId.tomato_seed_bag,
      buyPrice: 24,
      sellPrice: 14,
    ),
    MarketItem(
      itemId: HandItemId.grape_seed_bag,
      buyPrice: 32,
      sellPrice: 19,
    ),
    MarketItem(
      itemId: HandItemId.prickly_pear_seed_bag,
      buyPrice: 38,
      sellPrice: 23,
    ),
    MarketItem(
      itemId: HandItemId.coffee_seed_bag,
      buyPrice: 50,
      sellPrice: 30,
    ),
    MarketItem(
      itemId: HandItemId.zuchini_seed_bag,
      buyPrice: 27,
      sellPrice: 16,
    ),
    MarketItem(
      itemId: HandItemId.pumpkin_seed_bag,
      buyPrice: 34,
      sellPrice: 20,
    ),
    MarketItem(
      itemId: HandItemId.pineapple_seed_bag,
      buyPrice: 55,
      sellPrice: 33,
    ),
    MarketItem(
      itemId: HandItemId.watermelon_seed_bag,
      buyPrice: 45,
      sellPrice: 27,
    ),
    MarketItem(
      itemId: HandItemId.apple_seed_bag,
      buyPrice: 40,
      sellPrice: 24,
    ),
    MarketItem(
      itemId: HandItemId.strawberry_seed_bag,
      buyPrice: 35,
      sellPrice: 21,
    ),
  ];

  /// Mapa rápido para lookup por id.
  static final Map<HandItemId, MarketItem> byId = {
    for (final item in seeds) item.itemId: item,
  };

  /// Tabela de venda de loots (HarvestLootItem) em moedas (base 60% do valor de compra estimado).
  static const Map<HandItemId, int> harvestLootSellPrice = {
    HandItemId.carrot_loot_item: 9,
    HandItemId.radish_loot_item: 11,
    HandItemId.cabbage_loot_item: 15,
    HandItemId.turnip_loot_item: 12,
    HandItemId.wheat_item: 7,
    HandItemId.pepper_loot_item: 17,
    HandItemId.cotton_loot_item: 13,
    HandItemId.onion_loot_item: 14,
    HandItemId.cauliflower_loot_item: 18,
    HandItemId.corn_loot_item: 16,
    HandItemId.tomato_loot_item: 14,
    HandItemId.grape_loot_item: 19,
    HandItemId.prickly_pear_loot_item: 23,
    HandItemId.coffee_loot_item: 30,
    HandItemId.zuchini_loot_item: 16,
    HandItemId.pumpkin_loot_item: 20,
    HandItemId.pineapple_loot_item: 33,
    HandItemId.watermelon_loot_item: 27,
    HandItemId.apple_loot_item: 24,
    HandItemId.strawberry_loot_item: 21,
    HandItemId.potato_loot_item: 10,
  };
}

/// Helpers para precificação e documentação.
class MarketPricing {
  /// Preço de venda baseado no valor do item (já ajustado pela qualidade) e um payout percentual (default 60%).
  static int getSellPriceFromHandItem(num sellValue, {double payout = 0.6}) {
    return (sellValue * payout).round();
  }
}

/// Entrada de tabela de preços para documentação/balanceamento.
class MarketPriceEntry {
  final HandItemId id;
  final int buyPrice;
  final int? sellPrice;
  final String note; // ex.: "comum", "rara", "alta margem"

  const MarketPriceEntry({
    required this.id,
    required this.buyPrice,
    this.sellPrice,
    this.note = '',
  });
}

/// Tabela usada para documentação e ajustes rápidos de preço.
class MarketPriceTable {
  MarketPriceTable._();

  static const List<MarketPriceEntry> seeds = [
    MarketPriceEntry(id: HandItemId.carrot_seed_bag, buyPrice: 15, sellPrice: 9, note: 'comum'),
    MarketPriceEntry(id: HandItemId.radish_seed_bag, buyPrice: 18, sellPrice: 11, note: 'comum'),
    MarketPriceEntry(id: HandItemId.cabbage_seed_bag, buyPrice: 25, sellPrice: 15, note: 'incomum'),
    MarketPriceEntry(id: HandItemId.turnip_seed_bag, buyPrice: 20, sellPrice: 12, note: 'comum'),
    MarketPriceEntry(id: HandItemId.wheat_seed_bag, buyPrice: 12, sellPrice: 7, note: 'comum'),
    MarketPriceEntry(id: HandItemId.pepper_seed_bag, buyPrice: 28, sellPrice: 17, note: 'incomum'),
    MarketPriceEntry(id: HandItemId.cotton_seed_bag, buyPrice: 22, sellPrice: 13, note: 'comum'),
    MarketPriceEntry(id: HandItemId.onion_seed_bag, buyPrice: 24, sellPrice: 14, note: 'comum'),
    MarketPriceEntry(id: HandItemId.cauliflower_seed_bag, buyPrice: 30, sellPrice: 18, note: 'incomum'),
    MarketPriceEntry(id: HandItemId.corn_seed_bag, buyPrice: 26, sellPrice: 16, note: 'incomum'),
    MarketPriceEntry(id: HandItemId.tomato_seed_bag, buyPrice: 24, sellPrice: 14, note: 'comum'),
    MarketPriceEntry(id: HandItemId.grape_seed_bag, buyPrice: 32, sellPrice: 19, note: 'incomum'),
    MarketPriceEntry(id: HandItemId.prickly_pear_seed_bag, buyPrice: 38, sellPrice: 23, note: 'rara'),
    MarketPriceEntry(id: HandItemId.coffee_seed_bag, buyPrice: 50, sellPrice: 30, note: 'rara'),
    MarketPriceEntry(id: HandItemId.zuchini_seed_bag, buyPrice: 27, sellPrice: 16, note: 'incomum'),
    MarketPriceEntry(id: HandItemId.pumpkin_seed_bag, buyPrice: 34, sellPrice: 20, note: 'rara'),
    MarketPriceEntry(id: HandItemId.pineapple_seed_bag, buyPrice: 55, sellPrice: 33, note: 'rara'),
    MarketPriceEntry(id: HandItemId.watermelon_seed_bag, buyPrice: 45, sellPrice: 27, note: 'rara'),
    MarketPriceEntry(id: HandItemId.apple_seed_bag, buyPrice: 40, sellPrice: 24, note: 'rara'),
    MarketPriceEntry(id: HandItemId.strawberry_seed_bag, buyPrice: 35, sellPrice: 21, note: 'incomum'),
  ];
}
