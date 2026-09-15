import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5(f): the name a player reads. The pack has authored a
/// `display_name_key` on every document since the first import and nothing
/// read it — this is the class that does.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<LocalizationSystem>().loadLocale('en', <String, Object?>{
      'strings': <String, Object?>{
        'item.plank.name': 'Plank',
        'item.plank.desc': 'Flat, and enough of them is a house.',
      },
    });
  });
  tearDown(resetCoreSystems);

  ItemData plank({bool named = true, bool described = true}) =>
      ItemData.fromJson(<String, Object?>{
        'id': 't1_item_plank',
        if (named) 'display_name_key': 'item.plank.name',
        if (described) 'description_key': 'item.plank.desc',
      });

  test('the key is read off the document and answered in the locale', () {
    final item = plank();

    expect(item.displayNameKey, 'item.plank.name');
    expect(item.displayName, 'Plank');
    expect(item.description, 'Flat, and enough of them is a house.');
  });

  test('a document with no name key CRASHES when asked for the name', () {
    // Rule 5: an id on screen is not a degraded name, it is a content bug
    // wearing a name's clothes.
    expect(() => plank(named: false).displayName, throwsStateError);
  });

  test('a document with no description key answers with nothing', () {
    // The one asymmetry, and it is the spec's: descriptions are optional.
    expect(plank(described: false).description, isEmpty);
  });

  test("a clone carries the keys — a copy of a thing has the thing's name",
      () {
    final clone = plank().clone();

    expect(clone.displayName, 'Plank');
    expect(clone.descriptionKey, 'item.plank.desc');
  });

  test('the whole world-object hierarchy inherits it, not just items', () {
    final bench = PropWorkstationData.fromJson(<String, Object?>{
      'id': 't1_prop_workstation_bench',
      'workstation_type': 'WORKSHOP',
      'display_name_key': 'item.plank.name',
    });

    expect(bench.displayName, 'Plank');
    expect(bench.clone().displayName, 'Plank');
  });
}
