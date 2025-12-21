import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// State manager for inventory UI to communicate between Bonfire and Flutter
class InventoryState {
  InventoryState._();

  static final instance = InventoryState._();

  // Controls inventory overlay visibility
  final isVisible = ValueNotifier<bool>(true);

  void show() {
    isVisible.value = true;
    developer.log('[InventoryState] Inventory shown');
  }

  void hide() {
    isVisible.value = false;
    developer.log('[InventoryState] Inventory hidden');
  }

  void toggle() {
    isVisible.value = !isVisible.value;
    developer.log('[InventoryState] Inventory toggled: ${isVisible.value}');
  }

  void dispose() {
    isVisible.dispose();
  }
}
