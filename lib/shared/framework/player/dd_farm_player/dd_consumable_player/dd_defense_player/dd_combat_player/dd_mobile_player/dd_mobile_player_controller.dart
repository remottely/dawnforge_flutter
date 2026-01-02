import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/input_def.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';

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
    if (eventType == ActionEvent.DOWN) {
      model.isRunning = true;
      onChangeRunState.call(true);
    } else if (eventType == ActionEvent.UP) {
      model.isRunning = false;
      onChangeRunState.call(false);
    }
  }
}
