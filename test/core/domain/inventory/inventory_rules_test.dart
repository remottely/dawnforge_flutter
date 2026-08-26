import 'package:dawnforge/src/core/domain/inventory/inventory_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryRules', () {
    test('areIdsEqual refuses the empty id even against itself', () {
      expect(InventoryRules.areIdsEqual('t1_item_coal', 't1_item_coal'), isTrue);
      expect(InventoryRules.areIdsEqual('t1_item_coal', 't1_item_ore'), isFalse);
      expect(InventoryRules.areIdsEqual('', ''), isFalse);
    });

    test('isUniqueInstance: max_stack 1 is a thing, not a number', () {
      expect(InventoryRules.isUniqueInstance(1), isTrue);
      expect(InventoryRules.isUniqueInstance(2), isFalse);
      expect(InventoryRules.isUniqueInstance(1000000000), isFalse);
    });

    test('stack transfers respect capacity and demand', () {
      expect(InventoryRules.calculateStackTransfer(5, 8, 10), 2);
      expect(InventoryRules.calculateStackTransfer(1, 8, 10), 1);
      expect(InventoryRules.calculateStackTransfer(5, 10, 10), 0);
      expect(InventoryRules.calculateEmptySlotTransfer(25, 10), 10);
      expect(InventoryRules.calculateEmptySlotTransfer(3, 10), 3);
    });

    test('space accounting: empty slots, matching stacks, the flag', () {
      expect(
        InventoryRules.spaceForEmptySlot(10, onlyExistingStacks: false),
        10,
      );
      expect(InventoryRules.spaceForEmptySlot(10, onlyExistingStacks: true), 0);
      expect(InventoryRules.spaceForMatchingStack(10, 4), 6);
    });

    test('reservations: promised space counts against the real space', () {
      expect(InventoryRules.canReserve(10, 0, 10), isTrue);
      expect(InventoryRules.canReserve(10, 6, 5), isFalse);
      expect(InventoryRules.canReserve(10, 6, 4), isTrue);
      expect(InventoryRules.decrementReservation(6, 4), 2);
      expect(InventoryRules.decrementReservation(2, 5), 0);
    });

    test('take and split', () {
      expect(InventoryRules.calculateTake(5, 3), 3);
      expect(InventoryRules.calculateTake(2, 3), 2);
      // Split rounds UP: the picked-up half is the bigger one.
      expect(InventoryRules.splitHalfAmount(5), 3);
      expect(InventoryRules.splitHalfAmount(1), 1);
    });
  });
}
