import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_config.dart';
import 'package:flutter/foundation.dart';

class DDMobilePlayerModel extends DDBasePlayerModel {
  @override
  final DDMobilePlayerModelConfig modelConfig;

  bool _isInRunningState;

  @protected
  DDMobilePlayerModel.internal({
    required this.modelConfig,
    required super.saveData,
    required bool isInRunningState,
  }) : _isInRunningState = isInRunningState,
       super.internal(modelConfig: modelConfig);

  bool get isRunning => _isInRunningState;
  set isRunning(bool value) => _isInRunningState = value;

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @protected
  factory DDMobilePlayerModel.fromJson(
    Map<String, dynamic> json,
    DDMobilePlayerModelConfig modelConfig,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, modelConfig);

    return DDMobilePlayerModel.internal(
      modelConfig: modelConfig,
      saveData: baseData,
      isInRunningState: false,
    );
  }
}
