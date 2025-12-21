import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// State manager for inputs UI to communicate between Bonfire and Flutter
class InputsState {
  InputsState._();

  static final instance = InputsState._();

  // Controls inputs overlay visibility
  final isVisible = ValueNotifier<bool>(true);

  void show() {
    isVisible.value = true;
    developer.log('[InputsState] Inputs shown');
  }

  void hide() {
    isVisible.value = false;
    developer.log('[InputsState] Inputs hidden');
  }

  void toggle() {
    isVisible.value = !isVisible.value;
    developer.log('[InputsState] Inputs toggled: ${isVisible.value}');
  }

  void dispose() {
    isVisible.dispose();
  }
}
