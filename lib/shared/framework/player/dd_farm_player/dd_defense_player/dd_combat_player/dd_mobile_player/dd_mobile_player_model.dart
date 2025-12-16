import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_config.dart';

abstract class DDMobilePlayerModel extends DDBasePlayerModel {
  final DDMobilePlayerModelConfig modelConfig;

  DDMobilePlayerModel({required this.modelConfig, required super.modelState})
    : super(modelConfig: modelConfig);

  bool _isInRunningState = false;

  bool get isRunning => _isInRunningState;

  set isRunning(bool value) => _isInRunningState = value;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['isInRunningState'] = _isInRunningState;
    return json;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    _isInRunningState = (json['isInRunningState'] as bool?) ?? false;
  }
}
