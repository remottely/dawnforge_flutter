import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';

class DDMinePlayerViewConfig extends DDFarmPlayerViewConfig {
  final DDAnimationDirectionalFactory animationMineFactory;

  const DDMinePlayerViewConfig({
    required super.size,
    required super.life,
    required super.baseSpeed,
    required super.hitbox,
    required super.lighting,
    required super.getDeathMarker,
    required super.animationWalkDirectional,
    required super.animationRunDirectional,
    required super.animationAttackDirectionalFactory,
    required super.animationDigFactory,
    required super.animationWateringCanFactory,
    required super.animationPlaceSeedFactory,
    required super.animationHarvestFactory,
    required this.animationMineFactory,
  });
}

class DDMinePlayerModelConfig extends DDFarmPlayerModelConfig {
  final int mineStaminaCost;

  const DDMinePlayerModelConfig({
    required super.maxStamina,
    required super.maxEnergy,
    required super.staminaRegenIncrement,
    required super.longVisionRadius,
    required super.staminaRegenDebounce,
    required super.runSpeedMultiplier,
    required super.primaryAttackStaminaCost,
    required super.rangedAttackStaminaCost,
    required super.primaryAttackDamage,
    required super.rangedAttackDamage,
    required super.wateringCanStaminaCost,
    required super.digStaminaCost,
    required super.seedStaminaCost,
    required super.harvestStaminaCost,
    required this.mineStaminaCost,
  });
}
