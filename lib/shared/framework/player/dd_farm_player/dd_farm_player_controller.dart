import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

abstract class DDFarmPlayerController<M extends DDFarmPlayerModel>
    extends DDCombatPlayerController<M> {
  final bool Function() onExecuteShovel;
  final bool Function() onExecuteWateringCan;
  final bool Function() onExecuteSeed;
  final bool Function() onExecuteHarvestBasket;

  DDFarmPlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required this.onExecuteShovel,
    required this.onExecuteWateringCan,
    required this.onExecuteSeed,
    required this.onExecuteHarvestBasket,
  });

  bool isShovelAction({
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
      player.controller.model.equipment == EquippedHandType.strawberry;

  bool isHarvestBasketAction({
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
    if (isShovelAction(player: player, actionId: event.id)) {
      _handleExecuteShovel();
    } else if (isWateringCanAction(player: player, actionId: event.id)) {
      _handleExecuteWateringCan();
    } else if (isSeedAction(player: player, actionId: event.id)) {
      _handleExecuteSeed();
    } else if (isHarvestBasketAction(player: player, actionId: event.id)) {
      _handleExecuteHarvestBasket();
    }

    super.handleInputAction(player: player, event: event);
  }

  void _handleExecuteShovel() {
    if (!model.canExecuteShovel) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteShovel.call();
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.shovelStaminaCost);

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

    model.consumeStamina(model.wateringCanStaminaCost);

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

    model.consumeStamina(model.seedStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteHarvestBasket() {
    if (!model.canExecuteHarvestBasket) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteHarvestBasket.call();
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.harvestBasketStaminaCost);

    endStaminaConsumingAction();
  }
}
