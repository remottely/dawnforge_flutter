
import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:flutter/foundation.dart';

/// State manager for inventory UI to communicate between Bonfire and Flutter
class InventoryState {
  InventoryState._();

  static final instance = InventoryState._();

  // Controls inventory overlay visibility
  final isVisible = ValueNotifier<bool>(true);

  void show() {
    isVisible.value = true;
    GameLogger.info('[InventoryState] Inventory shown');
  }

  void hide() {
    isVisible.value = false;
    GameLogger.info('[InventoryState] Inventory hidden');
  }

  void toggle() {
    isVisible.value = !isVisible.value;
    GameLogger.info('[InventoryState] Inventory toggled: ${isVisible.value}');
  }

  void dispose() {
    isVisible.dispose();
  }
}
