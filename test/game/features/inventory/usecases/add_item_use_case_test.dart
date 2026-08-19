import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/services/item_factory_service.dart';
import 'package:dawnforge/game/features/inventory/usecases/add_item_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/manager_reset.dart';
import '../../../../helpers/test_data_builders.dart';

void main() {
  late InventoryManager manager;
  late AddItemUseCase useCase;

  setUp(() async {
    await resetAllManagers();
    manager = InventoryManager.instance;
    useCase = AddItemUseCase(manager, ItemFactoryService.instance);
  });

  group('AddItemUseCase', () {
    group('call by id', () {
      test('a known item is created and added', () {
        final added = useCase.call(HandItemId.shovel, 1);

        expect(added, isTrue);
        expect(manager.getItemQuantity('shovel'), 1);
      });

      test('an unknown item → false, inventory untouched', () {
        expect(useCase.call(HandItemId.unknown, 1), isFalse);
        expect(manager.isEmpty, isTrue);
      });

      test('quantity of zero or less → false', () {
        expect(useCase.call(HandItemId.shovel, 0), isFalse);
        expect(useCase.call(HandItemId.shovel, -5), isFalse);
        expect(manager.isEmpty, isTrue);
      });
    });

    group('addItemEntity — stackable items', () {
      test('fits in a single slot when below the stack size', () {
        final item = anItem(maxStackSize: 99);

        expect(useCase.addItemEntity(item, 30), isTrue);
        expect(manager.usedSlots, 1);
        expect(manager.getSlotByIndex(0)!.quantity, 30);
      });

      test('stacks onto an existing slot with the same item', () {
        final item = anItem(maxStackSize: 99);

        useCase.addItemEntity(item, 10);
        useCase.addItemEntity(item, 5);

        expect(manager.usedSlots, 1);
        expect(manager.getSlotByIndex(0)!.quantity, 15);
      });

      test('overflows into the next slot when the stack fills up', () {
        final item = anItem(maxStackSize: 10);

        expect(useCase.addItemEntity(item, 15), isTrue);
        expect(manager.getSlotByIndex(0)!.quantity, 10);
        expect(manager.getSlotByIndex(1)!.quantity, 5);
      });

      test('a large amount spreads across several slots', () {
        final item = anItem(maxStackSize: 10);

        useCase.addItemEntity(item, 35);

        expect(manager.getItemQuantity(item.id.name), 35);
        expect(manager.usedSlots, 4);
      });

      test('a different item never stacks onto an occupied slot', () {
        useCase.addItemEntity(anItem(id: HandItemId.wood), 5);
        useCase.addItemEntity(anItem(id: HandItemId.stone), 5);

        expect(manager.usedSlots, 2);
      });

      test('fills the remaining space of a partial stack first', () {
        final item = anItem(maxStackSize: 10);
        useCase.addItemEntity(item, 7);

        useCase.addItemEntity(item, 5);

        expect(manager.getSlotByIndex(0)!.quantity, 10);
        expect(manager.getSlotByIndex(1)!.quantity, 2);
      });
    });

    group('addItemEntity — non-stackable items', () {
      test('each unit takes its own slot', () {
        final tool = aNonStackableItem();

        useCase.addItemEntity(tool, 3);

        expect(manager.usedSlots, 3);
        expect(manager.getSlotByIndex(0)!.quantity, 1);
        expect(manager.getSlotByIndex(1)!.quantity, 1);
        expect(manager.getSlotByIndex(2)!.quantity, 1);
      });
    });

    group('addItemEntity — full inventory', () {
      test('returns false when nothing at all could be added', () {
        final filler = aNonStackableItem();
        useCase.addItemEntity(filler, manager.maxSlots);

        final added = useCase.addItemEntity(aNonStackableItem(), 1);

        expect(added, isFalse);
      });

      test('a partial add still reports success', () {
        final item = anItem(maxStackSize: 10);
        // Deixa exatamente um slot livre.
        useCase.addItemEntity(aNonStackableItem(), manager.maxSlots - 1);

        final added = useCase.addItemEntity(item, 25);

        expect(added, isTrue, reason: '10 of the 25 fit in the last slot');
        expect(manager.getItemQuantity(item.id.name), 10);
      });

      test('invalid quantity → false', () {
        expect(useCase.addItemEntity(anItem(), 0), isFalse);
        expect(useCase.addItemEntity(anItem(), -1), isFalse);
      });
    });

    group('addMultiple', () {
      test('adds every entry', () {
        final added = useCase.addMultiple([
          (HandItemId.shovel, 1),
          (HandItemId.wateringCan, 1),
        ]);

        expect(added, isTrue);
        expect(manager.getItemQuantity('shovel'), 1);
        expect(manager.getItemQuantity('wateringCan'), 1);
      });

      test('returns true when at least one entry succeeded', () {
        final added = useCase.addMultiple([
          (HandItemId.shovel, 1),
          (HandItemId.unknown, 1),
        ]);

        expect(added, isTrue);
        expect(manager.getItemQuantity('shovel'), 1);
      });

      test('returns false when nothing could be added', () {
        expect(useCase.addMultiple([(HandItemId.unknown, 1)]), isFalse);
      });

      test('an empty list → false', () {
        expect(useCase.addMultiple([]), isFalse);
      });
    });
  });
}
