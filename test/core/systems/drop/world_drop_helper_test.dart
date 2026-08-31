import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_empty_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/drop/world_drop_helper.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.1c: where a drop may come to rest — walkable ground at the SOURCE's
/// own elevation, rings outward, the origin as the honest sealed-pocket
/// answer.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  GridManager grid() => locator<GridManager>();

  void registerTerrain(GridPos pos, {int elevation = 0}) {
    grid().registerGroundData(
      pos,
      GroundBuildableData(id: 't1_ground_buildable_terrain'),
    );
    if (elevation > 0) grid().registerElevationTile(pos, elevation);
  }

  void registerWater(GridPos pos) {
    grid().registerGroundData(
      pos,
      GroundEmptyData(id: 't1_ground_empty_water', isWater: true),
    );
  }

  test('a clear desired position is honored untouched', () {
    registerTerrain(const GridPos(0, 0));
    registerTerrain(const GridPos(1, 0));
    final origin = grid().gridToWorld(const GridPos(0, 0));
    final desired = grid().gridToWorld(const GridPos(1, 0));

    expect(WorldDropHelper.resolveLandingPosition(desired, origin), desired);
  });

  test('a drop into the sea walks the rings to the nearest shore', () {
    registerTerrain(const GridPos(0, 0));
    registerTerrain(const GridPos(1, 0));
    registerWater(const GridPos(2, 0));
    final origin = grid().gridToWorld(const GridPos(0, 0));
    final desired = grid().gridToWorld(const GridPos(2, 0));

    // The only walkable tile within ring 1 of the water tile is the shore.
    expect(
      WorldDropHelper.resolveLandingPosition(desired, origin),
      grid().gridToWorld(const GridPos(1, 0)),
    );
  });

  test('a wall reads walkable but at the wrong height — refused', () {
    registerTerrain(const GridPos(0, 0));
    registerTerrain(const GridPos(1, 0), elevation: 1);
    final origin = grid().gridToWorld(const GridPos(0, 0));
    final desired = grid().gridToWorld(const GridPos(1, 0));

    // The wall is refused for the flat origin; the flat tile beside it (the
    // origin's own) is the nearest match at the reference height.
    expect(
      WorldDropHelper.resolveLandingPosition(desired, origin),
      grid().gridToWorld(const GridPos(0, 0)),
    );
  });

  test('a sealed pocket answers the origin — honestly, not as a fallback',
      () {
    // The origin tile itself is a wall pocket: nothing walkable anywhere.
    final origin = grid().gridToWorld(const GridPos(0, 0));
    final desired = grid().gridToWorld(const GridPos(3, 3));

    expect(WorldDropHelper.resolveLandingPosition(desired, origin), origin);
  });

  test('spawnPickup births through the factory and announces on the bus', () {
    registerTerrain(const GridPos(0, 0));
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_probe',
      'max_stack': 10,
    });
    final spawned = <Object>[];
    locator<Events>().pickupSpawned.connect(spawned.add);

    final origin = grid().gridToWorld(const GridPos(0, 0));
    final pickup = WorldDropHelper.spawnPickup(
      locator<ItemRegistry>().getItem('t1_item_probe'),
      3,
      origin,
      origin,
    );

    expect(spawned.single, same(pickup));
    expect(pickup.itemData.id, 't1_item_probe');
    expect(pickup.amount, 3);
    expect(pickup.position, origin);
    // The pickup owns a CLONE of the registry resource (rule 3).
    expect(
      identical(
        pickup.itemData,
        locator<ItemRegistry>().getItem('t1_item_probe'),
      ),
      isFalse,
    );
    expect(pickup, isA<ItemWorld>());
  });
}
