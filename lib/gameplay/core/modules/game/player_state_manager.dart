import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';

import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';

class PlayerStateManager {
  PlayerStateManager._();

  static final instance = PlayerStateManager._();

  Future<SpriteAnimation>? currentPlayerAnimation;
  DemoPlayer? lastPlayer;
  CharacterData? lastPlayerData;
  bool _respawnWithFullLife = false;

  Map<String, dynamic> toJson() {
    final json = {'playerData': lastPlayerData?.toJson()};
    final life = lastPlayerData?.life;
    final stamina = lastPlayerData?.stamina;
    final coins = lastPlayerData?.coins;
    final position = lastPlayerData?.position;

    GameLogger.info(
      '[PlayerStateManager] toJson life=$life, stamina=$stamina, coins=$coins, position=$position, json=$json',
    );
    return json;
  }

  void fromJson(Map<String, dynamic> json) {
    final data = json['playerData'] as Map<String, dynamic>?;

    if (data == null) {
      lastPlayerData = null;
      return;
    }

    final playerType = data['playerType'] as String?;

    // switch (playerType) {
    //   case 'farmer':
    //     lastPlayerData = CharacterData.fromJson(data);
    //     break;
    //   case 'cute':
    //     lastPlayerData = CharacterData.fromJson(data);
    //     break;
    //   case 'sunny':
    //     lastPlayerData = CharacterData.fromJson(data);
    //     break;
    //   case 'demo':
    //     lastPlayerData = CharacterData.fromJson(data);
    //     break;
    //   default:
    //     lastPlayerData = CharacterData.fromJson(data);
    //     break;
    // }

    GameLogger.info(
      '[PlayerStateManager] fromJson restored type=$playerType, life=${lastPlayerData?.life}, stamina=${lastPlayerData?.stamina}, coins=${lastPlayerData?.coins}, raw=$data',
    );
  }

  void reset() {
    lastPlayerData = null;
    _respawnWithFullLife = false;
  }

  void setLastPlayerData(CharacterData model) {
    lastPlayerData = model;
  }

  void setLastPlayerView(DemoPlayer view) {
    lastPlayer = view;
  }
}
