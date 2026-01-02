import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';

class DDCombatPlayerViewConfig extends DDMobilePlayerViewConfig {
  final DDAnimationDirectionalFactory animationAttackDirectionalFactory;

  const DDCombatPlayerViewConfig({
    required super.size,
    required super.life,
    required super.baseSpeed,
    required super.hitbox,
    required super.lighting,
    required super.getDeathMarker,
    required super.animationWalkDirectional,
    required super.animationRunDirectional,
    required this.animationAttackDirectionalFactory,
  });
}

class DDCombatPlayerModelConfig extends DDMobilePlayerModelConfig {
  final int primaryAttackStaminaCost;
  final int rangedAttackStaminaCost;
  final double primaryAttackDamage;
  final double rangedAttackDamage;

  const DDCombatPlayerModelConfig({
    required super.maxStamina,
    required super.maxEnergy,
    required super.staminaRegenIncrement,
    required super.longVisionRadius,
    required super.staminaRegenDebounce,
    required super.runSpeedMultiplier,
    required this.primaryAttackStaminaCost,
    required this.rangedAttackStaminaCost,
    required this.primaryAttackDamage,
    required this.rangedAttackDamage,
  });
}
