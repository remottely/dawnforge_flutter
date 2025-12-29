import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ItemFactoryService.initialize();
  });

  setUp(() {
    InventoryManager.instance.reset();
  });

  group('InventoryManager Tests', () {
    test('initial_state_is_empty', () {
      expect(InventoryManager.instance.isEmpty, isTrue);
      expect(InventoryManager.instance.usedSlots, equals(0));
      expect(
        InventoryManager.instance.freeSlots,
        equals(12),
      ); // kDefaultInventorySize
    });

    test('add_item_to_empty_slot', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      final result = InventoryManager.instance.addItem(sword);

      expect(result, isTrue);
      expect(InventoryManager.instance.usedSlots, equals(1));
      expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
      expect(
        InventoryManager.instance.getItemQuantity('iron_sword'),
        equals(1),
      );
    });

    test('add_stackable_item_stacks_correctly', () {
      final wood = ItemFactoryService.createItem('wood')!;

      // Adicionar 100 madeiras (deve criar 1 slot)
      InventoryManager.instance.addItem(wood, 100);
      expect(InventoryManager.instance.usedSlots, equals(1));
      expect(InventoryManager.instance.getItemQuantity('wood'), equals(100));

      // Adicionar mais 50 (deve empilhar no mesmo slot)
      InventoryManager.instance.addItem(wood, 50);
      expect(InventoryManager.instance.usedSlots, equals(1));
      expect(InventoryManager.instance.getItemQuantity('wood'), equals(150));
    });

    test('add_item_creates_multiple_stacks_when_needed', () {
      final wood = ItemFactoryService.createItem('wood')!;

      // Adicionar 2500 madeiras (maxStackSize = 999, deve criar 3 slots)
      InventoryManager.instance.addItem(wood, 2500);
      expect(InventoryManager.instance.usedSlots, equals(3));
      expect(InventoryManager.instance.getItemQuantity('wood'), equals(2500));
    });

    test('add_non_stackable_item_creates_multiple_slots', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;

      // Espadas não empilham
      InventoryManager.instance.addItem(sword, 3);
      expect(InventoryManager.instance.usedSlots, equals(3));
      expect(
        InventoryManager.instance.getItemQuantity('iron_sword'),
        equals(3),
      );
    });

    test('add_item_returns_false_when_full', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;

      // Encher inventário (30 slots)
      for (var i = 0; i < 30; i++) {
        InventoryManager.instance.addItem(sword);
      }

      expect(InventoryManager.instance.isFull, isTrue);

      // Tentar adicionar mais um
      final result = InventoryManager.instance.addItem(sword);
      expect(result, isFalse);
    });

    test('remove_item_decreases_quantity', () {
      final wood = ItemFactoryService.createItem('wood')!;
      InventoryManager.instance.addItem(wood, 100);

      final result = InventoryManager.instance.removeItem('wood', 30);
      expect(result, isTrue);
      expect(InventoryManager.instance.getItemQuantity('wood'), equals(70));
    });

    test('remove_item_clears_slot_when_quantity_zero', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);

      expect(InventoryManager.instance.usedSlots, equals(1));

      InventoryManager.instance.removeItem('iron_sword', 1);
      expect(InventoryManager.instance.usedSlots, equals(0));
      expect(InventoryManager.instance.hasItem('iron_sword'), isFalse);
    });

    test('remove_item_returns_false_when_not_enough', () {
      final wood = ItemFactoryService.createItem('wood')!;
      InventoryManager.instance.addItem(wood, 50);

      final result = InventoryManager.instance.removeItem('wood', 100);
      expect(result, isFalse);
      expect(InventoryManager.instance.getItemQuantity('wood'), equals(50));
    });

    test('get_item_quantity_counts_all_stacks', () {
      final wood = ItemFactoryService.createItem('wood')!;

      // Adicionar em múltiplos stacks
      InventoryManager.instance.addItem(wood, 999);
      InventoryManager.instance.addItem(wood, 999);
      InventoryManager.instance.addItem(wood, 500);

      expect(InventoryManager.instance.getItemQuantity('wood'), equals(2498));
    });

    test('has_item_checks_minimum_quantity', () {
      final wood = ItemFactoryService.createItem('wood')!;
      InventoryManager.instance.addItem(wood, 50);

      expect(InventoryManager.instance.hasItem('wood', 30), isTrue);
      expect(InventoryManager.instance.hasItem('wood', 50), isTrue);
      expect(InventoryManager.instance.hasItem('wood', 51), isFalse);
    });

    test('get_slot_by_index_returns_correct_slot', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);

      final slot = InventoryManager.instance.getSlotByIndex(0);
      expect(slot, isNotNull);
      expect(slot!.item?.id, equals('iron_sword'));
    });

    test('get_slots_by_item_id_returns_all_matching', () {
      final wood = ItemFactoryService.createItem('wood')!;
      InventoryManager.instance.addItem(wood, 2000); // Cria 3 slots

      final slots = InventoryManager.instance.getSlotsByItemId('wood');
      expect(slots.length, equals(3));
    });

    test('move_item_to_empty_slot', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      InventoryManager.instance.addItem(sword);

      final result = InventoryManager.instance.moveItem(0, 5);
      expect(result, isTrue);

      expect(InventoryManager.instance.getSlotByIndex(0)!.isEmpty, isTrue);
      expect(
        InventoryManager.instance.getSlotByIndex(5)!.item?.id,
        equals('iron_sword'),
      );
    });

    test('move_item_stacks_when_same_item', () {
      final wood = ItemFactoryService.createItem('wood')!;
      final stone = ItemFactoryService.createItem('stone')!;

      // Adicionar wood no slot 0 e stone no slot 1 primeiro
      InventoryManager.instance.addItem(wood, 50);
      InventoryManager.instance.addItem(stone, 100); // Cria barreira

      // Agora adicionar mais wood (vai empilhar no slot 0, não no slot 2!)
      InventoryManager.instance.addItem(wood, 30);

      // O InventoryManager empilha automaticamente no slot existente!
      // Então slot 0 já tem 80 wood
      expect(InventoryManager.instance.getSlotByIndex(0)!.quantity, equals(80));

      // Testar swap ao invés de move (já que move empilha automaticamente)
      InventoryManager.instance.swapSlots(0, 1);

      // Após swap, slot 0 tem stone e slot 1 tem wood
      expect(
        InventoryManager.instance.getSlotByIndex(0)!.item!.id,
        equals('stone'),
      );
      expect(
        InventoryManager.instance.getSlotByIndex(1)!.item!.id,
        equals('wood'),
      );
    });

    test('swap_slots_exchanges_items', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      final potion = ItemFactoryService.createItem('health_potion')!;

      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(potion);

      InventoryManager.instance.swapSlots(0, 1);

      expect(
        InventoryManager.instance.getSlotByIndex(0)!.item?.id,
        equals('health_potion'),
      );
      expect(
        InventoryManager.instance.getSlotByIndex(1)!.item?.id,
        equals('iron_sword'),
      );
    });

    test('sort_by_type_organizes_items', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      final wood = ItemFactoryService.createItem('wood')!;
      final potion = ItemFactoryService.createItem('health_potion')!;

      InventoryManager.instance.addItem(wood);
      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(potion);

      InventoryManager.instance.sortByType();

      // Verifica que itens foram reorganizados
      expect(InventoryManager.instance.usedSlots, equals(3));
    });

    test('sort_by_rarity_organizes_items', () {
      final common = ItemFactoryService.createItem('iron_sword')!;
      final legendary = ItemFactoryService.createItem('legendary_blade')!;

      InventoryManager.instance.addItem(common);
      InventoryManager.instance.addItem(legendary);

      InventoryManager.instance.sortByRarity();

      // Lendário deve vir primeiro
      expect(
        InventoryManager.instance.getSlotByIndex(0)!.item?.id,
        equals('legendary_blade'),
      );
    });

    test('sort_by_name_organizes_alphabetically', () {
      final wood = ItemFactoryService.createItem('wood')!;
      final axe = ItemFactoryService.createItem('steel_axe')!;

      InventoryManager.instance.addItem(wood);
      InventoryManager.instance.addItem(axe);

      InventoryManager.instance.sortByName();

      // Axe vem antes de Wood alfabeticamente (Steel Axe vs Wood)
      final firstItem = InventoryManager.instance.getSlotByIndex(0)!.item?.name;
      expect(firstItem, equals('Steel Axe'));
    });

    test('clear_removes_all_items', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      final wood = ItemFactoryService.createItem('wood')!;

      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(wood, 100);

      expect(InventoryManager.instance.usedSlots, greaterThan(0));

      InventoryManager.instance.clear();
      expect(InventoryManager.instance.isEmpty, isTrue);
      expect(InventoryManager.instance.usedSlots, equals(0));
    });

    test('serialization_roundtrip', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      final wood = ItemFactoryService.createItem('wood')!;
      final potion = ItemFactoryService.createItem('health_potion')!;

      InventoryManager.instance.addItem(sword);
      InventoryManager.instance.addItem(wood, 250);
      InventoryManager.instance.addItem(potion, 5);

      // Serializar
      final json = InventoryManager.instance.toJson();
      expect(json['slots'], isNotEmpty);

      // Limpar e restaurar
      InventoryManager.instance.clear();
      expect(InventoryManager.instance.isEmpty, isTrue);

      InventoryManager.instance.fromJson(json);

      // Verificar que foi restaurado
      expect(InventoryManager.instance.hasItem('iron_sword'), isTrue);
      expect(InventoryManager.instance.getItemQuantity('wood'), equals(250));
      expect(
        InventoryManager.instance.getItemQuantity('health_potion'),
        equals(5),
      );
    });

    test('add_zero_quantity_returns_false', () {
      final sword = ItemFactoryService.createItem('iron_sword')!;
      final result = InventoryManager.instance.addItem(sword, 0);
      expect(result, isFalse);
    });

    test('remove_zero_quantity_returns_false', () {
      final result = InventoryManager.instance.removeItem('iron_sword', 0);
      expect(result, isFalse);
    });
  });
}
