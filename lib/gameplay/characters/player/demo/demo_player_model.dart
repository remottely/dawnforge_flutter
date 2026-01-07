import 'package:darkness_dungeon/gameplay/characters/player/demo/demo_player_def.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class DemoPlayerModel extends DDFarmPlayerModel {
  DemoPlayerModel.internal({
    required DDFarmPlayerModelConfig config,
    required super.saveData,
  }) : super.internal(config: config);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'demo';
    return json;
  }

  factory DemoPlayerModel.fromJson(Map<String, dynamic> json) {
    final config = DemoPlayerDef.modelConfig;

    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return DemoPlayerModel.internal(config: config, saveData: baseData);
  }
}
