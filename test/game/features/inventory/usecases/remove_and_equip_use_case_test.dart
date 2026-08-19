import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/services/item_factory_service.dart';
import 'package:dawnforge/game/features/inventory/state/equipment_state.dart';
import 'package:dawnforge/game/features/inventory/usecases/add_item_use_case.dart';
import 'package:dawnforge/game/features/inventory/usecases/equip_item_use_case.dart';
import 'package:dawnforge/game/features/inventory/usecases/load_inventory_use_case.dart';
import 'package:dawnforge/game/features/inventory/usecases/remove_item_use_case.dart';
import 'package:dawnforge/game/features/inventory/usecases/save_inventory_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/manager_reset.dart';
import '../../../../helpers/test_data_builders.dart';

void main() {
  late InventoryManager inventory;
  late EquipmentManager equipment;
  late AddItemUseCase addItem;
  late RemoveItemUseCase removeItem;

  setUp(() async {
    await resetAllManagers();
    inventory = InventoryManager.instance;
    equipment = EquipmentManager.instance;
    addItem = AddItemUseCase(inventory, ItemFactoryService.instance);
    removeItem = RemoveItemUseCase(inventory);
  });

  group('RemoveItemUseCase', () {
    test('removes the requested amount', () {
      addItem.addItemEntity(anItem(id: HandItemId.wood), 10);

      final removed = removeItem.call(HandItemId.wood, 4);

      expect(removed, isTrue);
      expect(inventory.getItemQuantity('wood'), 6);
    });

    test('removing everything frees the slot', () {
      addItem.addItemEntity(anItem(id: HandItemId.wood), 5);

      removeItem.call(HandItemId.wood, 5);

      expect(inventory.getItemQuantity('wood'), 0);
      expect(inventory.isEmpty, isTrue);
    });

    test('not enough items → false and nothing is removed', () {
      addItem.addItemEntity(anItem(id: HandItemId.wood), 3);

      final removed = removeItem.call(HandItemId.wood, 10);

      expect(removed, isFalse);
      expect(inventory.getItemQuantity('wood'), 3);
    });

    test('item not in the inventory → false', () {
      expect(removeItem.call(HandItemId.wood, 1), isFalse);
    });

    test('non-positive quantity → false', () {
      addItem.addItemEntity(anItem(id: HandItemId.wood), 5);

      expect(removeItem.call(HandItemId.wood, 0), isFalse);
      expect(removeItem.call(HandItemId.wood, -1), isFalse);
      expect(inventory.getItemQuantity('wood'), 5);
    });

    test('drains across several slots, consuming the last ones first', () {
      final wood = anItem(id: HandItemId.wood, maxStackSize: 10);
      addItem.addItemEntity(wood, 25); // slots 0,1 cheios; slot 2 com 5

      removeItem.call(HandItemId.wood, 5);

      expect(inventory.getItemQuantity('wood'), 20);
      expect(inventory.getSlotByIndex(2)!.isEmpty, isTrue);
      expect(inventory.getSlotByIndex(0)!.quantity, 10);
    });

    group('removeAll', () {
      test('drops every unit of the item', () {
        addItem.addItemEntity(
          anItem(id: HandItemId.wood, maxStackSize: 10),
          25,
        );

        final removed = removeItem.removeAll(HandItemId.wood);

        expect(removed, isTrue);
        expect(inventory.getItemQuantity('wood'), 0);
      });

      test('absent item → false', () {
        expect(removeItem.removeAll(HandItemId.wood), isFalse);
      });
    });
  });

  group('EquipItemUseCase', () {
    late EquipItemUseCase useCase;

    setUp(() {
      useCase = EquipItemUseCase(equipment, inventory);
    });

    test('equipping an owned item selects its slot', () {
      addItem.call(HandItemId.shovel, 1);

      final equipped = useCase.call('shovel');

      expect(equipped, isTrue);
      expect(equipment.getEquippedItem()?.id, HandItemId.shovel);
    });

    test('equipping an item the player does not have → false', () {
      expect(useCase.call('shovel'), isFalse);
    });

    test('selectSlotIndex on a valid slot succeeds even if empty', () {
      expect(useCase.selectSlotIndex(3), isTrue);
      expect(equipment.currentMainHandSlotIndex, 3);
    });

    test('selectSlotIndex beyond the inventory → false', () {
      expect(useCase.selectSlotIndex(999), isFalse);
    });

    group('equipItemEntity', () {
      test('an explicit slot index wins over lookup', () {
        addItem.call(HandItemId.shovel, 1);

        final equipped = useCase.equipItemEntity(anItem(), 5);

        expect(equipped, isTrue);
        expect(equipment.currentMainHandSlotIndex, 5);
      });

      test('without an index, the item is looked up in the inventory', () {
        addItem.call(HandItemId.shovel, 1);
        final shovel = inventory.getSlotByIndex(0)!.item!;

        expect(useCase.equipItemEntity(shovel, null), isTrue);
      });

      test('item not in the inventory and no index → false', () {
        expect(useCase.equipItemEntity(anItem(), null), isFalse);
      });
    });
  });

  group('EquipmentManager', () {
    test('starts on slot 0 with nothing equipped', () {
      expect(equipment.currentMainHandSlotIndex, 0);
      expect(equipment.hasEquippedItem(), isFalse);
    });

    test('selecting a slot publishes the item to the overlay state', () {
      addItem.call(HandItemId.shovel, 1);

      equipment.selectSlotIndex(0);

      expect(EquipmentState.instance.getItem()?.id, HandItemId.shovel);
    });

    test('the selected slot follows inventory changes', () {
      equipment.selectSlotIndex(0);

      addItem.call(HandItemId.shovel, 1);

      expect(equipment.getEquippedItem()?.id, HandItemId.shovel);
    });

    test('clearSelectedEquipment empties the overlay state', () {
      addItem.call(HandItemId.shovel, 1);
      equipment.selectSlotIndex(0);

      equipment.clearSelectedEquipment();

      expect(EquipmentState.instance.getItem(), isNull);
    });

    test('a non-weapon contributes no damage', () {
      addItem.call(HandItemId.shovel, 1);
      equipment.selectSlotIndex(0);

      expect(equipment.getTotalDamage(), 0);
      expect(equipment.getTotalDps(), 0);
    });

    test('getTotalStats reports damage, dps and defense', () {
      final stats = equipment.getTotalStats();

      expect(stats.keys, containsAll(['damage', 'dps', 'defense']));
    });

    test('getAllEquippedItems is empty when nothing is equipped', () {
      expect(equipment.getAllEquippedItems(), isEmpty);
    });

    group('serialization', () {
      test('round-trips the selected slot', () {
        equipment.selectSlotIndex(4);

        final json = equipment.toJson();
        equipment.reset();
        equipment.fromJson(json, (_) => null);

        expect(equipment.currentMainHandSlotIndex, 4);
      });

      test('a slot index beyond the inventory is clamped back to 0', () {
        equipment.fromJson(<String, dynamic>{
          'selectedSlotIndex': 999,
        }, (_) => null);

        expect(equipment.currentMainHandSlotIndex, 0);
      });

      test('a missing index defaults to 0', () {
        equipment.fromJson(<String, dynamic>{}, (_) => null);

        expect(equipment.currentMainHandSlotIndex, 0);
      });
    });
  });

  group('Save/LoadInventoryUseCase', () {
    late SaveInventoryUseCase save;
    late LoadInventoryUseCase load;

    setUp(() {
      save = SaveInventoryUseCase(inventory, equipment);
      load = LoadInventoryUseCase(
        addItem,
        inventory,
        equipment,
        ItemFactoryService.instance,
      );
    });

    test('save produces a versioned payload', () {
      final data = save.call();

      expect(data['version'], 1);
      expect(data['inventory'], isA<Map<String, dynamic>>());
      expect(data['equipment'], isA<Map<String, dynamic>>());
    });

    test('save only records non-empty slots', () {
      addItem.call(HandItemId.shovel, 1);

      final data = save.call();
      final slots =
          (data['inventory'] as Map<String, dynamic>)['slots'] as List;

      expect(slots.length, 1);
    });

    test('round-trips items and the equipped slot', () {
      addItem.call(HandItemId.shovel, 1);
      addItem.call(HandItemId.wateringCan, 1);
      equipment.selectSlotIndex(1);

      final data = save.call();
      resetInventoryState(inventory, equipment);

      final loaded = load.call(data);

      expect(loaded, isTrue);
      expect(inventory.getItemQuantity('shovel'), 1);
      expect(inventory.getItemQuantity('wateringCan'), 1);
      expect(equipment.currentMainHandSlotIndex, 1);
    });

    test('round-trips an upgraded capacity', () {
      inventory.upgradeInventory();

      final data = save.call();
      resetInventoryState(inventory, equipment);

      load.call(data);

      expect(inventory.maxSlots, greaterThan(12));
    });

    test('malformed payload → false instead of throwing', () {
      final loaded = load.call(<String, dynamic>{'inventory': 'not a map'});

      expect(loaded, isFalse);
    });

    test('an empty payload is accepted as a fresh inventory', () {
      expect(load.call(<String, dynamic>{}), isTrue);
    });
  });
}

/// Reset síncrono para os testes de round-trip — o bootstrap já rodou no
/// `setUp`, então não precisa ser assíncrono aqui.
void resetInventoryState(
  InventoryManager inventory,
  EquipmentManager equipment,
) {
  inventory.reset();
  equipment.reset();
}
