import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fireball_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/player_primary_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_view.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
import 'package:flutter/foundation.dart';

abstract class DDCombatPlayerView<
  C extends DDCombatPlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDMobilePlayerView<C, M> {
  @protected
  final DDCombatPlayerViewConfig config;

  DDCombatPlayerView({
    required this.config,
    required super.position,
    required super.model,
  }) : super(config: config);

  late final DDAnimationDirectional animationAttackDirectional;

  late final SynchronizedAttackController meleeAttackController;
  late final SynchronizedAttackController rangedAttackController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeCombatSystems();

    animationAttackDirectional =
        await DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
          config.animationAttackDirectionalFactory,
        );
  }

  @override
  void onRemove() {
    meleeAttackController.dispose();
    rangedAttackController.dispose();
    super.onRemove();
  }

  void _initializeCombatSystems() {
    meleeAttackController = SynchronizedAttackController(
      config: SynchronizedAttackDef.standard,
    );
    rangedAttackController = SynchronizedAttackController(
      config: SynchronizedAttackDef.standard,
    );
  }

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

  bool _onExecutePrimaryAttack(double damage) {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationAttackDirectional.right,
          animationLeft: animationAttackDirectional.left,
          animationUp: animationAttackDirectional.up,
          animationDown: animationAttackDirectional.down,
          animationRightUp: animationAttackDirectional.rightUp,
          animationRightDown: animationAttackDirectional.rightDown,
          animationLeftUp: animationAttackDirectional.leftUp,
          animationLeftDown: animationAttackDirectional.leftDown,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 1,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => _executePrimaryAttack(damage: damage),
        );
      },
    );

    return executionInfo != null;
  }

  bool _onExecuteRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = rangedAttackController.execute(
      AttackType.ranged,
      () => _executeFireballAttack(damage: damage),
    );

    return executionInfo != null;
  }

  void _executePrimaryAttack({required double damage}) {
    final attackOffset = OffsetHelper.getCenterOffset(
      Vector2(-4, 0),
      lastDirection,
    );

    CameraFx.executePrimaryAttackShake(gameRef);

    AudioManager.instance.playPlayerPrimaryAttackSfx();

    simpleAttackMeleeByDirection(
      direction: lastDirection,
      damage: damage,
      size: PlayerPrimaryAttackDef.componentSize,
      centerOffset: attackOffset,
      animationRight: PlayerPrimaryAttackDef.loadAnimationFxRight(),
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
      onDamage: (_) => addParticle(
        CharacterFxParticlesAnimationsDef.createPrimaryAttackParticles(),
        position: size / 2,
      ),
    );
  }

  void _executeFireballAttack({required double damage}) {
    final Vector2 projectileOffset = OffsetHelper.getCenterOffset(
      Vector2(-16, 0),
      lastDirection,
    );

    addParticle(
      CharacterFxParticlesAnimationsDef.createFireballAttackParticles(),
      position: size / 2,
    );

    CharacterFireballAttackDef.playAudioExecution();

    simpleAttackRangeByDirection(
      size: CharacterFireballAttackDef.componentSize,
      speed: CharacterFireballAttackDef.kSpeed,
      lightingConfig: CharacterFireballAttackDef.lighting,
      damage: damage,
      collision: CharacterFireballAttackDef.createHitbox(),
      animationRight: CharacterFireballAttackDef.loadAnimationExecution(),
      animationDestroy: CharacterFireballAttackDef.loadAnimationDestroy(),
      onDestroy: () => CharacterFireballAttackDef.onDestroy(gameRef),
      direction: lastDirection,
      centerOffset: projectileOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }
}
