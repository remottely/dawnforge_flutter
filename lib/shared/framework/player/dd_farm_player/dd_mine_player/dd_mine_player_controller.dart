import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/game/core/modules/overlay/message/message_overlay_def.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_model.dart';

abstract class DDMinePlayerController<M extends DDMinePlayerModel>
    extends DDFarmPlayerController<M> {
  final bool Function() onExecuteMine;

  DDMinePlayerController({
    required this.onExecuteMine,
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onExecuteDig,
    required super.onExecuteWateringCan,
    required super.onExecuteSeed,
    required super.onExecuteHarvest,
  });

  bool _isPickaxe(HandItemId? id) =>
      id == HandItemId.iron_pickaxe || id == HandItemId.steel_pickaxe;

  bool isMineAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) {
    return InputDef.isPrimaryAction(actionId) &&
        _isPickaxe(player.controller.model.equipment);
  }

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    GameLogger.info(
      '[MineController] Verificando ação: ${event.id} | equipment: ${player.controller.model.equipment} | evento: ${event.event}',
    );

    if (handleConsumableInput(player: player, event: event)) {
      return;
    }

    // Só processa ações no DOWN, não no UP
    if (event.event != ActionEvent.DOWN) {
      super.handleInputAction(player: player, event: event);
      return;
    }

    if (isMineAction(player: player, actionId: event.id)) {
      GameLogger.info('[MineController] ✓ É mine action (pickaxe)');
      _handleExecuteMine();
    } else {
      GameLogger.info(
        '[MineController] ✗ Não é ação de mine, passando para super',
      );
    }

    // Encaminha para a cadeia de combate base (sem reprocessar consumo).
    handleBaseCombatInputAction(player: player, event: event);
  }

  void _handleExecuteMine() {
    GameLogger.info(
      '[MineController] _handleExecuteMine: stamina=${model.stamina}, canExecute=${model.canExecuteMine}',
    );

    if (!model.canExecuteMine) {
      GameLogger.warning('[MineController] ✗ Não pode executar mine');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.mineStaminaCost) {
        MessageOverlayDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteMine.call();

    GameLogger.info('[MineController] Mine wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.mineStaminaCost);

    endStaminaConsumingAction();
  }
}
