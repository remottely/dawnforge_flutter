import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_tool_action_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_defense_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
import 'package:flutter/foundation.dart';

abstract class DDFarmPlayerView<
  C extends DDFarmPlayerController<M>,
  M extends DDFarmPlayerModel
>
    extends DDDefensePlayerView<C, M> {
  @protected
  final DDFarmPlayerViewConfig viewConfig;

  DDFarmPlayerView({
    required this.viewConfig,
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required super.speed,
  }) : super(viewConfig: viewConfig);

  late final DDAnimationDirectional animationShovelDirectional;
  late final DDAnimationDirectional animationWateringCanDirectional;
  late final DDAnimationDirectional animationPlaceSeedDirectional;
  late final DDAnimationDirectional animationHarvestBasketDirectional;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final toolsLoaded = await Future.wait([
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        viewConfig.animationShovelFactory,
      ),
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        viewConfig.animationWateringCanFactory,
      ),
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        viewConfig.animationPlaceSeedFactory,
      ),
      DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        viewConfig.animationHarvestBasketFactory,
      ),
    ]);

    animationShovelDirectional = toolsLoaded[0];
    animationWateringCanDirectional = toolsLoaded[1];
    animationPlaceSeedDirectional = toolsLoaded[2];
    animationHarvestBasketDirectional = toolsLoaded[3];
  }

  @override
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
  }) {
    return createFarmController(
      model: model,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
      onChangeRunState: onChangeRunState,
      onExecutePrimaryAttack: onExecutePrimaryAttack,
      onExecuteRangedAttack: onExecuteRangedAttack,
      onExecuteShovel: _onExecuteShovel,
      onExecuteWateringCan: _onExecuteWateringCan,
      onExecuteSeed: _onExecuteSeed,
      onExecuteHarvestBasket: _onExecuteHarvestBasket,
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
    required bool Function() onExecuteShovel,
    required bool Function() onExecuteWateringCan,
    required bool Function() onExecuteSeed,
    required bool Function() onExecuteHarvestBasket,
  });

  bool _onExecuteShovel() {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationShovelDirectional.right,
          animationLeft: animationShovelDirectional.left,
          animationUp: animationShovelDirectional.up,
          animationDown: animationShovelDirectional.down,
          animationRightUp: animationShovelDirectional.rightUp,
          animationRightDown: animationShovelDirectional.rightDown,
          animationLeftUp: animationShovelDirectional.leftUp,
          animationLeftDown: animationShovelDirectional.leftDown,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionConfig.execute(player: this),
        );
      },
    );

    return executionInfo != null;
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
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionConfig.execute(player: this),
        );
      },
    );

    return executionInfo != null;
  }

  bool _onExecuteSeed() {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
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
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionConfig.execute(player: this),
        );
      },
    );

    return executionInfo != null;
  }

  bool _onExecuteHarvestBasket() {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: animationHarvestBasketDirectional.right,
          animationLeft: animationHarvestBasketDirectional.left,

          animationUp: animationHarvestBasketDirectional.up,
          animationDown: animationHarvestBasketDirectional.down,
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () => FarmToolActionConfig.execute(player: this),
        );
      },
    );

    return executionInfo != null;
  }
}
