import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/consumable_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/material_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/seed_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/tool_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ItemFactory.initialize();
  });

  tearDown(() {
    // Factory permanece inicializado entre testes
  });

  group('ItemFactory Tests', () {
    test('initialize_loads_database', () {
      expect(ItemFactory.isInitialized, isTrue);
      expect(ItemFactory.itemCount, greaterThan(0));
    });

    test('create_weapon_item_returns_correct_type', () {
      final item = ItemFactory.createItem('iron_sword');

      expect(item, isNotNull);
      expect(item, isA<WeaponItem>());
      expect(item!.id, equals('iron_sword'));
      expect(item.name, equals('Iron Sword'));
      expect((item as WeaponItem).damage, equals(15));
    });

    test('create_tool_item_returns_correct_type', () {
      final item = ItemFactory.createItem('iron_pickaxe');

      expect(item, isNotNull);
      expect(item, isA<ToolItem>());
      expect(item!.id, equals('iron_pickaxe'));
      expect((item as ToolItem).toolType, equals('pickaxe'));
      expect(item.maxDurability, equals(100));
    });

    test('create_consumable_item_returns_correct_type', () {
      final item = ItemFactory.createItem('health_potion');

      expect(item, isNotNull);
      expect(item, isA<ConsumableItem>());
      expect(item!.id, equals('health_potion'));
      expect((item as ConsumableItem).healthRestore, equals(50));
    });

    test('create_material_item_returns_correct_type', () {
      final item = ItemFactory.createItem('wood');

      expect(item, isNotNull);
      expect(item, isA<MaterialItem>());
      expect(item!.id, equals('wood'));
      expect((item as MaterialItem).materialType, equals('wood'));
      expect(item.isStackable, isTrue);
    });

    test('create_seed_item_returns_correct_type', () {
      final item = ItemFactory.createItem('carrot_seeds');

      expect(item, isNotNull);
      expect(item, isA<SeedItem>());
      expect(item!.id, equals('carrot_seeds'));
      expect((item as SeedItem).cropId, equals('carrot'));
      expect(item.growthTime, equals(4));
    });

    test('create_item_returns_null_for_invalid_id', () {
      final item = ItemFactory.createItem('invalid_item_id');
      expect(item, isNull);
    });

    test('get_all_item_ids_returns_all', () {
      final allIds = ItemFactory.getAllItemIds();
      expect(allIds, isNotEmpty);
      expect(allIds, contains('iron_sword'));
      expect(allIds, contains('health_potion'));
      expect(allIds, contains('wood'));
    });

    test('get_item_ids_by_type_filters_correctly', () {
      final weaponIds = ItemFactory.getItemIdsByType(ItemType.weapon);
      expect(weaponIds, isNotEmpty);
      expect(weaponIds, contains('iron_sword'));
      expect(weaponIds, contains('steel_axe'));

      final toolIds = ItemFactory.getItemIdsByType(ItemType.tool);
      expect(toolIds, isNotEmpty);
      expect(toolIds, contains('iron_pickaxe'));

      final materialIds = ItemFactory.getItemIdsByType(ItemType.material);
      expect(materialIds, isNotEmpty);
      expect(materialIds, contains('wood'));
      expect(materialIds, contains('stone'));
    });

    test('item_exists_returns_correct_value', () {
      expect(ItemFactory.itemExists('iron_sword'), isTrue);
      expect(ItemFactory.itemExists('invalid_item'), isFalse);
    });

    test('create_items_creates_multiple_items', () {
      final items = ItemFactory.createItems([
        'iron_sword',
        'health_potion',
        'wood',
        'invalid_item', // Deve ser ignorado
      ]);

      expect(items.length, equals(3));
      expect(items[0], isA<WeaponItem>());
      expect(items[1], isA<ConsumableItem>());
      expect(items[2], isA<MaterialItem>());
    });

    test('legendary_item_has_high_sell_value', () {
      final item = ItemFactory.createItem('legendary_blade');

      expect(item, isNotNull);
      expect(item, isA<WeaponItem>());
      expect(item!.sellValue, greaterThan(item.baseValue));
    });

    test('seed_can_plant_in_season', () {
      final carrotSeeds = ItemFactory.createItem('carrot_seeds') as SeedItem?;
      expect(carrotSeeds, isNotNull);
      expect(carrotSeeds!.canPlantInSeason('spring'), isTrue);
      expect(carrotSeeds.canPlantInSeason('summer'), isTrue);
      expect(carrotSeeds.canPlantInSeason('any'), isTrue);

      final wheatSeeds = ItemFactory.createItem('wheat_seeds') as SeedItem?;
      expect(wheatSeeds, isNotNull);
      expect(wheatSeeds!.canPlantInSeason('spring'), isTrue);
      expect(wheatSeeds.canPlantInSeason('summer'), isFalse);
    });

    test('tool_durability_mechanics', () {
      final pickaxe = ItemFactory.createItem('iron_pickaxe') as ToolItem?;
      expect(pickaxe, isNotNull);
      expect(pickaxe!.isBroken, isFalse);
      expect(pickaxe.durabilityPercent, equals(1.0));

      final usedPickaxe = pickaxe.use(50);
      expect(usedPickaxe.durability, equals(50));
      expect(usedPickaxe.durabilityPercent, equals(0.5));
      expect(usedPickaxe.isBroken, isFalse);

      final brokenPickaxe = usedPickaxe.use(100);
      expect(brokenPickaxe.durability, equals(0));
      expect(brokenPickaxe.isBroken, isTrue);
    });

    test('weapon_dps_calculation', () {
      final sword = ItemFactory.createItem('iron_sword') as WeaponItem?;
      expect(sword, isNotNull);
      expect(sword!.dps, greaterThan(sword.damage.toDouble()));

      final axe = ItemFactory.createItem('steel_axe') as WeaponItem?;
      expect(axe, isNotNull);
      // Machado tem mais dano mas menos velocidade
      expect(axe!.damage, greaterThan(sword.damage));
    });
  });
}
