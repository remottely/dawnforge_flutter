import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_tool_action_config.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_defense_player/dd_defense_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_model.dart';

abstract class DDFarmPlayerView<
  C extends DDFarmPlayerController<M>,
  M extends DDFarmPlayerModel
>
    extends DDDefensePlayerView<C, M> {
  DDFarmPlayerView({
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required super.speed,
  });

  Future<SpriteAnimation> getAnimShovelRight();
  Future<SpriteAnimation> getAnimShovelLeft();
  Future<SpriteAnimation>? getAnimShovelUp();
  Future<SpriteAnimation>? getAnimShovelDown();
  Future<SpriteAnimation>? getAnimShovelRightUp();
  Future<SpriteAnimation>? getAnimShovelRightDown();
  Future<SpriteAnimation>? getAnimShovelLeftUp();
  Future<SpriteAnimation>? getAnimShovelLeftDown();

  Future<SpriteAnimation> getAnimWateringCanRight();
  Future<SpriteAnimation> getAnimWateringCanLeft();
  Future<SpriteAnimation>? getAnimWateringCanUp();
  Future<SpriteAnimation>? getAnimWateringCanDown();
  Future<SpriteAnimation>? getAnimWateringCanRightUp();
  Future<SpriteAnimation>? getAnimWateringCanRightDown();
  Future<SpriteAnimation>? getAnimWateringCanLeftUp();
  Future<SpriteAnimation>? getAnimWateringCanLeftDown();

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

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    super.onJoystickChangeDirectional(event);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  bool _onExecuteShovel() {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: getAnimShovelRight(),
          animationLeft: getAnimShovelLeft(),
          animationUp: getAnimShovelUp(),
          animationDown: getAnimShovelDown(),
          animationRightUp: getAnimShovelRightUp(),
          animationRightDown: getAnimShovelRightDown(),
          animationLeftUp: getAnimShovelLeftUp(),
          animationLeftDown: getAnimShovelLeftDown(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () {
            FarmToolActionConfig.execute(player: this);
          },
        );
      },
    );

    return executionInfo != null;
  }

  bool _onExecuteWateringCan() {
    final AttackExecutionInfo?
    executionInfo = meleeAttackController.execute(AttackType.melee, () {
      // TODO(Kevin): NOW - create dinamic animation injected by view interface configurations
      CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
        animationRight: getAnimWateringCanRight(),
        animationLeft: getAnimWateringCanLeft(),
        animationUp: getAnimWateringCanUp(),
        animationDown: getAnimWateringCanDown(),
        animationRightUp: getAnimWateringCanRightUp(),
        animationRightDown: getAnimWateringCanRightDown(),
        animationLeftUp: getAnimWateringCanLeftUp(),
        animationLeftDown: getAnimWateringCanLeftDown(),
        currentAnimation: animation,
        target: this,
        executionStartFrame: 4,
        onActionStart: lockAction,
        onActionEnd: unlockAction,

        onExecutionFrames: () {
          FarmToolActionConfig.execute(player: this);
        },
      );
    });

    return executionInfo != null;
  }

  bool _onExecuteSeed() {
    final AttackExecutionInfo?
    executionInfo = meleeAttackController.execute(AttackType.melee, () {
      // TODO(Kevin): NOW - create dinamic animation injected by view interface configurations
      CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
        animationRight: SunnyPlayerConfig.loadRightSeedAnimation(),
        animationLeft: SunnyPlayerConfig.loadLeftSeedAnimation(),
        currentAnimation: animation,
        target: this,
        executionStartFrame: 4,
        onActionStart: lockAction,
        onActionEnd: unlockAction,

        onExecutionFrames: () {
          FarmToolActionConfig.execute(player: this);
        },
      );
    });

    return executionInfo != null;
  }

  bool _onExecuteHarvestBasket() {
    final AttackExecutionInfo?
    executionInfo = meleeAttackController.execute(AttackType.melee, () {
      // TODO(Kevin): NOW - create dinamic animation injected by view interface configurations
      CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
        animationRight: SunnyPlayerConfig.loadRightHarvestBasketAnimation(),
        animationLeft: SunnyPlayerConfig.loadLeftHarvestBasketAnimation(),
        currentAnimation: animation,
        target: this,
        executionStartFrame: 4,
        onActionStart: lockAction,
        onActionEnd: unlockAction,

        onExecutionFrames: () {
          FarmToolActionConfig.execute(player: this);
        },
      );
    });

    return executionInfo != null;
  }
}
