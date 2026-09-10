import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/loadout_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/progression/starting_loadout_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5(g): what a new world puts in the bag, and what it refuses to.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_pickaxe_copper',
        'tool_type': 'PICKAXE',
        'max_stack': 1,
        'tier': 1,
      })
      ..registerJson(<String, Object?>{'id': 't1_item_coal', 'max_stack': 100})
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
        'tier': 1,
      });
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 2,
    });
  });
  tearDown(resetCoreSystems);

  void loadout(String id, List<Map<String, Object?>> entries, {int xp = 0}) {
    locator<LoadoutRegistry>().registerJson(<String, Object?>{
      'id': id,
      'entries': entries,
      'granted_xp': xp,
    });
  }

  test('grants every line, whole, into the bag', () {
    loadout('starting_loadout_default', <Map<String, Object?>>[
      <String, Object?>{'id': 't1_item_tool_melee_pickaxe_copper', 'amount': 1},
      <String, Object?>{'id': 't1_item_coal', 'amount': 5},
    ]);
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);

    StartingLoadoutRules.apply(player);

    expect(player.inventory.countOf('t1_item_tool_melee_pickaxe_copper'), 1);
    expect(player.inventory.countOf('t1_item_coal'), 5);
  });

  test('an empty loadout grants nothing and is not an error', () {
    loadout('starting_loadout_default', <Map<String, Object?>>[]);
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    StartingLoadoutRules.apply(player);
    expect(player.inventory.slots.every((s) => s.isEmpty), isTrue);
  });

  test('a loadout that names no authored item crashes, not skips', () {
    loadout('starting_loadout_default', <Map<String, Object?>>[
      <String, Object?>{'id': 't9_item_nothing', 'amount': 1},
    ]);
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    expect(() => StartingLoadoutRules.apply(player), throwsStateError);
  });

  test('a loadout the bag cannot hold is a content error', () {
    // Two slots, three unstackable pickaxes.
    loadout('starting_loadout_default', <Map<String, Object?>>[
      <String, Object?>{'id': 't1_item_tool_melee_pickaxe_copper', 'amount': 3},
    ]);
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    expect(() => StartingLoadoutRules.apply(player),
        throwsA(isA<AssertionError>()));
  });

  test('XP has nowhere to land yet, so authoring it is refused', () {
    loadout('starting_loadout_default', <Map<String, Object?>>[], xp: 10);
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    expect(() => StartingLoadoutRules.apply(player),
        throwsA(isA<AssertionError>()));
  });
}
