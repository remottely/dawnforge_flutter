import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:flutter/foundation.dart';

/// State manager for mobile inputs overlay
class MobileInputsState {
  MobileInputsState._();

  static final MobileInputsState instance = MobileInputsState._();

  // Controls inputs overlay visibility
  final isVisible = ValueNotifier<bool>(true);

  void show() {
    isVisible.value = true;
    GameLogger.info('[InputsState] Mobile inputs shown');
  }

  void hide() {
    isVisible.value = false;
    GameLogger.info('[InputsState] Mobile inputs hidden');
  }

  void toggle() {
    isVisible.value = !isVisible.value;
    GameLogger.info('[InputsState] Mobile inputs toggled: ${isVisible.value}');
  }

  void dispose() {
    isVisible.dispose();
  }
}
