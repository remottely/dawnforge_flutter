import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_view.dart';

class DDCombatPlayerConfig extends DDMobilePlayerConfig {
  final DDAnimationDirectionalFactory animationAttackDirectionalFactory;

  DDCombatPlayerConfig({
    required super.animationWalkDirectional,
    required super.animationRunDirectional,
    required this.animationAttackDirectionalFactory,
  });
}
