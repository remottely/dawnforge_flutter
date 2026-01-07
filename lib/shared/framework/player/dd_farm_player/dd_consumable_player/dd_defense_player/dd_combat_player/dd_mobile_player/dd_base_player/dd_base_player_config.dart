import 'package:bonfire/bonfire.dart';

class DDBasePlayerViewConfig {
  final Vector2 size;
  final double life;
  final double baseSpeed;
  final RectangleHitbox hitbox;
  final LightingConfig lighting;
  final GameDecoration Function(Vector2 position) getDeathMarker;

  const DDBasePlayerViewConfig({
    required this.size,
    required this.life,
    required this.baseSpeed,
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
  int coins;

  DDBasePlayerSaveData({
    required this.stamina,
    required this.energy,
    this.life,
    required this.coins,
  });

  Map<String, dynamic> toJson() => {
    'stamina': stamina,
    'energy': energy,
    'life': life,
    'coins': coins,
  };

  factory DDBasePlayerSaveData.fromJson(
    Map<String, dynamic> json,
    DDBasePlayerModelConfig config,
  ) {
    return DDBasePlayerSaveData(
      stamina: (json['stamina'] as num?)?.toDouble() ?? config.maxStamina,
      energy: (json['energy'] as num?)?.toInt() ?? config.maxEnergy,
      life: (json['life'] as num?)?.toDouble(),
      coins: _readCoins(json),
    );
  }

  static int _readCoins(Map<String, dynamic> json) {
    final coinsValue = json['coins'];
    if (coinsValue is num) return coinsValue.toInt();
    throw ArgumentError('DDBasePlayerSaveData.fromJson: missing coins in payload');
  }
}
