import 'package:dawnforge/src/core/base/world_objects/helpers/actor_occupancy_helper.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/actor_tracker.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3a: the one definition of "somebody is standing there".
///
/// Every case below is one of the holes the spec's header records. Its rule
/// was once written three times with three different breadths, and the three
/// copies disagreed in exactly these places: an origin-tile comparison that
/// missed a straddling body, an anchor-only test that missed the rest of a
/// multi-tile footprint, and a hard-coded list of what may be broken
/// underfoot instead of asking the object.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe',
    });
    // A bush: standing on it and breaking it leaves you on the same ground.
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_probe_bush',
      'allows_actor_overlap': true,
    });
    // A shaft: what it IS is the ground. It may not go out from under anyone.
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_probe_shaft',
      'allows_actor_overlap': false,
    });
    // Three tiles wide, and it may not appear around somebody.
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_probe_hall',
      'allows_actor_overlap': false,
      'grid_size': <int>[3, 2],
    });
  });
  tearDown(resetCoreSystems);

  const tile = GameConstants.tileDimension;
  GridManager grid() => locator<GridManager>();

  /// An actor standing at the CENTRE of [at].
  void standAt(GridPos at) =>
      ActorFactory.create('t1_actor_probe', grid().gridToWorld(at));

  test('an actor joins the world it is created into, and can leave it', () {
    final tracker = locator<ActorTracker>();
    expect(tracker.count, 0);

    final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);
    expect(tracker.count, 1, reason: 'the factory is the only way in (rule 1)');

    actor.leaveWorld();
    expect(tracker.count, 0);
  });

  test('an empty tile is unoccupied; a tile with somebody on it is not', () {
    expect(ActorOccupancyHelper.isAreaOccupied(const GridPos(4, 4)), isFalse);
    standAt(const GridPos(4, 4));
    expect(ActorOccupancyHelper.isAreaOccupied(const GridPos(4, 4)), isTrue);
  });

  test('a body straddling two tiles counts as standing on BOTH', () {
    // Just past the boundary between (4,4) and (5,4): the position is inside
    // (5,4), but the body — a quarter-tile half-extent — still reaches back.
    // The origin-tile comparison the spec replaced answered "only (5,4)", and
    // that is how a floor got cut from under somebody's heel.
    final boundary = grid().gridToWorld(const GridPos(4, 4));
    ActorFactory.create(
      't1_actor_probe',
      WorldPos(boundary.x + tile / 2 + 1, boundary.y),
    );

    expect(ActorOccupancyHelper.isAreaOccupied(const GridPos(5, 4)), isTrue);
    expect(ActorOccupancyHelper.isAreaOccupied(const GridPos(4, 4)), isTrue,
        reason: 'the tile the body reaches back into is occupied too');
  });

  test('a tile the body only touches at the edge is free', () {
    // Dead centre of (4,4): the body spans a quarter tile each way, so it
    // comes nowhere near (6,4). Refusing the tile beside a player would make
    // the ground next to them unbuildable.
    standAt(const GridPos(4, 4));
    expect(ActorOccupancyHelper.isAreaOccupied(const GridPos(6, 4)), isFalse);
  });

  test('a multi-tile area is blocked by somebody anywhere in it, not just at '
      'the anchor', () {
    standAt(const GridPos(9, 4));
    final hall = locator<PropRegistry>().getProp('t1_prop_probe_hall');

    // The anchor is (7,4) and the actor stands two tiles along it. The
    // anchor-only test the spec replaced said this was fine, and the 3×2
    // building then appeared around the player.
    expect(ActorOccupancyHelper.isPlacementBlocked(hall, const GridPos(7, 4)),
        isTrue);
    expect(ActorOccupancyHelper.isAreaOccupied(const GridPos(7, 4)), isFalse,
        reason: 'the anchor tile alone really is empty — that is the trap');
  });

  test('permission is CONTENT: the same tile refuses one prop and allows '
      'another', () {
    standAt(const GridPos(4, 4));
    final props = locator<PropRegistry>();

    // A bush may be planted at your feet; a shaft may not. Nothing about the
    // tile differs — only what the two objects author.
    expect(
      ActorOccupancyHelper.isPlacementBlocked(
        props.getProp('t1_prop_probe_bush'),
        const GridPos(4, 4),
      ),
      isFalse,
    );
    expect(
      ActorOccupancyHelper.isPlacementBlocked(
        props.getProp('t1_prop_probe_shaft'),
        const GridPos(4, 4),
      ),
      isTrue,
    );
  });

  test('destruction asks the OBJECT whether it may go out from under you', () {
    const bushTile = GridPos(4, 4);
    const shaftTile = GridPos(9, 9);
    final bush =
        PropFactory.create('t1_prop_probe_bush', grid().gridToWorld(bushTile));
    final shaft = PropFactory.create(
      't1_prop_probe_shaft',
      grid().gridToWorld(shaftTile),
    );
    grid()
      ..occupyPropTiles(bushTile, bush)
      ..occupyPropTiles(shaftTile, shaft);

    // Nobody standing on either: both may be broken, whatever they author.
    expect(ActorOccupancyHelper.isDestructionBlocked(bush), isFalse);
    expect(ActorOccupancyHelper.isDestructionBlocked(shaft), isFalse);

    standAt(bushTile);
    standAt(shaftTile);

    // The same actor, the same act, opposite answers — decided entirely by
    // what the two objects author. Breaking a bush leaves you on the ground
    // you were already on; the shaft IS that ground.
    expect(ActorOccupancyHelper.isDestructionBlocked(bush), isFalse);
    expect(ActorOccupancyHelper.isDestructionBlocked(shaft), isTrue,
        reason: 'this is the staircase that sealed a player inside the rock');
  });

  test('a prop the grid does not hold occupies no ground to stand on', () {
    const at = GridPos(4, 4);
    standAt(at);
    // Built but never registered: nothing is standing ON it, whatever stands
    // near it. Refusing here would make an unplaced blueprint indestructible.
    final loose =
        PropFactory.create('t1_prop_probe_shaft', grid().gridToWorld(at));
    expect(ActorOccupancyHelper.isDestructionBlocked(loose), isFalse);
  });

  test('an area rect starts at the tile CORNER and covers whole tiles', () {
    final rect = ActorOccupancyHelper.areaRect(
      const GridPos(0, 0),
      width: 3,
      height: 2,
    );
    expect(rect.width, tile * 3);
    expect(rect.height, tile * 2);
    // `gridToWorld` answers with a centre; an area starts half a tile before
    // it. Getting this off by half a tile is invisible until something is
    // refused one tile away from where it should have been.
    final centre = grid().gridToWorld(const GridPos(0, 0));
    expect(rect.left, centre.x - tile / 2);
    expect(rect.top, centre.y - tile / 2);
  });
}
