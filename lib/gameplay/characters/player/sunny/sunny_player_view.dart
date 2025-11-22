import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farmable/farm_tile.dart';
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
  // final FarmActionManager _farmActionManager = FarmActionManager.instance;

  SunnyPlayerView({
    required super.farmActionManager,
    required super.position,
    required super.model,
  }) : super(
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
    required bool Function() onExecuteDigger,
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
      onExecuteDigger: onExecuteDigger,
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
        CharacterActionSpriteAnimationHelper.playExecutionOnceWithIdle(
          animationRight: SunnyPlayerConfig.loadRightAttackAnimation(),
          animationLeft: SunnyPlayerConfig.loadLeftAttackAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () {
            PlayerPrimaryAttackConfig.execute(player: this, damage: damage);
          },
        );
      },
    );

    return executionInfo != null;
  }

  @override
  bool onExecuteDigger() {
    final AttackExecutionInfo?
    executionInfo = _meleeAttackController.execute(AttackType.melee, () {
      CharacterActionSpriteAnimationHelper.playExecutionOnceWithIdle(
        animationRight: SunnyPlayerConfig.loadRightDiggerAnimation(),
        animationLeft: SunnyPlayerConfig.loadLeftDiggerAnimation(),
        currentAnimation: animation,
        target: this,
        executionStartFrame: 4,
        onActionStart: lockAction,
        onActionEnd: unlockAction,
        onExecutionFrames: () {
          // Compute the world position in front of the player where the digger acts
          final attackOffset = OffsetHelper.getCenterOffset(
            Vector2(6, 0),
            lastDirection,
          );
          final startPos =
              rectCollision.center.toVector2() +
              Vector2(attackOffset.x, attackOffset.y);

          // Define a small detection rect around the impact point
          final hitRect = Rect.fromCenter(
            center: Offset(startPos.x, startPos.y),
            width: 16,
            height: 16,
          );

          // var interacted = false;
          // Query for farm tile views that overlap the impact area and pick the closest one
          FarmTileView? bestTarget;
          double bestDistSq = double.infinity;

          for (final view in gameRef.query<FarmTileView>()) {
            final compRect = view.rectCollision;
            if (!compRect.overlaps(hitRect)) continue;

            final dx = compRect.center.dx - startPos.x;
            final dy = compRect.center.dy - startPos.y;
            final distSq = dx * dx + dy * dy;

            if (distSq < bestDistSq) {
              bestDistSq = distSq;
              bestTarget = view;
            }
          }

          if (bestTarget != null) {
            FarmManager.instance.tillSoil(bestTarget.tileX, bestTarget.tileY);
          }

          // // Fallback: if nothing handled the tool, call farmActionManager as before
          // if (!interacted) {
          //   farmActionManager.handleTillSoil(
          //     this.position.x.toInt(),
          //     this.position.y.toInt(),
          //   );
          // }
          // // PlayerPrimaryAttackConfig.execute(player: this, damage: damage);
        },
      );
    });

    return executionInfo != null;
  }

  @override
  bool onExecuteRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = _rangedAttackController.execute(
      AttackType.ranged,
      () => CharacterFireballAttackConfig.playerExecute(
        player: this,
        damage: damage,
      ),
    );

    return executionInfo != null;
  }
}
