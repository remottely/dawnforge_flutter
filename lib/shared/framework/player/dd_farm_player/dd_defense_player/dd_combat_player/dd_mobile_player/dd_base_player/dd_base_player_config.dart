import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

class DDBasePlayerViewConfig {
  final RectangleHitbox hitbox;
  final LightingConfig lighting;
  final DDDecoration Function(Vector2 position) getDeathMarker;

  const DDBasePlayerViewConfig({
    required this.hitbox,
    required this.lighting,
    required this.getDeathMarker,
  });
}

class DDBasePlayerModelConfig {
  final double maxStamina;
  final int maxEnergy;
  final int staminaRegenIncrement;
  final double longVisionRadius;

  const DDBasePlayerModelConfig({
    required this.maxStamina,
    required this.maxEnergy,
    required this.staminaRegenIncrement,
    required this.longVisionRadius,
  });
}
