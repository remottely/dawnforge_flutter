import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';

class DDFarmPlayerConfig extends DDCombatPlayerConfig {
  final DDAnimationDirectionalFactory animationShovelFactory;
  final DDAnimationDirectionalFactory animationWateringCanFactory;
  final DDAnimationDirectionalFactory animationPlaceSeedFactory;
  final DDAnimationDirectionalFactory animationHarvestBasketFactory;

  DDFarmPlayerConfig({
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
