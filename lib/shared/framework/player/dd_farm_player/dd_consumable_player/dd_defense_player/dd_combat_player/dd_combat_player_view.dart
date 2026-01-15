import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/systems/combat/attacks/character_fireball_attack_def.dart';
import 'package:dawnforge/game/core/systems/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:dawnforge/game/core/utils/offset_helper.dart';
import 'package:dawnforge/game/core/systems/audio/audio_manager.dart';
import 'package:dawnforge/game/core/systems/camera/camera_fx.dart';
import 'package:dawnforge/game/core/systems/combat/attacks/player_primary_attack_def.dart';
import 'package:dawnforge/game/core/systems/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:dawnforge/game/core/systems/combat/synchronized_attack/synchronized_attack_def.dart';
import 'package:dawnforge/game/core/systems/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_view.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
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

  late final List<DDAnimationDirectional> _comboAttackAnimations;
  int _comboStep = 0;
  bool _isAttackPlaying = false;
  bool _comboQueued = false;
  async.Timer? _comboResetTimer;
  static const Duration _kComboResetDelay = Duration(milliseconds: 450);

  late final SynchronizedAttackController meleeAttackController;
  late final SynchronizedAttackController rangedAttackController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeCombatSystems();

    final factories = config.comboAttackAnimationFactories.isNotEmpty
        ? config.comboAttackAnimationFactories
        : [config.animationAttackDirectionalFactory];

    final animations = await Future.wait(
      factories.map(
        DDCharacterActionSpriteAnimationHelper
            .loadAnimationDirectionalFromFactory,
      ),
    );

    _comboAttackAnimations = animations;
  }

  @override
  void onRemove() {
    _comboResetTimer?.cancel();
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
    if (_isAttackPlaying) {
      _comboQueued = true;
      return false; // evita cobrar stamina em cliques extras durante a animação
    }

    return _startComboAttack(damage);
  }

  bool _startComboAttack(double damage, {bool consumeStamina = false}) {
    _refreshFacingFromJoystick();

    if (consumeStamina) {
      final cost = controller.model.config.primaryAttackStaminaCost;
      if (controller.model.stamina < cost) {
        _comboQueued = false;
        _comboStep = 0;
        return false;
      }
      controller.model.consumeStamina(cost);
    }

    final DDAnimationDirectional comboAnimation =
        _comboAttackAnimations[_comboStep];

    // Captura o valor atual do combo para evitar que o closure capture a referência
    final currentComboStep = _comboStep;

    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: comboAnimation.right,
          animationLeft: comboAnimation.left,
          animationUp: comboAnimation.up,
          animationDown: comboAnimation.down,
          animationRightUp: comboAnimation.rightUp,
          animationRightDown: comboAnimation.rightDown,
          animationLeftUp: comboAnimation.leftUp,
          animationLeftDown: comboAnimation.leftDown,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 1,
          onActionStart: () {
            _isAttackPlaying = true;
            _comboResetTimer?.cancel();
            lockAction();
          },
          onActionEnd: () => _handleAttackEnd(damage),
          onExecutionFrames: () => _executePrimaryAttack(
            damage: damage,
            comboStep: currentComboStep,
          ),
        );
      },
    );

    if (executionInfo == null) {
      _isAttackPlaying = false;
      _comboQueued = false;
      return false;
    }

    _comboStep = (_comboStep + 1) % _comboAttackAnimations.length;
    return true;
  }

  void _refreshFacingFromJoystick() {}

  void _handleAttackEnd(double damage) {
    unlockAction();
    _isAttackPlaying = false;

    if (_comboQueued) {
      _comboQueued = false;
      if (!meleeAttackController.canPerformAttack) {
        meleeAttackController.forceReadyForCombo();
      }
      _startComboAttack(damage, consumeStamina: true);
      return;
    }

    _comboResetTimer?.cancel();
    _comboResetTimer = async.Timer(_kComboResetDelay, () {
      _comboStep = 0;
    });
  }

  bool _onExecuteRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = rangedAttackController.execute(
      AttackType.ranged,
      () => _executeFireballAttack(damage: damage),
    );

    return executionInfo != null;
  }

  void _executePrimaryAttack({required double damage, required int comboStep}) {
    final attackOffset = OffsetHelper.getCenterOffset(
      comboStep == 2 ? Vector2(4, 0) : Vector2(-4, 0),
      lastDirection,
    );

    CameraFx.executePrimaryAttackShake(gameRef);

    AudioManager.instance.playPlayerPrimaryAttackSfx(comboStep);

    // Terceiro ataque do combo (índice 2) usa tamanho maior
    final attackSize = comboStep == 2
        ? PlayerPrimaryAttackDef.componentSizeLarge
        : PlayerPrimaryAttackDef.componentSizeStandard;

    simpleAttackMeleeByDirection(
      direction: lastDirection,
      damage: damage,
      size: attackSize,
      centerOffset: attackOffset,
      // animationRight: PlayerPrimaryAttackDef.loadAnimationFxRight(),
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

    // addParticle(
    //   CharacterFxParticlesAnimationsDef.createFireballAttackParticles(),
    //   position: size / 2,
    // );

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
