import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/constants/farm_feedback_config.dart';
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_action_service.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_feedback_service.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/services.dart';

/// Handles keyboard input for farm-related actions.
///
/// This component acts as an input layer, routing keyboard events to the
/// appropriate services. It follows the Single Responsibility Principle by
/// delegating action execution to [FarmActionService] and feedback to
/// [FarmFeedbackService].
///
/// **Keyboard Mappings:**
/// - N: Advance day (debug)
/// - G: Clear save data (debug)
///
/// **Architecture:**
/// ```
/// Player Input → FarmInputHandler → FarmActionService → FarmManager
///                                 ↓
///                        FarmFeedbackService
/// ```
class FarmInputHandler extends GameComponent with KeyboardEventListener {
  final DDBasePlayerView player;
  final FarmFeedbackService _feedbackService = FarmFeedbackService.instance;

  FarmInputHandler({required this.player});

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;

    // Handle debug keys first
    if (_handleDebugKeys(event.logicalKey)) return true;

    return false;
  }

  // ============================================================================
  // Debug Actions
  // ============================================================================

  /// Handles debug keyboard commands.
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

    // Auto-save
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
