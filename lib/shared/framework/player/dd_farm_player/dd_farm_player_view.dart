import 'dart:async';
import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:dawnforge/core/utils/app_environment.dart';
import 'package:dawnforge/game/features/farm/services/farm_tool_action_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_consumable_player_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
import 'package:flutter/foundation.dart';

abstract class DDFarmPlayerView<
  C extends DDFarmPlayerController<M>,
  M extends DDFarmPlayerModel
>
    extends DDConsumablePlayerView<C, M> {
  @protected
  final DDFarmPlayerViewConfig config;

  DDFarmPlayerView({
    required this.config,
    required super.position,
    required super.model,
  }) : super(config: config);

  late final DDAnimationDirectional animationDigDirectional;
  late final DDAnimationDirectional animationWateringCanDirectional;
  late final DDAnimationDirectional animationPlaceSeedDirectional;
  late final DDAnimationDirectional animationHarvestDirectional;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final toolsLoaded = await Future.wait([
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        config.animationDigFactory,
      ),
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        config.animationWateringCanFactory,
      ),
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        config.animationPlaceSeedFactory,
      ),
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        config.animationHarvestFactory,
      ),
    ]);

    animationDigDirectional = toolsLoaded[0];
    animationWateringCanDirectional = toolsLoaded[1];
    animationPlaceSeedDirectional = toolsLoaded[2];
    animationHarvestDirectional = toolsLoaded[3];
  }

  @override
  C createConsumableController({
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
  }) {
    return createFarmController(
      model: model,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
      onChangeRunState: onChangeRunState,
      onExecutePrimaryAttack: onExecutePrimaryAttack,
      onExecuteRangedAttack: onExecuteRangedAttack,
      onExecuteDig: _onExecuteDig,
      onExecuteWateringCan: _onExecuteWateringCan,
      onExecuteSeed: _onExecuteSeed,
      onExecuteHarvest: _onExecuteHarvest,
    );
  }

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
  });

  bool _onExecuteDig() {
    GameLogger.info('[FarmPlayerView] _onExecuteDig chamado');

    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        GameLogger.info(
          '[FarmPlayerView] _onExecuteDig: Executando animação de dig',
        );
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationDigDirectional.right,
          animationLeft: animationDigDirectional.left,
          animationUp: animationDigDirectional.up,
          animationDown: animationDigDirectional.down,
          animationRightUp: animationDigDirectional.rightUp,
          animationRightDown: animationDigDirectional.rightDown,
          animationLeftUp: animationDigDirectional.leftUp,
          animationLeftDown: animationDigDirectional.leftDown,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 5, // TODO(Kevin): inject this value
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionDef.execute(player: this),
        );
      },
    );

    final wasExecuted = executionInfo != null;
    GameLogger.info(
      '[FarmPlayerView] _onExecuteDig resultado: $wasExecuted (executionInfo=$executionInfo)',
    );

    return wasExecuted;
  }

  bool _onExecuteWateringCan() {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationWateringCanDirectional.right,
          animationLeft: animationWateringCanDirectional.left,
          animationUp: animationWateringCanDirectional.up,
          animationDown: animationWateringCanDirectional.down,
          animationRightUp: animationWateringCanDirectional.rightUp,
          animationRightDown: animationWateringCanDirectional.rightDown,
          animationLeftUp: animationWateringCanDirectional.leftUp,
          animationLeftDown: animationWateringCanDirectional.leftDown,
          currentAnimation: animation,
          target: this,
          executionStartFrame: AppEnvironment.kIsDevToolsMode
              ? 0
              : 8, // TODO(Kevin): inject this value dynamically
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionDef.execute(player: this),
        );
      },
    );

    return executionInfo != null;
  }

  bool _onExecuteSeed() {
    GameLogger.info('[FarmPlayerView] _onExecuteSeed chamado');

    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        GameLogger.info(
          '[FarmPlayerView] _onExecuteSeed: Executando animação de seed',
        );
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationPlaceSeedDirectional.right,
          animationLeft: animationPlaceSeedDirectional.left,
          animationUp: animationPlaceSeedDirectional.up,
          animationDown: animationPlaceSeedDirectional.down,
          animationRightUp: animationPlaceSeedDirectional.rightUp,
          animationRightDown: animationPlaceSeedDirectional.rightDown,
          animationLeftUp: animationPlaceSeedDirectional.leftUp,
          animationLeftDown: animationPlaceSeedDirectional.leftDown,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4, // TODO(Kevin): inject this value
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionDef.execute(player: this),
        );
      },
    );

    final wasExecuted = executionInfo != null;
    GameLogger.info(
      '[FarmPlayerView] _onExecuteSeed resultado: $wasExecuted (executionInfo=$executionInfo)',
    );

    return wasExecuted;
  }

  bool _onExecuteHarvest() {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationHarvestDirectional.right,
          animationLeft: animationHarvestDirectional.left,

          animationUp: animationHarvestDirectional.up,
          animationDown: animationHarvestDirectional.down,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4, // TODO(Kevin): inject this value
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionDef.execute(player: this),
        );
      },
    );

    return executionInfo != null;
  }
}
