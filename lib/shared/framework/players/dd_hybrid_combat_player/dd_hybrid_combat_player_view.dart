import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_model.dart';

/// Abstract view for players with hybrid combat capabilities (melee + ranged).
///
/// Provides the foundational combat system implementation for characters
/// that can execute both close-range and long-range attacks. This class
/// handles the coordination between attack callbacks and the controller's
/// combat execution logic.
///
/// Subclasses must implement attack execution methods that define the
/// specific visual effects, animations, and damage application for each
/// attack type.
///
/// Type Parameters:
/// - [C] The specific controller type extending DDHybridCombatPlayerController
/// - [M] The specific model type extending DDHybridCombatPlayerModel
abstract class DDHybridCombatPlayerView<
  C extends DDHybridCombatPlayerController<M>,
  M extends DDHybridCombatPlayerModel
>
    extends DDBasePlayerView<C, M> {
  DDHybridCombatPlayerView({
    required super.position,
    required super.model,
    required super.animation,
    required super.size,
    required super.life,
    required super.speed,
  });

  // ============================================================================
  // Abstract Combat Execution Methods
  // ============================================================================

  /// Executes the primary melee attack with visual effects and damage application.
  ///
  /// Implementations should handle:
  /// - Animation playback
  /// - Damage hitbox creation
  /// - Visual effects (particles, camera shake)
  /// - Audio feedback
  ///
  /// [damage] The amount of damage to inflict on hit targets.
  ///
  /// Returns `true` if the attack was successfully executed, `false` if on cooldown
  /// or unable to execute.
  bool executePrimaryAttack(double damage);

  /// Executes the ranged attack with projectile spawning and effects.
  ///
  /// Implementations should handle:
  /// - Projectile creation and trajectory
  /// - Visual effects (particles, lighting)
  /// - Audio feedback
  /// - Destruction effects
  ///
  /// [damage] The amount of damage to inflict on hit targets.
  ///
  /// Returns `true` if the attack was successfully executed, `false` if on cooldown
  /// or unable to execute.
  bool executeRangedAttack(double damage);

  // ============================================================================
  // Controller Factory - Wired Combat Callbacks
  // ============================================================================

  @override
  C createController(M model) {
    return createCombatController(
      model: model,
      onPrimaryAttack: executePrimaryAttack,
      onRangedAttack: executeRangedAttack,
      onShowExclamation: displayExclamationEmote,
      onCheckEnemyVision: evaluateEnemyVisibility,
    );
  }

  /// Creates the combat controller with all required callbacks.
  ///
  /// Subclasses must implement this to instantiate their specific controller
  /// type with the provided callbacks.
  C createCombatController({
    required M model,
    required bool Function(double damage) onPrimaryAttack,
    required bool Function(double damage) onRangedAttack,
    required void Function() onShowExclamation,
    required void Function({
      required double visionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onCheckEnemyVision,
  });
}
