import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';

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
  Vector2 position;

  DDBasePlayerSaveData({
    required this.stamina,
    required this.energy,
    this.life,
    required this.coins,
    required this.position,
  });

  Map<String, dynamic> toJson() => {
    'stamina': stamina,
    'energy': energy,
    'life': life,
    'coins': coins,
    'position': [position.x, position.y],
  };

  factory DDBasePlayerSaveData.fromJson(
    Map<String, dynamic> json,
    DDBasePlayerModelConfig config,
  ) {
    final stamina = (json['stamina'] as num?)?.toDouble() ?? config.maxStamina;
    final energy = (json['energy'] as num?)?.toInt() ?? config.maxEnergy;
    final life = (json['life'] as num?)?.toDouble();
    final coins = _readCoins(json);
    final positionRaw = json['position'];

    // ✨ Converte List para Vector2
    Vector2 position = Vector2.zero();
    if (positionRaw != null && positionRaw is List && positionRaw.length >= 2) {
      position = Vector2(
        (positionRaw[0] as num).toDouble(),
        (positionRaw[1] as num).toDouble(),
      );
    }

    GameLogger.info(
      '[DDBasePlayerSaveData] fromJson stamina=$stamina, life=$life, energy=$energy, coins=$coins, position=$position, raw=$json',
    );
    if (life == null || life <= 0) {
      GameLogger.warning(
        '[DDBasePlayerSaveData] ⚠️ life is null/<=0 during load; check death flow or save timing',
      );
    }

    return DDBasePlayerSaveData(
      stamina: stamina,
      energy: energy,
      life: life,
      coins: coins,
      position: position,
    );
  }

  static int _readCoins(Map<String, dynamic> json) {
    final coinsValue = json['coins'];
    if (coinsValue is num) return coinsValue.toInt();
    throw ArgumentError(
      'DDBasePlayerSaveData.fromJson: missing coins in payload',
    );
  }
}
