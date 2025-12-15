import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';

final class FarmFeedbackService {
  FarmFeedbackService._();

  static final instance = FarmFeedbackService._();

  void showFloatingText(String message) {
    developer.log('[FarmFeedback] 💬 $message');
    // TODO: Add visual floating text implementation
  }

  void refreshInventoryHUD(
    BonfireGameInterface gameRef, {
    bool autoShow = true,
  }) {
    // TODO: Implementation pending
    // 1. Find inventory HUD component in gameRef
    // 2. Call its refresh/update method
    // 3. If autoShow is true, call its show method
    developer.log(
      '[FarmFeedback] Refreshing inventory HUD (autoShow: $autoShow)',
    );
  }

  /// TODO: Implement audio feedback.
  void playTillSound() {
    // Future: AudioManager.instance.playTillSfx();
  }

  /// TODO: Implement audio feedback.
  void playWaterSound() {
    // Future: AudioManager.instance.playWaterSfx();
  }

  /// TODO: Implement audio feedback.
  void playPlantSound() {
    // Future: AudioManager.instance.playPlantSfx();
  }

  /// TODO: Implement audio feedback.
  void playHarvestSound() {
    // Future: AudioManager.instance.playHarvestSfx();
  }
}
