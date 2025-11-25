import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_model.dart';

/// Model for players with enhanced mobility options (walk + run).
///
/// Extends the hybrid combat model to add run state management and
/// speed multiplier configuration. Suitable for characters like Sunny
/// who have variable movement speeds.
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

  // ============================================================================
  // Abstract Mobility Configuration
  // ============================================================================

  /// Speed multiplier applied when running.
  double get runSpeedMultiplier;

  // ============================================================================
  // Mobility State
  // ============================================================================

  /// Whether the character is currently in running state.
  bool get isRunning => _isInRunningState;

  /// Updates the running state.
  set isRunning(bool value) => _isInRunningState = value;

  // ============================================================================
  // Serialization
  // ============================================================================

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
