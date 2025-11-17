import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';

/// Service responsible for providing visual and audio feedback for farm actions.
///
/// Centralizes all UI feedback mechanisms including:
/// - Floating text notifications
/// - Inventory HUD updates
/// - Sound effects (future implementation)
///
/// This service ensures consistent user feedback across all farm interactions.
final class FarmFeedbackService {
  FarmFeedbackService._();

  static final instance = FarmFeedbackService._();

  // ============================================================================
  // Visual Feedback
  // ============================================================================

  /// Displays a floating text message to the player.
  ///
  /// [message] The text to display.
  ///
  /// TODO: Implement actual floating text visual effect.
  /// Currently only logs for debugging.
  void showFloatingText(String message) {
    developer.log('[FarmFeedback] 💬 $message');
    // TODO: Add visual floating text implementation
  }

  /// Refreshes the inventory HUD display and optionally shows it.
  ///
  /// **Parameters:**
  /// - [gameRef]: Game reference to access HUD components
  /// - [autoShow]: Whether to automatically show the HUD (default: true)
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

  // ============================================================================
  // Audio Feedback (Future Implementation)
  // ============================================================================

  /// Plays sound effect for tilling soil.
  ///
  /// TODO: Implement audio feedback.
  void playTillSound() {
    // Future: AudioManager.instance.playTillSfx();
  }

  /// Plays sound effect for watering.
  ///
  /// TODO: Implement audio feedback.
  void playWaterSound() {
    // Future: AudioManager.instance.playWaterSfx();
  }

  /// Plays sound effect for planting.
  ///
  /// TODO: Implement audio feedback.
  void playPlantSound() {
    // Future: AudioManager.instance.playPlantSfx();
  }

  /// Plays sound effect for harvesting.
  ///
  /// TODO: Implement audio feedback.
  void playHarvestSound() {
    // Future: AudioManager.instance.playHarvestSfx();
  }
}
