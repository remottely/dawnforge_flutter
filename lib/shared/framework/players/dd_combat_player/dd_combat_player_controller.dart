import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_controller.dart';

/// Controller for players with hybrid combat capabilities.
///
/// Manages input routing and execution for both melee and ranged attacks,
/// coordinating stamina consumption and attack callbacks with the view layer.
abstract class DDCombatPlayerController<M extends DDCombatPlayerModel>
    extends DDMobilePlayerController<M> {
  /// Callback invoked to execute the primary melee attack.
  final bool Function(double damage) onExecutePrimaryAttack;

  /// Callback invoked to execute the ranged attack.
  final bool Function(double damage) onExecuteRangedAttack;

  DDCombatPlayerController({
    required super.model,
    required this.onExecutePrimaryAttack,
    required this.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
  });

  // ============================================================================
  // Abstract Input Configuration
  // ============================================================================

  /// Determines if the action ID corresponds to the primary attack action.
  bool isPrimaryAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  });

  /// Determines if the action ID corresponds to the ranged attack action.
  bool isRangedAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  });

  // ============================================================================
  // Combat Actions
  // ============================================================================

  /// Executes the primary melee attack if resources are sufficient.
  void handleExecutePrimaryAttack() {
    if (!model.canExecutePrimaryAttack) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onExecutePrimaryAttack.call(
      model.primaryAttackDamage,
    );
    if (!wasExecuted) {
      // Ação não executada, retomar regeneração
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.primaryAttackStaminaCost);

    // Retomar regeneração após ação instantânea
    endStaminaConsumingAction();
  }

  /// Executes the ranged attack if resources are sufficient.
  void handleExecuteRangedAttack() {
    if (!model.canExecuteRangedAttack) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteRangedAttack.call(
      model.rangedAttackDamage,
    );
    if (!wasExecuted) {
      // Ação não executada, retomar regeneração
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.rangedAttackStaminaCost);

    // Retomar regeneração após ação instantânea
    endStaminaConsumingAction();
  }

  // ============================================================================
  // Input Processing
  // ============================================================================

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    // Only respond to button press events
    if (event.event != ActionEvent.DOWN) return;

    if (isPrimaryAttackAction(player: player, actionId: event.id)) {
      handleExecutePrimaryAttack();
    } else if (isRangedAttackAction(player: player, actionId: event.id)) {
      handleExecuteRangedAttack();
    }
  }
}
