import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/game/core/modules/save/game_save_controller.dart';
import 'package:dawnforge/game/core/modules/world/world_state_manager.dart';
import 'package:dawnforge/game/core/utils/app_environment.dart';
import 'package:dawnforge/game/features/farm/constants/farm_feedback_config.dart';
import 'package:dawnforge/game/features/farm/farm_service_locator.dart';
import 'package:dawnforge/game/features/farm/services/farm_feedback_service.dart';
import 'package:dawnforge/game/features/time/time_manager.dart' as new_time;
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

/// Handles farm-specific debug inputs from both keyboard and joystick.
/// Uses PlayerControllerListener to receive unified input events.
class FarmInputHandler extends GameComponent with PlayerControllerListener {
  final DDBasePlayerView player;
  final PlayerController playerController;
  late final FarmFeedbackService _feedbackService;

  FarmInputHandler({required this.player, required this.playerController});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _feedbackService = FarmFeedbackService.instance;
    playerController.addObserver(this);
  }

  @override
  void onRemove() {
    playerController.removeObserver(this);
    super.onRemove();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return;

    if (InputDef.isAdvanceDayAction(event.id) &&
        AppEnvironment.kIsDevToolsMode) {
      _handleAdvanceDayAndSaveGame();
    } else if (InputDef.isClearSaveAction(event.id)) {
      _handleClearSave();
    }
  }

  void _handleAdvanceDayAndSaveGame() {
    new_time.TimeManager.instance.advanceToNextDay();
    GameSaveController.instance.saveGame();
    
    final currentDay = WorldStateManager.instance.currentDay;
    GameLogger.info('[FarmInput] Advanced to day $currentDay');
  }

  void _handleClearSave() {
    GameLogger.info('[FarmInput] Clearing game and save...');

    GameSaveController.instance
        .clearGameAndSave()
        .then((success) {
          final message = success
              ? FarmFeedbackDef.kSaveCleared
              : FarmFeedbackDef.kClearSaveError;

          _feedbackService.showFloatingText(message);

          if (success) {
            GameLogger.info('[FarmInput] ✅ Game and save cleared');
          } else {
            GameLogger.warning('[FarmInput] ❌ Failed to clear game');
          }
        })
        .catchError((e) {
          GameLogger.error('[FarmInput] Error clearing game: $e');
        });
  }
}
