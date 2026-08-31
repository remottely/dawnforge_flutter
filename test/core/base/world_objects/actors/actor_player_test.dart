import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/actors/player/actor_player.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3a slice 6: the press becomes a swing. What the cursor is over is the
/// only candidate, the reach is the item's, and the pace is the actor's.
void main() {
  setUp(() {
    registerCoreSystems();

    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{
        'id': 't1_item_logs_probe',
        'max_stack': 10,
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_axe',
        'tool_type': 'AXE',
        'tier': 1,
        'attack_damage': 2,
        // One tile of reach, measured edge to edge.
        'action_range': 1.0,
      })
      // Bare hands: what this player holds between being created and being
      // handed the axe. Named here since FP4.3b slice 4, which BUILDS the hand
      // when the components are assembled instead of only remembering its id —
      // so the empty starting slot resolves for real, at creation.
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
        'tier': 1,
      });

    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 30,
      // Two swings a second, so the cooldown is half a second.
      'base_action_speed': 2.0,
    });

    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_probe_tree',
      'allowed_tools': <String>['AXE'],
      'tier': 1,
      'base_max_health': 100,
      'allows_actor_overlap': true,
      'drops': <Map<String, Object?>>[
        <String, Object?>{
          'item_id': 't1_item_logs_probe',
          'chance': 1.0,
          'min_amount': 1,
          'max_amount': 1,
        },
      ],
    });

    final grid = locator<GridManager>();
    for (var x = -2; x <= 14; x++) {
      for (var y = -2; y <= 14; y++) {
        grid.registerGroundData(
          GridPos(x, y),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      }
    }
  });
  tearDown(resetCoreSystems);

  GridManager grid() => locator<GridManager>();

  /// Puts the cursor at [at]. The projection is what the render layer binds
  /// at boot; a test binds one that answers with the world point it wants,
  /// which is exactly what `getCursorWorldPos` is asked for.
  void aimAt(GridPos at) {
    final point = grid().gridToWorld(at);
    locator<InputHelper>().screenToWorld = (_) => point;
  }

  ActorPlayer playerAt(GridPos at) {
    final player =
        ActorFactory.createPlayer('t1_actor_probe_player', grid().gridToWorld(at));
    player.inventory
        .setSlot(0, locator<ItemRegistry>().getItem('t1_item_tool_axe'), 1);
    return player;
  }

  Prop treeAt(GridPos at) {
    final prop = PropFactory.create(
      't1_prop_probe_tree',
      grid().gridToWorld(at),
      random: Random(20260826),
    );
    grid().occupyPropTiles(at, prop);
    return prop;
  }

  test('the player is the actor the PACK authors into the player group', () {
    locator<ActorRegistry>()
        .registerJson(<String, Object?>{'id': 't1_actor_probe_boar'});

    expect(ActorFactory.create('t1_actor_probe_player', WorldPos.zero),
        isA<ActorPlayer>());
    expect(ActorFactory.create('t1_actor_probe_boar', WorldPos.zero),
        isNot(isA<ActorPlayer>()));
  });

  test('a press swings at what the cursor is over, and at nothing else', () {
    final player = playerAt(const GridPos(5, 5));
    final aimed = treeAt(const GridPos(6, 5));
    final other = treeAt(const GridPos(4, 5));

    aimAt(const GridPos(6, 5));
    expect(player.performPrimaryAction(), isTrue);

    expect(aimed.health.current, 98);
    expect(other.health.current, 100,
        reason: 'the strict single-tile rule: no splash onto the neighbour');
  });

  test('a tree out of reach is a miss, however good the tool', () {
    final player = playerAt(const GridPos(5, 5));
    final far = treeAt(const GridPos(10, 5));

    aimAt(const GridPos(10, 5));
    expect(player.performPrimaryAction(), isFalse);
    expect(far.health.current, 100);
  });

  test('reach is measured edge to edge, so the next tile over is reachable',
      () {
    // Centre to centre this is 16px, exactly a one-tile reach — but only for
    // a player standing dead on the tile centre. Edge to edge it stays
    // reachable from anywhere on the player's own tile, which is what makes
    // the reach usable at all.
    final player = playerAt(const GridPos(5, 5))
      ..position = grid().gridToWorld(const GridPos(5, 5)) + const WorldPos(5, 3);
    final tree = treeAt(const GridPos(6, 5));

    aimAt(const GridPos(6, 5));
    expect(player.performPrimaryAction(), isTrue);
    expect(tree.health.current, 98);
  });

  test('aiming at bare ground costs nothing — the next press still lands', () {
    final player = playerAt(const GridPos(5, 5));
    final tree = treeAt(const GridPos(6, 5));

    aimAt(const GridPos(5, 4));
    expect(player.performPrimaryAction(), isFalse);

    // No cooldown was spent on a swing that never happened.
    aimAt(const GridPos(6, 5));
    expect(player.performPrimaryAction(), isTrue);
    expect(tree.health.current, 98);
  });

  test('the authored action speed paces the swings', () {
    final player = playerAt(const GridPos(5, 5));
    final tree = treeAt(const GridPos(6, 5));
    aimAt(const GridPos(6, 5));

    expect(player.performPrimaryAction(), isTrue);
    expect(player.performPrimaryAction(), isFalse,
        reason: 'base_action_speed 2.0 means half a second between swings');
    expect(tree.health.current, 98);

    // Half a second of fixed steps later, the next swing is owed.
    for (var i = 0; i < 31; i++) {
      player.update(1 / 60);
    }
    expect(player.canPerformAction, isTrue);
    expect(player.performPrimaryAction(), isTrue);
    expect(tree.health.current, 96);
  });

  test('a surface that holds the player holds the swing too (rule 30)', () {
    final player = playerAt(const GridPos(5, 5));
    final tree = treeAt(const GridPos(6, 5));
    aimAt(const GridPos(6, 5));

    const bag = Object();
    locator<GameInputManager>().pushUiBlocker(bag);
    expect(player.performPrimaryAction(), isFalse);
    expect(tree.health.current, 100,
        reason: "nothing is paused — the press simply is not the world's");

    locator<GameInputManager>().popUiBlocker(bag);
    expect(player.performPrimaryAction(), isTrue);
  });
}
