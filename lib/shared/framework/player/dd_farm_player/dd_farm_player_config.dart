import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';

class DDFarmPlayerViewConfig extends DDCombatPlayerViewConfig {
  final DDAnimationDirectionalFactory animationShovelFactory;
  final DDAnimationDirectionalFactory animationWateringCanFactory;
  final DDAnimationDirectionalFactory animationPlaceSeedFactory;
  final DDAnimationDirectionalFactory animationHarvestBasketFactory;

  const DDFarmPlayerViewConfig({
    required super.hitbox,
    required super.lighting,
    required super.getDeathMarker,
    required super.animationWalkDirectional,
    required super.animationRunDirectional,
    required super.animationAttackDirectionalFactory,
    required this.animationShovelFactory,
    required this.animationWateringCanFactory,
    required this.animationPlaceSeedFactory,
    required this.animationHarvestBasketFactory,
  });
}

class DDFarmPlayerModelConfig extends DDCombatPlayerModelConfig {
  final int wateringCanStaminaCost;
  final int shovelStaminaCost;
  final int seedStaminaCost;
  final int harvestBasketStaminaCost;

  const DDFarmPlayerModelConfig({
    required super.runSpeedMultiplier,
    required super.primaryAttackStaminaCost,
    required super.rangedAttackStaminaCost,
    required super.primaryAttackDamage,
    required super.rangedAttackDamage,
    required this.wateringCanStaminaCost,
    required this.shovelStaminaCost,
    required this.seedStaminaCost,
    required this.harvestBasketStaminaCost,
  });
}
