import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/constants/farm_messages.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_action_service.dart';
import 'package:darkness_dungeon/gameplay/farm/services/farm_feedback_service.dart';
import 'package:darkness_dungeon/gameplay/farmable/farm_tile.dart';
import 'package:flutter/services.dart';

/// Handles keyboard input for farm-related actions.
///
/// This component acts as an input layer, routing keyboard events to the
/// appropriate services. It follows the Single Responsibility Principle by
/// delegating action execution to [FarmActionService] and feedback to
/// [FarmFeedbackService].
///
/// **Keyboard Mappings:**
/// - H: Till soil
/// - J: Water crops
/// - K: Plant seeds
/// - R: Harvest crops
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
  final Player player;

  // Services
  final FarmActionService _actionService = FarmActionService.instance;
  final FarmFeedbackService _feedbackService = FarmFeedbackService.instance;

  FarmInputHandler({required this.player});

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;

    // Handle debug keys first
    if (_handleDebugKeys(event.logicalKey)) return true;

    // Find farm tile under player
    final farmTile = _getFarmTileInContact();
    if (farmTile == null) {
      developer.log('[FarmInput] No farm tile in contact with player');
      return false;
    }

    final x = farmTile.tileX;
    final y = farmTile.tileY;

    developer.log('[FarmInput] Interacting with tile ($x, $y)');

    // Route to appropriate action handler
    return _handleFarmAction(event.logicalKey, x, y);
  }

  // ============================================================================
  // Farm Action Routing
  // ============================================================================

  /// Routes farm actions based on the pressed key.
  bool _handleFarmAction(LogicalKeyboardKey key, int x, int y) {
    if (key == KeyboardSetup.kTillSoilKey) {
      return _handleTillSoil(x, y);
    } else if (key == KeyboardSetup.kWaterKey) {
      return _handleWater(x, y);
    } else if (key == KeyboardSetup.kPlantKey) {
      return _handlePlant(x, y);
    } else if (key == KeyboardSetup.kHarvestKey) {
      return _handleHarvest(x, y);
    }

    return false;
  }

  bool _handleTillSoil(int x, int y) {
    final result = _actionService.tillSoil(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmMessages.kSoilTilled);
    }
    return true;
  }

  bool _handleWater(int x, int y) {
    final result = _actionService.waterTile(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmMessages.kCropWatered);
    }
    return true;
  }

  bool _handlePlant(int x, int y) {
    // TODO: Get crop type from inventory/UI selection
    const cropId = 'carrot';

    final result = _actionService.plantSeed(x, y, cropId);
    if (result.success) {
      _feedbackService.showFloatingText(FarmMessages.kSeedPlanted);
    }
    return true;
  }

  bool _handleHarvest(int x, int y) {
    final result = _actionService.harvestCrop(x, y);

    if (result.success && result.crop != null) {
      final message = result.addedToInventory
          ? FarmMessages.cropHarvested(
              result.crop!.yieldAmount,
              result.crop!.name,
            )
          : FarmMessages.kInventoryFull;

      _feedbackService.showFloatingText(message);

      if (result.addedToInventory) {
        _feedbackService.refreshInventoryHUD(gameRef);
      }
    }

    return true;
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

    _feedbackService.showFloatingText(FarmMessages.dayAdvanced(currentDay));

    // Auto-save
    _saveGameAsync();
  }

  void _handleClearSave() {
    developer.log('[FarmInput] Clearing game and save...');

    GameSaveController.instance
        .clearGameAndSave()
        .then((success) {
          final message = success
              ? FarmMessages.kSaveCleared
              : FarmMessages.kClearSaveError;

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
              ? FarmMessages.kGameSaved
              : FarmMessages.kSaveError;

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

  // ============================================================================
  // Tile Detection
  // ============================================================================

  /// Finds the farm tile currently in contact with the player.
  FarmTileView? _getFarmTileInContact() {
    final allFarmTiles = gameRef.query<FarmTileView>();

    for (final farmTile in allFarmTiles) {
      if (farmTile.isPlayerOnTile(player)) {
        return farmTile;
      }
    }

    return null;
  }
}
