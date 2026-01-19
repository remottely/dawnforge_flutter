estou desenvolvendo um jogo clone de stardew valley totalmente sozinho, e pretendo consumir anos fazendo ele e por anos fazendo-o sozinho, assim como o criado do stardew valley, porém eu sou dev a 10 anos, hj senior em mobile flutter e sou especializado em clean architecture, TDD, DDD, BDD, etc. Então arquitetura é comigo mesmo. E a minha arquitetura do MVC inicialmente é robusta o suficiente para manter as logicas separadas por camadas e ate para reaproveitamento em outros jogos futuros feitos em flutter/bonfire. porem eu estou achando meio overengineer e sei q tem como fazer melhor e quero q vc me sugira algumas orgnaizacoes diferentes. inclusive eu queria pensar em uma maneira q nao service apenas para o player, mas sim ate poder talvez usar um padrao para o resto do projeto, ou pelo menos para componentes q se comportam parecidos como NPCs e Enemies. hj todas as minhas camadas de character é em MVC + config/definitions como na estrutura abaixo. hj como q eu faco, eu crio o mvc de cada camada e vou herdando da seguinte forma: 
abstract class DDBasePlayerView<
  C extends DDBasePlayerController<M>,
  M extends DDBasePlayerModel
>
    extends SimplePlayer
    with Lighting, BlockMovementCollision {
...
      abstract class DDMobilePlayerView<
  C extends DDMobilePlayerController<M>,
  M extends DDMobilePlayerModel
>
    extends DDBasePlayerView<C, M> {
...
abstract class DDCombatPlayerView<
  C extends DDCombatPlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDMobilePlayerView<C, M> {
...
abstract class DDDefensePlayerView<
  C extends DDCombatPlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDCombatPlayerView<C, M> {
...
abstract class DDFarmPlayerView<
  C extends DDFarmPlayerController<M>,
  M extends DDFarmPlayerModel
>
    extends DDDefensePlayerView<C, M> {
...
abstract class DDMinePlayerView<
  C extends DDMinePlayerController<M>,
  M extends DDMinePlayerModel
>
    extends DDFarmPlayerView<C, M> {
...

exemplo completo de uma das camadas:
import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/features/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/features/core/modules/overlay/overlay_message_def.dart';
import 'package:dawnforge/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_controller.dart';

abstract class DDCombatPlayerController<M extends DDCombatPlayerModel>
    extends DDMobilePlayerController<M> {
  final bool Function(double damage) onExecutePrimaryAttack;

  final bool Function(double damage) onExecuteRangedAttack;

  DDCombatPlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required this.onExecutePrimaryAttack,
    required this.onExecuteRangedAttack,
  });

  bool _isPrimaryAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == HandItemId.ironSword;

  bool _isRangedAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == HandItemId.staff;

  void _handleExecutePrimaryAttack() {
    GameLogger.info('[CombatController] _handleExecutePrimaryAttack: stamina=${model.stamina}, canExecute=${model.canExecutePrimaryAttack}');

    if (!model.canExecutePrimaryAttack) {
      GameLogger.warning('[CombatController] ✗ Não pode executar primary attack');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.primaryAttackStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecutePrimaryAttack.call(
      model.config.primaryAttackDamage,
    );

    GameLogger.info('[CombatController] Primary attack wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.primaryAttackStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteRangedAttack() {
    GameLogger.info('[CombatController] _handleExecuteRangedAttack: stamina=${model.stamina}, canExecute=${model.canExecuteRangedAttack}');

    if (!model.canExecuteRangedAttack) {
      GameLogger.warning('[CombatController] ✗ Não pode executar ranged attack');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.rangedAttackStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteRangedAttack.call(
      model.config.rangedAttackDamage,
    );

    GameLogger.info('[CombatController] Ranged attack wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.rangedAttackStaminaCost);

    endStaminaConsumingAction();
  }

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    GameLogger.info('[CombatController] Verificando ação: ${event.id} | equipment: ${player.controller.model.equipment} | evento: ${event.event}');

    // Só processa ações no DOWN, não no UP
    if (event.event != ActionEvent.DOWN) {
      super.handleInputAction(player: player, event: event);
      return;
    } else {
      if (_isPrimaryAttackAction(player: player, actionId: event.id)) {
        GameLogger.info('[CombatController] ✓ É primary attack action (iron sword)');
        _handleExecutePrimaryAttack();
      } else if (_isRangedAttackAction(player: player, actionId: event.id)) {
        GameLogger.info('[CombatController] ✓ É ranged attack action (staff)');
        _handleExecuteRangedAttack();
      } else {
        GameLogger.info('[CombatController] ✗ Não é ação de combate, passando para super');
      }

      super.handleInputAction(player: player, event: event);
    }
  }
}

import 'package:dawnforge/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';
import 'package:flutter/foundation.dart';

class DDCombatPlayerModel extends DDMobilePlayerModel {
  @override
  final DDCombatPlayerModelConfig config;

  @protected
  DDCombatPlayerModel.internal({required this.config, required super.saveData})
    : super.internal(config: config);

  bool get canExecutePrimaryAttack =>
      (stamina >= config.primaryAttackStaminaCost) &&
      (equipment == HandItemId.ironSword);

  bool get canExecuteRangedAttack =>
      (stamina >= config.rangedAttackStaminaCost) &&
      (equipment == HandItemId.staff);

  @override
  Map<String, dynamic> toJson() => super.toJson();

  @protected
  factory DDCombatPlayerModel.fromJson(
    Map<String, dynamic> json,
    DDCombatPlayerModelConfig config,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return DDCombatPlayerModel.internal(config: config, saveData: baseData);
  }
}

import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/features/core/modules/combat/attacks/character_fireball_attack_def.dart';
import 'package:dawnforge/features/core/modules/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:dawnforge/features/core/utils/offset_helper.dart';
import 'package:dawnforge/features/core/modules/audio/audio_manager.dart';
import 'package:dawnforge/features/core/modules/camera/camera_fx.dart';
import 'package:dawnforge/features/core/modules/combat/attacks/player_primary_attack_def.dart';
import 'package:dawnforge/features/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:dawnforge/features/core/modules/combat/synchronized_attack/synchronized_attack_def.dart';
import 'package:dawnforge/features/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
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

  void _executePrimaryAttack({
    required double damage,
    required int comboStep,
  }) {
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

import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/features/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/features/core/modules/overlay/overlay_message_def.dart';
import 'package:dawnforge/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_controller.dart';

abstract class DDCombatPlayerController<M extends DDCombatPlayerModel>
    extends DDMobilePlayerController<M> {
  final bool Function(double damage) onExecutePrimaryAttack;

  final bool Function(double damage) onExecuteRangedAttack;

  DDCombatPlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required this.onExecutePrimaryAttack,
    required this.onExecuteRangedAttack,
  });

  bool _isPrimaryAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == HandItemId.ironSword;

  bool _isRangedAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == HandItemId.staff;

  void _handleExecutePrimaryAttack() {
    GameLogger.info('[CombatController] _handleExecutePrimaryAttack: stamina=${model.stamina}, canExecute=${model.canExecutePrimaryAttack}');

    if (!model.canExecutePrimaryAttack) {
      GameLogger.warning('[CombatController] ✗ Não pode executar primary attack');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.primaryAttackStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecutePrimaryAttack.call(
      model.config.primaryAttackDamage,
    );

    GameLogger.info('[CombatController] Primary attack wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.primaryAttackStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteRangedAttack() {
    GameLogger.info('[CombatController] _handleExecuteRangedAttack: stamina=${model.stamina}, canExecute=${model.canExecuteRangedAttack}');

    if (!model.canExecuteRangedAttack) {
      GameLogger.warning('[CombatController] ✗ Não pode executar ranged attack');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.rangedAttackStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteRangedAttack.call(
      model.config.rangedAttackDamage,
    );

    GameLogger.info('[CombatController] Ranged attack wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.rangedAttackStaminaCost);

    endStaminaConsumingAction();
  }

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    GameLogger.info('[CombatController] Verificando ação: ${event.id} | equipment: ${player.controller.model.equipment} | evento: ${event.event}');

    // Só processa ações no DOWN, não no UP
    if (event.event != ActionEvent.DOWN) {
      super.handleInputAction(player: player, event: event);
      return;
    } else {
      if (_isPrimaryAttackAction(player: player, actionId: event.id)) {
        GameLogger.info('[CombatController] ✓ É primary attack action (iron sword)');
        _handleExecutePrimaryAttack();
      } else if (_isRangedAttackAction(player: player, actionId: event.id)) {
        GameLogger.info('[CombatController] ✓ É ranged attack action (staff)');
        _handleExecuteRangedAttack();
      } else {
        GameLogger.info('[CombatController] ✗ Não é ação de combate, passando para super');
      }

      super.handleInputAction(player: player, event: event);
    }
  }
}

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/features/characters/player/demo/demo_player_def.dart';
import 'package:dawnforge/features/characters/player/demo/demo_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_view.dart';

class DemoPlayerView<
  C extends DemoPlayerController<M>,
  M extends DDFarmPlayerModel
>
    extends DDFarmPlayerView<C, M> {
  DemoPlayerView({required super.position, required super.model})
    : super(config: DemoPlayerDef.viewConfig);

  @override
  C createFarmController({
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
    required bool Function() onExecuteDig,
    required bool Function() onExecuteWateringCan,
    required bool Function() onExecuteSeed,
    required bool Function() onExecuteHarvest,
  }) {
    return DemoPlayerController<DDFarmPlayerModel>(
          model: model,
          onDisplayExclamationEmote: onDisplayExclamationEmote,
          onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
          onChangeRunState: onChangeRunState,
          onExecutePrimaryAttack: onExecutePrimaryAttack,
          onExecuteRangedAttack: onExecuteRangedAttack,
          onExecuteDig: onExecuteDig,
          onExecuteWateringCan: onExecuteWateringCan,
          onExecuteSeed: onExecuteSeed,
          onExecuteHarvest: onExecuteHarvest,
        )
        as C;
  }
}


import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
class DemoPlayerController<M extends DDFarmPlayerModel>
    extends DDFarmPlayerController<M> {
  DemoPlayerController({
    required super.model,
    required super.onChangeRunState,
    required super.onExecuteDig,
    required super.onExecuteWateringCan,
    required super.onExecuteSeed,
    required super.onExecuteHarvest,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });
}

// ignore_for_file: unused_field

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/features/characters/character_constants.dart';
import 'package:dawnforge/features/core/modules/game/lightning_constants.dart';
import 'package:dawnforge/features/core/modules/game/tile_constants.dart';
import 'package:dawnforge/features/core/utils/app_environment.dart';
import 'package:dawnforge/features/core/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';

final class DemoPlayerDef {
  DemoPlayerDef._();

  static const double _kMaxStamina = 100.0;
  static const int _kMaxEnergy = 100;
  static const int _kStaminaIncrement = 1;
  static const double _kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const Duration _kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double _kRunSpeedMultiplier = 1.4;

  static const int _kPrimaryAttackStaminaCost = 1;
  static const int _kFireballAttackStaminaCost = 2;
  static const double _kPrimaryAttackDamage = 25.0;
  static const double _kFireballAttackDamage = 10.0;

  static const int _kDigStaminaCost = 5;
  static const int _kWateringCanStaminaCost = 5;
  static const int _kSeedStaminaCost = 5;
  static const int _kHarvestStaminaCost = 5;

  static const modelConfig = DDFarmPlayerModelConfig(
    maxStamina: _kMaxStamina,
    maxEnergy: _kMaxEnergy,
    staminaRegenIncrement: _kStaminaIncrement,
    longVisionRadius: _kLongVisionRadius,
    staminaRegenDebounce: _kStaminaRegenDebounce,
    runSpeedMultiplier: _kRunSpeedMultiplier,
    primaryAttackStaminaCost: _kPrimaryAttackStaminaCost,
    rangedAttackStaminaCost: _kFireballAttackStaminaCost,
    primaryAttackDamage: _kPrimaryAttackDamage,
    rangedAttackDamage: _kFireballAttackDamage,
    digStaminaCost: _kDigStaminaCost,
    wateringCanStaminaCost: _kWateringCanStaminaCost,
    seedStaminaCost: _kSeedStaminaCost,
    harvestStaminaCost: _kHarvestStaminaCost,
  );

  static const double _kLife = CharacterConstants.kLifeExtraLarge;
  static double _kBaseSpeed = CharacterConstants.kSpeedFast;

  static final Vector2 textureSize = TileConstants.tileSizeDemo;
  static final Vector2 _componentSize = textureSize;

  static final RectangleHitbox _hitbox = HitboxUtils.createCustomHitbox(
    componentSize: _componentSize,
    left: 26,
    top: 33,
    right: 27,
    bottom: 22,
  );

  // static String idleAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_idle_full_light_demo_2.png';
  // static String walkAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_walk_full_light_demo.png';
  // static String runAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_run_full_light_with_dust_specs_demo.png';
  // static String digAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_tools_shovel_full_light_demo.png';
  // static String wateringAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_tools_watercan_full_light_demo.png';
  // static String harvestAssetPath =
  //     'tiled/SmallBurg_farm_pack_v3.18/assets/demo/character_tools_hoe_full_light_demo.png';

  static String idleAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/idle/character_body/character_idle_body_light_2.png';
  static String placeSeedAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/place_seed/character_body/character_place_seed_body_light_6.png';
  static String runAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/run/character_body/character_run_body_light_with_dust_specs_4.png';
  static String chopAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_axe/character_body/character_tools_axe_body_light_7.png';
  static String harvestAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_hoe/character_body/character_tools_hoe_body_light_7.png';
  static String mineAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_pickaxe/character_body/character_tools_pickaxe_body_light_7.png';
  static String digAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_shovel/character_body/character_tools_shovel_body_light_6.png';
  static String wateringAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/tools_watercan/character_body/character_tools_watercan_body_light_10.png';
  static String walkAssetPath =
      'tiled/SmallBurg_farm_pack_v3.18/edited_assets/character/walk/character_body/character_walk_body_light_6.png';
  static String attac1kAssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/edited_assets/characters/slash_1/character_demo/character_slash_1_light_full_6.png';
  static String attack2AssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/edited_assets/characters/slash_2/character_demo/character_slash_2_light_full_6.png';
  static String attack3AssetPath =
      'tiled/Smallburg_dungeon_pack_v2.13/edited_assets/characters/super_slash/character_demo/character_super_slash_light_full_6.png';

  static const int _x2 = 2;
  static const int _x4 = 4;
  static const int _x6 = 6;
  static const int _x7 = 7;
  static const int _x10 = 10;
  static const double _frameRightY = 0;
  static const double _frameLeftY = TileConstants.kCharacterDimensionDemo * 1;
  static const double _frameDownY = TileConstants.kCharacterDimensionDemo * 2;
  static const double _frameUpY = TileConstants.kCharacterDimensionDemo * 3;

  static const int _x9 = 9;
  static const double _frameRightX9 = _x9 * 0;
  static const double _frameUpX9 = _x9 * 1;
  static const double _frameLeftX9 = _x9 * 2;
  static const double _frameDownX9 = _x9 * 3;

  static const double _frameRightX10 = _x10 * 0;
  static const double _frameUpX10 = _x10 * 1;
  static const double _frameLeftX10 = _x10 * 2;
  static const double _frameDownX10 = _x10 * 3;

  static const double _frameHarvestY = 6;
  static const double _framePlaceSeedY = _frameHarvestY;
  static const double _frameChoppingY = 18;
  static const double _frameAttackY = _frameChoppingY;

  static const int _skipFirstFramesX6 = 6;

  static final Future<SpriteAnimation> _loadAnimationIdleRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationIdleUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> loadAnimationIdleDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeSlow,
        textureSize: textureSize,
        totalFrames: _x2,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWalkDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: walkAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final SimpleDirectionAnimation _animationWalkDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft,
        idleRight: _loadAnimationIdleRight,
        idleUp: _loadAnimationIdleUp,
        idleDown: loadAnimationIdleDown,
        runLeft: _loadAnimationWalkLeft,
        runRight: _loadAnimationWalkRight,
        runUp: _loadAnimationWalkUp,
        runDown: _loadAnimationWalkDown,
      );

  static final Future<SpriteAnimation> _loadAnimationRunRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationRunDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: runAssetPath,
        textureSize: textureSize,
        totalFrames: _x4,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final SimpleDirectionAnimation _animationRunDirectional =
      SimpleDirectionAnimation(
        idleLeft: _loadAnimationIdleLeft,
        idleRight: _loadAnimationIdleRight,
        idleUp: _loadAnimationIdleUp,
        idleDown: loadAnimationIdleDown,
        // TODO(Kevin): NOW - create run animations
        runLeft: _loadAnimationRunLeft,
        runRight: _loadAnimationRunRight,
        runUp: _loadAnimationRunUp,
        runDown: _loadAnimationRunDown,
        // runLeft: _loadAnimationHarvestLeft,
        // runRight: _loadAnimationHarvestRight,
        // runUp: _loadAnimationHarvestUp,
        // runDown: _loadAnimationHarvestDown,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationHarvestDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: harvestAssetPath,
        textureSize: textureSize,
        totalFrames: _x7,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationHarvestDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationHarvestRight,
        loadLeft: _loadAnimationHarvestLeft,
        loadUp: _loadAnimationHarvestUp,
        loadDown: _loadAnimationHarvestDown,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameRightX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameLeftX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -6,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameUpX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -4,
      );

  static final Future<SpriteAnimation> _loadAnimationChoppingDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: idleAssetPath,
        textureSize: textureSize,
        totalFrames: _x10,
        framePositionX: _frameDownX10,
        framePositionY: _frameChoppingY,
        framePositionXPadding: -8,
        framePositionYPadding: -8,
      );

  static final _animationChoppingDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationChoppingRight,
        loadLeft: _loadAnimationChoppingLeft,
        loadUp: _loadAnimationChoppingUp,
        loadDown: _loadAnimationChoppingDown,
      );
  static Future<SpriteAnimation> _loadAnimationAttack1Right =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attac1kAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack1Left =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attac1kAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack1Up =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attac1kAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack1Down =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attac1kAssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationAttack1DirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttack1Right,
        loadLeft: _loadAnimationAttack1Left,
        loadUp: _loadAnimationAttack1Up,
        loadDown: _loadAnimationAttack1Down,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Right =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Left =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Up =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack2Down =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack2AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationAttack2DirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttack2Right,
        loadLeft: _loadAnimationAttack2Left,
        loadUp: _loadAnimationAttack2Up,
        loadDown: _loadAnimationAttack2Down,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Right =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Left =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Up =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static Future<SpriteAnimation> _loadAnimationAttack3Down =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: attack3AssetPath,
        stepTime: SpriteAnimationConstants.kStepTimeFast,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationAttack3DirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationAttack3Right,
        loadLeft: _loadAnimationAttack3Left,
        loadUp: _loadAnimationAttack3Up,
        loadDown: _loadAnimationAttack3Down,
      );

  static final Future<SpriteAnimation> _loadAnimationDigRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationDigDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: digAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationDigDirectionalFactory = DDAnimationDirectionalFactory(
    // executionStartFrame: 4,
    loadRight: _loadAnimationDigRight,
    loadLeft: _loadAnimationDigLeft,
    loadUp: _loadAnimationDigUp,
    loadDown: _loadAnimationDigDown,
  );

  static final Future<SpriteAnimation> _loadAnimationWateringRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationWateringDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: wateringAssetPath,
        textureSize: textureSize,
        totalFrames: AppEnvironment.kIsDevToolsMode ? 1 : _x10,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationWateringDirectionalFactory =
      DDAnimationDirectionalFactory(
        // executionStartFrame: 14,
        // TODO(Kevin): change all waterincan names to watering
        loadRight: _loadAnimationWateringRight,
        loadLeft: _loadAnimationWateringLeft,
        loadUp: _loadAnimationWateringUp,
        loadDown: _loadAnimationWateringDown,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedRight =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameRightY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedLeft =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameLeftY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedUp =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameUpY,
      );

  static final Future<SpriteAnimation> _loadAnimationPlaceSeedDown =
      SpriteAnimationConfigHelper.loadAnimationFromTextureAtlasSmallBurg(
        assetPath: placeSeedAssetPath,
        textureSize: textureSize,
        totalFrames: _x6,
        framePositionX: 0,
        framePositionY: _frameDownY,
      );

  static final _animationPlaceSeedDirectionalFactory =
      DDAnimationDirectionalFactory(
        loadRight: _loadAnimationPlaceSeedRight,
        loadLeft: _loadAnimationPlaceSeedLeft,
        loadUp: _loadAnimationPlaceSeedUp,
        loadDown: _loadAnimationPlaceSeedDown,
      );

  static final LightingConfig _lighting = LightingConfig(
    radius: TileConstants.kTileDimensionLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  static final Vector2 _cryptComponentSize = TileConstants.tileSizeStandard;

  static Future<Sprite> _loadSpriteCrypt() => Sprite.load(
    'gameplay/characters/player/player_crypt_1.png',
  ); // TODO(Kevin): add demo death animation playonce // - new/Player/death/

  static GameDecoration _createDeathMarker(Vector2 position) =>
      GameDecoration.withSprite(
        sprite: _loadSpriteCrypt(),
        position: Vector2(position.x, position.y),
        size: _cryptComponentSize,
      );

  static final viewConfig = DDFarmPlayerViewConfig(
    size: _componentSize,
    life: _kLife,
    baseSpeed: _kBaseSpeed,
    hitbox: _hitbox,
    lighting: _lighting,
    getDeathMarker: (position) => _createDeathMarker(position),
    animationWalkDirectional: _animationWalkDirectional,
    animationRunDirectional: _animationRunDirectional,
    animationAttackDirectionalFactory: _animationAttack1DirectionalFactory,
    comboAttackAnimationFactories: [
      _animationAttack1DirectionalFactory,
      _animationAttack2DirectionalFactory,
      _animationAttack3DirectionalFactory,
    ],
    animationDigFactory: _animationDigDirectionalFactory,
    animationWateringCanFactory: _animationWateringDirectionalFactory,
    animationPlaceSeedFactory: _animationPlaceSeedDirectionalFactory,
    animationHarvestFactory: _animationHarvestDirectionalFactory,
  );
}

// - new/Player/axe/
// - new/Player/pickaxe/
