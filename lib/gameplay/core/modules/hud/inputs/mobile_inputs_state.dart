import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// State manager for mobile inputs overlay
class MobileInputsState {
  MobileInputsState._();

  static final instance = MobileInputsState._();

  // Controls inputs overlay visibility
  final isVisible = ValueNotifier<bool>(true);

  void show() {
    isVisible.value = true;
    developer.log('[InputsState] Mobile inputs shown');
  }

  void hide() {
    isVisible.value = false;
    developer.log('[InputsState] Mobile inputs hidden');
  }

  void toggle() {
    isVisible.value = !isVisible.value;
    developer.log('[InputsState] Mobile inputs toggled: ${isVisible.value}');
  }

  void dispose() {
    isVisible.dispose();
  }
}
