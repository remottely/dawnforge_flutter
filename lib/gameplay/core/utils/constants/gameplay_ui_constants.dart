import 'package:flutter/material.dart';

/// [GameplayUIConstants] responsible for centralizing all UI constants for gameplay components
/// Following Flutter naming conventions for constant management systems
///
/// This class provides:
/// - HUD component sizing and positioning constants
/// - UI state manager configuration values
/// - Asset path definitions for UI elements
/// - Color constants for consistent theming
/// - Spacing and layout constants
class GameplayUIConstants {
  // Prevent instantiation - this is a constants-only class
  GameplayUIConstants._();

  // =============================================================================
  // HUD CONFIGURATION CONSTANTS
  // =============================================================================

  /// Standard padding used throughout HUD components
  static const double kHUDPadding = 20.0;

  /// Standard width for progress bars (health, stamina, etc.)
  static const double kBarWidth = 90.0;

  /// Standard stroke width for progress bars
  static const double kStrokeWidth = 12.0;

  /// Y position for health bar rendering
  static const double kHealthBarYPosition = 10.0;

  /// Y position for stamina bar rendering
  static const double kStaminaBarYPosition = 27.0;

  /// X position for progress bars (health and stamina)
  static const double kBarXPosition = 29.0;

  /// Maximum stamina value for calculations
  static const double kMaxStamina = 100.0;

  /// HUD component dimensions
  static const double kHUDWidth = 120.0;
  static const double kHUDHeight = 40.0;
  static const int kComponentId = 1;

  // =============================================================================
  // KEY ICON CONFIGURATION
  // =============================================================================

  /// Width of the key icon displayed when player has a key
  static const double kKeyIconWidth = 35.0;

  /// Height of the key icon displayed when player has a key
  static const double kKeyIconHeight = 30.0;

  /// X position for key icon rendering
  static const double kKeyIconX = 150.0;

  /// Y position for key icon rendering
  static const double kKeyIconY = 20.0;

  // =============================================================================
  // UI STATE MANAGER CONSTANTS
  // =============================================================================

  /// Height of the game over image in dialog
  static const double kGameOverImageHeight = 96.0;

  /// Standard spacing between UI elements
  static const double kStandardSpacing = 8.0;

  /// Large spacing for major UI sections
  static const double kLargeSpacing = 32.0;

  /// Horizontal padding for dialog content
  static const double kHorizontalPadding = 96.0;

  // =============================================================================
  // HEALTH BAR COLOR THRESHOLDS
  // =============================================================================

  /// Health percentage threshold for critical state (red color)
  /// Health below this percentage (33%) shows red
  static const double kHealthCriticalThreshold = 1.0 / 3.0;

  /// Health percentage threshold for warning state (yellow color)
  /// Health below this percentage (66%) but above critical shows yellow
  static const double kHealthWarningThreshold = 2.0 / 3.0;

  // =============================================================================
  // ASSET PATHS
  // =============================================================================

  /// Asset path for game over screen image
  static const String kGameOverAssetPath = 'assets/game_over.png';

  /// Asset path for health UI background sprite
  static const String kHealthUIAssetPath = 'health_ui.png';

  // =============================================================================
  // UI COLORS
  // =============================================================================

  /// Transparent color for UI backgrounds
  static const Color kTransparentColor = Colors.transparent;

  /// Background color for empty health bars
  static const Color kHealthBarBackgroundColor = Color(
    0xFF455A64,
  ); // Colors.blueGrey[800]

  /// Color for stamina bars
  static const Color kStaminaBarColor = Colors.yellow;

  /// Health bar colors based on health level
  static const Color kHealthBarGoodColor = Colors.green; // Health > 66%
  static const Color kHealthBarWarningColor = Colors.yellow; // Health 33-66%
  static const Color kHealthBarCriticalColor = Colors.red; // Health < 33%
}
