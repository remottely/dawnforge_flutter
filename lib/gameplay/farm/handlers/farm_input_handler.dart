import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/constants/farm_feedback_config.dart';
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_feedback_service.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/services.dart';

class FarmInputHandler extends GameComponent with KeyboardEventListener {
  final DDBasePlayerView player;
  final FarmFeedbackService _feedbackService = FarmFeedbackService.instance;

  FarmInputHandler({required this.player});

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;

    if (_handleDebugKeys(event.logicalKey)) return true;

    return false;
  }

  bool _handleDebugKeys(LogicalKeyboardKey key) {
    if (key == KeyboardSetup.kAdvanceDayKey) {
      _handleAdvanceDay();
      return true;
    } else if (key == KeyboardSetup.kClearSaveKey) {
      _handleClearSave();
      return true;
    }

    return false;
  }

  void _handleAdvanceDay() {
    WorldStateManager.instance.advanceDay();
    FarmManager.instance.advanceDay();

    final currentDay = WorldStateManager.instance.currentDay;
    developer.log('[FarmInput] Advanced to day $currentDay');

    _feedbackService.showFloatingText(
      FarmFeedbackConfig.dayAdvanced(currentDay),
    );

    _saveGameAsync();
  }

  void _handleClearSave() {
    developer.log('[FarmInput] Clearing game and save...');

    GameSaveController.instance
        .clearGameAndSave()
        .then((success) {
          final message = success
              ? FarmFeedbackConfig.kSaveCleared
              : FarmFeedbackConfig.kClearSaveError;

          _feedbackService.showFloatingText(message);

          if (success) {
            developer.log('[FarmInput] ✅ Game and save cleared');
          } else {
            developer.log('[FarmInput] ❌ Failed to clear game');
          }
        })
        .catchError((e) {
          developer.log('[FarmInput] Error clearing game: $e');
        });
  }

  void _saveGameAsync() {
    developer.log('[FarmInput] Saving game...');

    GameSaveController.instance
        .saveGame()
        .then((success) {
          final message = success
              ? FarmFeedbackConfig.kGameSaved
              : FarmFeedbackConfig.kSaveError;

          _feedbackService.showFloatingText(message);

          if (success) {
            developer.log('[FarmInput] ✅ Game saved');
          } else {
            developer.log('[FarmInput] ❌ Failed to save game');
          }
        })
        .catchError((e) {
          developer.log('[FarmInput] Error saving game: $e');
        });
  }
}
