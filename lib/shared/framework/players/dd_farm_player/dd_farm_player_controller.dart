import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_controller.dart';

abstract class DDFarmPlayerController<M extends DDFarmPlayerModel>
    extends DDMobilePlayerController<M> {
  final bool Function() onExecuteDigger;

  DDFarmPlayerController({
    required super.model,
    required super.onChangeRunState,
    required this.onExecuteDigger,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });

  bool isDiggerAction({
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

    if (isDiggerAction(player: player, actionId: event.id)) {
      _handleExecuteDigger();
    }

    super.handleInputAction(player: player, event: event);
  }

  /// Executes the primary melee attack if resources are sufficient.
  void _handleExecuteDigger() {
    if (!model.canExecuteDigger) return;

    // Pausar regeneração durante ação
    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteDigger.call();
    if (!wasExecuted) {
      // Ação não executada, retomar regeneração
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.diggerStaminaCost);

    // Retomar regeneração após ação instantânea
    endStaminaConsumingAction();
  }
}
