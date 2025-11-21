import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_view.dart';

/// Abstract view for players with enhanced mobility (walk + run).
///
/// Extends hybrid combat player to add run state management and animation
/// switching. This class coordinates run input with speed changes and
/// animation transitions while maintaining all combat capabilities.
///
/// Features:
/// - Dynamic speed adjustment based on run state
/// - Animation set switching (walk ↔ run)
/// - Movement lock awareness (prevents animation changes during attacks)
///
/// Type Parameters:
/// - [C] The specific controller type extending DDFarmPlayerController
/// - [M] The specific model type extending DDFarmPlayerModel
abstract class DDFarmPlayerView<
  C extends DDFarmPlayerController<M>,
  M extends DDFarmPlayerModel
>
    extends DDMobilePlayerView<C, M> {
  DDFarmPlayerView({
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required super.speed,
  });

  @override
  C createMobileController({
    required M model,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  }) {
    return createFarmController(
      model: model,
      onChangeRunState: onChangeRunState,
      onExecutePrimaryAttack: onExecutePrimaryAttack,
      onExecuteRangedAttack: onExecuteRangedAttack,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
    );
  }

  /// Creates the mobile controller with all required callbacks.
  C createFarmController({
    required M model,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  });

  // ============================================================================
  // Input Handling Override - Movement Locking
  // ============================================================================

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    super.onJoystickChangeDirectional(event);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
