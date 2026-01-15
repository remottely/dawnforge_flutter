import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:bonfire/bonfire.dart';

/// Service for providing user feedback during farm actions (I2: Service = stateless)
final class FarmFeedbackService {
  FarmFeedbackService._() {
    GameLogger.info('[FarmFeedbackService] Initialized');
  }

  static final instance = FarmFeedbackService._();

  /// Show a floating text message to the user
  void showFloatingText(String message) {
    GameLogger.info('[FarmFeedback] 💬 $message');
    // TODO: Add visual floating text implementation
  }

  /// Refresh the inventory HUD in the game interface
  void refreshInventoryHUD(
    BonfireGameInterface gameRef, {
    bool autoShow = true,
  }) {
    GameLogger.info(
      '[FarmFeedback] Refreshing inventory HUD (autoShow: $autoShow)',
    );
    // TODO: Implementation pending
    // 1. Find inventory HUD component in gameRef
    // 2. Call its refresh/update method
    // 3. If autoShow is true, call its show method
  }

  /// Play sound effect for tilling soil
  void playTillSound() {
    GameLogger.info('[FarmFeedback] 🔊 Till sound');
    // TODO: AudioManager.instance.playTillSfx();
  }

  /// Play sound effect for watering
  void playWaterSound() {
    GameLogger.info('[FarmFeedback] 🔊 Water sound');
    // TODO: AudioManager.instance.playWaterSfx();
  }

  /// Play sound effect for planting
  void playPlantSound() {
    GameLogger.info('[FarmFeedback] 🔊 Plant sound');
    // TODO: AudioManager.instance.playPlantSfx();
  }

  /// Play sound effect for harvesting
  void playHarvestSound() {
    GameLogger.info('[FarmFeedback] 🔊 Harvest sound');
    // TODO: AudioManager.instance.playHarvestSfx();
  }
}
