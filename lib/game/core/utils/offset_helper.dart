import 'package:bonfire/bonfire.dart';

final class OffsetHelper {
  OffsetHelper._();

  /// Calculates the rotated attack offset for the current direction.
  ///
  /// [rightOffset] is the offset Vector2 as if the player were
  /// looking to the RIGHT.
  /// - `rightOffset.x` is the "forward" distance.
  /// - `rightOffset.y` is the "sideways" distance (positive values are down).
  static Vector2 getCenterOffset(Vector2 rightOffset, Direction lastDirection) {
    // "Forward" component (e.g., 6)
    final double fwd = rightOffset.x;
    // "Sideways" component (e.g., 0)
    final double side = rightOffset.y;

    // k is the normalization factor for diagonals ( 1 / sqrt(2) )
    const double k = 0.7071067811865475; // 1 / sqrt(2)

    switch (lastDirection) {
      // --- Cardinals ---

      case Direction.right:
        // Position X = fwd
        // Position Y = side
        return Vector2(fwd, side);

      case Direction.left:
        // Position X = -fwd
        // Position Y = side
        return Vector2(-fwd, side);

      case Direction.up:
        // Position X = side (rotated)
        // Position Y = -fwd (rotated)
        return Vector2(side, -fwd);

      case Direction.down:
        // Position X = -side (rotated)
        // Position Y = fwd (rotated)
        return Vector2(-side, fwd);

      // --- Diagonals ---

      case Direction.upRight:
        // "Forward" vector (fwd) rotated by -45°
        // "Sideways" vector (side) rotated by -45°
        return Vector2((fwd * k) + (side * k), (-fwd * k) + (side * k));

      case Direction.upLeft:
        // Rotated by -135°
        return Vector2((-fwd * k) + (side * k), (-fwd * k) - (side * k));

      case Direction.downLeft:
        // Rotated by 135°
        return Vector2((-fwd * k) - (side * k), (fwd * k) - (side * k));

      case Direction.downRight:
        // Rotated by 45°
        return Vector2((fwd * k) - (side * k), (fwd * k) + (side * k));
    }
  }
}
