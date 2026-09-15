import 'package:dawnforge/src/core/registries/loadout_registry.dart';
import 'package:dawnforge/src/core/resources/progression/i_starting_loadout_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/data/almanac_loader.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5(g): the loadout document, read and routed.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  test('reads the two required fields', () {
    final loadout = IStartingLoadoutData.fromJson(<String, Object?>{
      'id': 'starting_loadout_default',
      'type': 'i_starting_loadout_data',
      'entries': <Map<String, Object?>>[
        <String, Object?>{'id': 't1_item_tool_melee_pickaxe_copper', 'amount': 1},
      ],
      'granted_xp': 0,
    });
    expect(loadout.entries.single.itemId, 't1_item_tool_melee_pickaxe_copper');
    expect(loadout.grantedXp, 0);
  });

  test('an empty list is a real answer, an absent one is not', () {
    expect(
      IStartingLoadoutData.fromJson(<String, Object?>{
        'id': 'starting_loadout_nothing',
        'entries': <Map<String, Object?>>[],
        'granted_xp': 0,
      }).entries,
      isEmpty,
    );
    expect(
      () => IStartingLoadoutData.fromJson(<String, Object?>{
        'id': 'starting_loadout_broken',
        'granted_xp': 0,
      }),
      throwsA(isA<Error>()),
    );
  });

  test('the manifest routes the type family to its registry', () {
    const AlmanacLoader().loadFromManifest(
      <String, Object?>{
        'entries': <Map<String, Object?>>[
          <String, Object?>{
            'id': 'starting_loadout_default',
            'type': 'i_starting_loadout_data',
            'path': 'starting_loadout_default.json',
          },
        ],
      },
      (path) => <String, Object?>{
        'id': 'starting_loadout_default',
        'type': 'i_starting_loadout_data',
        'entries': <Map<String, Object?>>[],
        'granted_xp': 0,
      },
    );
    expect(locator<LoadoutRegistry>().has('starting_loadout_default'), isTrue);
  });
}
