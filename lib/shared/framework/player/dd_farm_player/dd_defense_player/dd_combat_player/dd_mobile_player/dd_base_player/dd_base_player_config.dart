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
  // TODO(Kevin): NOWNOW - DDBasePlayerSpec
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

class DDBasePlayerSaveData {
  double stamina;
  int energy;
  double? life;
  bool hasKey;

  DDBasePlayerSaveData({
    required this.stamina,
    required this.energy,
    this.life,
    this.hasKey = false,
  });

  Map<String, dynamic> toJson() => {
    'stamina': stamina,
    'energy': energy,
    'life': life,
    'hasKey': hasKey,
  };

  factory DDBasePlayerSaveData.fromJson(
    Map<String, dynamic> json,
    DDBasePlayerModelConfig config,
  ) {
    return DDBasePlayerSaveData(
      stamina: (json['stamina'] as num?)?.toDouble() ?? config.maxStamina,
      energy: (json['energy'] as int?) ?? config.maxEnergy,
      life: (json['life'] as num?)?.toDouble(),
      hasKey: json['hasKey'] as bool? ?? false,
    );
  }
}
