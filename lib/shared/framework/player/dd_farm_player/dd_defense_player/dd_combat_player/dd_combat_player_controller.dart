import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/input_def.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_controller.dart';

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
      player.controller.model.equipment == EquippedHandType.ironSword;

  bool _isRangedAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == EquippedHandType.staff;

  void _handleExecutePrimaryAttack() {
    if (!model.canExecutePrimaryAttack) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecutePrimaryAttack.call(
      model.config.primaryAttackDamage,
    );
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.primaryAttackStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteRangedAttack() {
    if (!model.canExecuteRangedAttack) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteRangedAttack.call(
      model.config.rangedAttackDamage,
    );
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
    if (_isPrimaryAttackAction(player: player, actionId: event.id)) {
      _handleExecutePrimaryAttack();
    } else if (_isRangedAttackAction(player: player, actionId: event.id)) {
      _handleExecuteRangedAttack();
    }

    super.handleInputAction(player: player, event: event);
  }
}
