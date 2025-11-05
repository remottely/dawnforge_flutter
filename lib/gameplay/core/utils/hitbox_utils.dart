import 'package:bonfire/bonfire.dart';

final class HitboxUtils {
  HitboxUtils._();

  static RectangleHitbox createExpandHitbox(Vector2 componentSize) =>
      RectangleHitbox(size: componentSize);

  static RectangleHitbox createCenterHitbox({
    required Vector2 componentSize,
    required double hitboxStartPositionX,
    required double hitboxStartPositionY,
  }) => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      componentSize.x - (2 * hitboxStartPositionX),
      componentSize.y - (2 * hitboxStartPositionY),
    ),
  );

  static RectangleHitbox createBottomHitbox({
    required Vector2 componentSize,
    required double hitboxStartPositionX,
    required double hitboxStartPositionY,
  }) => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      componentSize.x - (2 * hitboxStartPositionX),
      componentSize.y - hitboxStartPositionY,
    ),
  );
}
