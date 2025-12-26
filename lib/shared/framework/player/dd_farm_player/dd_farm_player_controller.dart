import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

abstract class DDFarmPlayerController<M extends DDFarmPlayerModel>
    extends DDCombatPlayerController<M> {
  final bool Function() onExecuteDig;
  final bool Function() onExecuteWateringCan;
  final bool Function() onExecuteSeed;
  final bool Function() onExecuteHarvest;

  DDFarmPlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required this.onExecuteDig,
    required this.onExecuteWateringCan,
    required this.onExecuteSeed,
    required this.onExecuteHarvest,
  });

  bool isDigAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.controller.model.equipment == EquippedHandType.shovel;

  bool isWateringCanAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.controller.model.equipment == EquippedHandType.wateringCan;

  bool isSeedAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      (player.controller.model.equipment?.isSeed ?? false);

  bool isHarvestAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.controller.model.equipment == EquippedHandType.harvestBasket;

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    if (isDigAction(player: player, actionId: event.id)) {
      _handleExecuteDig();
    } else if (isWateringCanAction(player: player, actionId: event.id)) {
      _handleExecuteWateringCan();
    } else if (isSeedAction(player: player, actionId: event.id)) {
      _handleExecuteSeed();
    } else if (isHarvestAction(player: player, actionId: event.id)) {
      _handleExecuteHarvest();
    }

    super.handleInputAction(player: player, event: event);
  }

  void _handleExecuteDig() {
    if (!model.canExecuteDig) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteDig.call();
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.digStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteWateringCan() {
    if (!model.canExecuteWateringCan) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteWateringCan.call();
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.wateringCanStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteSeed() {
    if (!model.canExecuteSeed) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteSeed.call();
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.seedStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteHarvest() {
    if (!model.canExecuteHarvest) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteHarvest.call();
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.harvestStaminaCost);

    endStaminaConsumingAction();
  }
}
