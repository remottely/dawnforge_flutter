import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_config.dart';
import 'package:flutter/foundation.dart';

class DDMobilePlayerModel extends DDBasePlayerModel {
  @override
  final DDMobilePlayerModelConfig config;

  bool _isInRunningState = false;

  @protected
  DDMobilePlayerModel.internal({required this.config, required super.saveData})
    : super.internal(config: config);

  bool get isRunning => _isInRunningState;

  bool setRunning(bool value) {
    if (_isInRunningState == value) return false;
    _isInRunningState = value;
    return true;
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @protected
  factory DDMobilePlayerModel.fromJson(
    Map<String, dynamic> json,
    DDMobilePlayerModelConfig config,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return DDMobilePlayerModel.internal(config: config, saveData: baseData);
  }
}
