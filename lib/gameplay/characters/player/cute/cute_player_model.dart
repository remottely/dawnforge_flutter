import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_def.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class CutePlayerModel extends DDFarmPlayerModel {
  CutePlayerModel.internal({
    required DDFarmPlayerModelConfig config,
    required super.saveData,
    required super.isInRunningState,
  }) : super.internal(config: config);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'cute';
    return json;
  }

  factory CutePlayerModel.fromJson(Map<String, dynamic> json) {
    final config = CutePlayerDef.modelConfig;

    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return CutePlayerModel.internal(
      config: config,
      saveData: baseData,
      isInRunningState: false,
    );
  }
}
