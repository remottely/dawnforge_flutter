import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:flutter/foundation.dart';

class DDFarmPlayerModel extends DDCombatPlayerModel {
  @override
  final DDFarmPlayerModelConfig config;

  @protected
  DDFarmPlayerModel.internal({
    required this.config,
    required super.saveData,
    required super.isInRunningState,
  }) : super.internal(config: config);

  bool get canExecuteWateringCan =>
      (stamina >= config.wateringCanStaminaCost) &&
      (equipment == EquippedHandType.wateringCan);

  bool get canExecuteDig =>
      (stamina >= config.digStaminaCost) &&
      (equipment == EquippedHandType.shovel);

  bool get canExecuteSeed =>
      (stamina >= config.seedStaminaCost) && (equipment?.isSeed ?? false);

  bool get canExecuteHarvest =>
      (stamina >= config.harvestStaminaCost) &&
      (equipment == EquippedHandType.harvestBasket);

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @protected
  factory DDFarmPlayerModel.fromJson(
    Map<String, dynamic> json,
    DDFarmPlayerModelConfig config,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return DDFarmPlayerModel.internal(
      config: config,
      saveData: baseData,
      isInRunningState: false,
    );
  }
}
