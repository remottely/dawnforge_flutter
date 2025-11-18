import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_controller.dart';

/// Controller for the Sunny player character.
///
/// Implements mobile player controller to provide Sunny-specific input
/// mapping and configuration while inheriting all hybrid combat and
/// mobility management functionality.
class SunnyPlayerController extends DDMobilePlayerController<SunnyPlayerModel> {
  SunnyPlayerController({
    required super.model,
    required super.onRunChange,
    required super.onPrimaryAttack,
    required super.onRangedAttack,
    required super.onShowExclamation,
    required super.onCheckEnemyVision,
  });

  // ============================================================================
  // Configuration Overrides
  // ============================================================================

  @override
  Duration get staminaRegenDebounce => SunnyPlayerConfig.kStaminaRegenDebounce;

  @override
  bool isPrimaryAttackAction(dynamic actionId) =>
      actionId == JoystickSetup.kPrimaryAttackId ||
      actionId == KeyboardSetup.kPrimaryActionKey;

  @override
  bool isRangedAttackAction(dynamic actionId) =>
      actionId == JoystickSetup.kFireballAttackId ||
      actionId == KeyboardSetup.kSecondaryActionKey;

  @override
  bool isRunAction(dynamic actionId) =>
      actionId == JoystickSetup.kRunId || actionId == KeyboardSetup.kRunKey;
}
