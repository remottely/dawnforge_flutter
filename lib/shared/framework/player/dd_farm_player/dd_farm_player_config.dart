import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';

class DDFarmPlayerViewConfig extends DDCombatPlayerViewConfig {
  final DDAnimationDirectionalFactory animationDigFactory;
  final DDAnimationDirectionalFactory animationWateringCanFactory;
  final DDAnimationDirectionalFactory animationPlaceSeedFactory;
  final DDAnimationDirectionalFactory animationHarvestFactory;

  const DDFarmPlayerViewConfig({
    required super.size,
    required super.life,
    required super.baseSpeed,
    required super.hitbox,
    required super.lighting,
    required super.getDeathMarker,
    required super.animationWalkDirectional,
    required super.animationRunDirectional,
    required super.animationAttackDirectionalFactory,
    super.comboAttackAnimationFactories,
    required this.animationDigFactory,
    required this.animationWateringCanFactory,
    required this.animationPlaceSeedFactory,
    required this.animationHarvestFactory,
  });
}

class DDFarmPlayerModelConfig extends DDCombatPlayerModelConfig {
  final int wateringCanStaminaCost;
  final int digStaminaCost;
  final int seedStaminaCost;
  final int harvestStaminaCost;

  const DDFarmPlayerModelConfig({
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
    required this.wateringCanStaminaCost,
    required this.digStaminaCost,
    required this.seedStaminaCost,
    required this.harvestStaminaCost,
  });
}
