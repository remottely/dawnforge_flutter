import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';

import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';

class PlayerStateManager {
  PlayerStateManager._();

  static final instance = PlayerStateManager._();

  Future<SpriteAnimation>? currentPlayerAnimation;
  DemoPlayer? lastPlayerView;
  CharacterData? lastPlayerModel;
  bool _respawnWithFullLife = false;

  Map<String, dynamic> toJson() {
    final json = {'playerModel': lastPlayerModel?.toJson()};
    final life = lastPlayerModel?.life;
    final stamina = lastPlayerModel?.stamina;
    final coins = lastPlayerModel?.coins;
    final position = lastPlayerModel?.position;

    GameLogger.info(
      '[PlayerStateManager] toJson life=$life, stamina=$stamina, coins=$coins, position=$position, json=$json',
    );
    return json;
  }

  void fromJson(Map<String, dynamic> json) {
    final data = json['playerModel'] as Map<String, dynamic>?;

    if (data == null) {
      lastPlayerModel = null;
      return;
    }

    final playerType = data['playerType'] as String?;

    // switch (playerType) {
    //   case 'farmer':
    //     lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    //     break;
    //   case 'cute':
    //     lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    //     break;
    //   case 'sunny':
    //     lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    //     break;
    //   case 'demo':
    //     lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    //     break;
    //   default:
    //     lastPlayerModel = DDFarmPlayerModel.fromJson(data);
    //     break;
    // }

    GameLogger.info(
      '[PlayerStateManager] fromJson restored type=$playerType, life=${lastPlayerModel?.life}, stamina=${lastPlayerModel?.stamina}, coins=${lastPlayerModel?.coins}, raw=$data',
    );
  }

  void reset() {
    lastPlayerModel = null;
    _respawnWithFullLife = false;
  }

  void setLastPlayerModel(CharacterData model) {
    lastPlayerModel = model;
  }

  void setLastPlayerView(DemoPlayer view) {
    lastPlayerView = view;
  }
}
