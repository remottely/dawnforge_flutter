import 'package:flutter/material.dart';

class PlayerVitalStatsState {
  PlayerVitalStatsState._();

  static final instance = PlayerVitalStatsState._();

  final isVisible = ValueNotifier<bool>(true);

  void toggle() => isVisible.value = !isVisible.value;
}
