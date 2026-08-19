import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_type.dart';
import 'package:dawnforge/game/features/inventory/items/seed_bag_item.dart';
import 'package:dawnforge/game/features/inventory/items/tool_item.dart';
import 'package:dawnforge/game/features/inventory/services/item_factory_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/manager_reset.dart';

void main() {
  late ItemFactoryService factory;

  setUp(() async {
    await resetAllManagers();
    factory = ItemFactoryService.instance;
  });

  group('ItemFactoryService', () {
    test('is initialized by the bootstrap', () {
      expect(factory.isInitialized, isTrue);
    });

    test('initializing twice is a no-op', () async {
      final before = factory.getAllItemIds().length;

      await factory.initialize();

      expect(factory.getAllItemIds().length, before);
    });

    group('createItem', () {
      test('creates a tool', () {
        final item = factory.createItem(HandItemId.shovel);

        expect(item, isA<ToolItem>());
        expect(item!.type, HandItemType.tool);
      });

      test('creates a seed bag', () {
        final item = factory.createItem(HandItemId.radish_seed_bag);

        expect(item, isA<SeedBagItem>());
        expect(item!.type, HandItemType.cropSeed);
      });

      test('an unknown id → null', () {
        expect(factory.createItem(HandItemId.unknown), isNull);
      });

      test('each call returns an independent copy', () {
        final first = factory.createItem(HandItemId.shovel)!;
        final second = factory.createItem(HandItemId.shovel)!;

        expect(identical(first, second), isFalse);
        expect(first.id, second.id);
      });

      test('tools are not stackable', () {
        expect(factory.createItem(HandItemId.shovel)!.isStackable, isFalse);
      });

      test('seed bags are stackable', () {
        expect(
          factory.createItem(HandItemId.radish_seed_bag)!.isStackable,
          isTrue,
        );
      });
    });

    group('createItems', () {
      test('creates every valid id and drops the invalid ones', () {
        final items = factory.createItems([
          HandItemId.shovel,
          HandItemId.unknown,
          HandItemId.wateringCan,
        ]);

        expect(items.length, 2);
      });

      test('an empty list → empty result', () {
        expect(factory.createItems([]), isEmpty);
      });
    });

    group('catalogue access', () {
      test('exposes the registered item ids without duplicates', () {
        final ids = factory.getAllItemIds();

        expect(ids, isNotEmpty);
        expect(ids.toSet().length, ids.length);
      });

      test('hasItem recognises a registered item by name', () {
        expect(factory.hasItem('shovel'), isTrue);
      });

      test('hasItem on an unregistered name → false', () {
        expect(factory.hasItem('lightsaber'), isFalse);
      });

      test('every id reported by the catalogue can be created', () {
        for (final id in factory.getAllItemIds()) {
          expect(factory.createItem(id), isNotNull, reason: '$id');
        }
      });
    });

    group('seed bags', () {
      test('every seed bag points at a crop', () {
        final seedBags = factory
            .getAllItemIds()
            .map(factory.createItem)
            .whereType<SeedBagItem>();

        expect(seedBags, isNotEmpty);
        for (final seed in seedBags) {
          expect(seed.cropId, isNot(HandItemId.unknown), reason: '${seed.id}');
        }
      });

      test('a seed with SeasonType.any can be planted in any season', () {
        final seed =
            factory.createItem(HandItemId.radish_seed_bag)! as SeedBagItem;

        if (seed.requiredSeason.name == 'any') {
          expect(seed.canPlantInSeason(seed.requiredSeason), isTrue);
        }
      });
    });
  });
}
