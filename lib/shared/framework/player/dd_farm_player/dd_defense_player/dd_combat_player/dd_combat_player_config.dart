import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_config.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';

class DDCombatPlayerViewConfig extends DDMobilePlayerViewConfig {
  final DDAnimationDirectionalFactory animationAttackDirectionalFactory;

  DDCombatPlayerViewConfig({
    required super.hitbox,
    required super.lighting,
    required super.getDeathMarker,
    required super.animationWalkDirectional,
    required super.animationRunDirectional,
    required this.animationAttackDirectionalFactory,
  });
}
