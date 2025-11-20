import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_model.dart';

/// Controller for players with hybrid combat capabilities.
///
/// Manages input routing and execution for both melee and ranged attacks,
/// coordinating stamina consumption and attack callbacks with the view layer.
abstract class DDHybridCombatPlayerController<
  M extends DDHybridCombatPlayerModel
>
    extends DDBasePlayerController<M> {
  /// Callback invoked to execute the primary melee attack.
  final bool Function(double damage) onPrimaryAttack;

  /// Callback invoked to execute the ranged attack.
  final bool Function(double damage) onRangedAttack;

  DDHybridCombatPlayerController({
    required super.model,
    required this.onPrimaryAttack,
    required this.onRangedAttack,
    required super.onShowExclamation,
    required super.onDetectEnemyInLongVisionRadius,
  });

  // ============================================================================
  // Abstract Input Configuration
  // ============================================================================

  /// Determines if the action ID corresponds to the primary attack action.
  bool isPrimaryAttackAction(dynamic actionId);

  /// Determines if the action ID corresponds to the ranged attack action.
  bool isRangedAttackAction(dynamic actionId);

  // ============================================================================
  // Combat Actions
  // ============================================================================

  /// Executes the primary melee attack if resources are sufficient.
  void executePrimaryAttack() {
    if (!model.canExecutePrimaryAttack) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onPrimaryAttack.call(model.primaryAttackDamage);
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
  void executeRangedAttack() {
    if (!model.canExecuteRangedAttack) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onRangedAttack.call(model.rangedAttackDamage);
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
  void handleInputAction(JoystickActionEvent event) {
    // Only respond to button press events
    if (event.event != ActionEvent.DOWN) return;

    if (isPrimaryAttackAction(event.id)) {
      executePrimaryAttack();
    } else if (isRangedAttackAction(event.id)) {
      executeRangedAttack();
    }
  }
}
