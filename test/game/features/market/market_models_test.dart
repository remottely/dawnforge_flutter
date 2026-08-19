import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/market/market_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketItem', () {
    test('a seed bag entry is recognised as a seed', () {
      const item = MarketItem(
        itemId: HandItemId.radish_seed_bag,
        buyPrice: 18,
        sellPrice: 11,
      );

      expect(item.isSeed, isTrue);
    });

    test('a loot entry is not a seed', () {
      const item = MarketItem(
        itemId: HandItemId.radish_loot_item,
        buyPrice: 11,
        category: 'loot',
      );

      expect(item.isSeed, isFalse);
    });

    test('an entry without a sell price cannot be sold', () {
      const item = MarketItem(itemId: HandItemId.wood, buyPrice: 5);

      expect(item.isSellable, isFalse);
    });

    test('an entry with a sell price can be sold', () {
      const item = MarketItem(
        itemId: HandItemId.wood,
        buyPrice: 5,
        sellPrice: 3,
      );

      expect(item.isSellable, isTrue);
    });

    test('defaults to available in the seeds category', () {
      const item = MarketItem(itemId: HandItemId.wood, buyPrice: 5);

      expect(item.isAvailable, isTrue);
      expect(item.category, 'seeds');
    });
  });

  group('MarketCatalog', () {
    test('the catalog is not empty', () {
      expect(MarketCatalog.seeds, isNotEmpty);
    });

    test('every entry has a positive buy price', () {
      for (final item in MarketCatalog.seeds) {
        expect(item.buyPrice, greaterThan(0), reason: '${item.itemId}');
      }
    });

    test('selling never pays more than buying — no arbitrage loop', () {
      for (final item in MarketCatalog.seeds) {
        if (item.sellPrice == null) continue;

        expect(
          item.sellPrice,
          lessThan(item.buyPrice),
          reason: '${item.itemId} could be farmed for infinite money',
        );
      }
    });

    test('no item id appears twice in the catalog', () {
      final ids = MarketCatalog.seeds.map((item) => item.itemId).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('byId indexes every catalog entry', () {
      for (final item in MarketCatalog.seeds) {
        expect(MarketCatalog.byId[item.itemId], isNotNull);
      }
      expect(MarketCatalog.byId.length, MarketCatalog.seeds.length);
    });

    test('byId lookup of an unlisted item → null', () {
      expect(MarketCatalog.byId[HandItemId.unknown], isNull);
    });

    test('every harvest loot sell price is positive', () {
      for (final entry in MarketCatalog.harvestLootSellPrice.entries) {
        expect(entry.value, greaterThan(0), reason: '${entry.key}');
      }
    });

    test('the loot price table has no unknown ids', () {
      expect(
        MarketCatalog.harvestLootSellPrice.containsKey(HandItemId.unknown),
        isFalse,
      );
    });
  });

  group('MarketPricing', () {
    test('applies the default 60% payout', () {
      expect(MarketPricing.getSellPriceFromHandItem(100), 60);
    });

    test('honours an explicit payout', () {
      expect(MarketPricing.getSellPriceFromHandItem(100, payout: 0.5), 50);
    });

    test('rounds to the nearest coin', () {
      expect(MarketPricing.getSellPriceFromHandItem(10, payout: 0.55), 6);
    });

    test('a worthless item sells for nothing', () {
      expect(MarketPricing.getSellPriceFromHandItem(0), 0);
    });
  });

  group('MarketPriceTable', () {
    test('every documented entry has a positive buy price', () {
      for (final entry in MarketPriceTable.seeds) {
        expect(entry.buyPrice, greaterThan(0), reason: '${entry.id}');
      }
    });

    test('documented sell prices stay below the buy price', () {
      for (final entry in MarketPriceTable.seeds) {
        if (entry.sellPrice == null) continue;

        expect(
          entry.sellPrice,
          lessThan(entry.buyPrice),
          reason: '${entry.id}',
        );
      }
    });

    // O catálogo ativo (`MarketCatalog.seeds`) tem a maior parte das entradas
    // comentada, enquanto `MarketPriceTable` mantém a tabela completa de
    // balanceamento. Onde as duas coincidem, os preços precisam bater — senão
    // o que o jogador paga diverge do que foi balanceado.
    test('prices agree with the price table where both list the item', () {
      final documented = {
        for (final entry in MarketPriceTable.seeds) entry.id: entry,
      };

      for (final item in MarketCatalog.seeds) {
        final entry = documented[item.itemId];
        if (entry == null) continue;

        expect(
          item.buyPrice,
          entry.buyPrice,
          reason: '${item.itemId} buy price drifted from the price table',
        );
        expect(
          item.sellPrice,
          entry.sellPrice,
          reason: '${item.itemId} sell price drifted from the price table',
        );
      }
    });
  });

  group('MarketTransactionError', () {
    test('covers the failure modes a transaction can hit', () {
      expect(
        MarketTransactionError.values,
        containsAll([
          MarketTransactionError.insufficientFunds,
          MarketTransactionError.inventoryFull,
          MarketTransactionError.itemUnavailable,
          MarketTransactionError.notTradeable,
        ]),
      );
    });
  });

  group('MarketTransactionType', () {
    test('has exactly buy and sell', () {
      expect(MarketTransactionType.values, [
        MarketTransactionType.buy,
        MarketTransactionType.sell,
      ]);
    });
  });
}
