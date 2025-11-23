import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ItemFactory.initialize();
  });

  setUp(() {
    InventoryManager.instance.reset();
    EquipmentManager.instance.reset();
  });

  group('EquipmentManager Tests', () {
    test('initial_state_all_slots_empty', () {
      for (final slotType in EquipmentSlotType.values) {
        expect(EquipmentManager.instance.isSlotOccupied(slotType), isFalse);
        expect(EquipmentManager.instance.getEquippedItem(slotType), isNull);
      }
    });

    test('equip_weapon_success', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);

      final result = EquipmentManager.instance.equip(
        EquipmentSlotType.weapon,
        sword,
      );

      expect(result, isTrue);
      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isTrue,
      );
      expect(
        EquipmentManager.instance.getEquippedItem(EquipmentSlotType.weapon),
        equals(sword),
      );
      expect(InventoryManager.instance.hasItem('iron_sword'), isFalse);
    });

    test('equip_returns_false_when_item_not_in_inventory', () {
      final sword = ItemFactory.createItem('iron_sword')!;

      final result = EquipmentManager.instance.equip(
        EquipmentSlotType.weapon,
        sword,
      );

      expect(result, isFalse);
      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isFalse,
      );
    });

    test('equip_returns_false_for_wrong_slot_type', () {
      final wood = ItemFactory.createItem('wood')!;
      InventoryManager.instance.addItem(wood);

      final result = EquipmentManager.instance.equip(
        EquipmentSlotType.weapon,
        wood,
      );

      expect(result, isFalse);
      expect(InventoryManager.instance.hasItem('wood'), isTrue);
    });

    test('equip_replaces_existing_item', () {
      final sword1 = ItemFactory.createItem('iron_sword')!;
      final sword2 = ItemFactory.createItem('steel_axe')!;

      InventoryManager.instance.addItem(sword1);
      InventoryManager.instance.addItem(sword2);

      // Equipar primeira espada
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword1);
      expect(
        EquipmentManager.instance.getEquippedItem(EquipmentSlotType.weapon)?.id,
        equals('iron_sword'),
      );

      // Equipar segunda espada (deve trocar)
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword2);
      expect(
        EquipmentManager.instance.getEquippedItem(EquipmentSlotType.weapon)?.id,
        equals('steel_axe'),
      );
      expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
      expect(InventoryManager.instance.hasItem('steel_axe'), isFalse);
    });

    test('unequip_returns_item_to_inventory', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);

      final unequippedItem = EquipmentManager.instance.unequip(
        EquipmentSlotType.weapon,
      );

      expect(unequippedItem, isNotNull);
      expect(unequippedItem?.id, equals('iron_sword'));
      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isFalse,
      );
      expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
    });

    test('unequip_returns_null_when_slot_empty', () {
      final result = EquipmentManager.instance.unequip(
        EquipmentSlotType.weapon,
      );
      expect(result, isNull);
    });

    test('unequip_returns_null_when_inventory_full', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      final stone = ItemFactory.createItem('stone')!;

      // Equipar espada primeiro
      InventoryManager.instance.addItem(sword);
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);

      // Encher inventário com itens empilháveis
      for (var i = 0; i < 30; i++) {
        InventoryManager.instance.addItem(stone, 999);
      }

      // Tentar desequipar (inventário cheio)
      final result = EquipmentManager.instance.unequip(
        EquipmentSlotType.weapon,
      );
      expect(result, isNull);
      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isTrue,
      );
    });

    test('get_all_equipped_items_returns_all', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      final axe = ItemFactory.createItem('steel_axe')!;

      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(axe);

      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);
      EquipmentManager.instance.equip(EquipmentSlotType.offhand, axe);

      final equipped = EquipmentManager.instance.getAllEquippedItems();
      expect(equipped.length, equals(2));
      expect(equipped.any((item) => item.id == 'iron_sword'), isTrue);
      expect(equipped.any((item) => item.id == 'steel_axe'), isTrue);
    });

    test('get_total_damage_sums_weapons', () {
      final sword = ItemFactory.createItem('iron_sword')! as WeaponItem;

      InventoryManager.instance.addItem(sword);
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);

      final totalDamage = EquipmentManager.instance.getTotalDamage();
      expect(totalDamage, equals(sword.damage));
    });

    test('get_total_dps_sums_weapons', () {
      final sword = ItemFactory.createItem('iron_sword')! as WeaponItem;

      InventoryManager.instance.addItem(sword);
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);

      final totalDps = EquipmentManager.instance.getTotalDps();
      expect(totalDps, closeTo(sword.dps, 0.1));
    });

    test('get_total_stats_returns_all_stats', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);

      final stats = EquipmentManager.instance.getTotalStats();
      expect(stats['damage'], greaterThan(0));
      expect(stats['dps'], greaterThan(0));
      expect(stats['defense'], equals(0)); // Não há armadura ainda
    });

    test('unequip_all_moves_all_items_to_inventory', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      final axe = ItemFactory.createItem('steel_axe')!;

      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(axe);

      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);
      EquipmentManager.instance.equip(EquipmentSlotType.offhand, axe);

      final result = EquipmentManager.instance.unequipAll();
      expect(result, isTrue);

      expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);
      expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
      expect(InventoryManager.instance.hasItem('steel_axe'), isTrue);
    });

    test('unequip_all_fails_when_inventory_full', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      final stone = ItemFactory.createItem('stone')!;

      // Equipar espada
      InventoryManager.instance.addItem(sword);
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);

      // Encher inventário completamente
      for (var i = 0; i < 30; i++) {
        InventoryManager.instance.addItem(stone, 999);
      }

      final result = EquipmentManager.instance.unequipAll();
      expect(result, isFalse);
      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isTrue,
      );
    });

    test('serialization_roundtrip', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      final axe = ItemFactory.createItem('steel_axe')!;

      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(axe);

      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);
      EquipmentManager.instance.equip(EquipmentSlotType.offhand, axe);

      // Serializar
      final json = EquipmentManager.instance.toJson();
      expect(json['equipmentSlots'], isNotEmpty);

      // Resetar e restaurar
      EquipmentManager.instance.reset();
      expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);

      EquipmentManager.instance.fromJson(json);

      // Verificar que foi restaurado
      expect(
        EquipmentManager.instance.getEquippedItem(EquipmentSlotType.weapon)?.id,
        equals('iron_sword'),
      );
      expect(
        EquipmentManager.instance
            .getEquippedItem(EquipmentSlotType.offhand)
            ?.id,
        equals('steel_axe'),
      );
    });

    test('weapon_can_be_equipped_in_weapon_slot', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);

      final result = EquipmentManager.instance.equip(
        EquipmentSlotType.weapon,
        sword,
      );
      expect(result, isTrue);
    });

    test('weapon_can_be_equipped_in_offhand_slot', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);

      final result = EquipmentManager.instance.equip(
        EquipmentSlotType.offhand,
        sword,
      );
      expect(result, isTrue);
    });

    test('dual_wield_weapons', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      final axe = ItemFactory.createItem('steel_axe')!;

      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(axe);

      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);
      EquipmentManager.instance.equip(EquipmentSlotType.offhand, axe);

      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isTrue,
      );
      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.offhand),
        isTrue,
      );

      final totalDamage = EquipmentManager.instance.getTotalDamage();
      expect(totalDamage, greaterThan((sword as WeaponItem).damage));
    });

    test('reset_clears_all_equipment', () {
      final sword = ItemFactory.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);
      EquipmentManager.instance.equip(EquipmentSlotType.weapon, sword);

      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isTrue,
      );

      EquipmentManager.instance.reset();

      expect(
        EquipmentManager.instance.isSlotOccupied(EquipmentSlotType.weapon),
        isFalse,
      );
      expect(EquipmentManager.instance.getAllEquippedItems().isEmpty, isTrue);
    });
  });
}
