import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';

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

// class DDBasePlayerModelConfig {
//   final double maxStamina;
//   final int maxEnergy;
//   final int staminaRegenIncrement;
//   final double longVisionRadius;
//   final Duration staminaRegenDebounce;

//   const DDBasePlayerModelConfig({
//     required this.maxStamina,
//     required this.maxEnergy,
//     required this.staminaRegenIncrement,
//     required this.longVisionRadius,
//     required this.staminaRegenDebounce,
//   });
// }

// class DDBasePlayerModelConfig {
//   double? stamina;
//   int? energy;
//   double? life;
//   bool? hasKey;

//   DDBasePlayerModelConfig({this.stamina, this.energy, this.life, this.hasKey});
// }

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
  EquippedHandType? equipment;

  DDBasePlayerSaveData({
    required this.stamina,
    required this.energy,
    this.life,
    this.hasKey = false,
    this.equipment,
  });

  Map<String, dynamic> toJson() => {
    'stamina': stamina,
    'energy': energy,
    'life': life,
    'hasKey': hasKey,
    'equipment': equipment?.name,
  };

  factory DDBasePlayerSaveData.fromJson(
    Map<String, dynamic> json,
    DDBasePlayerModelConfig spec,
  ) {
    return DDBasePlayerSaveData(
      stamina: (json['stamina'] as num?)?.toDouble() ?? spec.maxStamina,
      energy: (json['energy'] as int?) ?? spec.maxEnergy,
      life: (json['life'] as num?)?.toDouble(),
      hasKey: json['hasKey'] as bool? ?? false,
      equipment: _parseEquipment(json['equipment'] as String?),
    );
  }

  static EquippedHandType? _parseEquipment(String? eq) {
    return (eq == null || eq == 'null')
        ? null
        : EquippedHandType.values.byName(eq);
  }
}
