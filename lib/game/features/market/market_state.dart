import 'package:dawnforge/game/systems/game/player_state_manager.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';
import 'package:flutter/foundation.dart';

/// Estado global simples indicando se o market está aberto.
class MarketState {
  MarketState._();

  static final MarketState instance = MarketState._();

  final isOpen = ValueNotifier<bool>(false);
  final activePlayer = ValueNotifier<DDBasePlayerModel?>(null);

  void open() => isOpen.value = true;

  void openWithPlayer(DDBasePlayerModel player) {
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
