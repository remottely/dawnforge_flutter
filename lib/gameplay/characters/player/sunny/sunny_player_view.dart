import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/combat/controllers/player_combat_action_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_tool_action_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_view.dart';

/// Visual representation and input handler for the Sunny player character.
///
/// This view implements the mobile player specialization, providing Sunny with
/// hybrid combat capabilities (melee + ranged) and enhanced mobility (walk + run).
///
/// Combat System:
/// - Synchronized attack controllers for cooldown management
/// - Frame-precise animation execution
/// - Dynamic hitbox positioning
/// - Visual and audio feedback coordination
///
/// Mobility System:
/// - Dynamic speed adjustment (walk/run)
/// - Animation set switching
/// - Movement locking during attacks
/// - Buffered input restoration
class SunnyPlayerView
    extends DDFarmPlayerView<SunnyPlayerController, SunnyPlayerModel> {
  late final SynchronizedAttackController _meleeAttackController;
  late final SynchronizedAttackController _rangedAttackController;

  SunnyPlayerView({required super.position, required super.model})
    : super(
        size: SunnyPlayerConfig.componentSize,
        life: SunnyPlayerConfig.kLife,
        speed: SunnyPlayerConfig.kSpeed,
      );
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
    _meleeAttackController.dispose();
    _rangedAttackController.dispose();
    super.onRemove();
  }

  // ============================================================================
  // Factory Methods - Configuration
  // ============================================================================

  @override
  SunnyPlayerController createFarmController({
    required SunnyPlayerModel model,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function() onExecuteShovel,
    required bool Function() onExecuteWateringCan,
    required bool Function() onExecuteSeed,
    required bool Function() onExecuteHarvestBasket,
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
    return SunnyPlayerController(
      model: model,
      onChangeRunState: onChangeRunState,
      onExecuteShovel: onExecuteShovel,
      onExecuteWateringCan: onExecuteWateringCan,
      onExecuteSeed: onExecuteSeed,
      onExecuteHarvestBasket: onExecuteHarvestBasket,
      onExecutePrimaryAttack: onExecutePrimaryAttack,
      onExecuteRangedAttack: onExecuteRangedAttack,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
    );
  }

  @override
  RectangleHitbox getHitbox() => SunnyPlayerConfig.hitbox;

  @override
  LightingConfig getLightingConfig() => SunnyPlayerConfig.lightingConfig;

  @override
  DDDecoration getDeathMarker(Vector2 position) =>
      SunnyPlayerConfig.createDeathMarker(position);

  @override
  SimpleDirectionAnimation getWalkAnimation() =>
      SunnyPlayerConfig.walkAnimation;

  @override
  SimpleDirectionAnimation getRunAnimation() => SunnyPlayerConfig.runAnimation;

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initializes the synchronized attack system controllers for combat.
  void _initializeCombatSystems() {
    _meleeAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
    _rangedAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
  }

  // ============================================================================
  // Combat Execution Implementation
  // ============================================================================

  @override
  bool onExecutePrimaryAttack(double damage) {
    final AttackExecutionInfo? executionInfo = _meleeAttackController.execute(
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

  @override
  bool onExecuteRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = _rangedAttackController.execute(
      AttackType.ranged,
      () => PlayerCombatActionController.executeFireballAttack(
        player: this,
        damage: damage,
      ),
    );

    return executionInfo != null;
  }

  // ============================================================================
  // Farm Execution Implementation
  // ============================================================================

  @override
  bool onExecuteShovel() {
    final AttackExecutionInfo? executionInfo = _meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: SunnyPlayerConfig.loadRightShovelAnimation(),
          animationLeft: SunnyPlayerConfig.loadLeftShovelAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          // TODO(chatgpt): preciso que vc
          onExecutionFrames: () {
            FarmToolActionConfig.execute(player: this);
          },
        );
      },
    );

    return executionInfo != null;
  }

  @override
  bool onExecuteWateringCan() {
    final AttackExecutionInfo? executionInfo = _meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: SunnyPlayerConfig.loadRightWateringCanAnimation(),
          animationLeft: SunnyPlayerConfig.loadLeftWateringCanAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          // TODO(chatgpt): preciso que vc
          onExecutionFrames: () {
            FarmToolActionConfig.execute(player: this);
          },
        );
      },
    );

    return executionInfo != null;
  }

  @override
  bool onExecuteSeed() {
    final AttackExecutionInfo? executionInfo = _meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: SunnyPlayerConfig.loadRightSeedAnimation(),
          animationLeft: SunnyPlayerConfig.loadLeftSeedAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          // TODO(chatgpt): preciso que vc
          onExecutionFrames: () {
            FarmToolActionConfig.execute(player: this);
          },
        );
      },
    );

    return executionInfo != null;
  }

  @override
  bool onExecuteHarvestBasket() {
    final AttackExecutionInfo? executionInfo = _meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: SunnyPlayerConfig.loadRightHarvestBasketAnimation(),
          animationLeft: SunnyPlayerConfig.loadLeftHarvestBasketAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          // TODO(chatgpt): preciso que vc
          onExecutionFrames: () {
            FarmToolActionConfig.execute(player: this);
          },
        );
      },
    );

    return executionInfo != null;
  }
}
