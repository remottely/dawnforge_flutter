import 'package:dawnforge/gameplay/core/modules/game/player_state_manager.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:flutter/foundation.dart';

/// Estado global simples indicando se o market está aberto.
class MarketState {
  MarketState._();

  static final MarketState instance = MarketState._();

  final isOpen = ValueNotifier<bool>(false);
  final activePlayer = ValueNotifier<CharacterData?>(null);

  void open() => isOpen.value = true;

  void openWithPlayer(CharacterData player) {
    activePlayer.value = player;
    isOpen.value = true;
    PlayerStateManager.instance.setLastPlayerModel(player);
  }

  void close() {
    isOpen.value = false;
    activePlayer.value = null;
  }

  void toggle() => isOpen.value = !isOpen.value;
}
