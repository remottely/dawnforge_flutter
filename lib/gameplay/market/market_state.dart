import 'package:flutter/foundation.dart';

/// Estado global simples indicando se o market está aberto.
class MarketState {
  MarketState._();

  static final MarketState instance = MarketState._();

  final isOpen = ValueNotifier<bool>(false);

  void open() => isOpen.value = true;
  void close() => isOpen.value = false;
  void toggle() => isOpen.value = !isOpen.value;
}
