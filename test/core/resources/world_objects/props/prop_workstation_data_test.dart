import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5 slice 3: a prop you make things AT.
///
/// The design worth pinning is that a station holds no recipe list — it asks
/// the item registry which items name it. Authoring a recipe is authoring one
/// document, and every test here is about that lookup answering the same thing
/// the authorisation gate does.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  void registerRecipe(
    String id, {
    required String craftedAt,
    int tier = 1,
    List<Map<String, Object?>>? ingredients,
  }) {
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'type': 'item_craftable_data',
      'id': id,
      'crafted_at': craftedAt,
      'tier': tier,
      'ingredients': ingredients ??
          <Map<String, Object?>>[
            <String, Object?>{'id': 't1_item_ore_copper', 'amount': 5},
          ],
    });
  }

  PropWorkstationData smelter({int tier = 1, double speed = 1.0}) =>
      PropWorkstationData.fromJson(<String, Object?>{
        'type': 'prop_workstation_data',
        'id': 't1_prop_workstation_smelter',
        'workstation_type': 'SMELTER',
        'production_speed_multiplier': speed,
        'tier': tier,
        'grid_size': <int>[2, 1],
      });

  group('the registry routes the pack type', () {
    test('a workstation document becomes the typed class', () {
      // Authored `prop_workstation_data` since the import, and read as a plain
      // prop until this slice — the type was dropped on the floor.
      locator<PropRegistry>().registerJson(<String, Object?>{
        'type': 'prop_workstation_data',
        'id': 't1_prop_workstation_smelter',
        'workstation_type': 'SMELTER',
        'grid_size': <int>[2, 1],
      });

      final prop = locator<PropRegistry>().getProp('t1_prop_workstation_smelter');
      expect(prop, isA<PropWorkstationData>());
      expect((prop as PropWorkstationData).workstationType,
          WorkstationType.smelter);
    });

    test('a family with no class of its own still reads as a plain prop', () {
      locator<PropRegistry>().registerJson(<String, Object?>{
        'type': 'prop_crop_data',
        'id': 't1_prop_crop_tree_palm',
      });

      final prop = locator<PropRegistry>().getProp('t1_prop_crop_tree_palm');
      expect(prop, isA<PropData>());
      expect(prop, isNot(isA<PropWorkstationData>()));
    });
  });

  group('a station that could not be authored', () {
    test('NONE is the value a RECIPE uses, never a station', () {
      expect(
        () => PropWorkstationData.fromJson(<String, Object?>{
          'id': 't1_prop_workstation_probe',
          'workstation_type': 'NONE',
        }),
        throwsA(isA<AssertionError>()),
        reason: 'a station answering to NONE would offer the hand list',
      );
    });

    test('a speed of zero is caught at construction, not at the division', () {
      // The spec guards this inline every time it divides. Here the invariant
      // is the guard, so the arithmetic downstream is plain arithmetic.
      expect(
        () => PropWorkstationData.fromJson(<String, Object?>{
          'id': 't1_prop_workstation_probe',
          'workstation_type': 'SMELTER',
          'production_speed_multiplier': 0,
        }),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('which recipes a station offers', () {
    test('the ones that NAME it, and no others', () {
      registerRecipe('t1_item_craftable_bar_copper', craftedAt: 'SMELTER');
      registerRecipe('t1_item_tool_melee_axe_copper', craftedAt: 'WORKSHOP');

      expect(
        smelter().validRecipes().map((recipe) => recipe.id),
        <String>['t1_item_craftable_bar_copper'],
      );
    });

    test('a HAND recipe belongs to no station at all', () {
      // The smelter blueprint is `crafted_at: NONE`. It must not appear at the
      // smelter — that would be the station offering the list it cannot own.
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'type': 'item_buildable_data',
        'id': 't1_item_buildable_workstation_smelter',
        'blueprint_id': 't1_prop_workstation_smelter',
        'crafted_at': 'NONE',
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_logs_palm', 'amount': 5},
        ],
      });

      expect(smelter().validRecipes(), isEmpty);
    });

    test('a BLUEPRINT that names a station does appear — it is a craftable', () {
      // ItemBuildableData extends ItemCraftableData since 0.45.0, so a thing
      // you place can be made at a bench like anything else.
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'type': 'item_buildable_data',
        'id': 't1_item_buildable_torch',
        'blueprint_id': 't1_prop_torch',
        'crafted_at': 'SMELTER',
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_logs_palm', 'amount': 1},
        ],
      });

      expect(smelter().validRecipes().map((recipe) => recipe.id),
          contains('t1_item_buildable_torch'));
    });

    test('an item with no recipe is not offered, whatever it names', () {
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_craftable_nothing',
        'crafted_at': 'SMELTER',
      });

      expect(smelter().validRecipes(), isEmpty);
    });

    test('tier is CUMULATIVE — a better station still makes the humble thing',
        () {
      registerRecipe('t1_item_craftable_bar_copper', craftedAt: 'SMELTER');
      registerRecipe('t2_item_craftable_bar_iron',
          craftedAt: 'SMELTER', tier: 2);

      expect(smelter().validRecipes().map((recipe) => recipe.id),
          <String>['t1_item_craftable_bar_copper']);
      expect(
        smelter(tier: 2).validRecipes().map((recipe) => recipe.id),
        <String>['t1_item_craftable_bar_copper', 't2_item_craftable_bar_iron'],
        reason: 'a tier 2 smelter still melts tier 1 bars',
      );
    });

    test('ordered by tier THEN id — text order puts t10_ between t1_ and t2_',
        () {
      registerRecipe('t1_item_craftable_zinc', craftedAt: 'SMELTER');
      registerRecipe('t1_item_craftable_bar_copper', craftedAt: 'SMELTER');
      registerRecipe('t2_item_craftable_amber', craftedAt: 'SMELTER', tier: 2);

      expect(
        smelter(tier: 5).validRecipes().map((recipe) => recipe.id),
        <String>[
          't1_item_craftable_bar_copper',
          't1_item_craftable_zinc',
          't2_item_craftable_amber',
        ],
        reason: 'tier decides first, so the id sort never has to carry it',
      );
    });

    test('the shown list and the AUTHORISING gate are one sentence', () {
      registerRecipe('t2_item_craftable_bar_iron',
          craftedAt: 'SMELTER', tier: 2);
      final station = smelter();
      final recipe = locator<ItemRegistry>().getItem('t2_item_craftable_bar_iron')
          as ItemCraftableData;

      expect(station.validRecipes(), isEmpty);
      expect(station.canUseRecipe(recipe), isFalse,
          reason: 'a gate looser than the list is how you craft what you were '
              'never shown');
    });
  });

  group('effective time', () {
    test('the authored time divided by how fast the station is', () {
      registerRecipe('t1_item_craftable_bar_copper', craftedAt: 'SMELTER');
      final recipe = locator<ItemRegistry>()
          .getItem('t1_item_craftable_bar_copper') as ItemCraftableData;

      // craft_time defaults to 1.0 for these fixtures.
      expect(smelter().effectiveTime(recipe), 1.0);
      expect(smelter().effectiveTime(recipe, quantity: 3), 3.0);
      expect(smelter(speed: 2).effectiveTime(recipe, quantity: 3), 1.5,
          reason: 'bigger multiplier is FASTER');
    });
  });

  test('the clone carries both authored fields (rule 3)', () {
    final copy = smelter(tier: 3, speed: 2.5).clone();

    expect(copy, isA<PropWorkstationData>());
    expect(copy.workstationType, WorkstationType.smelter);
    expect(copy.productionSpeedMultiplier, 2.5);
    expect(copy.tier, 3);
    expect(copy.gridWidth, 2);
  });
}
