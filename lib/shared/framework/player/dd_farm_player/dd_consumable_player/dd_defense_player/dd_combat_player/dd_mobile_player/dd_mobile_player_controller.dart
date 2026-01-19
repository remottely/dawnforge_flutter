import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';

abstract class DDMobilePlayerController<M extends DDMobilePlayerModel>
    extends DDBasePlayerController<M> {
  final void Function(bool isRunning) onChangeRunState;

  DDMobilePlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required this.onChangeRunState,
  });

  bool isRunAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) => InputDef.isRunAction(actionId);

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    if (isRunAction(player: player, actionId: event.id)) {
      _handleRunInput(event.event);
    }

    super.handleInputAction(player: player, event: event);
  }

  void _handleRunInput(ActionEvent eventType) {
    bool desiredState;
    if (eventType == ActionEvent.DOWN) {
      desiredState = true;
    } else if (eventType == ActionEvent.UP) {
      desiredState = false;
    } else {
      return;
    }

    final changed = model.setRunning(desiredState);
    if (changed) {
      onChangeRunState.call(model.isRunning);
    }
  }
}
