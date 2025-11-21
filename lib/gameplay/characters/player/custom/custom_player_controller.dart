import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_controller.dart';

/// Controller for the Knight player character.
///
/// Implements hybrid combat controller to provide Knight-specific input
/// mapping and configuration while inheriting all combat management and
/// resource regeneration functionality.
///
/// The Knight character uses a dual-hand equipment system for combat execution,
/// with this controller managing the resource costs and input routing while
/// the view's equipment system handles the actual attack implementation.
///
/// Key Differences from Sunny:
/// - No run state management (Knight doesn't run)
/// - Equipment-based combat (attacks routed through hand manager)
/// - Standard movement speed only
class CustomPlayerController
    extends DDHybridCombatPlayerController<CustomPlayerModel> {
  /// Creates a Knight player controller with required dependencies.
  ///
  /// All callbacks are wired to the view layer to maintain proper
  /// separation between controller logic and presentation.
  ///
  /// [model] The Knight player data model.
  /// [onExecutePrimaryAttack] Callback for primary attack execution via equipment.
  /// [onExecuteRangedAttack] Callback for ranged attack execution via equipment.
  /// [onDisplayExclamationEmote] Callback for emote display.
  /// [onDetectEnemyInLongVisionRadius] Callback for enemy detection.
  CustomPlayerController({
    required super.model,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });

  // ============================================================================
  // Configuration Overrides
  // ============================================================================

  @override
  Duration get staminaRegenDebounce => KnightPlayerConfig.kStaminaRegenDebounce;

  @override
  bool isPrimaryAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      actionId == JoystickSetup.kPrimaryAttackId ||
      actionId == KeyboardSetup.kPrimaryActionKey;

  @override
  bool isRangedAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      actionId == JoystickSetup.kFireballAttackId ||
      actionId == KeyboardSetup.kSecondaryActionKey;

  // ============================================================================
  // Additional Actions - Knight Specific
  // ============================================================================
  // Note: Tool actions are currently commented out as they're not yet
  // implemented for the Knight character. When implemented, consider
  // creating a DDToolablePlayerController mixin or extension.

  /// Restores energy to maximum value.
  ///
  /// Typically called when interacting with rest points or consuming
  /// energy restoration items. This is exposed as a public API for
  /// external systems (like rest points or item consumption) to use.
  void restoreEnergy() => model.restoreEnergy();
}
