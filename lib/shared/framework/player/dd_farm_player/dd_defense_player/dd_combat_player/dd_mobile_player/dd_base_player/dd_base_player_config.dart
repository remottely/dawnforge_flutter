import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

class DDBasePlayerViewConfig {
  final RectangleHitbox hitbox;
  final LightingConfig lighting;
  final DDDecoration Function(Vector2 position) getDeathMarker;

  DDBasePlayerViewConfig({
    required this.hitbox,
    required this.lighting,
    required this.getDeathMarker,
  });
}
