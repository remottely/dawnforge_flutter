import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
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

  bool isPrimaryAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kPrimaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.controller.model.equipment == EquippedHandType.ironSword;

  bool isRangedAttackAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      (actionId == JoystickSetup.kSecondaryActionId ||
          actionId == KeyboardSetup.kPrimaryActionKey) &&
      player.controller.model.equipment == EquippedHandType.staff;

  void handleExecutePrimaryAttack() {
    if (!model.canExecutePrimaryAttack) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecutePrimaryAttack.call(
      model.primaryAttackDamage,
    );
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.primaryAttackStaminaCost);

    endStaminaConsumingAction();
  }

  void handleExecuteRangedAttack() {
    if (!model.canExecuteRangedAttack) return;

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteRangedAttack.call(
      model.rangedAttackDamage,
    );
    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.rangedAttackStaminaCost);

    endStaminaConsumingAction();
  }

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    if (isPrimaryAttackAction(player: player, actionId: event.id)) {
      handleExecutePrimaryAttack();
    } else if (isRangedAttackAction(player: player, actionId: event.id)) {
      handleExecuteRangedAttack();
    }

    super.handleInputAction(player: player, event: event);
  }
}
