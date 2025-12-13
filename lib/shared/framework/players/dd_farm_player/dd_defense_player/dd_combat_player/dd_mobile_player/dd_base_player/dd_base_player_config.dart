import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

class DDBasePlayerConfig {
  final RectangleHitbox hitbox;
  final LightingConfig lighting;
  final DDDecoration Function(Vector2 position) getDeathMarker;

  DDBasePlayerConfig({
    required this.hitbox,
    required this.lighting,
    required this.getDeathMarker,
  });
}
