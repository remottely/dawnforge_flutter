import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_model.dart';

abstract class DDFarmPlayerController<M extends DDFarmPlayerModel>
    extends DDCombatPlayerController<M> {
  final bool Function() onExecuteShovel;
  final bool Function() onExecuteWateringCan;
  final bool Function() onExecuteSeed;
  final bool Function() onExecuteHarvestBasket;

  DDFarmPlayerController({
    required super.model,
    required super.onChangeRunState,
    required this.onExecuteShovel,
    required this.onExecuteWateringCan,
    required this.onExecuteSeed,
    required this.onExecuteHarvestBasket,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });

  bool isShovelAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  });

  bool isWateringCanAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  });

  bool isSeedAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  });

  bool isHarvestBasketAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  });

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    // Only respond to button press events
    if (event.event != ActionEvent.DOWN) return;

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

  /// Executes the primary melee attack if resources are sufficient.
  void _handleExecuteShovel() {
    if (!model.canExecuteShovel) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteShovel.call();
    if (!wasExecuted) {
      // Ação não executada, retomar regeneração
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.shovelStaminaCost);

    // Retomar regeneração após ação instantânea
    endStaminaConsumingAction();
  }

  /// Executes the primary melee attack if resources are sufficient.
  void _handleExecuteWateringCan() {
    if (!model.canExecuteWateringCan) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteWateringCan.call();
    if (!wasExecuted) {
      // Ação não executada, retomar regeneração
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.wateringCanStaminaCost);

    // Retomar regeneração após ação instantânea
    endStaminaConsumingAction();
  }

  /// Executes the primary melee attack if resources are sufficient.
  void _handleExecuteSeed() {
    if (!model.canExecuteSeed) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteSeed.call();
    if (!wasExecuted) {
      // Ação não executada, retomar regeneração
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.seedStaminaCost);

    // Retomar regeneração após ação instantânea
    endStaminaConsumingAction();
  }

  /// Executes the primary melee attack if resources are sufficient.
  void _handleExecuteHarvestBasket() {
    if (!model.canExecuteHarvestBasket) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteHarvestBasket.call();
    if (!wasExecuted) {
      // Ação não executada, retomar regeneração
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.harvestBasketStaminaCost);

    // Retomar regeneração após ação instantânea
    endStaminaConsumingAction();
  }
}
