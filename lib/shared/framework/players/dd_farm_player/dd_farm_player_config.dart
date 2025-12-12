import 'package:darkness_dungeon/shared/framework/animation_directional.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';

class DDFarmPlayerConfig extends DDCombatPlayerConfig {
  final AnimationDirectionalFactory animationShovelFactory;
  final AnimationDirectionalFactory animationWateringCanFactory;
  final AnimationDirectionalFactory animationPlaceSeedFactory;
  final AnimationDirectionalFactory animationHarvestBasketFactory;

  DDFarmPlayerConfig({
    required super.animationWalkDirectional,
    required super.animationRunDirectional,
    required super.animationAttackDirectionalFactory,
    required this.animationShovelFactory,
    required this.animationWateringCanFactory,
    required this.animationPlaceSeedFactory,
    required this.animationHarvestBasketFactory,
  });
}
