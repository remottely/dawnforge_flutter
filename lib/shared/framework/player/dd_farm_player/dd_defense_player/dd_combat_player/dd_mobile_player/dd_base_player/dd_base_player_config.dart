import 'package:bonfire/bonfire.dart';

class DDBasePlayerViewConfig {
  final RectangleHitbox hitbox;
  final LightingConfig lighting;
  final GameDecoration Function(Vector2 position) getDeathMarker;

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
  final Duration staminaRegenDebounce;

  const DDBasePlayerModelConfig({
    required this.maxStamina,
    required this.maxEnergy,
    required this.staminaRegenIncrement,
    required this.longVisionRadius,
    required this.staminaRegenDebounce,
  });
}

class DDBasePlayerModelState {
  double? stamina;
  int? energy;
  double? life;
  bool? hasKey;

  DDBasePlayerModelState({this.stamina, this.energy, this.life, this.hasKey});
}
