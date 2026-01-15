import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';
import 'package:flutter/foundation.dart';

class DDCombatPlayerModel extends DDMobilePlayerModel {
  @override
  final DDCombatPlayerModelConfig config;

  @protected
  DDCombatPlayerModel.internal({required this.config, required super.saveData})
    : super.internal(config: config);

  bool get canExecutePrimaryAttack =>
      (stamina >= config.primaryAttackStaminaCost) &&
      (equipment == HandItemId.ironSword);

  bool get canExecuteRangedAttack =>
      (stamina >= config.rangedAttackStaminaCost) &&
      (equipment == HandItemId.staff);

  @override
  Map<String, dynamic> toJson() => super.toJson();

  @protected
  factory DDCombatPlayerModel.fromJson(
    Map<String, dynamic> json,
    DDCombatPlayerModelConfig config,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return DDCombatPlayerModel.internal(config: config, saveData: baseData);
  }
}
