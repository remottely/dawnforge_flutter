import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:flutter/foundation.dart';

class DDFarmPlayerModel extends DDCombatPlayerModel {
  @override
  final DDFarmPlayerModelConfig modelConfig;

  @protected
  DDFarmPlayerModel.internal({
    required this.modelConfig,
    required super.saveData,
    required super.isInRunningState,
  }) : super.internal(modelConfig: modelConfig);

  bool get canExecuteWateringCan =>
      (stamina >= modelConfig.wateringCanStaminaCost) &&
      (equipment == EquippedHandType.wateringCan);

  bool get canExecuteShovel =>
      (stamina >= modelConfig.shovelStaminaCost) &&
      (equipment == EquippedHandType.shovel);

  bool get canExecuteSeed =>
      (stamina >= modelConfig.seedStaminaCost) && (equipment?.isSeed ?? false);

  bool get canExecuteHarvestBasket =>
      (stamina >= modelConfig.harvestBasketStaminaCost) &&
      (equipment == EquippedHandType.harvestBasket);

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @protected
  factory DDFarmPlayerModel.fromJson(
    Map<String, dynamic> json,
    DDFarmPlayerModelConfig modelConfig,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, modelConfig);

    return DDFarmPlayerModel.internal(
      modelConfig: modelConfig,
      saveData: baseData,
      isInRunningState: false,
    );
  }
}
