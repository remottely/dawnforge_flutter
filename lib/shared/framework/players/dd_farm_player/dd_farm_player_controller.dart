import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_controller.dart';

abstract class DDFarmPlayerController<M extends DDFarmPlayerModel>
    extends DDMobilePlayerController<M> {
  DDFarmPlayerController({
    required super.model,
    required super.onChangeRunState,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    super.handleInputAction(player: player, event: event);
  }
}
