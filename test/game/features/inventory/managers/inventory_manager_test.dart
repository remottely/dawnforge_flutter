import 'package:dawnforge/game/features/inventory/config/inventory_def.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/inventory_slot.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/manager_reset.dart';
import '../../../../helpers/test_data_builders.dart';

void main() {
  late InventoryManager manager;

  setUp(() async {
    await resetAllManagers();
    manager = InventoryManager.instance;
  });

  group('InventoryManager', () {
    group('initial state', () {
      test('starts empty at the default capacity', () {
        expect(manager.maxSlots, InventoryDef.kSizeInventoryDefault);
        expect(manager.isEmpty, isTrue);
        expect(manager.usedSlots, 0);
        expect(manager.freeSlots, InventoryDef.kSizeInventoryDefault);
      });

      test('every slot exists and carries its own index', () {
        for (var i = 0; i < manager.maxSlots; i++) {
          expect(manager.getSlotByIndex(i)!.index, i);
        }
      });
    });

    group('slot access', () {
      test('negative or out-of-range index → null', () {
        expect(manager.getSlotByIndex(-1), isNull);
        expect(manager.getSlotByIndex(manager.maxSlots), isNull);
      });

      test('updateSlot with an invalid index is ignored', () {
        manager.updateSlot(999, aSlot(index: 999, item: anItem(), quantity: 1));

        expect(manager.isEmpty, isTrue);
      });

      test('updateSlot stores the slot', () {
        manager.updateSlot(2, aSlot(index: 2, item: anItem(), quantity: 5));

        expect(manager.getSlotByIndex(2)!.quantity, 5);
        expect(manager.usedSlots, 1);
      });
    });

    group('capacity', () {
      test('upgrade goes default → lvl2 → lvl3 and then stops', () {
        expect(manager.upgradeInventory(), isTrue);
        expect(manager.maxSlots, InventoryDef.kSizeInventoryUpgradeLvl2);

        expect(manager.upgradeInventory(), isTrue);
        expect(manager.maxSlots, InventoryDef.kSizeInventoryUpgradeLvl3);

        expect(manager.canUpgrade, isFalse);
        expect(manager.upgradeInventory(), isFalse);
      });

      test('upgrading adds empty slots without touching the existing ones', () {
        manager.updateSlot(0, aSlot(item: anItem(), quantity: 3));

        manager.upgradeInventory();

        expect(manager.getSlotByIndex(0)!.quantity, 3);
        expect(
          manager.getSlotByIndex(InventoryDef.kSizeInventoryDefault)!.isEmpty,
          isTrue,
        );
      });

      test('setMaxSlots grows the inventory', () {
        manager.setMaxSlots(20);

        expect(manager.maxSlots, 20);
        expect(manager.getSlotByIndex(19), isNotNull);
      });

      test('setMaxSlots shrinks the inventory, dropping the tail', () {
        manager.setMaxSlots(5);

        expect(manager.maxSlots, 5);
        expect(manager.getSlotByIndex(5), isNull);
      });

      test('setMaxSlots to the current size is a no-op', () {
        final before = manager.maxSlots;

        manager.setMaxSlots(before);

        expect(manager.maxSlots, before);
      });
    });

    group('quantities', () {
      test('getItemQuantity sums across every slot holding the item', () {
        final wood = anItem(id: HandItemId.wood);
        manager
          ..updateSlot(0, aSlot(index: 0, item: wood, quantity: 10))
          ..updateSlot(3, aSlot(index: 3, item: wood, quantity: 7));

        expect(manager.getItemQuantity('wood'), 17);
      });

      test('getItemQuantity for an absent item → 0', () {
        expect(manager.getItemQuantity('wood'), 0);
      });

      test('hasItem respects the requested amount', () {
        manager.updateSlot(
          0,
          aSlot(item: anItem(id: HandItemId.wood), quantity: 5),
        );

        expect(manager.hasItem('wood'), isTrue);
        expect(manager.hasItem('wood', 5), isTrue);
        expect(manager.hasItem('wood', 6), isFalse);
      });
    });

    group('consumeFromSlot', () {
      test('reduces the quantity', () {
        manager.updateSlot(0, aSlot(item: anItem(), quantity: 5));

        manager.consumeFromSlot(0, 2);

        expect(manager.getSlotByIndex(0)!.quantity, 3);
      });

      test('consuming everything frees the slot', () {
        manager.updateSlot(0, aSlot(item: anItem(), quantity: 5));

        manager.consumeFromSlot(0, 5);

        expect(manager.getSlotByIndex(0)!.isEmpty, isTrue);
      });

      test('non-positive amount is ignored', () {
        manager.updateSlot(0, aSlot(item: anItem(), quantity: 5));

        manager.consumeFromSlot(0, 0);

        expect(manager.getSlotByIndex(0)!.quantity, 5);
      });

      test('consuming from an empty slot is harmless', () {
        expect(() => manager.consumeFromSlot(0, 1), returnsNormally);
      });
    });

    group('findSlotByItemId', () {
      test('returns the first slot holding the item', () {
        final wood = anItem(id: HandItemId.wood);
        manager
          ..updateSlot(2, aSlot(index: 2, item: wood, quantity: 1))
          ..updateSlot(5, aSlot(index: 5, item: wood, quantity: 1));

        expect(manager.findSlotByItemId('wood')!.index, 2);
      });

      test('absent item → null', () {
        expect(manager.findSlotByItemId('wood'), isNull);
      });
    });

    group('findItem', () {
      test('finds the first match from the start', () {
        manager.updateSlot(
          3,
          aSlot(index: 3, item: anItem(id: HandItemId.wood), quantity: 1),
        );

        final found = manager.findItem((item) => item.id == HandItemId.wood);

        expect(found!.index, 3);
      });

      test('afterIndex skips forward past the given slot', () {
        final wood = anItem(id: HandItemId.wood);
        manager
          ..updateSlot(1, aSlot(index: 1, item: wood, quantity: 1))
          ..updateSlot(4, aSlot(index: 4, item: wood, quantity: 1));

        final found = manager.findItem(
          (item) => item.id == HandItemId.wood,
          afterIndex: 1,
        );

        expect(found!.index, 4);
      });

      test('wraps around to the beginning when nothing is found ahead', () {
        manager.updateSlot(
          1,
          aSlot(index: 1, item: anItem(id: HandItemId.wood), quantity: 1),
        );

        final found = manager.findItem(
          (item) => item.id == HandItemId.wood,
          afterIndex: 5,
        );

        expect(found!.index, 1);
      });

      test('no match → null', () {
        expect(manager.findItem((_) => false), isNull);
      });
    });

    group('findItemReverse', () {
      test('without beforeIndex, searches from the end', () {
        final wood = anItem(id: HandItemId.wood);
        manager
          ..updateSlot(1, aSlot(index: 1, item: wood, quantity: 1))
          ..updateSlot(6, aSlot(index: 6, item: wood, quantity: 1));

        final found = manager.findItemReverse(
          (item) => item.id == HandItemId.wood,
        );

        expect(found!.index, 6);
      });

      test('beforeIndex searches backwards from that slot', () {
        final wood = anItem(id: HandItemId.wood);
        manager
          ..updateSlot(1, aSlot(index: 1, item: wood, quantity: 1))
          ..updateSlot(6, aSlot(index: 6, item: wood, quantity: 1));

        final found = manager.findItemReverse(
          (item) => item.id == HandItemId.wood,
          beforeIndex: 5,
        );

        expect(found!.index, 1);
      });

      test('no match → null', () {
        expect(manager.findItemReverse((_) => false), isNull);
      });
    });

    group('clear and reset', () {
      test('clear empties every slot but keeps the capacity', () {
        manager
          ..setMaxSlots(20)
          ..updateSlot(0, aSlot(item: anItem(), quantity: 5))
          ..clear();

        expect(manager.isEmpty, isTrue);
        expect(manager.maxSlots, 20);
      });

      test('reset also restores the default capacity', () {
        manager
          ..setMaxSlots(24)
          ..updateSlot(0, aSlot(item: anItem(), quantity: 5))
          ..reset();

        expect(manager.isEmpty, isTrue);
        expect(manager.maxSlots, InventoryDef.kSizeInventoryDefault);
      });
    });

    group('notifications', () {
      test('updateSlot notifies listeners', () {
        var notifications = 0;
        void listener() => notifications++;
        manager.slotsNotifier.addListener(listener);
        addTearDown(() => manager.slotsNotifier.removeListener(listener));

        manager.updateSlot(0, aSlot(item: anItem(), quantity: 1));

        expect(notifications, 1);
      });

      test('the exposed slot list is unmodifiable', () {
        expect(() => manager.slots.add(aSlot()), throwsUnsupportedError);
      });
    });

    group('serialization', () {
      test('only non-empty slots are written', () {
        manager.updateSlot(
          2,
          aSlot(index: 2, item: anItem(id: HandItemId.wood), quantity: 4),
        );

        final json = manager.toJson();

        expect(json['maxSlots'], InventoryDef.kSizeInventoryDefault);
        expect((json['slots'] as List).length, 1);
      });

      test('round-trips slot contents and positions', () {
        final wood = anItem(id: HandItemId.wood);
        manager
          ..updateSlot(2, aSlot(index: 2, item: wood, quantity: 4))
          ..updateSlot(7, aSlot(index: 7, item: wood, quantity: 9));

        final json = manager.toJson();
        manager.clear();
        manager.fromJson(json, (_) => wood);

        expect(manager.getSlotByIndex(2)!.quantity, 4);
        expect(manager.getSlotByIndex(7)!.quantity, 9);
        expect(manager.usedSlots, 2);
      });

      test('restores the saved capacity', () {
        manager.setMaxSlots(24);
        final json = manager.toJson();
        manager.reset();

        manager.fromJson(json, (_) => null);

        expect(manager.maxSlots, 24);
      });

      test('missing slots key leaves the inventory empty', () {
        manager.updateSlot(0, aSlot(item: anItem(), quantity: 1));

        manager.fromJson(<String, dynamic>{'maxSlots': 12}, (_) => null);

        expect(manager.isEmpty, isTrue);
      });

      test('a slot index beyond the capacity is dropped, not crashed on', () {
        manager.fromJson(<String, dynamic>{
          'maxSlots': 12,
          'slots': [const InventorySlot(index: 99).toJson()],
        }, (_) => anItem());

        expect(manager.maxSlots, 12);
      });
    });
  });
}
