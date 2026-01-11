import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:flutter/foundation.dart';

/// State manager for inputs UI to communicate between Bonfire and Flutter
class TutorialInputsState {
  TutorialInputsState._();

  static final instance = TutorialInputsState._();

  // Controls inputs overlay visibility
  final isVisible = ValueNotifier<bool>(true);

  void show() {
    isVisible.value = true;
    GameLogger.info('[InputsState] Inputs shown');
  }

  void hide() {
    isVisible.value = false;
    GameLogger.info('[InputsState] Inputs hidden');
  }

  void toggle() {
    isVisible.value = !isVisible.value;
    GameLogger.info('[InputsState] Inputs toggled: ${isVisible.value}');
  }

  void dispose() {
    isVisible.dispose();
  }
}
