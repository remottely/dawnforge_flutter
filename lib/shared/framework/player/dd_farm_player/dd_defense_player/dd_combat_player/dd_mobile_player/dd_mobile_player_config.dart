import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';

class DDMobilePlayerViewConfig extends DDBasePlayerViewConfig {
  final SimpleDirectionAnimation animationWalkDirectional;
  final SimpleDirectionAnimation animationRunDirectional;

  const DDMobilePlayerViewConfig({
    required super.hitbox,
    required super.lighting,
    required super.getDeathMarker,
    required this.animationWalkDirectional,
    required this.animationRunDirectional,
  });
}

class DDMobilePlayerModelConfig extends DDBasePlayerModelConfig {
  final double runSpeedMultiplier;

  const DDMobilePlayerModelConfig({
    required super.maxStamina,
    required super.maxEnergy,
    required super.staminaRegenIncrement,
    required super.longVisionRadius,
    required this.runSpeedMultiplier,
  });
}
