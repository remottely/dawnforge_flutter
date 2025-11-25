import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/combat/controllers/player_combat_action_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_view.dart';

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
/// - [C] The specific controller type extending DDCombatPlayerController
/// - [M] The specific model type extending DDCombatPlayerModel
abstract class DDCombatPlayerView<
  C extends DDCombatPlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDMobilePlayerView<C, M> {
  DDCombatPlayerView({
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required super.speed,
  });

  late final SynchronizedAttackController meleeAttackController;
  late final SynchronizedAttackController rangedAttackController;

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeCombatSystems();
  }

  @override
  void onRemove() {
    meleeAttackController.dispose();
    rangedAttackController.dispose();
    super.onRemove();
  }

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initializes the synchronized attack system controllers for combat.
  void _initializeCombatSystems() {
    meleeAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
    rangedAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
  }

  // ============================================================================
  // Controller Factory - Wired Combat Callbacks
  // ============================================================================

  @override
  C createMobileController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
    required void Function(bool isRunning) onChangeRunState,
  }) {
    return createCombatController(
      model: model,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
      onChangeRunState: onChangeRunState,
      onExecutePrimaryAttack: _onExecutePrimaryAttack,
      onExecuteRangedAttack: _onExecuteRangedAttack,
    );
  }

  /// Creates the combat controller with all required callbacks.
  ///
  /// Subclasses must implement this to instantiate their specific controller
  /// type with the provided callbacks.
  C createCombatController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
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

  bool _onExecutePrimaryAttack(double damage) {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: SunnyPlayerConfig.loadRightAttackAnimation(),
          animationLeft: SunnyPlayerConfig.loadLeftAttackAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () {
            PlayerCombatActionController.executePrimaryAttack(
              player: this,
              damage: damage,
            );
          },
        );
      },
    );

    return executionInfo != null;
  }

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

  bool _onExecuteRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = rangedAttackController.execute(
      AttackType.ranged,
      () => PlayerCombatActionController.executeFireballAttack(
        player: this,
        damage: damage,
      ),
    );

    return executionInfo != null;
  }
}
