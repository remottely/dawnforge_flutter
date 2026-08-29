import 'package:dawnforge/src/core/base/world_objects/helpers/world_placement_helper.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3b slice 2: where a blueprint may land, answered once, with the gate
/// that refused NAMED.
///
/// The order is the port. Two of these tiles are refused by more than one gate
/// at once, and which reason comes back is the assertion that keeps the order
/// from being rearranged into something that reads safer and is not.
void main() {
  setUp(() {
    registerCoreSystems();

    locator<GroundRegistry>()
      ..registerJson(<String, Object?>{
        'type': 'ground_buildable_data',
        'id': 't1_ground_buildable_terrain',
      })
      // Water and cliff refuse props THEMSELVES — the authored flag is the
      // whole reason no code here has a water branch (rule 33).
      ..registerJson(<String, Object?>{
        'type': 'ground_empty_data',
        'id': 't1_ground_empty_water',
        'is_water': true,
        'is_passable': false,
        'blocks_props': true,
      });

    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe',
    });

    locator<PropRegistry>()
      // A torch: it may be planted at your feet, because it says so.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_torch',
        'allows_actor_overlap': true,
      })
      // A shaft: what it IS is the ground, so it may not appear under anyone.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_shaft',
        'allows_actor_overlap': false,
      })
      // The smelter's shape: two tiles wide, one tall.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_smelter',
        'allows_actor_overlap': false,
        'grid_size': <int>[2, 1],
      });
  });

  tearDown(resetCoreSystems);

  GridManager grid() => locator<GridManager>();
  PropData blueprint(String id) => locator<PropRegistry>().getProp(id);

  /// Lays terrain over [from]..[to] inclusive, so a footprint has something to
  /// stand on.
  void layTerrain(GridPos from, GridPos to) {
    final data = locator<GroundRegistry>().getGround('t1_ground_buildable_terrain');
    for (var x = from.x; x <= to.x; x++) {
      for (var y = from.y; y <= to.y; y++) {
        grid().registerGroundData(GridPos(x, y), data);
      }
    }
  }

  void standAt(GridPos at) =>
      ActorFactory.create('t1_actor_probe', grid().gridToWorld(at));

  /// Puts a prop on the grid the way the world does — factory, then claim.
  void occupy(String id, GridPos at) => grid()
      .occupyPropTiles(at, PropFactory.create(id, grid().gridToWorld(at)));

  group('the ground under it', () {
    test('open terrain takes a prop', () {
      layTerrain(const GridPos(0, 0), const GridPos(4, 4));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_torch'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.allowed,
      );
      expect(
        WorldPlacementHelper.canPlaceProp(
          blueprint('t1_prop_probe_torch'),
          const GridPos(2, 2),
        ),
        isTrue,
      );
    });

    test('the VOID takes nothing — a tile outside the streamed window is not '
        'a place to build', () {
      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_torch'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.needsGround,
      );
    });

    test('water refuses because water says so, not because code checks for it',
        () {
      final water = locator<GroundRegistry>().getGround('t1_ground_empty_water');
      grid().registerGroundData(const GridPos(2, 2), water);

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_torch'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.needsGround,
      );
    });

    test('the WHOLE footprint needs ground, not just the anchor', () {
      // Terrain under (2,2) only; the smelter's second tile hangs over nothing.
      layTerrain(const GridPos(2, 2), const GridPos(2, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_smelter'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.needsGround,
      );

      layTerrain(const GridPos(3, 2), const GridPos(3, 2));
      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_smelter'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.allowed,
      );
    });
  });

  group('what is already there', () {
    test('a tile another prop holds is refused', () {
      layTerrain(const GridPos(0, 0), const GridPos(4, 4));
      occupy('t1_prop_probe_torch', const GridPos(2, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_torch'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.tileOccupied,
      );
    });

    test('the WHOLE footprint is asked — a 2x1 whose anchor is free still has '
        'a second tile', () {
      layTerrain(const GridPos(0, 0), const GridPos(4, 4));
      occupy('t1_prop_probe_torch', const GridPos(3, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_smelter'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.tileOccupied,
      );
    });
  });

  group('nobody is built on top of', () {
    test('a prop that may not share a tile is refused at your feet', () {
      layTerrain(const GridPos(0, 0), const GridPos(4, 4));
      standAt(const GridPos(2, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_shaft'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.actorInTheWay,
      );
    });

    test('permission is CONTENT: a torch may be planted at those same feet',
        () {
      layTerrain(const GridPos(0, 0), const GridPos(4, 4));
      standAt(const GridPos(2, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_torch'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.allowed,
      );
    });

    test('the WHOLE footprint again — a 2x1 built AROUND somebody traps them '
        'just as well as one built ON them', () {
      layTerrain(const GridPos(0, 0), const GridPos(4, 4));
      standAt(const GridPos(3, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_smelter'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.actorInTheWay,
      );
    });
  });

  group('the order the spec insists on', () {
    test('an actor answers BEFORE the tile that is also occupied', () {
      // Both gates refuse this tile. The spec asks occupancy first and above
      // every early-return, so that no blueprint type can reach a later gate
      // and return before the actor is considered — put the prop-occupancy
      // rule on top instead and the reason a player is shown becomes whichever
      // gate happens to be cheapest to evaluate.
      layTerrain(const GridPos(0, 0), const GridPos(4, 4));
      occupy('t1_prop_probe_torch', const GridPos(2, 2));
      standAt(const GridPos(2, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_shaft'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.actorInTheWay,
      );
    });

    test('an actor answers BEFORE the ground that is not there either', () {
      standAt(const GridPos(2, 2));

      expect(
        WorldPlacementHelper.placePropRefusal(
          blueprint('t1_prop_probe_shaft'),
          const GridPos(2, 2),
        ),
        PlacementRefusal.actorInTheWay,
      );
    });
  });
}
