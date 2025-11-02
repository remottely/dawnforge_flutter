import 'package:bonfire/bonfire.dart';

class HitboxUtils {
  static RectangleHitbox createExpandHitbox(Vector2 componentSize) =>
      RectangleHitbox(size: componentSize);

  static RectangleHitbox createCenterHitbox({
    required Vector2 textureSize,
    required double hitboxStartPositionX,
    required double hitboxStartPositionY,
  }) => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      textureSize.x - (2 * hitboxStartPositionX),
      textureSize.y - (2 * hitboxStartPositionY),
    ),
  );

  static RectangleHitbox createBottomHitbox({
    required Vector2 textureSize,
    required double hitboxStartPositionX,
    required double hitboxStartPositionY,
  }) => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      textureSize.x - (2 * hitboxStartPositionX),
      textureSize.y - hitboxStartPositionY,
    ),
  );
}
