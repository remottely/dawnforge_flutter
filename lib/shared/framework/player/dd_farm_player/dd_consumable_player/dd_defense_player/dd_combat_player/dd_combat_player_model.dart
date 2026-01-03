import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';
import 'package:flutter/foundation.dart';

class DDCombatPlayerModel extends DDMobilePlayerModel {
  @override
  final DDCombatPlayerModelConfig config;

  @protected
  DDCombatPlayerModel.internal({required this.config, required super.saveData})
    : super.internal(config: config);

  bool get canExecutePrimaryAttack =>
      (stamina >= config.primaryAttackStaminaCost) &&
      (equipment == EquippedHandType.ironSword);

  bool get canExecuteRangedAttack =>
      (stamina >= config.rangedAttackStaminaCost) &&
      (equipment == EquippedHandType.staff);

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @protected
  factory DDCombatPlayerModel.fromJson(
    Map<String, dynamic> json,
    DDCombatPlayerModelConfig config,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return DDCombatPlayerModel.internal(config: config, saveData: baseData);
  }
}
