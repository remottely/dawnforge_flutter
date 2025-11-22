import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_model.dart';

/// Model for players with enhanced mobility options (walk + run).
///
/// Extends the hybrid combat model to add run state management and
/// speed multiplier configuration. Suitable for characters like Sunny
/// who have variable movement speeds.
abstract class DDFarmPlayerModel extends DDMobilePlayerModel {
  DDFarmPlayerModel({
    required super.maxStamina,
    required super.maxEnergy,
    super.initialStamina,
    super.initialEnergy,
    super.initialLife,
    super.initialHasKey,
  });

  // ============================================================================
  // Serialization
  // ============================================================================

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    // json['equipment'] = _equipment;
    return json;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    // _equipment = (json['equipment'] as String?) ?? 'digger';
  }
}
