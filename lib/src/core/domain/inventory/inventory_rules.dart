import 'dart:math' as math;

/// Pure domain rules for slot-based inventories — the Dart port of
/// `InventoryRules.cs` (`shared/domain/inventory/`). No component/engine
/// dependency; every quantity arrives as a parameter.
abstract final class InventoryRules {
  static bool areIdsEqual(String idA, String idB) =>
      idA.isNotEmpty && idA == idB;

  /// Whether one of these occupies a resource of its own rather than a
  /// counter in a shared one. A stack of planks is a number; a tool is a
  /// thing, with its own durability and its own identity. Everything that
  /// treats the two differently asks here, so "unique" is defined once and
  /// cannot come to mean two things.
  static bool isUniqueInstance(int maxStack) => maxStack == 1;

  static int calculateStackTransfer(
    int remaining,
    int stackAmount,
    int maxStack,
  ) =>
      math.min(remaining, maxStack - stackAmount);

  static int calculateEmptySlotTransfer(int remaining, int maxStack) =>
      math.min(remaining, maxStack);

  static bool canReserve(int realSpace, int pending, int amount) =>
      realSpace - pending >= amount;

  static int decrementReservation(int currentReserved, int amount) =>
      math.max(0, currentReserved - amount);

  static int spaceForEmptySlot(int maxStack, {required bool onlyExistingStacks}) =>
      onlyExistingStacks ? 0 : maxStack;

  static int spaceForMatchingStack(int maxStack, int stackAmount) =>
      maxStack - stackAmount;

  static int calculateTake(int remaining, int stackAmount) =>
      math.min(remaining, stackAmount);

  static int splitHalfAmount(int stackAmount) => (stackAmount / 2).ceil();
}
