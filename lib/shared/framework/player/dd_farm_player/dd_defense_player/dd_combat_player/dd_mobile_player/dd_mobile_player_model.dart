import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';

abstract class DDMobilePlayerModel extends DDBasePlayerModel {
  bool _isInRunningState = false;

  DDMobilePlayerModel({
    required super.maxStamina,
    required super.maxEnergy,
    super.initialStamina,
    super.initialEnergy,
    super.initialLife,
    super.initialHasKey,
  });

  double get runSpeedMultiplier;

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
