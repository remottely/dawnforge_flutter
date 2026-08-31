import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3a slice 6: the aim is measured ONCE, where the press happened, and
/// carries every form a consumer could ask for. Every case here is one the
/// spec's header records as having gone wrong when it did not.
void main() {
  test('an aim at a point keeps the point AND the heading to it', () {
    final aim = AimSnapshot.fromPoint(
      WorldPos.zero,
      const WorldPos(30, 40),
      WorldPos.right,
    );

    expect(aim.origin, WorldPos.zero);
    expect(aim.point, const WorldPos(30, 40));
    // 3-4-5: the heading is normalized once, here, and never re-derived.
    expect(aim.direction.x, closeTo(0.6, 1e-9));
    expect(aim.direction.y, closeTo(0.8, 1e-9));
  });

  test('the direction survives the aimer walking away from the point', () {
    // THE BUG THIS CLASS EXISTS FOR. The old shape carried a bare point and
    // subtracted the shooter's position at the FAR end; once the walk had
    // carried them past what they aimed at, the vector's sign flipped and the
    // shot flew backwards. Here the heading is a value, so walking cannot
    // touch it — only a NEW aim can.
    final aim = AimSnapshot.fromPoint(
      WorldPos.zero,
      const WorldPos(16, 0),
      WorldPos.right,
    );
    expect(aim.direction, WorldPos.right);

    const walkedPast = WorldPos(64, 0);
    final rederived = (aim.point - walkedPast).normalized();
    expect(rederived, const WorldPos(-1, 0),
        reason: 'this is what the old shape computed — backwards');
    expect(aim.direction, WorldPos.right,
        reason: 'and this is what the snapshot still says');
  });

  test('aiming at your own feet keeps your facing, never a zero heading', () {
    final aim = AimSnapshot.fromPoint(
      const WorldPos(100, 100),
      const WorldPos(100, 100),
      const WorldPos(0, -1),
    );

    expect(aim.direction, const WorldPos(0, -1));
  });

  test('a raw vector shorter than one unit is not a heading', () {
    // Half a pixel of cursor drift is not a decision; the facing stands.
    final aim = AimSnapshot.fromPoint(
      WorldPos.zero,
      const WorldPos(0.5, 0),
      WorldPos.right,
    );
    expect(aim.direction, WorldPos.right);
  });

  test('an aim along a direction lands its point at the reach', () {
    final aim = AimSnapshot.fromDirection(
      const WorldPos(10, 10),
      const WorldPos(0, 5),
      16,
    );

    expect(aim.direction, const WorldPos(0, 1));
    expect(aim.point, const WorldPos(10, 26));
  });

  test('a reach of zero is honest for an action with no target', () {
    final aim = AimSnapshot.fromDirection(WorldPos.zero, WorldPos.right, 0);

    expect(aim.point, WorldPos.zero);
    expect(aim.direction, WorldPos.right);
  });
}
