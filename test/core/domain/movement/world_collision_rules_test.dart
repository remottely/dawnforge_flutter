import 'package:dawnforge/src/core/domain/movement/world_collision_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pure resolution against a fake blocker set — the `move_and_slide`
/// replacement's whole contract: blocked axes stop and zero, free axes
/// slide, and tile coverage respects the body's edges.
void main() {
  const tile = 16;
  const halfExtent = 4.0;

  ResolvedStep step({
    required WorldPos position,
    required WorldPos velocity,
    required Set<GridPos> blockers,
    double dt = 1.0,
  }) =>
      WorldCollisionRules.resolveStep(
        position: position,
        velocity: velocity,
        dt: dt,
        bodyHalfExtent: halfExtent,
        tileDimension: tile,
        blocksBody: blockers.contains,
      );

  test('free space integrates exactly — no blockers, no interference', () {
    final resolved = step(
      position: const WorldPos(8, 8),
      velocity: const WorldPos(5, -3),
      blockers: <GridPos>{},
    );
    expect(resolved.position, const WorldPos(13, 5));
    expect(resolved.velocity, const WorldPos(5, -3));
  });

  test('a wall on X stops X, zeroes vx, and lets Y slide', () {
    // Body at the center of tile (0,0); tile (1,0) is a wall to the right.
    final resolved = step(
      position: const WorldPos(8, 8),
      velocity: const WorldPos(10, 4),
      blockers: <GridPos>{const GridPos(1, 0)},
    );
    expect(resolved.position.x, 8, reason: 'x must not enter the wall');
    expect(resolved.velocity.x, 0, reason: 'the blocked axis zeroes');
    expect(resolved.position.y, 12, reason: 'y slides along the wall');
    expect(resolved.velocity.y, 4, reason: 'the free axis keeps its speed');
  });

  test('a wall on Y stops Y and lets X slide', () {
    final resolved = step(
      position: const WorldPos(8, 8),
      velocity: const WorldPos(4, 10),
      blockers: <GridPos>{const GridPos(0, 1)},
    );
    expect(resolved.position, const WorldPos(12, 8));
    expect(resolved.velocity, const WorldPos(4, 0));
  });

  test('a corner blocks both axes — the body stays put, fully stopped', () {
    final resolved = step(
      position: const WorldPos(8, 8),
      velocity: const WorldPos(10, 10),
      blockers: <GridPos>{
        const GridPos(1, 0),
        const GridPos(0, 1),
        const GridPos(1, 1),
      },
    );
    expect(resolved.position, const WorldPos(8, 8));
    expect(resolved.velocity, WorldPos.zero);
  });

  test('coverage spans every tile under the body, not just its center', () {
    // Moving right lands the body straddling tiles (0,0) and (1,0); a wall
    // in (1,0) must block even though the CENTER stays in tile 0.
    final resolved = step(
      position: const WorldPos(8, 8),
      velocity: const WorldPos(3, 0), // center 11 — right edge reaches 15
      blockers: <GridPos>{const GridPos(1, 0)},
      dt: 2, // center 14 — right edge 18, into tile 1
    );
    expect(resolved.position.x, 8);
    expect(resolved.velocity.x, 0);
  });

  test('flush against a border never reads the neighbor tile (edge inset)',
      () {
    // Body centered so its right edge sits EXACTLY on x=16 (the border of
    // wall tile (1,0)): standing there is legal; moving further is not.
    final holding = step(
      position: const WorldPos(12, 8),
      velocity: WorldPos.zero,
      blockers: <GridPos>{const GridPos(1, 0)},
    );
    expect(holding.position, const WorldPos(12, 8));

    final pushing = step(
      position: const WorldPos(12, 8),
      velocity: WorldPos.right,
      blockers: <GridPos>{const GridPos(1, 0)},
    );
    expect(pushing.position.x, 12);
    expect(pushing.velocity.x, 0);
  });
}
