import 'package:flutter/services.dart';

/// Constants for farm-related keyboard inputs.
///
/// Centralizes all keyboard mappings for farm actions to maintain consistency
/// and ease of maintenance.
final class FarmInputConstants {
  FarmInputConstants._();

  // ============================================================================
  // Action Keys
  // ============================================================================

  /// Key to till soil (prepare land for planting).
  static const LogicalKeyboardKey kTillSoilKey = LogicalKeyboardKey.keyH;

  /// Key to water crops.
  static const LogicalKeyboardKey kWaterKey = LogicalKeyboardKey.keyJ;

  /// Key to plant seeds.
  static const LogicalKeyboardKey kPlantKey = LogicalKeyboardKey.keyK;

  /// Key to harvest mature crops.
  static const LogicalKeyboardKey kHarvestKey = LogicalKeyboardKey.keyR;

  // ============================================================================
  // Debug Keys
  // ============================================================================

  /// Debug key to advance one day (also triggers auto-save).
  static const LogicalKeyboardKey kAdvanceDayKey = LogicalKeyboardKey.keyN;

  /// Debug key to clear all save data.
  static const LogicalKeyboardKey kClearSaveKey = LogicalKeyboardKey.keyG;
}
