import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';
import 'package:flutter/foundation.dart';

class DDCombatPlayerModel extends DDMobilePlayerModel {
  @override
  final DDCombatPlayerModelConfig modelConfig;

  @protected
  DDCombatPlayerModel.internal({
    required this.modelConfig,
    required super.saveData,
    required super.isInRunningState,
  }) : super.internal(modelConfig: modelConfig);

  bool get canExecutePrimaryAttack =>
      (stamina >= modelConfig.primaryAttackStaminaCost) &&
      (equipment == EquippedHandType.ironSword);

  bool get canExecuteRangedAttack =>
      (stamina >= modelConfig.rangedAttackStaminaCost) &&
      (equipment == EquippedHandType.staff);

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @protected
  factory DDCombatPlayerModel.fromJson(
    Map<String, dynamic> json,
    DDCombatPlayerModelConfig modelConfig,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, modelConfig);

    return DDCombatPlayerModel.internal(
      modelConfig: modelConfig,
      saveData: baseData,
      isInRunningState: false,
    );
  }
}
