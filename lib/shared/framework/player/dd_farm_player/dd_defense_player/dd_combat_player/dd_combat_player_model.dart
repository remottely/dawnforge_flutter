import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';

abstract class DDCombatPlayerModel extends DDMobilePlayerModel {
  final DDCombatPlayerModelConfig modelConfig;

  DDCombatPlayerModel({
    required this.modelConfig,
    required super.maxStamina,
    required super.maxEnergy,
    super.initialStamina,
    super.initialEnergy,
    super.initialLife,
    super.initialHasKey,
  });

  bool get canExecutePrimaryAttack =>
      (currentStamina >= modelConfig.primaryAttackStaminaCost) &&
      (equipment == EquippedHandType.ironSword);

  bool get canExecuteRangedAttack =>
      (currentStamina >= modelConfig.rangedAttackStaminaCost) &&
      (equipment == EquippedHandType.staff);

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }
}
