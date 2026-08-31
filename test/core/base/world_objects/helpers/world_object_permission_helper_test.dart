import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_permission_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3a slice 4: a swing is refused or allowed for one reason, in one place.
///
/// The cases that matter most here are the two ORDER cases at the bottom. Both
/// gates read as safer the other way round, and both are wrong that way: the
/// spec's own comments exist because someone reordered them once.
void main() {
  setUp(() {
    registerCoreSystems();

    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_axe',
        'tool_type': 'AXE',
        'tier': 1,
      })
      ..registerJson(<String, Object?>{
        'id': 't2_item_tool_axe',
        'tool_type': 'AXE',
        'tier': 2,
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_hoe',
        'tool_type': 'HOE',
        'tier': 1,
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_shovel',
        'tool_type': 'SHOVEL',
        'tier': 1,
      })
      // Bare hands, which the player holds when a slot is empty (0.28.0).
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
        'tier': 1,
      });

    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 30,
    });

    locator<PropRegistry>()
      // A bush: an axe takes it, and standing on it changes nothing.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_bush',
        'allowed_tools': <String>['AXE'],
        'tier': 1,
        'allows_actor_overlap': true,
      })
      // Bare hands are enough for this one.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_weeds',
        'allowed_tools': <String>['INNATE'],
        'tier': 1,
        'allows_actor_overlap': true,
      })
      // A t2 rock: same axe, higher bar.
      ..registerJson(<String, Object?>{
        'id': 't2_prop_probe_rock',
        'allowed_tools': <String>['AXE'],
        'tier': 2,
        'allows_actor_overlap': true,
      })
      // Authored to answer to nothing at all.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_monolith',
        'tier': 1,
        'allows_actor_overlap': true,
      })
      // A shaft: what it IS is the ground under you.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_shaft',
        'allowed_tools': <String>['AXE'],
        'tier': 1,
        'allows_actor_overlap': false,
      });

    // Farmland: a hoe TRANSFORMS it (rule 33), a shovel would DESTROY it, and
    // it is terrain, so it may not vanish from under anybody.
    locator<GroundRegistry>().registerJson(<String, Object?>{
      'type': 'ground_buildable_data',
      'id': 't1_ground_probe_soil',
      'allowed_tools': <String>['SHOVEL'],
      'farm_tools': <String>['HOE'],
      'farm_prop_id': 't1_prop_probe_bush',
      'tier': 1,
      'allows_actor_overlap': false,
    });
  });
  tearDown(resetCoreSystems);

  GridManager grid() => locator<GridManager>();

  /// A player standing at the centre of [at], holding [itemId] — or bare
  /// hands when no id is given.
  IActor playerAt(GridPos at, {String? holding}) {
    final actor =
        ActorFactory.create('t1_actor_probe_player', grid().gridToWorld(at));
    if (holding != null) {
      actor.inventory.setSlot(0, locator<ItemRegistry>().getItem(holding), 1);
    }
    return actor;
  }

  /// A prop of [id] holding [at], registered on the grid the way a spawn does.
  Prop propAt(String id, GridPos at) {
    final prop = PropFactory.create(id, grid().gridToWorld(at));
    grid().occupyPropTiles(at, prop);
    return prop;
  }

  /// Terrain at [at] — nodeless, as the streamed world builds it (FP3.4).
  GroundTarget groundAt(GridPos at) {
    grid().registerGroundData(
      at,
      locator<GroundRegistry>().getGround('t1_ground_probe_soil'),
    );
    return GroundTarget(at);
  }

  group('the tool gate', () {
    test('the right kind of tool, good enough, breaks it', () {
      final player = playerAt(const GridPos(0, 0), holding: 't1_item_tool_axe');
      final bush = propAt('t1_prop_probe_bush', const GridPos(5, 5));

      expect(
        WorldObjectPermissionHelper.canDamageTarget(ObjectTarget(bush), player),
        isTrue,
      );
    });

    test('the wrong kind of tool is refused', () {
      final player = playerAt(const GridPos(0, 0), holding: 't1_item_tool_hoe');
      final bush = propAt('t1_prop_probe_bush', const GridPos(5, 5));

      expect(
        WorldObjectPermissionHelper.canDamageTarget(ObjectTarget(bush), player),
        isFalse,
      );
    });

    test('a tool of a lesser tier is refused; a better one is not', () {
      final rock = propAt('t2_prop_probe_rock', const GridPos(5, 5));
      final weak = playerAt(const GridPos(0, 0), holding: 't1_item_tool_axe');
      final strong = playerAt(const GridPos(1, 0), holding: 't2_item_tool_axe');

      expect(
        WorldObjectPermissionHelper.canDamageTarget(ObjectTarget(rock), weak),
        isFalse,
        reason: '"you need a better axe" is not "you need an axe"',
      );
      expect(
        WorldObjectPermissionHelper.canDamageTarget(ObjectTarget(rock), strong),
        isTrue,
      );
    });

    test('an object that allows no tools answers to none of them', () {
      final player = playerAt(const GridPos(0, 0), holding: 't1_item_tool_axe');
      final monolith = propAt('t1_prop_probe_monolith', const GridPos(5, 5));

      expect(
        WorldObjectPermissionHelper.canDamageTarget(
          ObjectTarget(monolith),
          player,
        ),
        isFalse,
      );
    });

    test('bare hands are a tool, and satisfy an object that asks for them', () {
      // The join between slice 3 and this one: the player equipped nothing, so
      // the hand holds the INNATE item, and the weeds accept exactly that.
      final player = playerAt(const GridPos(0, 0));
      final weeds = propAt('t1_prop_probe_weeds', const GridPos(5, 5));

      expect(
        WorldObjectPermissionHelper.canDamageTarget(
          ObjectTarget(weeds),
          player,
        ),
        isTrue,
      );
    });
  });

  group('nothing is destroyed out from under an actor', () {
    test('a shaft with somebody standing on it is refused', () {
      const at = GridPos(5, 5);
      final shaft = propAt('t1_prop_probe_shaft', at);
      final player = playerAt(at, holding: 't1_item_tool_axe');

      expect(
        WorldObjectPermissionHelper.canDamageTarget(
          ObjectTarget(shaft),
          player,
        ),
        isFalse,
      );

      // Step off it and the same swing with the same tool lands.
      player.position = grid().gridToWorld(const GridPos(9, 9));
      expect(
        WorldObjectPermissionHelper.canDamageTarget(
          ObjectTarget(shaft),
          player,
        ),
        isTrue,
      );
    });

    test('a bush may be broken under your own feet, because it says so', () {
      const at = GridPos(5, 5);
      final bush = propAt('t1_prop_probe_bush', at);
      final player = playerAt(at, holding: 't1_item_tool_axe');

      expect(
        WorldObjectPermissionHelper.canDamageTarget(ObjectTarget(bush), player),
        isTrue,
        reason: "the permission is the object's, not the helper's",
      );
    });
  });

  group('the order the spec insists on', () {
    test('TILLING the tile you are standing on stays legal', () {
      // Trap one. The soil forbids actor overlap — it is terrain — and the
      // player is standing on it. Move the occupancy rule above the farm
      // bypass, which reads as the safer arrangement, and this returns false:
      // you can no longer till the ground under your feet, silently.
      const at = GridPos(5, 5);
      final ground = groundAt(at);
      final player = playerAt(at, holding: 't1_item_tool_hoe');

      expect(WorldObjectPermissionHelper.canFarmTarget(ground, player), isTrue);
      expect(
        WorldObjectPermissionHelper.canDamageTarget(ground, player),
        isTrue,
      );
    });

    test('DESTROYING that same tile while standing on it is refused', () {
      const at = GridPos(5, 5);
      final ground = groundAt(at);
      final player = playerAt(at, holding: 't1_item_tool_shovel');

      expect(WorldObjectPermissionHelper.canFarmTarget(ground, player), isFalse,
          reason: "a shovel is not one of this soil's farm tools");
      expect(
        WorldObjectPermissionHelper.canDamageTarget(ground, player),
        isFalse,
      );

      // And the refusal really was the occupancy clause: step away and the
      // shovel is accepted, since it IS one of the soil's allowed tools.
      player.position = grid().gridToWorld(const GridPos(9, 9));
      expect(
        WorldObjectPermissionHelper.canDamageTarget(ground, player),
        isTrue,
      );
    });

    test('ground is asked ONCE, through the clause that has the extra rule',
        () {
      // Trap two. Nobody is standing anywhere here, so the generic occupancy
      // clause would allow this. Ground does not go through it: it goes
      // through canGroundBeDestroyed, which carries a clause of its own — a
      // tile holding a prop is not pulled out from under the prop.
      const at = GridPos(5, 5);
      final ground = groundAt(at);
      propAt('t1_prop_probe_bush', at);
      final player =
          playerAt(const GridPos(0, 0), holding: 't1_item_tool_shovel');

      expect(
        WorldObjectPermissionHelper.canGroundBeDestroyed(at),
        isFalse,
        reason: 'the prop clause is the one the generic rule does not have',
      );
      expect(
        WorldObjectPermissionHelper.canDamageTarget(ground, player),
        isFalse,
      );
    });

    test('a transform with nowhere to put what it plants is not a farm act',
        () {
      // The farm bypass is not a free pass: it asks for room for the prop the
      // transform spawns. With the tile taken, the act falls through to the
      // destruction lock — which refuses it for the prop standing there.
      const at = GridPos(5, 5);
      final ground = groundAt(at);
      propAt('t1_prop_probe_bush', at);
      final player = playerAt(const GridPos(0, 0), holding: 't1_item_tool_hoe');

      expect(WorldObjectPermissionHelper.canFarmTarget(ground, player), isFalse);
      expect(
        WorldObjectPermissionHelper.canDamageTarget(ground, player),
        isFalse,
      );
    });
  });
}
