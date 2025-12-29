import 'package:darkness_dungeon/gameplay/inventory/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/consumable_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/seed_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/services/item_factory_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await getIt<ItemFactoryService>().initialize();
  });

  tearDown(() {
    // Factory permanece inicializado entre testes
  });

  group('getIt<ItemFactoryService>() Tests', () {
    test('initialize_loads_database', () {
      expect(getIt<ItemFactoryService>().isInitialized, isTrue);
    });

    test('create_weapon_item_returns_correct_type', () {
      final item = getIt<ItemFactoryService>().createItem('iron_sword');

      expect(item, isNotNull);
      expect(item, isA<MainHandItem>());
      expect(item!.id, equals('iron_sword'));
      expect(item.name, equals('Iron Sword'));
      expect((item as MainHandItem).damage, equals(15));
    });

    test('create_tool_item_returns_correct_type', () {
      final item = getIt<ItemFactoryService>().createItem('iron_pickaxe');

      expect(item, isNotNull);
      expect(item, isA<ToolItem>());
      expect(item!.id, equals('iron_pickaxe'));
      expect((item as ToolItem).toolType, equals('pickaxe'));
    });

    test('create_consumable_item_returns_correct_type', () {
      final item = getIt<ItemFactoryService>().createItem('health_potion');

      expect(item, isNotNull);
      expect(item, isA<ConsumableItem>());
      expect(item!.id, equals('health_potion'));
      expect((item as ConsumableItem).healthRestore, equals(50));
    });

    test('create_material_item_returns_correct_type', () {
      final item = getIt<ItemFactoryService>().createItem('wood');

      expect(item, isNotNull);
      expect(item, isA<MaterialItem>());
      expect(item!.id, equals('wood'));
      expect((item as MaterialItem).materialType, equals('wood'));
      expect(item.isStackable, isTrue);
    });

    test('create_seed_item_returns_correct_type', () {
      final item =
          getIt<ItemFactoryService>().createItem('carrot_seeds') as SeedItem?;

      expect(item, isNotNull);
      expect(item, isA<SeedItem>());
      expect(item!.id, equals('carrot_seeds'));
      expect(item.cropId, equals('carrot'));
      expect(item.growthTime, equals(4));
    });

    test('create_item_returns_null_for_invalid_id', () {
      final item = getIt<ItemFactoryService>().createItem('invalid_item_id');
      expect(item, isNull);
    });

    test('get_all_item_ids_returns_all', () {
      final allIds = getIt<ItemFactoryService>().getAllItemIds();
      expect(allIds, isNotEmpty);
      expect(allIds, contains('iron_sword'));
      expect(allIds, contains('health_potion'));
      expect(allIds, contains('wood'));
    });

    test('create_items_creates_multiple_items', () {
      final items = getIt<ItemFactoryService>().createItems([
        'iron_sword',
        'health_potion',
        'wood',
        'invalid_item', // Deve ser ignorado
      ]);

      expect(items.length, equals(3));
      expect(items[0], isA<MainHandItem>());
      expect(items[1], isA<ConsumableItem>());
      expect(items[2], isA<MaterialItem>());
    });

    test('legendary_item_has_high_sell_value', () {
      final item = getIt<ItemFactoryService>().createItem('legendary_blade');

      expect(item, isNotNull);
      expect(item, isA<MainHandItem>());
      expect(item!.sellValue, greaterThan(item.baseValue));
    });

    test('seed_can_plant_in_season', () {
      final carrotSeeds =
          getIt<ItemFactoryService>().createItem('carrot_seeds') as SeedItem?;
      expect(carrotSeeds, isNotNull);
      expect(carrotSeeds!.canPlantInSeason('spring'), isTrue);
      expect(carrotSeeds.canPlantInSeason('summer'), isTrue);
      expect(carrotSeeds.canPlantInSeason('any'), isTrue);

      final wheatSeeds =
          getIt<ItemFactoryService>().createItem('wheat_seeds') as SeedItem?;
      expect(wheatSeeds, isNotNull);
      expect(wheatSeeds!.canPlantInSeason('spring'), isTrue);
      expect(wheatSeeds.canPlantInSeason('summer'), isFalse);
    });

    test('weapon_dps_calculation', () {
      final sword =
          getIt<ItemFactoryService>().createItem('iron_sword') as MainHandItem?;
      expect(sword, isNotNull);
      expect(sword!.dps, greaterThan(sword.damage.toDouble()));

      final axe =
          getIt<ItemFactoryService>().createItem('steel_axe') as MainHandItem?;
      expect(axe, isNotNull);
      // Machado tem mais dano mas menos velocidade
      expect(axe!.damage, greaterThan(sword.damage));
    });
  });
}
