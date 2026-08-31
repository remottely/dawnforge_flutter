import 'package:dawnforge/src/core/domain/inventory/inventory_sort_rules.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5 slice 1: an item that has a RECIPE.
///
/// Four fields the pack has authored and the pipeline has emitted since the
/// import, unread until now — and the link the 0.35.0 note promised, which is
/// what makes a blueprint something you can make.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  /// The smelter's own recipe, as the pack authors it.
  Map<String, Object?> smelterBlueprintJson() => <String, Object?>{
        'type': 'item_buildable_data',
        'id': 't1_item_buildable_workstation_smelter',
        'blueprint_id': 't1_prop_workstation_smelter',
        'crafted_at': 'NONE',
        'craft_time': 1.0,
        'craft_amount': 1,
        'max_stack': 1,
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_logs_palm', 'amount': 5},
          <String, Object?>{'id': 't1_item_ore_copper', 'amount': 5},
          <String, Object?>{'id': 't1_item_coal', 'amount': 5},
        ],
      };

  /// A copper bar, as the smelter makes it.
  Map<String, Object?> barJson() => <String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_craftable_bar_copper',
        'crafted_at': 'SMELTER',
        'craft_time': 5.0,
        'craft_amount': 1,
        'max_stack': 100,
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_ore_copper', 'amount': 5},
          <String, Object?>{'id': 't1_item_coal', 'amount': 1},
        ],
      };

  group('the registry routes the new family', () {
    test('a craftable document becomes the typed class', () {
      locator<ItemRegistry>().registerJson(barJson());

      final item = locator<ItemRegistry>().getItem('t1_item_craftable_bar_copper');
      expect(item, isA<ItemCraftableData>());
      expect(item, isNot(isA<ItemBuildableData>()),
          reason: 'a bar is made, not placed');
    });

    test('a family with no class of its own still reads as a plain item', () {
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'type': 'item_consumable_data',
        'id': 't1_item_consumable_fruit_apple',
      });

      final item =
          locator<ItemRegistry>().getItem('t1_item_consumable_fruit_apple');
      expect(item, isA<ItemData>());
      expect(item, isNot(isA<ItemCraftableData>()));
    });
  });

  group('the recipe', () {
    test('reads the pack shape: id + amount, in authored order', () {
      final bar = ItemCraftableData.fromJson(barJson());

      expect(bar.ingredients.length, 2);
      expect(bar.ingredients[0].itemId, 't1_item_ore_copper');
      expect(bar.ingredients[0].amount, 5);
      expect(bar.ingredients[1].itemId, 't1_item_coal');
      expect(bar.ingredients[1].amount, 1);
    });

    test('crafted_at travels as the AUTHORED NAME, not an index', () {
      expect(ItemCraftableData.fromJson(barJson()).craftedAt,
          WorkstationType.smelter);
    });

    test('NONE is a value — made by HAND, not a field somebody forgot', () {
      final smelter = ItemBuildableData.fromJson(smelterBlueprintJson());

      expect(smelter.craftedAt, WorkstationType.none);
      expect(smelter.isCraftable, isTrue,
          reason: 'a hand recipe is still a recipe');
    });

    test('an item with no ingredients is found, not made', () {
      final ore = ItemCraftableData.fromJson(<String, Object?>{
        'id': 't1_item_ore_copper',
      });

      expect(ore.ingredients, isEmpty);
      expect(ore.isCraftable, isFalse);
      // The two numbers keep their declared defaults and mean nothing, which
      // is why the validation does not ask about them here.
      expect(ore.craftTime, 1.0);
      expect(ore.craftAmount, 1);
    });

    test('a recipe whose numbers are impossible cannot be authored', () {
      Map<String, Object?> withNumbers(double time, int amount) =>
          <String, Object?>{
            'id': 't1_item_craftable_probe',
            'craft_time': time,
            'craft_amount': amount,
            'ingredients': <Map<String, Object?>>[
              <String, Object?>{'id': 't1_item_coal', 'amount': 1},
            ],
          };

      expect(() => ItemCraftableData.fromJson(withNumbers(0, 1)),
          throwsA(isA<AssertionError>()));
      expect(() => ItemCraftableData.fromJson(withNumbers(5, 0)),
          throwsA(isA<AssertionError>()));
      expect(() => ItemCraftableData.fromJson(withNumbers(5, 1)),
          returnsNormally);
    });

    test('an ingredient missing either half is a crash at read (rule 5)', () {
      Map<String, Object?> withIngredient(Map<String, Object?> entry) =>
          <String, Object?>{
            'id': 't1_item_craftable_probe',
            'ingredients': <Map<String, Object?>>[entry],
          };

      expect(
        () => ItemCraftableData.fromJson(
          withIngredient(<String, Object?>{'amount': 5}),
        ),
        throwsStateError,
      );
      expect(
        () => ItemCraftableData.fromJson(
          withIngredient(<String, Object?>{'id': 't1_item_coal'}),
        ),
        throwsStateError,
      );
      expect(
        () => ItemCraftableData.fromJson(
          withIngredient(<String, Object?>{'id': 't1_item_coal', 'amount': 0}),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('the link the 0.35.0 note promised', () {
    test('a blueprint IS a craftable, and carries its own recipe', () {
      final smelter = ItemBuildableData.fromJson(smelterBlueprintJson());

      expect(smelter, isA<ItemCraftableData>());
      expect(smelter.blueprintId, 't1_prop_workstation_smelter');
      expect(smelter.ingredients.map((entry) => entry.itemId), <String>[
        't1_item_logs_palm',
        't1_item_ore_copper',
        't1_item_coal',
      ]);
    });

    test('the sort ladder did NOT move under the re-parenting', () {
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_workstation_smelter',
        'grid_size': <int>[2, 1],
      });

      // A blueprint is a craftable now, and the ladder never tests craftable —
      // it tests the subclasses and lets the parent fall to the bottom. So a
      // bar is still a MATERIAL and a blueprint is still what you BUILD.
      expect(
        InventorySortRules.categoryRank(
          ItemBuildableData.fromJson(smelterBlueprintJson()),
        ),
        InventorySortRules.categoryBuildable,
      );
      expect(
        InventorySortRules.categoryRank(ItemCraftableData.fromJson(barJson())),
        InventorySortRules.categoryMaterial,
      );
    });
  });

  group('the clone (rule 3)', () {
    test('carries the recipe', () {
      final copy = ItemCraftableData.fromJson(barJson()).clone();

      expect(copy, isA<ItemCraftableData>());
      expect(copy.craftedAt, WorkstationType.smelter);
      expect(copy.craftTime, 5.0);
      expect(copy.craftAmount, 1);
      expect(copy.ingredients.length, 2);
      expect(copy.ingredients[0].itemId, 't1_item_ore_copper');
    });

    test('does not SHARE the ingredient list with the registry entry', () {
      final bar = ItemCraftableData.fromJson(barJson());
      final copy = bar.clone();

      // The entries are immutable, so what an instance must not share is the
      // container they sit in.
      expect(identical(copy.ingredients, bar.ingredients), isFalse);
      expect(copy.ingredients[0].itemId, bar.ingredients[0].itemId);
    });

    test('a blueprint clone keeps BOTH halves', () {
      final copy = ItemBuildableData.fromJson(smelterBlueprintJson()).clone();

      expect(copy.blueprintId, 't1_prop_workstation_smelter');
      expect(copy.craftedAt, WorkstationType.none);
      expect(copy.ingredients.length, 3);
      expect(copy.maxStack, 1);
    });
  });
}
