import 'package:dawnforge/src/core/domain/production/crafting_rules.dart';
import 'package:dawnforge/src/core/resources/items/item_amount.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5 slice 2: can this be paid for, and how many times.
void main() {
  /// The copper bar's recipe, as the pack authors it.
  final barRecipe = <ItemAmount>[
    ItemAmount(itemId: 't1_item_ore_copper', amount: 5),
    ItemAmount(itemId: 't1_item_coal', amount: 1),
  ];

  ItemCount bagOf(Map<String, int> contents) =>
      (itemId) => contents[itemId] ?? 0;

  group('batchesFrom', () {
    test('floors — a part of a batch is not a batch', () {
      expect(CraftingRules.batchesFrom(10, 5), 2);
      expect(CraftingRules.batchesFrom(9, 5), 1);
      expect(CraftingRules.batchesFrom(4, 5), 0);
      expect(CraftingRules.batchesFrom(0, 5), 0);
    });
  });

  group('canCraft', () {
    test('every line has to be covered, not just the biggest one', () {
      expect(
        CraftingRules.canCraft(
          barRecipe,
          bagOf(<String, int>{'t1_item_ore_copper': 5, 't1_item_coal': 1}),
        ),
        isTrue,
        reason: 'exactly enough is enough',
      );
      expect(
        CraftingRules.canCraft(
          barRecipe,
          // All the ore in the world and no coal.
          bagOf(<String, int>{'t1_item_ore_copper': 500}),
        ),
        isFalse,
      );
      expect(
        CraftingRules.canCraft(
          barRecipe,
          bagOf(<String, int>{'t1_item_ore_copper': 4, 't1_item_coal': 1}),
        ),
        isFalse,
      );
    });

    test('a quantity multiplies every line', () {
      final bag = bagOf(<String, int>{
        't1_item_ore_copper': 10,
        't1_item_coal': 2,
      });

      expect(CraftingRules.canCraft(barRecipe, bag, quantity: 2), isTrue);
      expect(CraftingRules.canCraft(barRecipe, bag, quantity: 3), isFalse);
    });

    test('an order of nothing is not an order', () {
      final bag = bagOf(<String, int>{
        't1_item_ore_copper': 500,
        't1_item_coal': 500,
      });

      expect(CraftingRules.canCraft(barRecipe, bag, quantity: 0), isFalse);
      expect(CraftingRules.canCraft(barRecipe, bag, quantity: -1), isFalse);
    });

    test('an EMPTY recipe is false — "every" over nothing is the wrong true',
        () {
      // A thing nobody wrote a recipe for cannot be made out of nothing. This
      // is the whole reason the guard is written down rather than left to the
      // loop.
      expect(
        CraftingRules.canCraft(<ItemAmount>[], bagOf(<String, int>{})),
        isFalse,
      );
      expect(
        CraftingRules.canCraft(
          <ItemAmount>[],
          bagOf(<String, int>{'t1_item_coal': 500}),
        ),
        isFalse,
      );
    });
  });

  group('maxCraftable', () {
    test('the scarcest line decides', () {
      expect(
        CraftingRules.maxCraftable(
          barRecipe,
          // Ore pays for 4 bars, coal for 3. The answer is 3.
          bagOf(<String, int>{'t1_item_ore_copper': 20, 't1_item_coal': 3}),
        ),
        3,
      );
    });

    test('a line the bag does not hold at all makes it zero', () {
      expect(
        CraftingRules.maxCraftable(
          barRecipe,
          bagOf(<String, int>{'t1_item_ore_copper': 500}),
        ),
        0,
      );
    });

    test('one order is capped at a hundred, however full the bag', () {
      expect(
        CraftingRules.maxCraftable(
          barRecipe,
          bagOf(<String, int>{
            't1_item_ore_copper': 5000,
            't1_item_coal': 5000,
          }),
        ),
        CraftingRules.maxBatchesPerOrder,
      );
      expect(CraftingRules.maxBatchesPerOrder, 100);
    });

    test('an EMPTY recipe is zero, NOT the untouched ceiling', () {
      // The loud version of the same trap: a minimum over no lines never
      // lowers the cap, so without the guard an unmakeable thing would report
      // a hundred of itself.
      expect(
        CraftingRules.maxCraftable(
          <ItemAmount>[],
          bagOf(<String, int>{'t1_item_coal': 500}),
        ),
        0,
      );
    });

    test('agrees with canCraft at the boundary', () {
      final bag = bagOf(<String, int>{
        't1_item_ore_copper': 17,
        't1_item_coal': 9,
      });
      final most = CraftingRules.maxCraftable(barRecipe, bag);

      expect(most, 3);
      expect(CraftingRules.canCraft(barRecipe, bag, quantity: most), isTrue);
      expect(
        CraftingRules.canCraft(barRecipe, bag, quantity: most + 1),
        isFalse,
        reason: 'the list a player is shown and the check that authorises it '
            'must be the same sentence',
      );
    });
  });

  test('totalTime is per batch', () {
    expect(CraftingRules.totalTime(5, 3), 15.0);
    expect(CraftingRules.totalTime(1, 1), 1.0);
    expect(CraftingRules.totalTime(0.5, 4), 2.0);
  });
}
