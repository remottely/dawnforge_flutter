import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/core/modules/overlay/overlay_message_def.dart';
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
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
