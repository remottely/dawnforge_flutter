import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:dawnforge/gameplay/farm/services/farm_tool_action_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_model.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
import 'package:flutter/foundation.dart';

abstract class DDMinePlayerView<
  C extends DDMinePlayerController<M>,
  M extends DDMinePlayerModel
>
    extends DDFarmPlayerView<C, M> {
  @protected
  final DDMinePlayerViewConfig config;

  DDMinePlayerView({
    required this.config,
    required super.position,
    required super.model,
  }) : super(config: config);

  late final DDAnimationDirectional animationMineDirectional;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final toolsLoaded = await Future.wait([
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        config.animationMineFactory,
      ),
    ]);

    animationMineDirectional = toolsLoaded[0];
  }

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
    return createMineController(
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
      onExecuteMine: _onExecuteMine,
    );
  }

  C createMineController({
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
    required bool Function() onExecuteMine,
  });

  bool _onExecuteMine() {
    GameLogger.info('[FarmPlayerView] _onExecuteDig chamado');

    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        GameLogger.info(
          '[FarmPlayerView] _onExecuteDig: Executando animação de dig',
        );
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationMineDirectional.right,
          animationLeft: animationMineDirectional.left,
          animationUp: animationMineDirectional.up,
          animationDown: animationMineDirectional.down,
          animationRightUp: animationMineDirectional.rightUp,
          animationRightDown: animationMineDirectional.rightDown,
          animationLeftUp: animationMineDirectional.leftUp,
          animationLeftDown: animationMineDirectional.leftDown,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 5, // TODO(Kevin): inject this value
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionDef.execute(
            player: this,
          ), // TODO(kevin): change this to MineToolActionDef
        );
      },
    );

    final wasExecuted = executionInfo != null;
    GameLogger.info(
      '[FarmPlayerView] _onExecuteDig resultado: $wasExecuted (executionInfo=$executionInfo)',
    );

    return wasExecuted;
  }
}
