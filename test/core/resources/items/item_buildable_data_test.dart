import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3b slice 1: an item that is a BLUEPRINT.
///
/// The whole slice is one field and one lookup, and the lookup is the part
/// worth testing: the spec keeps every world object in one registry and asks
/// the result what it is, while this port keeps props and grounds in registries
/// of their own. Both spellings have to give the same answer.
void main() {
  setUp(() {
    registerCoreSystems();

    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_workstation_smelter',
      'grid_size': <int>[2, 1],
    });

    locator<GroundRegistry>().registerJson(<String, Object?>{
      'type': 'ground_buildable_data',
      'id': 't1_ground_buildable_bridge_palm',
      'floats_on_water': true,
    });
  });

  tearDown(resetCoreSystems);

  group('the registry routes the pack type', () {
    test('a buildable document becomes the typed class', () {
      locator<ItemRegistry>().registerJson(<String, Object?>{
        'type': 'item_buildable_data',
        'id': 't1_item_buildable_workstation_smelter',
        'blueprint_id': 't1_prop_workstation_smelter',
      });

      final item =
          locator<ItemRegistry>().getItem('t1_item_buildable_workstation_smelter');
      expect(item, isA<ItemBuildableData>());
      expect((item as ItemBuildableData).blueprintId,
          't1_prop_workstation_smelter');
    });

    test('every other family still reads as a plain item', () {
      locator<ItemRegistry>()
        ..registerJson(<String, Object?>{
          'type': 'item_tool_melee_data',
          'id': 't1_item_tool_melee_hand',
          'tool_type': 'INNATE',
        })
        // A document that names the base class itself, and one that names no
        // type at all: the second is what every test fixture in this suite
        // passes, and it has to keep working.
        ..registerJson(<String, Object?>{
          'type': 'item_data',
          'id': 't1_item_logs_palm',
        })
        ..registerJson(<String, Object?>{'id': 't1_item_coal'});

      final items = locator<ItemRegistry>();
      for (final id in items.ids) {
        expect(items.getItem(id), isNot(isA<ItemBuildableData>()),
            reason: '$id is not a blueprint');
        expect(items.getItem(id), isA<ItemData>());
      }
    });
  });

  group('the blueprint', () {
    ItemBuildableData buildableFor(String blueprintId) =>
        ItemBuildableData.fromJson(<String, Object?>{
          'id': 't1_item_buildable_probe',
          'blueprint_id': blueprintId,
        });

    test('resolves through whichever registry holds it — a PROP', () {
      final item = buildableFor('t1_prop_workstation_smelter');

      expect(item.blueprint, isA<PropData>());
      expect(item.blueprint.id, 't1_prop_workstation_smelter');
      expect(item.isPropBlueprint, isTrue);
      expect(item.isGroundBlueprint, isFalse);
    });

    test('resolves through whichever registry holds it — a GROUND', () {
      final item = buildableFor('t1_ground_buildable_bridge_palm');

      expect(item.blueprint, isA<GroundBuildableData>());
      expect(item.blueprint.id, 't1_ground_buildable_bridge_palm');
      expect(item.isGroundBlueprint, isTrue);
      expect(item.isPropBlueprint, isFalse);
    });

    test('is the SHARED registry entry, not a clone — a blueprint is read, '
        'never initialized', () {
      final item = buildableFor('t1_prop_workstation_smelter');

      expect(
        identical(
          item.blueprint,
          locator<PropRegistry>().getProp('t1_prop_workstation_smelter'),
        ),
        isTrue,
      );
    });

    test('an id in no registry crashes at the first read (rule 5)', () {
      final item = buildableFor('t1_prop_that_nobody_authored');

      expect(() => item.blueprint, throwsStateError);
    });
  });

  group('a buildable that builds nothing cannot be authored', () {
    test('a document without blueprint_id is a crash', () {
      expect(
        () => ItemBuildableData.fromJson(
          <String, Object?>{'id': 't1_item_buildable_probe'},
        ),
        throwsStateError,
      );
    });

    test('an EMPTY blueprint_id is the same crash, not an empty blueprint', () {
      expect(
        () => ItemBuildableData.fromJson(<String, Object?>{
          'id': 't1_item_buildable_probe',
          'blueprint_id': '',
        }),
        throwsStateError,
      );
    });
  });

  test('the clone carries the blueprint (rule 3)', () {
    final item = ItemBuildableData.fromJson(<String, Object?>{
      'id': 't1_item_buildable_workstation_smelter',
      'blueprint_id': 't1_prop_workstation_smelter',
      'action_range': 1,
      'max_stack': 1,
    });

    final copy = item.clone();
    expect(copy, isA<ItemBuildableData>());
    expect(copy.blueprintId, 't1_prop_workstation_smelter');
    expect(copy.actionRange, 1.0);
    expect(copy.maxStack, 1);
    expect(copy.blueprint.id, 't1_prop_workstation_smelter');
  });
}
